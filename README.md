# 🛰️ Viewer NG

<div align="center">

[![pipeline](https://img.shields.io/badge/pipeline-passing-brightgreen)](https://gitlab-produits.rmm.scom/tools/Viewer_NG/-/pipelines)
[![coverage](https://img.shields.io/badge/coverage-≥80%25-brightgreen)](https://gitlab-produits.rmm.scom/tools/Viewer_NG/-/pipelines)
![Flutter](https://img.shields.io/badge/Flutter-3.5.6-02569B?logo=flutter&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.13-3776AB?logo=python&logoColor=white)
![gRPC](https://img.shields.io/badge/gRPC-grpclib-4285F4?logo=grpc&logoColor=white)
![DLMS](https://img.shields.io/badge/Protocol-DLMS%2FCOSEM-orange)
![GitLab CI](https://img.shields.io/badge/GitLab-CI%2FCD-FC6D26?logo=gitlab&logoColor=white)
![Copilot](https://img.shields.io/badge/Copilot-claude--sonnet--4.6-6e40c9?logo=githubcopilot&logoColor=white)
![Agents](https://img.shields.io/badge/AI%20Agents-11-blueviolet)
![OpenSpec](https://img.shields.io/badge/Spec-OpenSpec-0F766E)
![License](https://img.shields.io/badge/License-Proprietary-lightgrey)

**Next-generation electricity meter viewer — Flutter desktop UI + Python gRPC backend.**
DLMS/COSEM data extraction, multi-format export (CSV · PDF · XML · DOCX),
and a **GitLab CI/CD pipeline powered by 11 AI agents** (named after gods and pioneers)
running on every Merge Request — fast static analysis first, then **Claude Sonnet 4.6**
through the GitHub Copilot SDK.

*Spec-driven development with [OpenSpec](https://github.com/Fission-AI/OpenSpec) (local-only, gitignored).*

</div>

---

## 📋 Table of Contents

| Section | |
|---|---|
| [📁 Project Structure](#-project-structure) | File tree |
| [🏗 Overall Architecture](#-overall-architecture) | Big picture — Flutter ⇄ gRPC ⇄ Meter |
| [🖥 Flutter Desktop App](#-flutter-desktop-app) | UI features, pages, providers |
| [🐍 Python gRPC Backend](#-python-grpc-backend) | Services, sessions, NG SDK |
| [📡 gRPC Contracts](#-grpc-contracts) | 7 proto files, services exposed |
| [📤 Export Templates](#-export-templates) | CSV · PDF · XML · DOCX, 8 reports |
| [🚀 CI/CD Pipeline](#-cicd-pipeline) | 6 stages, 22 jobs |
| [🤖 AI Agents — The Pantheon](#-ai-agents--the-pantheon) | 11 agents, hybrid 2-layer |
| [🧠 Copilot SDK / CLI Fallback](#-copilot-sdk--cli-fallback) | Claude Sonnet 4.6, env vars |
| [📧 Pipeline Email Automation](#-pipeline-email-automation) | One MR-comment + one email |
| [🔐 Licence System](#-licence-system) | AES decryption, parser |
| [📐 Spec-Driven Workflow](#-spec-driven-workflow) | OpenSpec proposals (local) |
| [⚡ Quick Start](#-quick-start) | Install, build, run |
| [📦 Build & Installer](#-build--installer) | PyInstaller + Inno Setup |
| [📑 User Guide](#-user-guide) | SAGEMCOM ViewerNG presentation |

---

## 📁 Project Structure

```text
Viewer_NG_main2/
│
├── flutter_app/                          # 🖥 Flutter desktop client
│   ├── lib/
│   │   ├── main.dart                     #     entrypoint — window_manager + Riverpod
│   │   ├── app.dart
│   │   ├── core/                         #     theme, navigation, user rights
│   │   ├── features/
│   │   │   ├── pages/                    #     24 pages (configuration, load profile, …)
│   │   │   ├── widgets/
│   │   │   ├── services/                 #     auth_provider, ConfigurationApi…
│   │   │   ├── export/                   #     CSV/PDF/XML/DOCX export registry
│   │   │   └── super_manual/
│   │   ├── grpc/                         #     generated stubs + admin_client
│   │   ├── platform/python_launcher.dart #     spawns py_grpc_server.exe
│   │   ├── state/  routes/  util/
│   │   └── assets/  (animations, config, images)
│   └── pubspec.yaml                      #     grpc 5.1 · protobuf 6 · riverpod · lottie
│
├── backend/                              # 🐍 Python gRPC server (grpclib)
│   ├── server.py                         #     starts grpclib.Server on 127.0.0.1:50051
│   ├── service/                          #     4 gRPC services
│   │   ├── authentication_service.py
│   │   ├── configuration_service.py
│   │   ├── logger_service.py
│   │   └── meter_service.py
│   ├── configuration/                    #     DataModel, association, JSON5 mappings
│   ├── session/session_manager.py
│   ├── translator/                       #     DLMS / xDLMS / HDLC / ACSE translators
│   ├── license/                          #     AES cipher + licence parser
│   ├── logger/  util/  meter_context.py
│   ├── gen/                              #     generated *_pb2 / *_grpc.py
│   ├── tests/                            #     pytest — coverage ≥ 80%
│   ├── server.spec  py_grpc_server.spec  #     PyInstaller specs
│   └── requirements.txt                  #     grpclib · protobuf · pdfkit · docxtpl…
│
├── protos/                               # 📡 Protocol Buffer contracts
│   ├── admin.proto                       #     Close server
│   ├── authentication.proto              #     Login / role / licence
│   ├── configuration.proto               #     Data model push / pull
│   ├── echo.proto                        #     Health-check
│   ├── logger.proto                      #     Streamed logs
│   ├── meter.proto                       #     Read meter (DLMS over gRPC)
│   └── progress.proto                    #     Long-task progress events
│
├── templates/                            # 📤 Report templates (8 datasets × 4 formats)
│   ├── csv/    *.csv                     #     8 dataset CSV templates
│   ├── pdf/    *.html                    #     wkhtmltox → PDF
│   ├── xml/    *.xml
│   └── docx/   *.docx                    #     docxtpl Jinja templates
│
├── ng_sdk_whl/                           # 📦 Native SDK
│   └── ng_sdk-0.1.0-py3-none-any.whl     #     bundled wheel
│
├── wkhtmltox/                            # 🖨 PDF rendering engine
│
├── agents/                               # 🤖 11 AI CI agents — the Pantheon
│   ├── copilot_client.py                 #     SDK → CLI → disabled fallback
│   ├── code_reviewer.py                  #     🏺 Osiris
│   ├── security_scanner.py               #     ⚖️ Anubis
│   ├── dependency_audit_agent.py         #     🔮 Cassandra
│   ├── license_compliance_agent.py       #     ⚖️ Themis
│   ├── test_coverage_agent.py            #     🧪 TIA-Python
│   ├── flutter_coverage_agent.py         #     🐾 Laika-Flutter
│   ├── flutter_analyzer_agent.py         #     🚀 Vostok
│   ├── documentation_agent.py            #     📜 Hermes
│   ├── code_explainer.py                 #     🪨 Rosetta
│   ├── cicd_agent.py                     #     🔥 Phoenix
│   ├── pipeline_report_agent.py          #     🌍 Atlas
│   ├── prompts/                          #     12 Markdown prompt files
│   ├── mr_format.py                      #     MR comment composer
│   ├── config.py
│   └── AGENTS_IDENTITY.md                #     symbolic names map
│
├── tools/                                # 🛠 Developer tooling
│   ├── send_pipeline_email.py            #     end-of-pipeline email (18+ attachments)
│   ├── setup_gitlab_variables.py         #     bootstrap GitLab CI variables
│   ├── setup_gitlab_ci_variables.ps1
│   ├── PIPELINE_EMAIL_SETUP.md
│   └── report_converters/                #     flake8 → JUnit, flutter → CodeQuality…
│
├── .gitlab-ci.yml                        # ⚙️ prepare → lint → test → review → report → deploy
├── build.ps1                             # 🔨 PowerShell — backend + Flutter + installer
├── setup.iss                             # 📦 Inno Setup script (ViewerNG-Setup.exe)
├── Cleaner.bat                           # 🧹 Recursive __pycache__ cleanup
├── SAGEMCOM - ViewerNG UserGuide.pptx    # 📑 End-user presentation
└── README.md
```

---

## 🏗 Overall Architecture

```text
┌──────────────────────────────────────────────────────────────────────────────┐
│                          🖥  Viewer NG — Desktop App                          │
│                                                                              │
│   ┌────────────────────────────────────────────────────────────────────┐     │
│   │  Flutter (Material 3) — window_manager + Riverpod + Provider       │     │
│   │  ├── connexion_page   (authentication / role / licence)            │     │
│   │  ├── configuration_page                                            │     │
│   │  ├── load_profile / status / energy_register / event_logs          │     │
│   │  ├── firmware_version / firmware_download                          │     │
│   │  ├── fresnel_diagram / push_setup / sim_config / modem_config      │     │
│   │  ├── dlms_translator / gurux_translator / super_manual_tool        │     │
│   │  └── export → CSV · PDF · XML · DOCX                               │     │
│   └─────────────────────────────────┬──────────────────────────────────┘     │
│                                     │  gRPC (protobuf 6 over HTTP/2)         │
│                                     ▼                                        │
│   ┌────────────────────────────────────────────────────────────────────┐     │
│   │  Python gRPC server (grpclib)  ──  127.0.0.1:50051                 │     │
│   │  ┌──────────────────────────┬────────────────────────────────┐     │     │
│   │  │  AuthenticationService   │  ConfigurationService          │     │     │
│   │  │  LoggerService           │  MeterService                  │     │     │
│   │  └──────────────────────────┴────────────────────────────────┘     │     │
│   │  session_manager · translator (DLMS/xDLMS/HDLC/ACSE)               │     │
│   │  license (AES cipher) · meter_context · util.fresnel/hexa          │     │
│   └─────────────────────────────────┬──────────────────────────────────┘     │
│                                     │  ng_sdk (whl) — native meter I/O       │
│                                     ▼                                        │
│                          📟  Electricity meter  (DLMS/COSEM)                  │
└──────────────────────────────────────────────────────────────────────────────┘

                                   │ on push / MR
                                   ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                  ⚙  GitLab CI/CD  —  gitlab-produits.rmm.scom                 │
│                                                                              │
│   prepare ─► lint ─► test ─► review (11 agents) ─► report ─► deploy + email   │
│                                                                              │
│              Each agent: regex/AST/structural pass first (free),             │
│              then Claude Sonnet 4.6 via the GitHub Copilot SDK.              │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## 🖥 Flutter Desktop App

Windowed desktop application (`window_manager` maximised on launch) that drives the embedded Python gRPC server and renders meter data.

### Highlights

| Capability | Stack / Files |
|---|---|
| State management | `provider` 6 · `flutter_riverpod` 2.5 |
| Window control | `window_manager` 0.5 (set title, maximise, focus) |
| Local persistence | `shared_preferences` + `flutter_secure_storage` ("Remember me") |
| File handling | `file_picker` 8 (open / save dialogs) |
| Animations | `lottie` 2.7 |
| gRPC | `grpc` 5.1 · `protobuf` 6 (generated stubs in `lib/grpc/generated`) |
| Backend launcher | [`platform/python_launcher.dart`](flutter_app/lib/platform/python_launcher.dart) — spawns `py_grpc_server.exe` |
| Authentication | [`features/services/auth_provider.dart`](flutter_app/lib/features/services/auth_provider.dart) — role + rights |

### 📑 Pages (24)

`average_page` · `calendar_profiles_page` · `configuration_page` · `connexion_page` · `date_time_page` · `device_id_page` · `dlms_translator_page` · `energy_register_page` · `event_logs_page` · `firmware_download_page` · `firmware_version_page` · `fresnel_diagram_page` · `gurux_translator_page` · `load_profile_page` · `load_profile_status_page` · `meter_connexion_page` · `modem_config_page` · `push_action_page` · `push_recovery_page` · `push_selective_page` · `push_setup_page` · `script_table_page` · `sim_config_page` · `super_manual_tool_page` · `template_config_page`

### 🎨 Export Registry Pattern

Each page registers its export adapter at startup ([`main.dart:39-50`](flutter_app/lib/main.dart#L39-L50)):

```dart
registerConfigurationPage();
registerDeviceIdPage();
registerFirmwareVersionPage();
registerDateTimePage();
registerEnergyRegisterPage();
registerFresnelPage();
registerAllLoadProfilePages();
registerAllLoadProfileStatusPages();
registerAllEventLogsPages();
```

Output is dispatched to **CSV · PDF · XML · DOCX** depending on user choice — same data, four formats.

---

## 🐍 Python gRPC Backend

A `grpclib` async server bundled as a single PyInstaller executable (`py_grpc_server.exe`) launched by Flutter on app start.

### Entrypoint — `backend/server.py`

```python
HOST = os.environ.get("PY_GRPC_HOST", "127.0.0.1")
PORT = int(os.environ.get("PY_GRPC_PORT", "50051"))

services = [
    LoggerService(),
    ConfigurationService(),
    MeterService(),
    AuthenticationService(),
]
server = Server(services)
await server.start(HOST, PORT)
```

### 🔌 Services

| Service | Module | Purpose |
|---|---|---|
| 🔐 Authentication | [`service/authentication_service.py`](backend/service/authentication_service.py) | Login, role, licence validation |
| ⚙ Configuration | [`service/configuration_service.py`](backend/service/configuration_service.py) | Push/pull device datamodel |
| 📊 Meter | [`service/meter_service.py`](backend/service/meter_service.py) | DLMS read/write, export pipeline |
| 📜 Logger | [`service/logger_service.py`](backend/service/logger_service.py) | Stream backend logs to UI |

### 🔁 Translators (`backend/translator/`)

- `abstract_translator.py` — base contract
- `dlms_translator.py` — full DLMS frame parsing
- `xdlms_translator.py` — eXtended DLMS
- `ciphered_xdlms_translator.py` — AES/GCM ciphered xDLMS
- `hdlc_translator.py` — HDLC link layer
- `acse_translator.py` — ACSE association

### 🧪 Tests (`backend/tests/`)

~20 pytest modules covering services (gRPC smoke + unit), translators, licence parsing, configuration utils. Coverage gate **≥ 80%** enforced by `BACKEND_COV_THRESHOLD`.

---

## 📡 gRPC Contracts

Seven proto files live in [`protos/`](protos/) and are compiled into both Dart (Flutter) and Python (`backend/gen/`).

| Proto | Service | Purpose |
|---|---|---|
| `admin.proto` | Admin | Graceful server shutdown |
| `authentication.proto` | Authentication | Login, role enum, licence check |
| `configuration.proto` | Configuration | Data model upload / download |
| `echo.proto` | Echo | Liveness probe |
| `logger.proto` | Logger | Server-streamed log lines |
| `meter.proto` | Meter | DLMS read/write, export jobs |
| `progress.proto` | Progress | Long-running task progress stream |

Regenerate stubs with `grpcio-tools` (backend) and `protoc-gen-dart` (Flutter).

---

## 📤 Export Templates

Eight datasets × four output formats — all reports are generated server-side and streamed to Flutter.

| Dataset | CSV | PDF (wkhtmltox) | XML | DOCX |
|---|:---:|:---:|:---:|:---:|
| Date / Time | ✅ | ✅ | ✅ | ✅ |
| Device ID | ✅ | ✅ | ✅ | ✅ |
| Energy Register | ✅ | ✅ | ✅ | ✅ |
| Event Logs | ✅ | ✅ | ✅ | ✅ |
| Firmware Version | ✅ | ✅ | ✅ | ✅ |
| Fresnel Diagram | ✅ | ✅ | ✅ | ✅ |
| Load Profile | ✅ | ✅ | ✅ | ✅ |
| Load Profile Status | ✅ | ✅ | ✅ | ✅ |

Templates live under [`templates/{csv,pdf,xml,docx}/`](templates/). PDF rendering uses bundled [`wkhtmltox/`](wkhtmltox/) (HTML → PDF).

---

## 🚀 CI/CD Pipeline

> Runner: **Windows shell executor** (pwsh) — tag controlled by `$RUNNER_TAG`
> Binaries: `$PYTHON_BIN` · `$FLUTTER_BIN` (override from GitLab CI/CD Variables)

```text
 prepare ──► lint ──────────► test ──────────► copilot-check ──► review (10 agents) ──► report ──► deploy
    │         │                 │               (mandatory gate)        │                  │          │
 cleanup    flake8             pytest          ✓ Copilot SDK ?      🔐 Anubis          🌍 Atlas    staging
            black --check      pytest-cov      ✓ Copilot CLI ?      👁  Osiris         (aggregate) (manual)
            pylint             mutation tests  ✓ Auth token ?       🧪 TIA-Python          │       email
            mypy               flutter test    └► aggregates        🐾 Laika-Flutter       ▼       notify
            radon              coverage lcov     lint+test           🚀 Vostok        MR comment
            flutter analyze                      artefacts into      🔮 Cassandra      (single,
                                                 ci_inputs/          ⚖️  Themis         consolidated)
                                                 ↓ allow_failure:    📜 Hermes
                                                   false             🪨 Rosetta
                                                                     🔥 Phoenix
```

> 💡 **11 agents total** — 10 run in parallel under `review`, the 11th (**Atlas**) runs in `report` to merge everything into a single MR comment.
> All 10 review agents have `needs: [copilot-check]` — if the gate fails (no SDK/CLI/auth), the agents simply never start.

### 📊 Jobs (24)

| Stage | Job | Description |
|---|---|---|
| `prepare` | `workspace_cleanup` | Wipe previous reports, `__pycache__`, fresh start |
| `lint` | `lint_python_flake8` | PEP 8 — text + HTML + GitLab CodeQuality + JUnit |
| `lint` | `lint_python_black` | Formatting diff with KPI block |
| `lint` | `lint_python_pylint` | Deep static analysis |
| `lint` | `lint_python_mypy` | Type checking → CodeQuality JSON |
| `lint` | `lint_python_radon` | Cyclomatic complexity metrics |
| `lint` | `lint_flutter_analyze` | Dart analyser → CodeQuality |
| `test` | `test_backend` | pytest + coverage XML/HTML + JUnit |
| `test` | `test_frontend` | flutter test + lcov |
| `test` | `test_backend_mutation` | Mutation testing |
| `review` | **`copilot-check`** | 🚦 **Mandatory gate** — verifies Copilot SDK / CLI / auth + aggregates all lint+test artefacts into `backend/reports/ci_inputs/`. `allow_failure: false` → blocks the 10 agents below if it fails. |
| `review` | `agent_security_scanner` | 🔐 **Anubis** — CVEs, secrets, OWASP |
| `review` | `agent_code_reviewer` | 👁️ **Osiris** — quality, patterns, best practices |
| `review` | `agent_test_coverage` | 🧪 **TIA-Python** — pytest / coverage.py |
| `review` | `agent_flutter_coverage` | 🐾 **Laika-Flutter** — lcov / Flutter tests |
| `review` | `agent_flutter_analyzer` | 🚀 **Vostok** — Dart warnings & lints |
| `review` | `agent_dependency_audit` | 🔮 **Cassandra** — stale & vulnerable deps |
| `review` | `agent_license_compliance` | ⚖️ **Themis** — OSS licence compatibility |
| `review` | `agent_documentation` | 📜 **Hermes** — doc gaps & generation |
| `review` | `agent_code_explainer` | 🪨 **Rosetta** — plain-English MR notes |
| `review` | `agent_cicd_diagnosis` | 🔥 **Phoenix** — YAML lint + diagnosis |
| `report` | `pipeline_report` | 🌍 **Atlas** — aggregates the 10 reports → single MR comment |
| `deploy` | `notify_pipeline_completion` | 📧 HTML email with 18+ attachments |
| `deploy` | `deploy_staging` | Manual gate |

> 💡 The pipeline runs **only on Merge Requests** (see `.agent-rules`). Push events stay lightweight.

### 🔑 Required CI/CD Variables

| Variable | Scope | Notes |
|---|---|---|
| `GITLAB_TOKEN` | Masked | `api` scope — agents post MR comments |
| `COPILOT_GITHUB_TOKEN` | Masked (**not** Protected) | GitHub PAT for Copilot SDK |
| `PIPELINE_NOTIFICATION_EMAIL` | Plain | Email recipient — never hardcoded |
| `SMTP_SERVER` · `SMTP_USER` · `SMTP_PASSWORD` | Masked | Email transport (optional) |
| `RUNNER_TAG` · `PYTHON_BIN` · `FLUTTER_BIN` | Plain | Runner config |
| `HTTP_PROXY` · `HTTPS_PROXY` · `NO_PROXY` | Plain | Corporate proxy |
| `BACKEND_COV_THRESHOLD` · `FLUTTER_COV_THRESHOLD` | Plain | Coverage gates |

Bootstrap them all at once:

```powershell
python tools/setup_gitlab_variables.py [--dry-run]
```

---

## 🤖 AI Agents — The Pantheon

Eleven specialised agents — named after gods, oracles, and pioneers — run on every Merge Request. Each follows the **Hybrid 2-Layer** pattern:

```text
 CI job
   │── Layer 1  (always)  ───────────────────────────────────────────┐
   │   regex / AST / XML / lcov / pip-audit                          │
   │   ~10–30 ms  ·  $0  ·  0 tokens                                 │
   │   returns:  findings[]                                          │
   │                                                                 │
   │── CopilotClient._ask(findings + prompt)  (if mode != disabled)  │
   │        │                                                        │
   │    mode = sdk  ──►  claude-sonnet-4.6  (JSON-RPC stdio)         │
   │    mode = cli  ──►  gh copilot explain  (subprocess)            │
   │    mode = off  ──►  Layer 1 only                                │
   │        │                                                        │
   │   enhanced findings  ◄──────────────────────────────────────────┘
   │
   └── MR pipeline?  → POST /merge_requests/:iid/notes  (GitLab API)
```

### 📦 Agent Inventory

| Agent CI | Symbolic Name | Inspiration | Role | Mission |
|---|:---:|:---:|:---:|---|
| `code_reviewer` | 🏺 **Osiris** | Horus KB | Judge of code | Quality, patterns, best practices |
| `security_scanner` | ⚖️ **Anubis** | Kojak KB | Guardian of threats | CVEs, secrets, OWASP |
| `dependency_audit_agent` | 🔮 **Cassandra** | Kojak KB | Oracle of risks | Stale & vulnerable deps |
| `license_compliance_agent` | ⚖️ **Themis** | Kojak KB | Keeper of law | OSS licence compatibility |
| `test_coverage_agent` | 🧪 **TIA-Python** | T_IA KB | Coverage meter | pytest / coverage.py |
| `flutter_coverage_agent` | 🐾 **Laika-Flutter** | Laika KB | Coverage meter | lcov · Flutter tests |
| `flutter_analyzer_agent` | 🚀 **Vostok** | Laika KB | Flutter analyst | Dart warnings & lints |
| `documentation_agent` | 📜 **Hermes** | new | Knowledge messenger | Doc gaps & generation |
| `code_explainer` | 🪨 **Rosetta** | new | Code translator | Plain-English MR notes |
| `cicd_agent` | 🔥 **Phoenix** | new | Pipeline architect | YAML lint + diagnosis |
| `pipeline_report_agent` | 🌍 **Atlas** | new | Global synthesiser | Aggregates 10 reports → 1 |

Full map: [`agents/AGENTS_IDENTITY.md`](agents/AGENTS_IDENTITY.md)

### ▶️ Run Agents Locally

```powershell
# Single agent against a real MR
py -3.13 -m agents.security_scanner --project-id 2202 --mr-iid 48

# Force regex-only (no Copilot, no network)
$env:COPILOT_ENABLED = "0"
py -3.13 -m agents.code_reviewer --project-id 2202 --mr-iid 48
```

### 📝 Agent Prompts

Each agent's `claude-sonnet-4.6` system instructions live as a Markdown file under [`agents/prompts/`](agents/prompts/) — fully editable, no recompile needed.

---

## 🧠 Copilot SDK / CLI Fallback

```text
 CopilotClient.__init__()
         │
   COPILOT_ENABLED == '0'? ──yes──► mode = disabled  (Layer 1 only)
         │ no
         ▼
   import copilot.CopilotClient  +  create_session(claude-sonnet-4.6)
         │
   import succeeded? ──yes──► mode = sdk  (JSON-RPC stdio, persistent)
         │ no
         ▼
   gh copilot installed? ──yes──► mode = cli  (gh copilot explain)
         │ no
         ▼
   mode = disabled  (Layer 1 only)
```

### 🤖 Model — Claude Sonnet 4.6

All 11 agents send their Layer-1 findings to **Anthropic Claude Sonnet 4.6** through the
GitHub Copilot API ([`agents/copilot_client.py:12`](agents/copilot_client.py#L12)).

| Aspect | Value |
|---|---|
| Provider | GitHub Copilot API (`COPILOT_GITHUB_TOKEN`) |
| Model ID | `claude-sonnet-4.6` |
| Vendor | Anthropic |
| Transport | JSON-RPC over stdio (SDK) or `gh copilot explain` (CLI) |
| Session | Persistent — reused across all Layer-2 calls within a job |
| Override | `COPILOT_MODEL` env var (defaults to `claude-sonnet-4.6`) |

### ⚙️ Environment Variables

| Variable | Default | Description |
|---|---|---|
| `COPILOT_GITHUB_TOKEN` | — | GitHub PAT. Falls back to `gh auth login` |
| `COPILOT_ENABLED` | `1` | Set to `0` for Layer-1 (regex/AST) only |
| `COPILOT_TIMEOUT` | `120` | Seconds before SDK/CLI call times out |
| `COPILOT_MODEL` | `claude-sonnet-4.6` | Override model name |

---

## 📧 Pipeline Email Automation

End-of-pipeline notification with **18+ attachments** (reports, charts, manifests) — recipient configured **only** via GitLab CI/CD Variables (no hardcoded emails).

```text
 ✅ MR pipeline success
       │
       ▼
  notify_pipeline_completion  (stage: deploy)
       │
       │  ── reads ──►  PIPELINE_NOTIFICATION_EMAIL   (required)
       │                SMTP_SERVER / SMTP_USER / SMTP_PASSWORD  (optional)
       │
       │  ── collects ──►  Anubis · Osiris · TIA-Python · Laika-Flutter
       │                   Cassandra · Themis · Hermes · Vostok
       │                   Rosetta · Phoenix · Atlas
       │                   + 5 PNG charts + manifest
       │
       ▼
  📩  HTML email (Outlook-safe) with 18+ attachments
```

Trigger setup:

```powershell
# Option A — GitLab UI: Settings → CI/CD → Variables
#   Key: PIPELINE_NOTIFICATION_EMAIL   Value: walid.abbassi@sagemcom.com

# Option B — automation script
.\tools\setup_gitlab_ci_variables.ps1 `
  -ProjectId 2202 `
  -Email walid.abbassi@sagemcom.com `
  -GitLabToken $env:GITLAB_TOKEN
```

Full guide: [`tools/PIPELINE_EMAIL_SETUP.md`](tools/PIPELINE_EMAIL_SETUP.md)

---

## 🔐 Licence System

A small AES-based licence module guards backend access — parsed once at startup, then enforced through `AuthenticationService`.

```text
 backend/license/
 ├── aes_cipher.py    # AES-CBC decrypt (key from env / config)
 └── parser.py        # XML payload → role + rights + expiry
```

Roles are propagated to Flutter via the `Authentication.Login` RPC and applied in [`flutter_app/lib/core/user_rights.dart`](flutter_app/lib/core/user_rights.dart).

---

## 📐 Spec-Driven Workflow

This project uses **[OpenSpec](https://github.com/Fission-AI/OpenSpec)** — a lightweight
proposal-driven workflow that lets Claude (Sonnet 4.6) reason about, scope, and validate
changes **before** they hit the code.

> ⚠️ The `openspec/` directory is **local-only** and **gitignored** ([`.gitignore:32-33`](.gitignore#L32-L33)).
> Specs are personal working artefacts, not shipped in the repo.

### Why OpenSpec here

| Need | How OpenSpec addresses it |
|---|---|
| Large refactors across Flutter + Python + CI | Spec captures cross-cutting impact before edits |
| Multi-agent CI changes (Osiris, Anubis, …) | Each agent change → one proposal → one review loop |
| Reviewer onboarding | Spec acts as living design doc when the PR opens |
| Drift between intent and implementation | `openspec validate` keeps task lists honest |

### Typical loop

```text
 1. openspec init                       # bootstrap local folder
 2. claude /openspec:proposal           # describe the change in plain English
 3. claude refines spec + task list
 4. claude implements iteratively       # ticking tasks as it goes
 5. openspec validate                   # gates the change before commit
 6. git commit -m "TV-11441: …"         # spec stays local, code ships
```

> 💡 OpenSpec pairs naturally with the **11 CI agents**: a spec describes the *intent*,
> the agents enforce the *invariants* (security, coverage, licences, docs) on the way in.

---

## ⚡ Quick Start

### 1. Prerequisites

| Tool | Version | Used by |
|---|---|---|
| Python | 3.13 | Backend, agents, CI tooling |
| Flutter SDK | 3.5.6+ | Desktop app |
| Inno Setup | 6.x | Windows installer (`setup.iss`) |
| `wkhtmltox` | bundled | PDF rendering |

### 2. Backend

```powershell
cd backend
py -3.13 -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
pip install ..\ng_sdk_whl\ng_sdk-0.1.0-py3-none-any.whl

# Run gRPC server (dev)
py server.py            # → listening on 127.0.0.1:50051

# Tests
py -m pytest tests/ -v --cov=. --cov-fail-under=80
```

### 3. Flutter App

```powershell
cd flutter_app
flutter pub get
flutter run -d windows
```

The Flutter app auto-launches `py_grpc_server.exe` via [`platform/python_launcher.dart`](flutter_app/lib/platform/python_launcher.dart). In dev, run `backend/server.py` separately.

### 4. Agents (local dry-run)

```powershell
$env:COPILOT_GITHUB_TOKEN = "ghp_..."
$env:GITLAB_TOKEN         = "glpat-..."
py -3.13 -m agents.code_reviewer --project-id 2202 --mr-iid 48
```

---

## 📦 Build & Installer

One-shot Windows build → `ViewerNG-Setup.exe`:

```powershell
.\build.ps1
```

The script ([`build.ps1`](build.ps1)) performs **11 steps**:

```text
 [1/11]  Clean + create build/
 [2/11]  PyInstaller — backend (py_grpc_server.exe)
 [3/11]  Copy backend dist → build/
 [4/11]  Bundle ng_sdk wheel + configuration JSON5
 [5/11]  Flutter build windows --release
 [6/11]  Copy Flutter Release/ → build/
 [7/11]  Copy templates/ (csv · pdf · xml · docx)
 [8/11]  Copy wkhtmltox/ (PDF engine)
 [9/11]  Strip dev artifacts
 [10/11] Inno Setup compile → ViewerNG-Setup.exe
 [11/11] Done.
```

Installer layout ([`setup.iss`](setup.iss)):

```text
 {pf}\SAGEMCOM\Viewer NG\
 ├── next_gen_viewer.exe       ← Flutter
 ├── py_grpc_server.exe        ← Python backend
 ├── _internal\wkhtmltox\
 ├── templates\{csv,pdf,xml,docx}\
 ├── configuration\
 ├── data\
 └── logs\
```

Cleanup helper:

```bat
Cleaner.bat       :: recursive __pycache__ removal
```

---

## 📑 User Guide

A complete end-user walkthrough is provided as a PowerPoint deck at the repository root:

📎 **[`SAGEMCOM - ViewerNG UserGuide.pptx`](SAGEMCOM%20-%20ViewerNG%20UserGuide.pptx)**

Covers:

- 🔐 First launch & licence activation
- 🔌 Meter connection (serial / modem / push)
- 📊 Reading data — Load Profile, Energy Register, Event Logs
- 🛠 Configuration push/pull & Super-Manual tool
- 📤 Exporting reports to CSV · PDF · XML · DOCX
- 🌐 DLMS / Gurux translator usage

> Recommended viewer: PowerPoint 2019+ or Microsoft 365 (embedded screenshots & animations).

---

## 📚 Documentation

| File | Content |
|---|---|
| [`SAGEMCOM - ViewerNG UserGuide.pptx`](SAGEMCOM%20-%20ViewerNG%20UserGuide.pptx) | 📑 End-user presentation — UI walkthrough |
| [`agents/AGENTS_IDENTITY.md`](agents/AGENTS_IDENTITY.md) | The 11-agent Pantheon — symbolic names, roles, missions |
| [`tools/PIPELINE_EMAIL_SETUP.md`](tools/PIPELINE_EMAIL_SETUP.md) | GitLab UI walkthrough + email troubleshooting |
| [`flutter_app/README.md`](flutter_app/README.md) | Flutter app — quick reference |
| `protos/*.proto` | gRPC contracts (source of truth) |
| `openspec/` *(local-only)* | OpenSpec proposals — gitignored personal workspace |

---

<div align="center">

**Viewer NG** — *DLMS made approachable.*
Built with 🐍 Python · 💙 Flutter · 🤖 AI Agents · ❤️ at SAGEMCOM

</div>
