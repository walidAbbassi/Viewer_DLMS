from functools import wraps

from grpclib import GRPCError, Status
import traceback


def grpc_exception_handler(func):
    """
    Decorator to convert unexpected exceptions into gRPC INTERNAL errors
    while preserving the original exception message.
    """

    @wraps(func, assigned=("__name__", "__doc__"))
    async def wrapper(*args, **kwargs):
        try:
            return await func(*args, **kwargs)
        except GRPCError:
            # Already a well-formed gRPC error, just propagate
            raise
        except IndexError:
            traceback.print_exc()
            raise GRPCError(
                Status.INTERNAL,
                "Connection lost. The meter response was incomplete. "
                "Reconnect and try again.",
            )
        except PermissionError:
            traceback.print_exc()
            raise GRPCError(
                Status.INTERNAL,
                "Serial port access denied. "
                "Close any application using this port and retry.",
            )
        except TimeoutError:
            traceback.print_exc()
            raise GRPCError(
                Status.UNAVAILABLE,
                "No response from the meter. " "Check the connection and retry.",
            )
        except (ConnectionResetError, BrokenPipeError):
            traceback.print_exc()
            raise GRPCError(
                Status.UNAVAILABLE,
                "Connection interrupted. " "Check the link and reconnect.",
            )
        except ConnectionRefusedError:
            traceback.print_exc()
            raise GRPCError(
                Status.UNAVAILABLE,
                "Connection refused. " "Verify the IP address, port, and meter power.",
            )
        except Exception as e:
            # Log full stack trace server-side for diagnostics
            traceback.print_exc()
            msg = str(e)
            msg_l = msg.lower()
            if "could not open port" in msg_l:
                raise GRPCError(
                    Status.INTERNAL,
                    "Serial port unavailable. " "Check the cable and COM port setting.",
                )
            if "timed out" in msg_l or "timeout" in msg_l:
                raise GRPCError(
                    Status.UNAVAILABLE,
                    "No response from the meter. " "Check the connection and retry.",
                )
            if "connection refused" in msg_l:
                raise GRPCError(
                    Status.UNAVAILABLE,
                    "Connection refused. "
                    "Verify the IP address, port, and meter power.",
                )
            if "connection reset" in msg_l or "broken pipe" in msg_l:
                raise GRPCError(
                    Status.UNAVAILABLE,
                    "Connection interrupted. " "Check the link and reconnect.",
                )
            if "invocation counter" in msg_l or "setup association failed" in msg_l:
                raise GRPCError(
                    Status.UNAUTHENTICATED,
                    "Frame counter incorrect. Check the frame counter configuration.",
                )
            if (
                "network is unreachable" in msg_l
                or "host is unreachable" in msg_l
                or "no route to host" in msg_l
            ):
                raise GRPCError(
                    Status.UNAVAILABLE,
                    "Meter unreachable. " "Check the network configuration.",
                )
            if "permission denied" in msg_l or "access denied" in msg_l:
                raise GRPCError(
                    Status.INTERNAL,
                    "Serial port access denied. "
                    "Close any application using this port and retry.",
                )
            # Surface the exception message to the client in the gRPC error
            raise GRPCError(Status.INTERNAL, msg)
            

    return wrapper
