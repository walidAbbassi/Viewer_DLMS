# ÉTAPE 5 — Internationalisation (i18n)

Branche : `ui_ux_design` (Viewer_DLMS). Instruction pour Claude Code.

## CONSTAT (repo actuel)
- `app.dart` : **aucun** `localizationsDelegates` / `supportedLocales` / `locale`.
- `pubspec.yaml` : a `intl: ^0.19.0` mais **pas** `flutter_localizations` ni `flutter_gen`/l10n.
- Toutes les chaînes UI sont en anglais codé en dur (`'Read'`, `'Write'`, `'Loaded X fields'`…).
- Un sélecteur de langue (EN) existe visuellement mais n'est pas branché.

→ L'i18n est à **mettre en place**, pas juste à « brancher ». Faire en dernier (après steps 3-4)
car ça touche toutes les pages.

## PLAN
### 5a. Dépendances (pubspec.yaml)
```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0            # déjà présent

flutter:
  generate: true           # active la génération l10n
```
Créer `l10n.yaml` à la racine de flutter_app :
```yaml
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
```

### 5b. Fichiers ARB (lib/l10n/)
- `app_en.arb` (référence) + `app_fr.arb`. Démarrer par les libellés partagés les plus
  fréquents (boutons/statuts), pas tout d'un coup :
```json
{ "@@locale": "en",
  "actionRead": "Read", "actionWrite": "Write", "actionRefresh": "Refresh",
  "actionConnect": "Connect", "actionDisconnect": "Disconnect",
  "statusConnected": "Connected", "statusNotConnected": "Not connected",
  "msgLoadedFields": "Loaded {count} identification fields",
  "@msgLoadedFields": { "placeholders": { "count": { "type": "int" } } }
}
```

### 5c. Brancher dans app.dart (les DEUX MaterialApp : app + splash)
```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
// …
MaterialApp(
  locale: ref.watch(localeProvider),          // Riverpod, persist via shared_preferences
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  // …
)
```

### 5d. localeProvider (nouveau, core/state)
`StateNotifier<Locale>` persistant (`shared_preferences`, déjà en dépendance). Le sélecteur
de langue de l'en-tête pousse `setLocale(const Locale('fr'))` / `'en'`.

### 5e. Migration des chaînes (progressive, par page)
Remplacer `'Read'` → `AppLocalizations.of(context)!.actionRead`, etc. Prioriser les
composants partagés d'abord (`AppButton` labels passés par les pages, `AppHeader`
Connected/Disconnect), puis page par page.

## DoD
- Changement de langue live EN↔FR sans redémarrage, persistant au relancement.
- Zéro chaîne UI en dur dans les composants partagés + pages migrées.
- `flutter gen-l10n` + `flutter analyze` OK.

## État (Claude Code)
Non commencé — dernier de la file (Passe 4 du runbook), après snackbars/couleurs/calendar.
