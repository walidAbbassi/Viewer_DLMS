# SWEEP STEP 6 — Meter Connexion consistency + icon unification

Written by **Claude Design** (this project) for **Claude Code** to apply to
`walidAbbassi/Viewer_DLMS` (`ui_ux_design` branch), continuing the pass
documented in `Claude_Design/` (`STATUS_FROM_CLAUDE_CODE.md`,
`sweeps/PATCHES_STEP1.md`, `SWEEP_STEP3_snackbars.md`,
`SWEEP_STEP4_colors.md`, `CALENDAR_full_migration.md`, `STEP5_i18n.md`).

Source review: `Viewer NG UI/UX Design Review` (Claude Design project),
cross-checked against Viewer Legacy screenshots. Full findings + mockups in
that project; this file is the actionable patch list only.

## Context for Claude Code
- Read `docs/SPECS_UI.md` and `Claude_Design/STATUS_FROM_CLAUDE_CODE.md`
  first — this sweep assumes STEP 1–5 are already applied.
- Do **not** refactor beyond what's listed here. Same non-negotiables as
  every prior sweep: `SemanticColors`, `AppButton`, no hardcoded hex, no
  orange, green/red = status only.

## Patch 1 — `core/widgets/app_scaffold_wrapper.dart` (highest priority)
`_onRouteChanged()`'s "Not connected" SnackBar hardcodes
`backgroundColor: Colors.orange` directly — the framework wrapper itself
violates the rule the rest of the app was just migrated to follow.
- Replace the raw `SnackBar(... backgroundColor: Colors.orange ...)` with
  `feedback.warning('Not connected — please connect to a meter first.')`
  (see `core/services/feedback_service.dart` — same call pattern already
  used everywhere else).

## Patch 2 — `features/pages/meter_connexion_page.dart` (largest patch)
This page never migrated in STEP 1–5. It hardcodes hex colors per
light/dark branch (`#1e3a6e`, `#0f172a`, `#334155`, `#1E3A5F`, `#60A5FA`…)
and uses raw `ElevatedButton.icon` / `OutlinedButton.icon` instead of
`AppButton`. Two specific violations of `docs/SPECS_UI.md`:
- `_buildActionsPanel()`'s **Connect** button is styled with
  `DesignTokens.success` (green) as an *action* color — spec reserves
  green for status only.
- Its **Disconnect** button uses raw `Colors.red` instead of the danger
  semantic token.

Patch:
1. Replace `_buildActionsPanel()`'s Connect/Disconnect buttons with
   `AppButton.primary(label: 'Connect', icon: AppIcons.connect, ...)` and
   `AppButton.danger(label: 'Disconnect', icon: AppIcons.disconnect, ...)`.
2. Replace the `Configuration` `OutlinedButton.icon` with
   `AppButton.secondary(...)`.
3. Replace the page's own `AppBar` background
   (`isDark ? Color(0xFF1e3a6e) : DesignTokens.primary600`) and the
   `_card()` helper's hardcoded `Color(0xFF1e293b)` /
   `Color(0xFF334155)` with `SemanticColors.of(context).surface` /
   `.outline` (mirror the pattern already used in `device_id_page.dart`).
4. Add a `Breadcrumb(segments: ['Menu', 'Meter Connexion'])` above the
   page body — every migrated page should carry one per STEP 1.

## Patch 3 — icon system: single source of truth
`core/theme/app_icons.dart` (semantic icon map) and
`core/widgets/app_drawer.dart` (`_allMenuItems`, the nav rail) currently
hardcode two independent icon sets for the same concepts (e.g. `AppIcons
.deviceId` = `Icons.badge`, drawer's "Device ID" item = `Icons.badge_
outlined`).
1. Make `app_drawer.dart` import `AppIcons` and reference it by key
   instead of inlining `Icons.*` literals in `_allMenuItems`.
2. Once unified, swap every `AppIcons` value from mixed
   filled/outlined/rounded `Icons.*` to **Material Symbols Outlined**
   (already bundled with Flutter — no new dependency), one weight (400),
   one optical size (24). Suggested glyph map (old → new, same names as
   Material Symbols):
   - `AppIcons.read` → `download` (kept, already correct family)
   - `AppIcons.write` → `upload` (kept)
   - `AppIcons.deviceId` → `badge` (drop the drawer's `_outlined` variant)
   - `AppIcons.meter` → `electric_meter`
   - `AppIcons.calendar` → `calendar_month`
   - `AppIcons.eventLog` → `receipt_long`
   - `AppIcons.qualityParams` → `tune`
   - `AppIcons.firmwareUpgrade` → `system_update_alt`
   - `AppIcons.configuration` → `settings`
   - `AppIcons.disconnect` → `link_off`

## Patch 4 — communication retry dialog needs a Cancel
`core/widgets/app_scaffold_wrapper.dart`'s `_showOrUpdateRetryDialog()`
("Communication Warning" / attempt N of 3) has no user-facing cancel — it
only auto-dismisses after a silent 7s safety timer (`_kAutoCloseDelay`).
Add an explicit `TextButton(child: Text('Cancel'), onPressed:
_dismissRetryDialog)` inside the `AlertDialog.actions`, alongside the
existing spinner/message column. (Inspired by Viewer Legacy's "Receiving
Packets… Abort" pattern — legacy always pairs a busy spinner with a
visible way out.)

## Out of scope for this sweep
- `calendar_profiles_page.dart` full migration — tracked separately
  (see `Claude_Design/sweeps/CALENDAR_full_migration.md`).
- i18n — tracked in `STEP5_i18n.md`, still not wired.
- Per-attribute granular Read/Write on `manual_dlms_page.dart` /
  `super_manual_tool_page.dart` — flagged as a legacy-inspired idea worth
  keeping, not a regression, no patch required unless requested.

## Definition of done
- No `Colors.orange` / raw hex left in `app_scaffold_wrapper.dart` or
  `meter_connexion_page.dart`.
- Connect/Disconnect/Configuration on Meter Connexion all render through
  `AppButton`.
- `app_drawer.dart` has zero inline `Icons.*` — all icons resolve through
  `AppIcons`.
- Retry dialog has a working Cancel.
- Verified in both light and dark theme.
