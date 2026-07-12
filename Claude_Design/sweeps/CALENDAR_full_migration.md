# MIGRATION COMPLÈTE — calendar_profiles_page.dart

Branche : `ui_ux_design`. Fichier ~180 Ko, le plus lourd. NE PAS faire en patch mécanique
(cf. STATUS_FROM_CLAUDE_CODE : constantes top-level utilisées hors `build()`).

## PROBLÈME
Bloc de `const _cPrimary600 = Color(0xFF1976D2)` … `_cBg` **top-level**, référencé dans
~12 méthodes qui n'ont pas `context`. On ne peut pas les passer en locales de `build()`
sans casser ces méthodes. En plus : palette locale ≠ `SemanticColors`, orange `_cWarning`
hors charte, `TabBar`/onglets maison, `Colors.white` en dur, `pushReplacementNamed`.

## STRATÉGIE (faire circuler le thème, pas des globales)
### Option A (recommandée) — passer `SemanticColors` en paramètre
1. Dans `build()` : `final sc = SemanticColors.of(context);`
2. Chaque méthode `_buildX(...)` qui utilisait `_cPrimary600` etc. reçoit `sc`
   en paramètre : `Widget _buildX(..., SemanticColors sc)`.
3. Remplacer dans le corps :
   `_cPrimary600→sc.primary`, `_cSuccess→sc.success`, `_cWarning→sc.warning` (fin de l'orange),
   `_cDanger→sc.error`, `_cInfo→sc.info`, `_cGray50/100→sc.surfaceVariant`,
   `_cGray200/300→sc.outline`, `_cTextSec→sc.onSurfaceVariant`, `_cBg→sc.background`,
   `_cPrimary50→sc.surfaceVariant` (⚠ PAS de `primaryContainer`).
4. Supprimer le bloc `const _c…` top-level.
5. Retirer les branches `_isDark ? const Color(0xFF…) : _c…` → `sc.<token>` unique
   (SemanticColors gère déjà light+dark).

### Onglets & boutons
- `TabBar` Day/Week/Season → `AppTabs` (import `core/widgets/app_tabs.dart`).
- Boutons `ElevatedButton(backgroundColor: Color(0xFF1976D2))` / `Colors.white` →
  `AppButton.primary` / `AppButton.secondary` (+ `AppIcons`).
- `Colors.white` de texte sur primaire → `sc.onPrimary`.

### Palette catégorielle (NE PAS toucher)
Les `Color(0xFF42A5F5)`, `Color(0xFF26A69A)`, `Color(0xFFEF5350)` … (lignes ~260-265)
sont les **couleurs de saisons/journées** du calendrier tarifaire : ce sont des couleurs
de **données**, à conserver telles quelles (éventuellement centraliser dans
`calendar_controller.dart` où la même palette existe déjà).

### SnackBar & navigation
- SnackBar restantes → `feedback.*` (cf. étape 3).
- `pushReplacementNamed` (s'il y en a) → `pushNamed`.

## VÉRIFICATION
- `flutter analyze` (surveiller les méthodes qui ont perdu l'accès aux ex-globales).
- Test light/dark : plus de blanc résiduel, un seul bleu, plus d'orange.
- Onglets = mêmes pilules que le reste de l'app.

## État (Claude Code)
Non appliqué à ce stade. Seuls les 3 boutons "Read" orange (héritage `_outlinedBtn`-like)
ont été corrigés en bleu primaire dans le commit `a947679`, en attendant cette migration
complète (Passe 3 du runbook).
