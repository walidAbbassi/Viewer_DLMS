"""
BaseHandler — socle commun partagé par tous les handlers de domaine.

SRP : ne gère que l'exécution DLMS (_run / _run_optional) et la vérification
      des réponses GET/SET.
DIP : dépend des abstractions AbstractFrameResponse, pas des concrets.
"""
import asyncio

from grpclib import GRPCError, Status as GRPCStatus
from logger import logging_setup as _ls

from ng_sdk.frame_builder.abstract_frame_response import AbstractFrameResponse
from ng_sdk.frame_builder.dlms.xdlms.exception.dlms_exception_response import DLMSExceptionResponse
from ng_sdk.frame_builder.dlms.xdlms.get.response.dlms_get_response_normal import DLMSGetResponseNormal
from ng_sdk.frame_builder.dlms.xdlms.set.response.dlms_set_response_normal import DLMSSetResponseNormal

from meter_context import MeterContext


class BaseHandler:
    """Classe de base pour tous les handlers de domaine."""

    # ── Execution helpers ────────────────────────────────────────────────────

    async def _run(self, func, *args, **kwargs):
        """Exécute un appel DLMS bloquant dans un thread sans bloquer l'event loop."""
        _ls._had_retry.clear()
        result = await asyncio.to_thread(func, *args, **kwargs)
        if _ls._had_retry.is_set():
            _ls._had_retry.clear()
            try:
                _ls.retry_queue.put_nowait({"__success__": True})
            except Exception:
                pass
        return result

    async def _run_optional(self, func, *args, **kwargs):
        """Comme _run() pour les objets DLMS optionnels (SIM/GSM…)."""
        _ls._suppress_retry_inc()
        try:
            return await asyncio.to_thread(func, *args, **kwargs)
        except (TimeoutError, ConnectionResetError, BrokenPipeError,
                ConnectionRefusedError, IndexError):
            raise GRPCError(GRPCStatus.UNAVAILABLE, "Meter did not respond.")
        finally:
            _ls._suppress_retry_dec()

    # ── Response verification (public so all subclasses & old code can call them) ──

    def _verify_get_response(self, get_response: AbstractFrameResponse):
        """Lève Exception si la réponse GET est invalide."""
        if not isinstance(get_response, DLMSGetResponseNormal) or not get_response.is_success():
            if isinstance(get_response, DLMSExceptionResponse):
                raise Exception(
                    "Service error: " + get_response.service_error.name
                    + " State error:" + get_response.state_error.name
                )
            elif isinstance(get_response, DLMSGetResponseNormal):
                raise Exception(get_response.data_access_result.name)
            else:
                raise Exception("Response Error")

    def _verify_set_response(self, set_response: AbstractFrameResponse):
        """Lève Exception si la réponse SET est invalide."""
        if not isinstance(set_response, DLMSSetResponseNormal) or not set_response.is_success():
            if isinstance(set_response, DLMSExceptionResponse):
                raise Exception(
                    "Service error: " + set_response.service_error.name
                    + " State error:" + set_response.state_error.name
                )
            elif isinstance(set_response, DLMSSetResponseNormal):
                raise Exception(set_response.data_access_result.name)
            else:
                raise Exception("Response Error")
    def _get_object_from_datamodel(self,object_name:str)-> dict:
        data_model = MeterContext.configuration.datamodel[MeterContext.datamodel].objects
        obj = next((item for item in data_model if item["name"] == object_name), None)
        if obj is None:
            raise Exception(object_name+" Object not found in data model")
        return obj
    def _get_attribute_from_object(self,object:dict,value:str)->dict:
        attribute = next((attr for attr in object["dlmsAttribute"] if attr["name"] == value), None)
        if attribute is None:
            raise Exception(value+" attribute not found for "+object["name"]+" Object in data model")
        return attribute
    # Aliases for compatibility with code using double-underscore private names
    # (Python name mangling: __verify_X in a class Foo becomes _Foo__verify_X)
    _BaseHandler__verify_get_response = _verify_get_response
    _BaseHandler__verify_set_response = _verify_set_response

