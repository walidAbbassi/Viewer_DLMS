# Patchs par page — UI/UX Consistency

Diffs commentés à appliquer après avoir déposé les fichiers `core/` et `util/`.
Notation : `-` ligne à retirer, `+` ligne à ajouter. Chemins relatifs à `flutter_app/lib/`.

---

## 0. `app.dart` — brancher tokens + messenger

```dart
+ import 'core/theme/semantic_colors.dart';
+ import 'core/services/feedback_service.dart';

+ final messengerKey = GlobalKey<ScaffoldMessengerState>();
+ final feedback = FeedbackService(messengerKey);

  MaterialApp(
+   scaffoldMessengerKey: messengerKey,
    theme: ThemeData(useMaterial3: true, /* … */)
+       .copyWith(extensions: const [SemanticColors.light]),
    darkTheme: DarkTheme.build()
+       .copyWith(extensions: const [SemanticColors.dark]),
    /* … */
  )
```
> Exposer `feedback` via Riverpod/Provider (ou singleton) pour l'utiliser dans les pages.

---

## 1. `features/pages/device_id_page.dart` — read-only + boutons + Write réel

```dart
- // valeurs affichées dans des TextFormField (semblent éditables)
- TextFormField(controller: controller, decoration: InputDecoration(...))
+ ReadOnlyValue(label: fieldName, value: controller.text, feedback: feedback, monospace: true)

- FilledButton.icon(icon: Icon(Icons.refresh), label: Text('Read'),
-     style: FilledButton.styleFrom(backgroundColor: /* orange */))
+ AppButton.secondary(label: 'Read', icon: AppIcons.read, onPressed: _readIdentification)

- FilledButton.icon(icon: Icon(Icons.save), label: Text('Write'), style: /* vert */ )
+ AppButton.primary(label: 'Write', icon: AppIcons.write,
+     onPressed: (canSet && _hasUnsavedChanges) ? _showWriteConfirmDialog : null)
```
```dart
  Future<void> _writeIdentification() async {
-   // TODO: Appeler le backend pour écrire
-   await Future.delayed(const Duration(milliseconds: 500)); // faux succès
+   final ok = await _client.setDeviceId(valuesToWrite);   // appel réel
+   if (!ok) { feedback.error('Écriture refusée par le compteur'); return; }
+   feedback.success('Identité mise à jour');
  }
```
> Si l'API backend n'existe pas encore : **masquer** le bouton Write (`if (canSet && backendReady)`) plutôt qu'afficher un faux succès.

---

## 2. `features/pages/firmware_download_page.dart` — erreur en rouge

```dart
- ScaffoldMessenger.of(context).showSnackBar(
-   SnackBar(content: Text('Authorization: Denied'),
-            backgroundColor: DesignTokens.success)) // ← vert, trompeur
+ feedback.error('Authorization: Denied');           // ← rouge
```
> Retirer les constantes locales `cPrimary600 = 0xFF1976D2` etc. et utiliser `SemanticColors.of(context)`.

## 2bis. `features/pages/event_logs_page.dart` (Fraud Detection) — idem

```dart
- SnackBar(..., backgroundColor: DesignTokens.success) // pour un refus
+ feedback.error(msg);
```

---

## 3. `features/pages/date_time_page.dart` — onglets + controllers + bornes

```dart
- bottom: TabBar(controller: _tabController, /* bande bleue pleine largeur */)
+ // dans le body, au-dessus du contenu :
+ AppTabs(items: const [AppTabItem(label:'Clock Setting', icon: AppIcons.clock),
+                       AppTabItem(label:'Daylight Savings', icon: AppIcons.daylightSavings)],
+         index: _tab, onChanged: (i)=>setState(()=>_tab=i))
```
```dart
  Widget _buildNumberField(...) {
-   controller: TextEditingController(text: value.toString()), // recréé à chaque build
+   controller: _ctrlFor(key),  // contrôleur persistant, créé dans initState / cache
    onChanged: (val) {
      final n = int.tryParse(val);
-     if (n != null && n >= min && n <= max) onChanged(n); // rejet silencieux
+     if (n == null) return;
+     if (n < min || n > max) { feedback.warning('Valeur hors bornes [$min, $max]'); return; }
+     onChanged(n);
    },
  }
```

---

## 4. `core/widgets/app_scaffold_wrapper.dart` — navigation unique

```dart
- return Column(children: [
-   Expanded(child: child),
-   AppBottomToolbar(isConnected: isConnected, onDisconnect: ...), // barre du bas
- ]);
+ return child; // le rail latéral suffit ; actions + Disconnect passent dans l'en-tête
```
> Ajouter le Disconnect global et les actions de page dans `app_header.dart`.
> Supprimer `core/widgets/app_bottom_toolbar.dart`.
> Remplacer `pushReplacementNamed` par `pushNamed` pour garder un historique.

---

## 5. Pages Quality (Neutral, Sag, Swell, THD…) — formatValue

```dart
- Text('${item.value} ${item.unit}')   // -> "0 unknown"
+ Text(formatValue(item.value, unit: item.unit, scaler: item.scaler))
```

---

## 6. Icônes (rail + en-têtes) — `app_icons.dart`

Remplacer les `Icons.*` génériques par la clé métier correspondante, ex :
`Meter Connexion → AppIcons.connection`, `Energy Register → AppIcons.energyRegister`,
`PQ Profile → AppIcons.pqProfile`, `Fraud Detection → AppIcons.fraud`,
`Firmware Download → AppIcons.firmwareUpgrade`, `SIM Config → AppIcons.sim`,
`Sag → AppIcons.sag`, `Swell → AppIcons.swell`, `THD → AppIcons.thd`.

## État (Claude Code)
§0, §1, §2, §2bis, §3, §4 appliqués (commit `a947679`), avec un écart assumé :
`FeedbackService` a été implémenté en **instance globale** (`feedback.error('msg')`,
sans passer `context` ni `feedback:` explicitement à chaque widget) plutôt qu'injectée
par constructeur — plus simple à appeler depuis n'importe quelle page.
§5 appliqué sur `quality_page.dart`. §6 (mapping icônes du rail) pas encore fait.
