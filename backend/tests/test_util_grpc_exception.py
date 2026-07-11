from __future__ import annotations

import pytest

pytest.importorskip("grpclib")

from grpclib import GRPCError, Status

from util.grpc_exception import grpc_exception_handler


@pytest.mark.asyncio
async def test_grpc_exception_handler_passes_through_grpc_error():
    @grpc_exception_handler
    async def handler():
        raise GRPCError(Status.NOT_FOUND, "nope")

    with pytest.raises(GRPCError) as exc:
        await handler()

    assert exc.value.status == Status.NOT_FOUND
    assert "nope" in (exc.value.message or "")


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_unexpected_exception_as_internal():
    @grpc_exception_handler
    async def handler():
        raise RuntimeError("boom")

    with pytest.raises(GRPCError) as exc:
        await handler()

    assert exc.value.status == Status.INTERNAL
    assert "boom" in (exc.value.message or "")


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_index_error_as_connection_lost():
    @grpc_exception_handler
    async def handler():
        raise IndexError("list index out of range")

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.INTERNAL
    assert "connection lost" in msg
    assert "incomplete" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_serial_port_error_as_port_unavailable():
    @grpc_exception_handler
    async def handler():
        raise Exception(
            "could not open port COM4: [Errno 2] No such file or directory: 'COM4'"
        )

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.INTERNAL
    assert "serial port" in msg
    assert "com port" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_timeout_error():
    @grpc_exception_handler
    async def handler():
        raise TimeoutError()

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.UNAVAILABLE
    assert "no response" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_connection_refused():
    @grpc_exception_handler
    async def handler():
        raise ConnectionRefusedError()

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.UNAVAILABLE
    assert "connection refused" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_connection_reset():
    @grpc_exception_handler
    async def handler():
        raise ConnectionResetError()

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.UNAVAILABLE
    assert "connection interrupted" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_wraps_permission_error():
    @grpc_exception_handler
    async def handler():
        raise PermissionError()

    with pytest.raises(GRPCError) as exc:
        await handler()

    msg = (exc.value.message or "").lower()
    assert exc.value.status == Status.INTERNAL
    assert "access denied" in msg


@pytest.mark.asyncio
async def test_grpc_exception_handler_returns_value_on_success():
    @grpc_exception_handler
    async def handler(x: int):
        return x + 1

    assert await handler(41) == 42
