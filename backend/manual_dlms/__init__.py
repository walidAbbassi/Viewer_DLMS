# manual_dlms package
# Provides a clean, decoupled Manual DLMS feature implementation.
# Architecture:
#
#   ManualDlmsGrpcService (service/manual_dlms_service.py)
#       └── ManualDlmsCore (manual_dlms/core.py)
#               ├── DlmsAdapter  (manual_dlms/dlms_adapter.py)
#               └── XdrCodec     (manual_dlms/xdr_codec.py)
