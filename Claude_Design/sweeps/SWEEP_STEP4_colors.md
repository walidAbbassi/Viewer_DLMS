# SWEEP — Couleurs en dur → SemanticColors (étape 4)

Branche : `ui_ux_design` (Viewer_DLMS). À coller comme instruction à Claude Code.
Prérequis : étape 3 (SnackBar → feedback) appliquée.

═══════════════════════════════════════════════════════════════════
## OBJECTIF
Supprimer les couleurs codées en dur restantes (dark-mode manuel `Color(0xFF…)`,
`Colors.white`, `Colors.red.shade###` d'icônes/textes) et passer par le thème,
pour un rendu clair/sombre correct partout et un seul bleu de marque.

## RÈGLES DE MAPPING
Toujours via `final sc = SemanticColors.of(context);` (ou `Theme.of(context).colorScheme`).

| En dur actuel | Remplacer par |
|---|---|
| `DesignTokens.primary600` / `Color(0xFF1976D2)` / `Color(0xFF1565C0)` | `sc.primary` |
| `Color(0xFF60A5FA)` / `Color(0xFF1e3a6e)` (primaire dark) | `sc.primary` |
| `Colors.white` en `foregroundColor`/texte sur primaire | `sc.onPrimary` |
| `Colors.red` / `Colors.red.shade###` / `DesignTokens.danger` (icône/texte statut) | `sc.error` |
| `Colors.green` / `Colors.green.shade###` (icône/texte statut) | `sc.success` |
| `Colors.orange###` / `DesignTokens.warning` | `sc.warning` |
| `Color(0xFF0f172a)` / `Color(0xFF1e293b)` (fond dark) | `sc.background` / `sc.surface` |
| `Color(0xFF334155)` (bordure dark) | `sc.outline` |
| `Color(0xFF94A3B8)` / `Color(0xFFF1F5F9)` (texte dark) | `sc.onSurfaceVariant` / `sc.onSurface` |
| `Color(0xFFF5F5F5)` / `Color(0xFFEEEEEE)` (gris clair) | `sc.surfaceVariant` |
| `Color(0xFF6B7280)` (texte secondaire) | `sc.onSurfaceVariant` |

## PRINCIPE ANTI-RÉGRESSION
- Supprimer les branches `isDark ? const Color(0xFF…) : DesignTokens.…` : `SemanticColors`
  fournit déjà light **et** dark → une seule valeur `sc.<token>` remplace tout le ternaire.
- Ne PAS toucher aux couleurs **de données** intentionnelles (séries de graphes, palettes
  catégorielles calendar `calendar_controller.dart` lignes ~238-243) : ce sont des
  couleurs sémantiques de contenu, pas de l'UI chrome.
- `SemanticColors` n'a PAS de `primaryContainer` → utiliser `surfaceVariant`.

═══════════════════════════════════════════════════════════════════
## PROMPT À DONNER À CLAUDE CODE

> Sur `ui_ux_design`, remplace les couleurs UI codées en dur par `SemanticColors.of(context)`
> selon la table de mapping de `deliverables/SWEEP_STEP4_colors.md`. Traite par lots, un
> fichier à la fois, en commençant par les AppBar + gradients + branches `isDark ? Color(0xFF…)`.
> Ne touche pas aux palettes catégorielles de données (calendar_controller, séries de charts).
> Après chaque lot : `flutter analyze`. Priorité :
> 1. AppBar/gradient dark en dur : device_id, date_time, average, energy_register, quality,
>    configuration, meter_connexion (backgroundColor `Color(0xFF1e3a6e)`, foreground `Colors.white`).
> 2. Icônes/textes de statut `Colors.red.shade###` / `Colors.green.shade###` :
>    push_action, push_recovery, push_selective, push_setup, push_setup_server,
>    load_profile_status (213/214), connexion (1863).
> 3. Cartes/bordures/fonds dark `Color(0xFF0f172a|1e293b|334155|94A3B8|F1F5F9)` :
>    date_time, calendar_profiles, configuration.

═══════════════════════════════════════════════════════════════════
## ⚠ app.dart — unifier le bleu du thème (à faire dans ce sweep)
Le `appBarTheme` a un **3ᵉ bleu** : `Color(0xFF1e40af)` (light) / `Color(0xFF1e3a6e)` (dark),
différent de `SemanticColors.primary` (#1565C0) et du seed. Remplacer les deux
`appBarTheme.backgroundColor` par la primaire de la palette (et `foregroundColor` par
`onPrimary`). Idéalement aligner aussi `ColorScheme.fromSeed(seedColor:)` sur `#1565C0`
pour qu'il n'y ait qu'un seul bleu de marque dans toute l'app.

## VÉRIFICATION FINALE
- Basculer light ↔ dark sur chaque page : aucune surface blanche résiduelle, un seul bleu.
- `grep` de contrôle (doit tendre vers 0 hors données) :
  `Color(0xFF1976D2)`, `Color(0xFF60A5FA)`, `Colors.white` en foreground d'AppBar.
- Puis étape 5 : i18n (`supportedLocales`/`localeProvider` branchés sur les chaînes).
