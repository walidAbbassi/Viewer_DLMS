import asyncio

from gen import logger_grpc, logger_pb2
from logger.logging_setup import add_grpc_sink, remove_grpc_sink


class LoggerService(logger_grpc.LogServiceBase):

    async def StreamLogs(self, stream):
        sink_id = add_grpc_sink(stream)
        try:
            # Stream server→client : on attend indéfiniment jusqu'à déconnexion
            while True:
                await asyncio.sleep(1)
        except asyncio.CancelledError:
            pass
        except Exception:
            pass
        finally:
            remove_grpc_sink(sink_id)
