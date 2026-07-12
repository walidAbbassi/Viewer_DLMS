# Skill — Viewer_NG UI/UX Consistency

Guide l'agent (Claude Code / spec-kit / OpenSpec) pour appliquer la passe de cohérence UI/UX de Viewer_NG **sans refondre** l'application. À invoquer quand on touche à une page Flutter (`flutter_app/lib/features/pages/**`) ou à un widget de `core/widgets/**`.

## Contexte projet
- App : Viewer_NG — client Flutter DLMS/COSEM (Windows / Linux / Android), backend Python gRPC (`:50051`).
- L'UI est **déjà moderne** (rail latéral groupé + recherche, onglets, états de chargement). Objectif : **cohérence**, pas refonte.
- Référence design : `docs/SPECS_UI.md`. Change associé : `Claude_Design/openspec/` (ou `openspec/changes/2026-07-11-ui-ux-consistency/`).

## Règles NON négociables

### Couleurs
- Interdit : `Color(0xFF…)`, `Colors.white`, orange, ou une couleur passée à la main à une bannière.
- Toujours via `Theme.of(context).colorScheme` ou `SemanticColors.of(context)`.
- Un seul bleu primaire : `#1565C0`. Vert/rouge = **statut uniquement**.

### Feedback
- Message utilisateur → `feedback.success/error/warning/info(msg)` (instance globale, sans `context`).
- La couleur découle du **type** de message, jamais d'un paramètre. Un refus/erreur n'est **jamais** vert.

### Boutons
- `AppButton.primary` = action principale (Write, Connect, Activate).
- `AppButton.secondary` (contour) = action secondaire (Read, Configuration).
- `AppButton.danger` = destructif seulement. Pas d'orange, pas de vert « action ».

### Données
- Donnée en lecture seule → `ReadOnlyValue` (texte + copie). `TextField` seulement si le champ est réellement `Set`.
- Affichage numérique → `formatValue(raw, unit)` : `—` si non lu, jamais « 0 unknown ».

### Navigation
- Une seule navigation : le rail. Pas de barre du bas.
- Actions de page dans l'en-tête ; Disconnect global dans l'en-tête.
- Navigation : `push` nommé (garder l'historique), pas `pushReplacementNamed`.

### Onglets & fil d'Ariane
- Onglets : composant unique `AppTabs` (style pilule). Pas de bande bleue pleine largeur.
- Fil d'Ariane : cohérent partout (présent ou absent), rendu par le shell.

### Dark mode & i18n
- Vérifier chaque écran modifié en mode sombre (aucune surface claire en dur).
- Chaînes visibles passées par la localisation (`supportedLocales`/`localeProvider`) — voir
  `Claude_Design/sweeps/STEP5_i18n.md` pour l'état (rien n'est encore branché).

## Procédure
1. Lire `docs/SPECS_UI.md` + `Claude_Design/STATUS_FROM_CLAUDE_CODE.md` (ce qui est déjà fait).
2. Repérer les écarts sur la page ciblée (couleurs en dur, SnackBar colorée, boutons orange, `TextField` read-only, onglets, breadcrumb, `0 unknown`).
3. Appliquer via les widgets `core/widgets/*` partagés ; ne pas dupliquer de style local.
4. Tester le rendu clair **et** sombre.
5. Cocher les tâches correspondantes dans `Claude_Design/openspec/tasks.md`.

## Definition of Done
- Aucune couleur en dur, aucun feedback de couleur erronée, une seule navigation, données read-only non éditables, onglets/breadcrumb cohérents, dark mode OK.

## API réelles du repo (à respecter, pas d'hypothèse)
- `SemanticColors` : champs `primary, onPrimary, secondary, success, warning, error, info,
  surface, surfaceVariant, background, onSurface, onSurfaceVariant, outline`. **Pas** de
  `primaryContainer`.
- `feedback` : instance globale, pas de `context` requis à l'appel.
- Package interne : `flutter_python_grpc`.
