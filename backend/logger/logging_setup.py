# logging_setup.py
from gen import logger_pb2
from ng_sdk.logger.logger import get_logger

import asyncio
import queue as _threading_queue
import re
import threading

logger = get_logger()

# Thread-safe queue for retry status notifications.
retry_queue: "_threading_queue.Queue" = _threading_queue.Queue(maxsize=20)
# Set whenever at least one retry attempt is logged; cleared by _run() before each execute().
_had_retry = threading.Event()

# ---- Suppress-retry mechanism -----------------------------------------------
# When _suppress_retry_count > 0 (set by _run_optional), retry_sink discards
# all retry events so optional DLMS reads do not trigger a global disconnect.
_suppress_retry_lock = threading.Lock()
_suppress_retry_count = 0


def _suppress_retry_inc():
    global _suppress_retry_count
    with _suppress_retry_lock:
        _suppress_retry_count += 1


def _suppress_retry_dec():
    global _suppress_retry_count
    with _suppress_retry_lock:
        if _suppress_retry_count > 0:
            _suppress_retry_count -= 1


# Regex patterns for ng_sdk retry log messages
_RE_ATTEMPT = re.compile(r"Attempt (\d+): no data received before timeout")
_RE_ALL_FAILED = re.compile(r"All (\d+) attempts failed")


def add_grpc_sink(stream):
    """Ajoute un sink loguru thread-safe qui envoie directement au stream gRPC."""

    # Capture the running event loop from the calling coroutine (main loop thread).
    # The sink may later be called from asyncio.to_thread() worker threads which
    # have no event loop — run_coroutine_threadsafe bridges the two worlds.
    try:
        loop = asyncio.get_event_loop()
    except RuntimeError:
        loop = asyncio.new_event_loop()

    def grpc_sink(message):
        line = str(message).rstrip("\n")
        asyncio.run_coroutine_threadsafe(
            stream.send_message(logger_pb2.LogLine(message=line)),
            loop,
        )

    sink_id = logger.add(
        grpc_sink,
        format="{time} {level} {message}",
        level="INFO"
    )
    return sink_id


def remove_grpc_sink(sink_id):
    """Retire le sink gRPC du logger."""
    logger.remove(sink_id)
