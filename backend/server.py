import os
import sys
import asyncio
from grpclib.server import Server

from service.configuration_service import ConfigurationService
from service.logger_service import LoggerService
from service.manual_dlms_service import ManualDlmsGrpcService
from service.meter_service import MeterService
from service.authentication_service import AuthenticationService

HOST = os.environ.get("PY_GRPC_HOST", "127.0.0.1")
PORT = int(os.environ.get("PY_GRPC_PORT", "50051"))

server: Server | None = None  # set inside serve()


async def close_server():
    """Close the global gRPC server if it is running.

    Intended to be called by an admin endpoint/service.
    """

    global server
    if server is not None:
        print("server.close()")
        server.close()


async def serve():
    global server

    # Create services first, then pass them to Server(...)
    services = [
        LoggerService(),
        ConfigurationService(),
        MeterService(),
        AuthenticationService(),
        ManualDlmsGrpcService()
    ]
    server = Server(services)
    await server.start(HOST, PORT)
    print(f"[py-grpc] listening on {HOST}:{PORT}", flush=True)

    await server.wait_closed()
    print("[py-grpc] server closed...")


if __name__ == "__main__":
    try:
        print("[py-grpc] starting server...")
        asyncio.run(serve())
    except KeyboardInterrupt:
        pass
    print("[py-grpc] stopping app...")
    sys.exit(0)
