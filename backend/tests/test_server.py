from __future__ import annotations

import asyncio
import importlib
import runpy
import sys
import types
from dataclasses import dataclass

import pytest


def _install_fake_service_modules(monkeypatch) -> None:
    """Avoid importing real service implementations (may pull heavy deps).

    server.py imports these at module import time.
    """

    def _mod(name: str, cls_name: str):
        module = types.ModuleType(name)

        @dataclass
        class _Svc:  # noqa: N801 (generated-ish test helper)
            created: bool = True

        _Svc.__name__ = cls_name
        setattr(module, cls_name, _Svc)
        monkeypatch.setitem(sys.modules, name, module)

    _mod("service.configuration_service", "ConfigurationService")
    _mod("service.meter_service", "MeterService")
    _mod("service.authentication_service", "AuthenticationService")


def _install_fake_grpclib(monkeypatch) -> None:
    """Provide a minimal grpclib.* package tree so importing server.py works.

    This keeps the unit tests runnable even outside the backend virtualenv.
    The fake ``grpclib`` module must declare ``__path__`` so that subsequent
    ``import grpclib.<sub>`` statements (used by ``gen/*_grpc.py`` stubs)
    treat it as a package rather than a plain module.
    """

    grpclib_pkg = sys.modules.get("grpclib")
    if grpclib_pkg is None:
        grpclib_pkg = types.ModuleType("grpclib")
        grpclib_pkg.__path__ = []  # mark as package so submodule imports resolve
        monkeypatch.setitem(sys.modules, "grpclib", grpclib_pkg)

    server_mod = types.ModuleType("grpclib.server")

    class _PlaceholderServer:  # noqa: N801
        pass

    server_mod.Server = _PlaceholderServer
    monkeypatch.setitem(sys.modules, "grpclib.server", server_mod)

    # Fake grpclib.const + grpclib.client used by gen/*_grpc.py stubs.
    for sub in ("const", "client"):
        full_name = f"grpclib.{sub}"
        if full_name not in sys.modules:
            sub_mod = types.ModuleType(full_name)
            monkeypatch.setitem(sys.modules, full_name, sub_mod)


def _fresh_import_server(
    monkeypatch, *, host: str | None = None, port: str | None = None
):
    monkeypatch.delenv("PY_GRPC_HOST", raising=False)
    monkeypatch.delenv("PY_GRPC_PORT", raising=False)
    if host is not None:
        monkeypatch.setenv("PY_GRPC_HOST", host)
    if port is not None:
        monkeypatch.setenv("PY_GRPC_PORT", port)

    _install_fake_service_modules(monkeypatch)
    _install_fake_grpclib(monkeypatch)

    sys.modules.pop("server", None)
    server_mod = importlib.import_module("server")  # type: ignore
    return importlib.reload(server_mod)


def test_defaults_for_host_and_port(monkeypatch):
    server_mod = _fresh_import_server(monkeypatch)
    assert server_mod.HOST == "127.0.0.1"
    assert server_mod.PORT == 50051


def test_env_overrides_host_and_port(monkeypatch):
    server_mod = _fresh_import_server(monkeypatch, host="0.0.0.0", port="12345")
    assert server_mod.HOST == "0.0.0.0"
    assert server_mod.PORT == 12345


def test_serve_creates_services_and_starts_server(monkeypatch, capsys):
    server_mod = _fresh_import_server(monkeypatch, host="127.0.0.1", port="50051")

    created = {}

    class FakeServer:
        def __init__(self, services):
            created["services"] = list(services)
            self.started = None
            self.closed = False

        async def start(self, host, port):
            self.started = (host, port)

        async def wait_closed(self):
            # Immediately allow serve() to exit
            return None

        def close(self):
            self.closed = True

    # Patch the imported Server symbol inside server.py
    monkeypatch.setattr(server_mod, "Server", FakeServer)

    asyncio.run(server_mod.serve())

    # Global variable should be set
    assert server_mod.server is not None
    assert isinstance(server_mod.server, FakeServer)

    # Services list created and wired
    services = created["services"]
    assert len(services) == 5
    assert services[0].__class__.__name__ == "LoggerService"
    assert services[1].__class__.__name__ == "ConfigurationService"
    assert services[2].__class__.__name__ == "MeterService"
    assert services[3].__class__.__name__ == "AuthenticationService"

    assert server_mod.server.started == ("127.0.0.1", 50051)

    out = capsys.readouterr().out
    assert "[py-grpc] listening on 127.0.0.1:50051" in out
    assert "[py-grpc] server closed" in out


def test_close_server_noop_when_server_is_none(monkeypatch, capsys):
    server_mod = _fresh_import_server(monkeypatch)
    server_mod.server = None

    asyncio.run(server_mod.close_server())

    out = capsys.readouterr().out
    assert "server.close()" not in out


def test_close_server_closes_when_server_is_set(monkeypatch, capsys):
    server_mod = _fresh_import_server(monkeypatch)

    class FakeServer:
        def __init__(self):
            self.closed = False

        def close(self):
            self.closed = True

    fake = FakeServer()
    server_mod.server = fake

    asyncio.run(server_mod.close_server())

    assert fake.closed is True
    out = capsys.readouterr().out
    assert "server.close()" in out


def test_main_runs_serve_and_exits_cleanly(monkeypatch):
    _install_fake_service_modules(monkeypatch)
    _install_fake_grpclib(monkeypatch)

    called = {"ran": False, "arg": None}

    def _fake_asyncio_run(arg):
        called["ran"] = True
        called["arg"] = arg
        # asyncio.run() would consume the coroutine; close it to avoid warnings.
        close = getattr(arg, "close", None)
        if callable(close):
            close()
        return None

    def _fake_exit(code=0):
        raise SystemExit(code)

    monkeypatch.setattr(asyncio, "run", _fake_asyncio_run)
    monkeypatch.setattr(sys, "exit", _fake_exit)
    sys.modules.pop("server", None)

    with pytest.raises(SystemExit) as exc:
        runpy.run_module("server", run_name="__main__")

    assert exc.value.code == 0
    assert called["ran"] is True
    assert called["arg"] is not None


def test_main_handles_keyboard_interrupt_and_exits(monkeypatch):
    _install_fake_service_modules(monkeypatch)
    _install_fake_grpclib(monkeypatch)

    def _fake_asyncio_run(arg):
        close = getattr(arg, "close", None)
        if callable(close):
            close()
        raise KeyboardInterrupt

    def _fake_exit(code=0):
        raise SystemExit(code)

    monkeypatch.setattr(asyncio, "run", _fake_asyncio_run)
    monkeypatch.setattr(sys, "exit", _fake_exit)
    sys.modules.pop("server", None)

    with pytest.raises(SystemExit) as exc:
        runpy.run_module("server", run_name="__main__")

    assert exc.value.code == 0
