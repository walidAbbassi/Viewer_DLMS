# Viewer_NG — UI/UX Conventions

Source of truth for how Viewer_NG's Flutter UI is styled and how feedback,
buttons, and read-only data are presented. Written as part of the July 2026
UI/UX consistency pass — see `docs/SPECS_UI.md` history and the app's design
review for the audit that motivated it.

## Colors

- Single source: `core/theme/semantic_colors.dart` (`SemanticColors`, a
  `ThemeExtension` wired into both the light and dark `ThemeData` in
  `app.dart`). Access it via `SemanticColors.of(context)`.
- No hardcoded `Color(0xFF…)` / `Colors.white` for feedback or button colors
  in pages — always go through `SemanticColors` (or `Theme.of(context)`).
- One primary blue (`#1565C0` light / `#90CAF9` dark). **No orange** in the
  semantic palette.
- Green (`success`) and red (`error`) are reserved for **status only** —
  never repurposed as a "this is the read button" or "this is the write
  button" color.

## Feedback

- All user-facing banners go through `FeedbackService`
  (`core/services/feedback_service.dart`):
  `FeedbackService.success/error/warning/info(context, message)`.
- The banner color is derived from the **type**, never passed in by the
  caller. This is what prevents a refusal like "Authorization: Denied" from
  rendering in a green "success" SnackBar (`app_snackbar.dart`).

## Buttons

- `core/widgets/app_button.dart` — `AppButton.primary` / `.secondary` /
  `.danger`.
  - `primary` — the screen's main action (Write / Connect / Activate).
  - `secondary` (outlined) — secondary action (Read / Configuration).
  - `danger` — destructive actions only.
- No orange buttons; green/red are not used as button colors (see above).

## Read-only data

- `core/widgets/read_only_value.dart` — `ReadOnlyValue(label, value)` shows
  a non-editable meter value as selectable text + a copy action, instead of
  a `TextField`-styled box that visually implies it can be edited.
- `TextField` is reserved for attributes that are actually `Set`-able.

## Tabs

- `core/widgets/app_tabs.dart` — `AppTabs`, a single pill-style tab bar.
  Used instead of ad hoc full-width `TabBar` bands so every page with tabs
  looks the same.

## Breadcrumb

- `core/widgets/breadcrumb.dart` — `Breadcrumb(segments: [...])`, for pages
  that need a trail (`Menu > Group > Page`). Kept consistent rather than
  present on some pages and absent on others.

## Value formatting

- `util/value_format.dart` — `formatValue(raw, unit, {decimals})` returns
  `—` when a value hasn't been read yet, otherwise the value with its
  resolved unit. Never leaks a placeholder like "0 unknown" into the UI.

## Navigation

- The grouped side rail (with search) is the single navigation surface.
  The old `AppBottomToolbar` (a second, overlapping navigation bar) has
  been removed; `core/widgets/app_header.dart` (`AppHeader`) now only
  surfaces what isn't already reachable from the rail: live connection
  status and a global Disconnect action.

## Known gaps (not yet migrated)

- `calendar_profiles_page.dart` is large (4500+ lines) and has only had its
  three orange "Read" buttons fixed to the primary blue; a full pass to
  `AppButton` is still open.
- i18n (`supportedLocales` / `localeProvider`) is not wired to the strings
  touched by this pass — the app-wide localization plumbing needs its own
  change.
