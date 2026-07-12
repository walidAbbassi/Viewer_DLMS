# RUNBOOK — Enchaînement des passes (Claude Code)

Branche : `ui_ux_design` (repo Viewer_DLMS). Package interne : `flutter_python_grpc`.
Exécuter les passes **dans l'ordre**, en committant + `flutter analyze` entre chacune.

Rappels API (pour que tout compile) :
- `feedback` est une **instance globale** → `feedback.error('msg')`, pas de `context`.
  Import : `package:flutter_python_grpc/core/services/feedback_service.dart`.
- `SemanticColors.of(context)` fournit light **et** dark. **Pas** de `primaryContainer`
  (utiliser `surfaceVariant`).
- Déjà faits — NE PAS refaire : device_id, firmware_version, date_time, firmware_download,
  event_logs, quality, average, app_scaffold_wrapper (→ AppHeader).

═══════════════════════════════════════════════════════════════════
## PROMPT UNIQUE À COLLER DANS CLAUDE CODE

> Travaille sur la branche `ui_ux_design`. Applique les 4 passes suivantes DANS L'ORDRE,
> avec un commit + `flutter analyze` (corrige les erreurs) après chaque passe. Ne re-migre
> pas les pages déjà faites (device_id, firmware_version, date_time, firmware_download,
> event_logs, quality, average). Respecte les rappels API : `feedback` global sans context ;
> `SemanticColors` sans `primaryContainer` (→ `surfaceVariant`).
>
> **PASSE 1 — SnackBar → feedback** (suivre `deliverables/SWEEP_STEP3_snackbars.md`)
> Remplace toutes les `SnackBar(backgroundColor:…)` par `feedback.success/error/warning/info`,
> couleur déduite du type de message (erreur/échec/Denied → error). Ne touche pas aux
> `color:` d'Icon/Text/Border. Commit « ui: snackbars via feedback service ».
>
> **PASSE 2 — couleurs en dur → SemanticColors** (suivre `deliverables/SWEEP_STEP4_colors.md`)
> Remplace les couleurs UI codées en dur (AppBar/gradient dark `Color(0xFF1e3a6e|0f172a|1e293b|334155|…)`,
> `Colors.white` en foreground, `Colors.red/green.shade###` d'icônes/textes de statut) par
> `SemanticColors.of(context)` selon la table de mapping. Unifie aussi le bleu d'AppBar de
> `app.dart` (light `0xFF1e40af` / dark `0xFF1e3a6e`) sur la primaire de la palette, et aligne
> `ColorScheme.fromSeed(seedColor:)` sur `#1565C0`. NE touche PAS aux palettes catégorielles
> de données (calendar_controller, séries de charts). Commit « ui: hardcoded colors → SemanticColors ».
>
> **PASSE 3 — calendar_profiles (migration complète)** (suivre `deliverables/CALENDAR_full_migration.md`)
> Fais circuler `SemanticColors sc` en paramètre des méthodes `_buildX`, supprime le bloc
> `const _c…` top-level, remplace onglets→`AppTabs`, boutons→`AppButton`, SnackBar→`feedback`,
> en gardant la palette de saisons/journées (couleurs de données). Commit « ui: migrate calendar_profiles ».
>
> **PASSE 4 — i18n** (suivre `deliverables/STEP5_i18n.md`)
> Ajoute `flutter_localizations` + `generate: true` + `l10n.yaml`, crée `app_en.arb`/`app_fr.arb`
> (boutons + statuts d'abord), branche `localizationsDelegates`/`supportedLocales`/`locale`
> dans les DEUX MaterialApp, crée un `localeProvider` persistant (shared_preferences) piloté
> par le sélecteur de langue de l'en-tête, puis migre les chaînes des composants partagés
> (AppButton labels, AppHeader) et des pages déjà traitées. `flutter gen-l10n` + `flutter analyze`.
> Commit « i18n: setup + EN/FR + shared components ».
>
> À la fin : pousse la branche et écris un court `STATUS_TO_DESIGN.md` (ce qui est fait /
> reste / éventuels blocages) pour le Claude Design.

═══════════════════════════════════════════════════════════════════
## CONTRÔLE APRÈS LES 4 PASSES
- `grep` doit tendre vers ~0 (hors données) : `backgroundColor: Colors.red`, `Color(0xFF1976D2)`,
  `Color(0xFF1e40af)`, `Colors.white` en foreground d'AppBar.
- Test light↔dark sur chaque page : pas de blanc résiduel, un seul bleu, plus d'orange.
- Bascule EN↔FR live + persistante.
