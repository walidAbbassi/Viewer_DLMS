# gRPC code generation

Generated stubs are committed to the repo:

- **Python** (backend): `backend/gen/*_pb2.py`, `backend/gen/*_grpc.py` (grpclib),
  plus `backend/gen/*_pb2_grpc.py` (grpcio) for `meter` and `authentication` only.
- **Dart** (frontend): `flutter_app/lib/grpc/generated/*.pb*.dart`.

Regenerate with `regen_grpc.ps1` (repo root) after **any** change to a `.proto`
in `protos/`. It is a codegen step, not part of the normal build.

```powershell
.\regen_grpc.ps1
```

The script loops over every `protos/*.proto`, generates grpclib stubs for all of
them, grpcio stubs for the two tested services, patches grpclib imports
(`import X_pb2` -> `from gen import X_pb2`), and generates Dart stubs for all.

## Runtimes

- Backend server uses **grpclib** (`backend/server.py`). The `*_grpc.py` files are
  the real service stubs — needed for all protos.
- The **grpcio** `*_pb2_grpc.py` stubs are kept only for `meter` + `authentication`
  because those two have smoke tests (`backend/tests/test_gen_meter_pb2_grpc_smoke.py`,
  `test_gen_meter_pb2_smoke.py`). grpcio stubs stay flat (`import X_pb2`) — the tests
  inject `gen/` on `sys.path`; do **not** patch them to `from gen import`.

## Frozen toolchain

Regenerating with different tool versions produces large, meaningless diffs
(version drift). Pin these versions when regenerating so committed output stays
stable. Values below are the known-good set used on 2026-07:

| Tool | Version | Notes |
|------|---------|-------|
| protoc | libprotoc 33.2 | autodetected by the script (install manually) |
| grpcio-tools | 1.80.0 | `python -m grpc_tools.protoc` |
| grpcio | 1.80.0 | runtime for the grpcio stubs |
| grpclib | 0.4.7 | backend server runtime |
| protobuf (python) | 6.33.6 | |
| protoc_plugin (dart) | 25.0.0 | pinned in `regen_grpc.ps1` (`$dartPluginVersion`) |
| Python | 3.14.3 | |
| Dart SDK | 3.10.8 | |

If you bump any of these, expect (and review) a one-time diff across the
generated files, then commit that as an intentional "regen on toolchain X" change.

## Line endings

`.gitattributes` forces `eol=lf` on generated files so regenerating on Windows
does not flip line endings on every file. Keep it — without it a clean regen
shows ~40 files changed with zero real content difference.

## Known gap

`admin`, `echo`, and `progress` currently have **no Python stubs committed** (only
Dart). `regen_grpc.ps1` will generate them if run. Decide whether the Python
backend needs those services before committing the new stubs; if not, they can be
left out (the script generating them is harmless — just don't commit unused files).
