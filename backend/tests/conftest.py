from __future__ import annotations

import inspect
from contextlib import asynccontextmanager
from typing import Iterable

import pytest
from grpclib.client import Channel
from grpclib.server import Server


async def _maybe_await(value):
    if inspect.isawaitable(value):
        return await value
    return value


@asynccontextmanager
async def serve(services: Iterable[object], host: str = "127.0.0.1"):
    server = Server(list(services))
    await server.start(host, 0)

    sockets = getattr(getattr(server, "_server", None), "sockets", None)
    if not sockets:
        server.close()
        await _maybe_await(server.wait_closed())
        raise RuntimeError("Unable to determine bound port for grpclib server")

    port = sockets[0].getsockname()[1]

    try:
        yield host, port
    finally:
        close = getattr(server, "close", None)
        if callable(close):
            close()
        wait_closed = getattr(server, "wait_closed", None)
        if callable(wait_closed):
            await _maybe_await(wait_closed())


@asynccontextmanager
async def open_channel(host: str, port: int):
    channel = Channel(host, port)
    try:
        yield channel
    finally:
        close = getattr(channel, "close", None)
        if callable(close):
            await _maybe_await(close())


@pytest.fixture
def anyio_backend():
    return "asyncio"
