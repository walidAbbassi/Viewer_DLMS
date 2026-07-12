# PATCHS — Étape 1 (feedback couleur + palette locale)

Branche : `ui_ux_design` (repo Viewer_DLMS). Appliquer tels quels dans Claude Code.
Notation : ▸ REMPLACER (bloc exact présent) → PAR.

Nom de package interne = `flutter_python_grpc` (cf. imports existants).

═══════════════════════════════════════════════════════════════════
## 1. average_page.dart
Objectif : erreur en rouge via `feedback`, succès via `feedback.success`, supprimer les couleurs en dur.

### 1a. Import — après la ligne
```dart
import '../../core/theme/design_tokens.dart';
```
▸ AJOUTER :
```dart
import '../../core/services/feedback_service.dart';
```

### 1b. SnackBar de succès — REMPLACER tout le bloc :
```dart
      if (mounted && registers.isNotEmpty) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('${registers.length} average values loaded'),
                ],
              ),
              backgroundColor: DesignTokens.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
      }
```
→ PAR :
```dart
      if (mounted && registers.isNotEmpty) {
        feedback.success('${registers.length} average values loaded');
      }
```

### 1c. SnackBar d'erreur — REMPLACER :
```dart
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ));
      }
```
→ PAR :
```dart
      if (mounted) {
        feedback.error(msg);
      }
```
> Les bandeaux `_error` internes (rouge sur `DesignTokens.danger`) peuvent rester : ce ne sont pas des SnackBar. Idéalement basculer plus tard sur `SemanticColors`.

═══════════════════════════════════════════════════════════════════
## 2. quality_page.dart
Objectif : router `_showErrorMessage` et `_showSnackBar` par `feedback` (fin de `Colors.red` / `Colors.green.shade700`).

### 2a. Import — après :
```dart
import '../../util/value_format.dart';
```
▸ AJOUTER :
```dart
import 'package:flutter_python_grpc/core/services/feedback_service.dart';
```

### 2b. _showErrorMessage — REMPLACER :
```dart
  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
  }
```
→ PAR :
```dart
  void _showErrorMessage(BuildContext context, String message) {
    feedback.error(message);
  }
```

### 2c. _showSnackBar — REMPLACER :
```dart
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }
```
→ PAR :
```dart
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    isError ? feedback.error(message) : feedback.success(message);
  }
```
> `formatValue` est déjà utilisé ici ✅ — rien à faire côté « 0 unknown ».
> Onglets (`TabBar` blanc) + boutons Read/Write → étape 2 (AppTabs / AppButton).

═══════════════════════════════════════════════════════════════════
## 3. calendar_profiles_page.dart — palette locale
Objectif : supprimer les constantes couleur maison, passer par `SemanticColors`.

### 3a. Imports — ajouter en haut :
```dart
import 'package:flutter_python_grpc/core/theme/semantic_colors.dart';
```

### 3b. REMPLACER le bloc de constantes (≈ lignes 17-28) :
```dart
  const _cPrimary600 = Color(0xFF1976D2);
  const _cPrimary50 = Color(0xFFE3F2FD);
  const _cSuccess = Color(0xFF4CAF50);
  const _cWarning = Color(0xFFFF9800);
  const _cDanger = Color(0xFFF44336);
  const _cInfo = Color(0xFF2196F3);
  const _cGray50 = Color(0xFFF5F5F5);
  const _cGray100 = Color(0xFFF5F5F5);
  const _cGray200 = Color(0xFFEEEEEE);
  const _cGray300 = Color(0xFFE0E0E0);
  const _cTextSec = Color(0xFF6B7280);
  const _cBg = Color(0xFFF7F9FC);
```
→ PAR (dérivé du thème, dans `build`/méthodes ayant `context`) :
```dart
    final _sc = SemanticColors.of(context);
    final _cPrimary600 = _sc.primary;
    final _cPrimary50  = _sc.primaryContainer;   // si défini, sinon _sc.surfaceVariant
    final _cSuccess    = _sc.success;
    final _cWarning    = _sc.warning;             // ⚠ plus d'orange 0xFFFF9800
    final _cDanger     = _sc.error;
    final _cInfo       = _sc.info;
    final _cGray50     = _sc.surfaceVariant;
    final _cGray100    = _sc.surfaceVariant;
    final _cGray200    = _sc.outline;
    final _cGray300    = _sc.outline;
    final _cTextSec    = _sc.onSurfaceVariant;
    final _cBg         = _sc.background;
```
> Fichier volumineux (180 Ko) : ces constantes sont réutilisées partout. Le plus sûr = les recalculer une fois dans `build()` et supprimer les `const` top-level. Retirer aussi les `Color(0xFF1976D2)` / `Colors.white` codés dans les boutons au fil de la migration.
> ⚠ `_cWarning` passait de l'orange (`0xFFFF9800`) au warning de la palette : c'est voulu (fin de l'orange hors-charte).
> **Note Claude Code (voir STATUS_FROM_CLAUDE_CODE.md)** : appliqué tel quel, ce patch ne compile
> pas — `_sc.primaryContainer` n'existe pas dans `SemanticColors`, et ces constantes sont utilisées
> hors `build()`. Traité à part dans `CALENDAR_full_migration.md` (Option A : `sc` en paramètre).

═══════════════════════════════════════════════════════════════════
## Après application
- `flutter analyze`
- Vérifier : plus aucune SnackBar verte pour une erreur ; test clair + sombre.
- Étape 2 ensuite : device_id / date_time (AppButton + ReadOnlyValue + AppTabs).
