# Claude_Design — coordination Claude Code ↔ Claude Design

Ce dossier est le **point de coordination versionné** entre deux sessions Claude
Pro travaillant sur Viewer_NG :

- **Claude Code** (ce repo, `Viewer_DLMS`) — écrit le code Dart, commit, push.
- **Claude Design** (projet claude.ai/design `8a32b677-2b52-4b62-9f26-02bee55faee0`)
  — analyse les captures d'écran réelles, écrit les specs/patchs/runbooks.

Auparavant ces échanges ne vivaient que dans le projet design (privé, hors repo).
Ils sont recopiés ici pour que **n'importe quel compte Claude Pro** ouvrant ce
repo (Claude Code local, une autre session web, un autre collaborateur) ait le
même contexte sans devoir avoir accès au projet design.

## Comment ça marche

1. Le Claude Design lit les captures d'écran de l'app + le code (accès lecture
   GitHub) et écrit des specs/patchs dans son projet (`deliverables/*.md`).
2. Une session Claude Code lit ces documents (via l'outil DesignSync), les
   applique au code, commit + push sur GitHub.
3. Claude Code écrit un `STATUS_FROM_CLAUDE_CODE.md` (ici et dans le projet
   design) pour dire ce qui est fait / reporté / les contraintes réelles du repo.
4. Le Claude Design ajuste son prochain lot de patchs en conséquence.
5. Ce dossier est mis à jour à chaque échange notable pour que l'historique
   soit traçable depuis le repo, pas seulement depuis le projet design.

## Contenu

- `STATUS_FROM_CLAUDE_CODE.md` — état courant : ce qui est appliqué, reporté, les
  écarts d'API réels à respecter (ex. pas de `primaryContainer` dans
  `SemanticColors`, `feedback` est une instance globale sans `context`).
- `runbook/RUNBOOK_claude_code.md` — plan d'enchaînement en 4 passes (SnackBar,
  couleurs, calendar_profiles, i18n) écrit par Claude Design pour Claude Code.
- `sweeps/` — les instructions détaillées de chaque passe :
  `PATCHES_STEP1.md`, `SWEEP_STEP3_snackbars.md`, `SWEEP_STEP4_colors.md`,
  `CALENDAR_full_migration.md`, `STEP5_i18n.md`.
- `initial-package/` — le tout premier paquet de patchs (`README.md` +
  `PATCHES.md`) qui a lancé la passe de cohérence UI/UX.
- `openspec/` — `proposal.md` / `design.md` / `tasks.md` : la spec formelle du
  changement `2026-07-11-ui-ux-consistency`.
- `skill/viewer-ng-ui-consistency.md` — règles non négociables (couleurs,
  feedback, boutons, navigation, onglets, dark mode) à respecter pour toute
  page touchée.

## Projet design source

https://claude.ai/design/p/8a32b677-2b52-4b62-9f26-02bee55faee0

Le code Dart livrable réel vit dans `flutter_app/lib/` (déjà appliqué) — ce
dossier ne contient que la **documentation de coordination**, pas de code
dupliqué.
