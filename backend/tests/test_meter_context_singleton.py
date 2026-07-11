from __future__ import annotations

import importlib
import sys
import types

import pytest


def _install_fake_ng_sdk(monkeypatch: pytest.MonkeyPatch) -> None:
    # Create a minimal fake ng_sdk tree so backend/meter_context.py can import.
    ng_sdk = types.ModuleType("ng_sdk")
    monkeypatch.setitem(sys.modules, "ng_sdk", ng_sdk)

    def _mod(path: str, **attrs):
        mod = types.ModuleType(path)
        for k, v in attrs.items():
            setattr(mod, k, v)
        monkeypatch.setitem(sys.modules, path, mod)
        return mod

    class _Base:  # simple placeholder base class
        pass

    class ConfigManager:
        def __init__(self, _name: str):
            self.name = _name

    _mod("ng_sdk.communication")
    _mod("ng_sdk.communication.abstract_communication", AbstractCommunication=_Base)
    _mod("ng_sdk.configuration")
    _mod("ng_sdk.configuration.config_manager", ConfigManager=ConfigManager)
    _mod("ng_sdk.frame_builder")
    _mod("ng_sdk.frame_builder.abstract_frame_builder", AbstractFrameBuilder=_Base)
    _mod("ng_sdk.frame_executor")
    _mod("ng_sdk.frame_executor.abstract_frame_executor", AbstractFrameExecutor=_Base)
    _mod("ng_sdk.security")
    _mod("ng_sdk.security.security_context", SecurityContext=_Base)
    _mod("ng_sdk.session")
    _mod("ng_sdk.session.abstract_session", AbstractSession=_Base)


def test_meter_context_is_singleton_and_initializes_instance_branch(
    monkeypatch: pytest.MonkeyPatch,
):
    _install_fake_ng_sdk(monkeypatch)

    # Ensure a clean import so class attributes are re-evaluated.
    sys.modules.pop("meter_context", None)
    meter_context = importlib.import_module("meter_context")
    meter_context = importlib.reload(meter_context)

    MeterContext = meter_context.MeterContext

    # Force the 'if cls._instance is None' branch to execute.
    MeterContext._instance = None

    first = MeterContext()
    assert MeterContext._instance is first

    second = MeterContext()
    assert second is first
