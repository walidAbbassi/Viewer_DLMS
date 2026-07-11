"""
MeterService — façade gRPC mince qui agrège les handlers de domaine.

Architecture SOLID :
  SRP  : chaque handler gère un seul domaine COSEM.
  OCP  : nouveau domaine → nouveau handler, ce fichier reste inchangé.
  LSP  : tous les handlers héritent de BaseHandler sans casser le contrat.
  ISP  : interfaces fines par domaine, pas une seule interface géante.
  DIP  : handlers dépendent de MeterContext (abstraction), pas de concrets.
"""
import threading

from gen import meter_grpc

from service.handlers.base_handler import BaseHandler
from service.handlers.calendar_handler import CalendarHandler
from service.handlers.clock_handler import ClockHandler
from service.handlers.connection_handler import ConnectionHandler
from service.handlers.ct_vt_management_handler import CTVTManagementHandler
from service.handlers.device_handler import DeviceHandler
from service.handlers.dlms_execution_handler import DlmsExecutionHandler
from service.handlers.energy_handler import EnergyHandler
from service.handlers.load_profile_handler import LoadProfileHandler
from service.handlers.export_handler import ExportHandler
from service.handlers.firmware_handler import FirmwareHandler
from service.handlers.mni_handler import MniHandler
from service.handlers.modem_handler import ModemHandler
from service.handlers.push_server_handler import PushServerHandler
from service.handlers.push_setup_handler import PushSetupHandler
from service.handlers.quality_handler import QualityHandler

# Serialise les appels execute() au niveau transport
_frame_executor_lock = threading.Lock()


class MeterService(
    ConnectionHandler,       # InitMeterContext, Connect, Disconnect
    DlmsExecutionHandler,    # ExecuteGet/Set/Action, Advanced*, BlockSize, Datamodel, TranslateData, GetObjectWriteRights
    FirmwareHandler,         # Image transfer lifecycle
    DeviceHandler,           # GetDeviceID, GetFirmwareVersion, GetBitStatus
    EnergyHandler,           # GetEnergyRegister, GetAverage, GetFresnelData
    LoadProfileHandler,      # GetLoadProfile, GetLoadProfileParam, SetLoadProfileParam
    ModemHandler,            # APN, PIN, IP, GSM, AutoConnect, AutoAnswer, TcpUdp, Class 27/28/29/41/44/45/47/48
    MniHandler,              # IMSI, MSISDN, IMEI, ICCID, GetMniRights
    ClockHandler,            # Clock, DST, Timezone, IncrementalDate, DecrementalDate
    CalendarHandler,         # ActivityCalendar, SpecialDays
    PushSetupHandler,        # Push object config, CommunicationWindow, ExecutionTime, Scripts...
    PushServerHandler,       # TCP/UDP server, WatchRetryStatus
    ExportHandler,           # ExportData, DlmsTranslate
    CTVTManagementHandler,   # CT VT Management
    QualityHandler,          # Quality
    meter_grpc.MeterServiceBase,
):
    """
    Façade gRPC mince — agrège les handlers de domaine par héritage multiple.
    N'ajoute aucune logique métier directement.
    """

    def __init__(self):
        super().__init__()
        # _push_server est géré par PushServerHandler

