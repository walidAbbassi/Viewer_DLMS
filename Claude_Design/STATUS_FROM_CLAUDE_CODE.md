# STATUS — depuis Claude Code (repo Viewer_DLMS)

Écrit par la session Claude **Code** pour le Claude **Design**. But : éviter les
allers-retours et ne pas re-migrer ce qui est déjà fait.
Branches à jour : `ui_ux_design` **et** `claude/github-account-connection-rn0vbe`
(les deux pointent sur le même HEAD).

Dernière mise à jour : commit `c969549` (+ Passe 1 SWEEP_STEP3 en cours).

## ✅ Déjà appliqué et poussé sur GitHub

### Commit `a947679` — passe de cohérence (fondations + pages)
Nouveaux `core/` : `theme/semantic_colors.dart`, `theme/app_icons.dart`,
`services/feedback_service.dart` (instance globale `feedback` + `appMessengerKey`
câblé dans `app.dart`), `widgets/app_button.dart` (primary/secondary/danger,
loading, expand), `widgets/read_only_value.dart` (label + SelectableText + copy),
`widgets/app_tabs.dart`, `widgets/breadcrumb.dart`, `widgets/app_header.dart`,
`util/value_format.dart`. Supprimés : `app_bottom_toolbar.dart`, `app_snackbar.dart`.

Pages **déjà migrées** (NE PAS refaire) :
- **device_id_page** ✅, **firmware_version_page** ✅, **date_time_page** ✅,
  **firmware_download_page** ✅, **event_logs_page** ✅, **quality_page** ✅,
  **app_scaffold_wrapper** ✅ (`AppBottomToolbar` → `AppHeader`).

### Commit `c969549` — PATCHES_STEP1 §1 + §2
- **average_page** ✅, **quality_page** ✅ (`_showErrorMessage`/`_showSnackBar`).

### Passe 1 (SWEEP_STEP3_snackbars) — en cours
- **template_config_page** ✅, **load_profile_page** ✅.
- Reste : fresnel_diagram, connexion, push_action, meter_connexion,
  energy_register, super_manual_tool, configuration, script_table, push_setup.

## ⚠️ Écart constaté vs SWEEP_STEP3_snackbars.md

Trois fichiers listés n'ont **aucune SnackBar** — à ne pas traiter dans ce sweep :
- `mobile_network_id_page.dart` — utilise `showDialog`, pas de SnackBar.
- `modem_config_page.dart` — utilise `showDialog`, pas de SnackBar.
- `push_setup_server_page.dart` — ni SnackBar ni showDialog trouvé.

Les numéros de ligne du document ne correspondaient à aucun `SnackBar(`/`showSnackBar`
dans ces 3 fichiers (vérifié par grep). Possible confusion avec un état antérieur ou
un autre fichier. Si un feedback utilisateur y est réellement souhaité, ce sera un
ajout, pas une migration.

## ⏸️ Reporté (ne PAS livrer en patch mécanique)

- **PATCHES_STEP1 §3 — calendar_profiles (constantes couleur)** : NON appliqué tel
  quel. Raisons : (1) les `const _cPrimary600 = …` sont **top-level** et utilisées
  dans ~12 méthodes hors `build()` ; (2) référence `_sc.primaryContainer`, **champ
  inexistant** dans notre `SemanticColors`.
  → Couvert par `CALENDAR_full_migration.md` (Option A : faire circuler `sc` en
  paramètre) — prévu en Passe 3 du runbook, pas encore fait.

## 📌 Rappels API réels du repo (pour que les patchs compilent)

- `SemanticColors` n'a **pas** de `primaryContainer` (utiliser `surfaceVariant`).
- `feedback` est une **instance globale** (`import '.../core/services/feedback_service.dart'`),
  appel : `feedback.error('msg')` — pas de `context`.
- Package interne : `flutter_python_grpc`.
- i18n : état actuel confirmé = rien de branché (`app.dart` n'a aucun
  `localizationsDelegates`/`supportedLocales`, `pubspec.yaml` a `intl` mais pas
  `flutter_localizations`). `STEP5_i18n.md` part donc bien d'une mise en place
  complète, pas d'un simple branchement.

## Cibles restantes (backlog, ordre du runbook)

Passe 1 (snackbars, en cours) → Passe 2 (couleurs en dur → SemanticColors,
`SWEEP_STEP4_colors.md`) → Passe 3 (calendar_profiles complet,
`CALENDAR_full_migration.md`) → Passe 4 (i18n, `STEP5_i18n.md`).
