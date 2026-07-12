# STATUS — Branche `ui_ux_design` (repo Viewer_DLMS)

Résumé de tout ce qui a été fait sur la branche `ui_ux_design`, destiné à être
partagé avec **d'autres comptes Claude Design & Claude Code** qui reprendraient
ce chantier. Écrit par une session Claude Code.

Branches à jour (même HEAD) : `ui_ux_design` **et** `claude/github-account-connection-rn0vbe`.
Dernier commit : `834a9e5`.
Repo : https://github.com/walidAbbassi/Viewer_DLMS
Projet design source : https://claude.ai/design/p/8a32b677-2b52-4b62-9f26-02bee55faee0

## Historique des commits (du plus ancien au plus récent)

| Commit | Contenu |
|---|---|
| `a947679` | Fondations : `SemanticColors`, `AppIcons`, `FeedbackService`, `AppButton`, `ReadOnlyValue`, `AppTabs`, `Breadcrumb`, `AppHeader`, `formatValue`. Suppression `AppBottomToolbar`/`AppSnackBar`. 7 pages migrées (voir ci-dessous). |
| `c969549` | PATCHES_STEP1 §1+§2 : `average_page`, `quality_page` → `feedback.*`. |
| `e20f874` | Ajout du dossier `Claude_Design/` (coordination versionnée, ce fichier inclus). |
| `42ff308` → `bc7adc2` | Passe 1 (sweep SnackBar → feedback) sur 16 fichiers, par lots successifs. |
| `8150100`, `834a9e5` | Corrections d'imports/blocs manqués découverts après coup. |

## ✅ État final — ce qui est fait

### Bloc 1 — Fondations (commit `a947679`)
Nouveaux fichiers `flutter_app/lib/core/` :
- `theme/semantic_colors.dart` — palette unique (light+dark), plus d'orange.
- `theme/app_icons.dart` — vocabulaire d'icônes DLMS/COSEM.
- `services/feedback_service.dart` — **instance globale** `feedback`, adossée à
  `appMessengerKey` (`GlobalKey<ScaffoldMessengerState>`) câblé dans
  `MaterialApp(scaffoldMessengerKey:)` (`app.dart`). Appel : `feedback.error('msg')`
  — **pas de `context`**. Couleur dérivée du type (success/error/warning/info),
  jamais passée en paramètre.
- `widgets/app_button.dart` — `AppButton.primary/.secondary/.danger`, + `loading`/`expand`.
- `widgets/read_only_value.dart` — label + `SelectableText` + copier (pas de `TextField`).
- `widgets/app_tabs.dart` — onglets pilule uniques.
- `widgets/breadcrumb.dart` — fil d'Ariane partagé (widget créé, pas encore rendu
  par le shell partout).
- `widgets/app_header.dart` — remplace `AppBottomToolbar` : statut connexion +
  bouton Disconnect global (toujours visible, désactivé si non connecté).
- `util/value_format.dart` — `formatValue(raw, unit, {decimals})` → `—` si non lu.

Supprimés : `core/widgets/app_bottom_toolbar.dart` (+ son test), `core/widgets/app_snackbar.dart`.

**Pages migrées dans ce commit** (ne pas re-migrer) :
`device_id_page`, `firmware_version_page` (champs → `ReadOnlyValue`, bouton Write
masqué — backend non branché), `date_time_page` (`AppTabs`, controllers persistants,
feedback hors-bornes), `firmware_download_page` (fix "Authorization: Denied"/"Transfer
not authorized" vert→rouge), `event_logs_page`, `quality_page` (+ `formatValue`),
`app_scaffold_wrapper` (→ `AppHeader`).

### Bloc 2 — PATCHES_STEP1 §1+§2 (commit `c969549`)
`average_page`, `quality_page` (`_showErrorMessage`/`_showSnackBar`) → `feedback.*`.

### Bloc 3 — Passe 1 complète : SnackBar → feedback (commits `42ff308`…`834a9e5`)
**16 fichiers migrés**, toutes les `SnackBar(backgroundColor: ...)` remplacées par
`feedback.success/error/warning/info(...)` :
`template_config_page`, `load_profile_page`, `fresnel_diagram_page`, `connexion_page`,
`push_action_page`, `meter_connexion_page`, `energy_register_page`,
`super_manual_tool_page`, `configuration_page`, `script_table_page`,
`push_setup_page` (le plus gros : 24 occurrences).

**Vérifié par grep sur tout `features/pages/`** : plus aucune SnackBar codée en dur
(`backgroundColor: Colors.red/green` ou `DesignTokens.success/danger`) dans un
`SnackBar(...)`. Les occurrences restantes de ce pattern sont des **styles de
bouton** (`FilledButton`/`ElevatedButton.styleFrom(backgroundColor:...)`) —
hors scope de cette passe, à traiter en Passe 2.

## ⚠️ Écarts constatés vs les documents du Claude Design (important à corriger)

1. **3 fichiers mal catégorisés dans `SWEEP_STEP3_snackbars.md`** — listés comme
   ayant des SnackBar, mais en réalité ce sont des **couleurs de bouton** :
   - `mobile_network_id_page.dart` (lignes 807/822 réelles = `FilledButton.styleFrom`)
   - `modem_config_page.dart` (789/1051/1114/1486/1544 réelles = `FilledButton.styleFrom`)
   - `push_setup_server_page.dart` (200/223 réelles = `ElevatedButton.styleFrom`)
   → **Ne pas les traiter en Passe 2 "couleurs" comme prévu par `SWEEP_STEP4_colors.md`
   (ils n'y sont pas listés), il faudra les y ajouter.**
2. `event_logs_page.dart` était déjà migré avant le sweep (fait dans `a947679`) —
   le document `SWEEP_STEP3_snackbars.md` le listait comme à faire.

## ⏸️ Reporté — pas encore fait

- **Passe 2 — couleurs en dur → SemanticColors** (`SWEEP_STEP4_colors.md`) : pas
  commencée. Comprend l'unification du 3ᵉ bleu d'AppBar dans `app.dart`
  (`Color(0xFF1e40af)`/`Color(0xFF1e3a6e)` → `sc.primary`), et les couleurs de
  bouton en dur (voir écart ci-dessus, à étendre à mobile_network_id/modem_config/
  push_setup_server).
- **Passe 3 — calendar_profiles migration complète** (`CALENDAR_full_migration.md`) :
  pas commencée. Le patch mécanique initial (`PATCHES_STEP1.md` §3) ne compile pas
  tel quel — voir raisons ci-dessous. Seuls 3 boutons "Read" orange→bleu ont été
  corrigés (dans `a947679`), en attendant cette migration complète.
- **Passe 4 — i18n** (`STEP5_i18n.md`) : pas commencée. État confirmé du repo :
  `app.dart` n'a aucun `localizationsDelegates`/`supportedLocales`, `pubspec.yaml`
  a `intl` mais pas `flutter_localizations`. C'est une mise en place complète,
  pas un simple branchement.
- **Breadcrumb** : widget créé mais pas rendu par le shell pour toutes les pages.
- **Historique de navigation** : `pushReplacementNamed` pas encore remplacé par
  `pushNamed`.

## 🚫 Pourquoi PATCHES_STEP1 §3 (calendar_profiles) n'a pas été appliqué tel quel

1. Les `const _cPrimary600 = Color(0xFF1976D2)` … `_cBg` sont **top-level**,
   référencées dans ~12 méthodes qui n'ont pas `context` — les passer en locales
   de `build()` casse la compilation de ces méthodes.
2. Le patch référence `_sc.primaryContainer`, **champ inexistant** dans notre
   `SemanticColors` (champs réels : `primary, onPrimary, secondary, success,
   warning, error, info, surface, surfaceVariant, background, onSurface,
   onSurfaceVariant, outline`).

→ Stratégie retenue (documentée dans `CALENDAR_full_migration.md`, Option A) :
faire circuler `SemanticColors sc` en paramètre des méthodes `_buildX(...)`,
supprimer le bloc top-level, ne pas toucher à la palette catégorielle de données
(saisons/journées du calendrier tarifaire).

## 📌 Rappels API réels du repo (pour que tout patch futur compile)

- `SemanticColors` n'a **pas** de `primaryContainer` → utiliser `surfaceVariant`.
- `feedback` est une **instance globale**, pas de `context` requis à l'appel.
  Import : `../../core/services/feedback_service.dart` (chemin relatif) ou
  `package:flutter_python_grpc/core/services/feedback_service.dart`.
- Package interne : `flutter_python_grpc`.
- `AppButton` : enum public `AppButtonVariant`, constructeurs `.primary/.secondary/.danger`,
  params `loading`/`expand`.
- `ReadOnlyValue` : `label`, `value`, `monospace` — pas de paramètre `feedback:`
  (il utilise l'instance globale en interne).

## Diff global de la branche (vs `main`)

47 fichiers changés, ~1970 insertions / ~1978 suppressions (le solde net est
faible : beaucoup de code retiré — dialogues, SnackBar dupliquées — remplacé
par des appels courts aux composants partagés).

## Prochaines étapes suggérées (ordre)

1. Passe 2 — couleurs en dur → SemanticColors (`SWEEP_STEP4_colors.md`), en
   ajoutant mobile_network_id/modem_config/push_setup_server à son périmètre.
2. Passe 3 — calendar_profiles complet (`CALENDAR_full_migration.md`).
3. Passe 4 — i18n (`STEP5_i18n.md`).
4. Breadcrumb généralisé + `pushNamed` partout.
