from ng_sdk.configuration.config_manager import ConfigModuleProxy


def get_configuration_value(value, default_value=None):
    if isinstance(value, ConfigModuleProxy):
        return default_value
    return value
