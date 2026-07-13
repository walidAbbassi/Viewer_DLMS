# STATUS — Branche `ui_ux_design` (repo Viewer_DLMS)

Résumé de tout ce qui a été fait sur la branche `ui_ux_design`, destiné à être
partagé avec **d'autres comptes Claude Design & Claude Code** qui reprendraient
ce chantier. Écrit par une session Claude Code.

Dernier commit : `eed67f1` sur `ui_ux_design` (pushé sur GitHub ; `main` a été
fusionné jusqu'à `322130a` — voir Bloc 4 — mais **pas encore jusqu'à
`eed67f1`, la fusion de `main` reste à refaire** après ce commit).
Repo : https://github.com/walidAbbassi/Viewer_DLMS
Projet design source : https://claude.ai/design/p/8a32b677-2b52-4b62-9f26-02bee55faee0
Sweep STEP6 + ce sweep icônes/toolbar reçus via le projet
`1ee44508-26f1-42d0-8d48-7c599417abd6` (Viewer NG UI/UX Review).
**Tout le travail se fait désormais uniquement sur `ui_ux_design`** (consigne
explicite de l'utilisateur) — ne plus pousser sur
`claude/viewer-ng-ui-ux-review-m4t078` ni `claude/github-account-connection-rn0vbe`.

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

### Bloc 4 — SWEEP STEP6 : meter_connexion + icônes (`sweeps/SWEEP_STEP6_meter_connexion_and_icons.md`)
Reçu via le fichier `Claude_Design_sweeps/SWEEP_STEP6_meter_connexion_and_icons.md`
du projet design (même projet que la review `Viewer NG UI/UX Design Review`,
pas le projet de coordination `8a32b677` — celui-ci n'est pas accessible en
lecture directe par Claude Code, d'où le passage par ce fichier dans le même
projet). Appliqué sur la branche `claude/viewer-ng-ui-ux-review-m4t078`.

**Patch 1 — `app_scaffold_wrapper.dart`** : SnackBar `Colors.orange` codé en
dur remplacé par `feedback.warning(...)`. Le `ScaffoldMessenger.maybeOf(ctx)`
manuel a été supprimé (inutile, `feedback` gère déjà son propre
`clearSnackBars()`/`showSnackBar()` via `appMessengerKey`).

**Patch 2 — `meter_connexion_page.dart`** : boutons Connect/Disconnect/
Configuration migrés vers `AppButton.primary/.danger/.secondary` (icônes
`AppIcons.connect/.disconnect/.configuration`). AppBar et `_card()` migrés
vers `SemanticColors.of(context)` (`.primary`, `.surface`, `.outline`) au
lieu des hex codés en dur par branche light/dark. `Breadcrumb(segments:
['Menu', 'Meter Connexion'])` ajouté au-dessus du contenu. **Écart constaté** :
`device_id_page.dart` (cité en modèle par le sweep) n'a en fait *pas* migré
son AppBar non plus (toujours `isDark ? Color(0xFF1e3a6e) :
DesignTokens.primary600`) — `SemanticColors.of(context).primary` a été
utilisé directement plutôt que de copier ce pattern non migré. À corriger
dans une passe future sur `device_id_page.dart`.

**Patch 3 — icônes** : `app_drawer.dart` importe désormais `AppIcons` et
n'a plus aucune icône `Icons.*` codée en dur dans `_allMenuItems` (les
icônes de chrome structurel — menu, logout, chevrons, search, clear, le
bolt de marque — restent hors périmètre, ce ne sont pas des icônes de
domaine). La plupart des glyphes suggérés par le sweep étaient déjà corrects
dans `app_icons.dart` ; seul `AppIcons.calendar` a changé
(`Icons.event_note` → `Icons.calendar_month`, pour matcher exactement
l'icône déjà utilisée par le rail de nav). 17 constantes `AppIcons`
manquantes ont été ajoutées (mêmes glyphes que ceux déjà choisis par le
drawer, juste déplacés dans `AppIcons` : `meterConnexion`, `mobileNetworkId`,
`pushSetupServer`, `pushSetup`, `pushAction`, `scriptTable`,
`pushSelective`, `pushRecovery`, `superManual`, `exportTemplates`,
`dlmsTranslator`) — le sweep ne les listait pas car il ne couvrait que les
9 glyphes déjà nommés dans `AppIcons`, pas tout `_allMenuItems`.

**Patch 4 — dialogue de retry** : bouton `Cancel` (`TextButton` →
`_dismissRetryDialog`) ajouté aux `actions` de l'`AlertDialog`.

**Effet de bord sur les tests** : `meter_connexion_page_test.dart` cherchait
les boutons Connect/Disconnect par leurs anciennes icônes brutes
(`Icons.power`/`Icons.power_off`, ~20 occurrences). Mis à jour vers
`AppIcons.connect`/`AppIcons.disconnect`. Le bouton Configuration n'a pas eu
besoin de changement de test — `AppIcons.configuration` == `Icons.settings`,
déjà identique.

**Non vérifié** : `flutter analyze`/`flutter test` n'ont pas pu être
exécutés dans cet environnement (SDK Flutter absent du conteneur). Relecture
manuelle ligne à ligne des 5 fichiers modifiés + vérification croisée contre
les tests existants à la place. À faire tourner dans un environnement avec
le SDK avant de considérer cette passe définitivement close.

### Bloc 5 — Sweep icônes/toolbar sur toutes les pages restantes (commit `eed67f1`)
Suite du finding "single header" de la review (`step 4` de la séquence
recommandée). Périmètre : les 27 pages restantes de
`flutter_app/lib/features/pages/` (toutes sauf `meter_connexion_page.dart`,
déjà fait en STEP6, et `connexion_page.dart`, l'écran de login sans AppBar),
plus 2 widgets partagés.

**Décision prise après audit du code réel (Explore) : ne PAS retirer
l'AppBar de chaque page.** La formulation littérale de la review ("single
header") aurait impliqué de redessiner le placement des `TabBar` (9 pages
les portent via `AppBar.bottom`) et de reloger les callbacks page-locaux
(`ExportActionButton`/`RefreshAppBarButton` avec fermeture de flux gRPC,
capture de graphique, etc. — trop risqué pour une passe mécanique. À la
place, chaque `AppBar` existant est conservé tel quel (titre, actions,
tabs) et on ajoute seulement :
1. **Couleur** : `AppBar.backgroundColor` (`DesignTokens.primary600` ou
   ternaire dark-mode codé en dur, y compris un cas 100% hardcodé sans
   branche dark dans `load_profile_page.dart`) → `SemanticColors.of(context)
   .primary`.
2. **Breadcrumb** : `Breadcrumb(segments: [...])` ajouté au-dessus du body
   existant (même wrapper `Column([Padding(Breadcrumb), Expanded(<body
   original inchangé>)])` que celui utilisé sur `meter_connexion_page.dart`
   en STEP6), segments alignés sur les catégories du rail de nav
   (`app_drawer.dart`). **Exception** : `firmware_download_page.dart` a été
   exclu de ce point — sa propre `_buildHeader()` rend déjà un breadcrumb
   équivalent ("Menu > Firmware Upgrade > Firmware Download"), ajouter le
   widget partagé l'aurait dupliqué visuellement. Seule la couleur a été
   migrée sur cette page.
3. **Icônes des 2 widgets partagés** (touche 20+ pages sans éditer chaque
   fichier) : `RefreshAppBarButton`'s `Icons.refresh` → `AppIcons.refresh`
   (même glyphe, zéro impact visuel) ; `ExportActionButton`'s
   `Icons.upload_file` → `AppIcons.export` (= `Icons.ios_share`, changement
   de glyphe réel et volontaire).

**Exclu de cette passe** (documenté explicitement, pas un oubli) :
icônes de `TabBar` par page (trop nombreuses, pas de correspondance
`AppIcons` claire), icônes de format d'export XML/CSV/PDF/DOCX,
duplication `MeterStatusIndicator`/`AppHeader` du statut de connexion
(déjà présente avant ce sweep, nécessite une décision de design séparée),
retrait des `AppBar` par page.

**`gurux_translator_page.dart` exclu du décompte des 27 pages** — vérifié
via `app_routes.dart` : la route `/gurux_translator` (libellé du rail de
nav "DLMS Translator") pointe en réalité vers `DlmsTranslatorPage`
(`dlms_translator_page.dart`). La classe `GuruxTranslatorPage` de
`gurux_translator_page.dart` n'est référencée par aucune route ni appel de
navigation dans tout le code — fichier mort, non traité.

**Effet de bord sur les tests** : vérifié tous les tests pour des
assertions par icône (`find.byIcon`) sur `Icons.refresh` (aucun risque,
même valeur qu'`AppIcons.refresh`) et `Icons.upload_file` (un seul hit,
`calendar_profiles_page_test.dart:97` — mais cette page n'utilise pas du
tout `ExportActionButton`, seulement `RefreshAppBarButton` ; ce test était
déjà cassé/obsolète avant ce sweep, non lié à ce changement, laissé tel
quel). Aucune assertion structurelle fragile (`find.byType(...).first` sur
`Container`/`Column`/`Row`/`Padding`) trouvée dans la suite de tests — tous
les tests de cette codebase utilisent des finders par clé/texte/icône, pas
par position, donc le nouveau wrapping `Column`/`Expanded` du body de
chaque page n'a cassé aucun test connu.

**Non vérifié** (même limite que STEP6) : pas de SDK Flutter dans cet
environnement, donc `flutter analyze`/`flutter test` n'ont pas pu tourner.
Vérification faite par : relecture ligne à ligne de chaque diff (29
fichiers), script Python de comptage d'accolades/parenthèses/crochets sur
chaque fichier modifié comparé à sa version d'origine (`git show HEAD:...`)
pour confirmer qu'aucun déséquilibre n'a été introduit (2 déséquilibres de
parenthèses trouvés dans `configuration_page.dart` et
`fresnel_diagram_page.dart` — confirmés préexistants, pas causés par ce
sweep), et grep de chaque fichier pour confirmer imports/usages uniques
(pas de doublons). À faire tourner avec le vrai SDK avant de considérer
cette passe définitivement close.

## ⏸️ Reporté — pas encore fait

- **Passe 2 — couleurs en dur → SemanticColors** (`SWEEP_STEP4_colors.md`) :
  **le sous-ensemble `AppBar.backgroundColor` est fait** (Bloc 5, toutes les
  pages). Reste non fait : l'unification du 3ᵉ bleu d'AppBar dans `app.dart`
  (`Color(0xFF1e40af)`/`Color(0xFF1e3a6e)` → `sc.primary`), et les couleurs de
  bouton en dur (voir écart ci-dessus, à étendre à mobile_network_id/modem_config/
  push_setup_server) — ces boutons n'ont pas été touchés par le Bloc 5.
- **Passe 3 — calendar_profiles migration complète** (`CALENDAR_full_migration.md`) :
  pas commencée. Le patch mécanique initial (`PATCHES_STEP1.md` §3) ne compile pas
  tel quel — voir raisons ci-dessous. Seuls 3 boutons "Read" orange→bleu ont été
  corrigés (dans `a947679`) + AppBar color/Breadcrumb (Bloc 5), en attendant
  cette migration complète (boutons, onglets, SnackBar de cette page restent
  à migrer).
- **Passe 4 — i18n** (`STEP5_i18n.md`) : pas commencée. État confirmé du repo :
  `app.dart` n'a aucun `localizationsDelegates`/`supportedLocales`, `pubspec.yaml`
  a `intl` mais pas `flutter_localizations`. C'est une mise en place complète,
  pas un simple branchement.
- **Breadcrumb** : **fait sur 28/29 pages** (Bloc 5) — toutes sauf
  `connexion_page.dart` (login, pas d'AppBar) et `firmware_download_page.dart`
  (a déjà son propre breadcrumb hand-rolled, volontairement laissé tel quel
  pour ne pas dupliquer).
- **Retrait des AppBar par page au profit du seul AppHeader partagé** :
  décision explicite de ne PAS le faire (Bloc 5) — trop couplé aux `TabBar`
  et callbacks page-locaux pour une passe mécanique. Resterait un vrai
  chantier de redesign par page si souhaité.
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
