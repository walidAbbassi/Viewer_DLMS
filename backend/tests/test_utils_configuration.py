from __future__ import annotations

import importlib
import sys
import types


def _install_fake_ng_sdk(monkeypatch):
    ng_sdk = types.ModuleType("ng_sdk")
    configuration = types.ModuleType("ng_sdk.configuration")
    config_manager = types.ModuleType("ng_sdk.configuration.config_manager")

    class ConfigModuleProxy:  # minimal stand-in
        pass

    config_manager.ConfigModuleProxy = ConfigModuleProxy

    monkeypatch.setitem(sys.modules, "ng_sdk", ng_sdk)
    monkeypatch.setitem(sys.modules, "ng_sdk.configuration", configuration)
    monkeypatch.setitem(
        sys.modules, "ng_sdk.configuration.config_manager", config_manager
    )

    return ConfigModuleProxy


def test_get_configuration_value_returns_default_for_config_module_proxy(monkeypatch):
    ConfigModuleProxy = _install_fake_ng_sdk(monkeypatch)

    sys.modules.pop("utils_configuration", None)
    utils_configuration = importlib.import_module("utils_configuration")

    proxy = ConfigModuleProxy()

    assert utils_configuration.get_configuration_value(proxy) is None
    assert utils_configuration.get_configuration_value(proxy, default_value="x") == "x"


def test_get_configuration_value_returns_value_for_non_proxy(monkeypatch):
    _install_fake_ng_sdk(monkeypatch)

    sys.modules.pop("utils_configuration", None)
    utils_configuration = importlib.import_module("utils_configuration")

    assert utils_configuration.get_configuration_value(123, default_value="x") == 123
    assert utils_configuration.get_configuration_value("abc") == "abc"
