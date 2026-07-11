from typing import Optional

from ng_sdk.communication.abstract_communication import AbstractCommunication
from ng_sdk.configuration.config_manager import ConfigManager
from ng_sdk.frame_builder.abstract_frame_builder import AbstractFrameBuilder
from ng_sdk.frame_executor.abstract_frame_executor import AbstractFrameExecutor
from ng_sdk.security.security_context import SecurityContext
from ng_sdk.session.abstract_session import AbstractSession


class MeterContext:
    _instance = None
    configuration: ConfigManager = ConfigManager("configuration")
    communication: AbstractCommunication = None
    security_context: SecurityContext = None
    session: AbstractSession = None
    frame_builder: AbstractFrameBuilder = None
    frame_executor: AbstractFrameExecutor = None
    datamodel: str = None
    module_name: str = None  # current association name (e.g. "LocalOperation")
    class7_cache: dict = {}  # {objectName: {entries_in_use, headers, values_list}}

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(MeterContext, cls).__new__(cls)
        return cls._instance
