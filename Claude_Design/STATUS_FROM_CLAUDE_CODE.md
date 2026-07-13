# STATUS — Branche `ui_ux_design` (repo Viewer_DLMS)

Résumé de tout ce qui a été fait sur la branche `ui_ux_design`, destiné à être
partagé avec **d'autres comptes Claude Design & Claude Code** qui reprendraient
ce chantier. Écrit par une session Claude Code.

Dernier commit : `5c1bdf2` sur `ui_ux_design` (pushé sur GitHub). `main` a été
fusionné jusqu'à `eed67f1`/`b70c8ec` (le sweep icônes/toolbar sur les 27
pages) mais **pas encore jusqu'à `5fd2f5b`/`214d340`/`f29e5d2`/`5c1bdf2`**
(SWEEP STEP7 Phase 1, STEP8, les restes de Passe 2, et Passe 3
calendar_profiles ci-dessous) — fusion à refaire si souhaité.
Repo : https://github.com/walidAbbassi/Viewer_DLMS
Projet design source : https://claude.ai/design/p/8a32b677-2b52-4b62-9f26-02bee55faee0
Sweep STEP6, le sweep icônes/toolbar (27 pages), SWEEP STEP7 et SWEEP
STEP8 reçus via le projet `1ee44508-26f1-42d0-8d48-7c599417abd6`
(Viewer NG UI/UX Review).
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

### Bloc 6 — SWEEP STEP7 Phase 1 : toolbar persistante (commit `5fd2f5b`)
Reçu via `Claude_Design_sweeps/SWEEP_STEP7_persistent_toolbar.md` +
`RUNBOOK_STEP6_claude_code.md` (même projet design). Le mockup HTML montre
l'intention ; le spec texte dit explicitement de faire confiance à sa
logique plutôt qu'au glyphe exact du mockup — suivi à la lettre.

**Découvertes avant d'implémenter (le spec ne le savait pas)** :
- `core/widgets/app_toolbar.dart` (`AppToolbar`) existait déjà mais
  **n'était instancié nulle part dans l'app** — code mort. Reconstruit
  entièrement plutôt que d'ajouter un nouveau widget, conformément à la
  consigne du spec.
- Aucun champ "modèle de compteur" n'existe dans `AppState`. Le "T310
  STEG" du mockup vient de `DeviceIdCache.data['Model']` (nom de champ
  confirmé réel via `device_id_page_test.dart`) — vide tant que
  l'utilisateur n'a pas visité Device ID au moins une fois.
- L'i18n n'existe **toujours pas du tout** (0 hit `flutter_localizations`/
  `localizationsDelegates`/`supportedLocales`/`localeProvider`). Le spec
  suppose que la Passe 4 est faite — elle ne l'est pas. Le sélecteur de
  langue est donc **visuel uniquement** : `language_selector_widget.dart`
  (auparavant un stub 0 octet) toggle EN/FR, persiste via
  `SharedPreferences`, chargé au démarrage (`app.dart` `initState` →
  `loadPersistedLanguage()`) — mais ne retraduit aucune chaîne.
- `AppHeader` était la **seule** action Disconnect sur toutes les routes
  sauf `meter_connexion`. La liste d'actions du spec ne mentionne pas
  Disconnect — si on l'avait suivie à la lettre, remplacer `AppHeader` par
  la nouvelle toolbar aurait supprimé le déconnexion partout. **Préservé
  volontairement** dans la nouvelle toolbar, non listé par le spec.
- Même chose pour le toggle du panneau de logs (auparavant sur
  `RefreshAppBarButton`) — préservé pour ne pas perdre une fonctionnalité
  existante.
- Le rail de nav a déjà son propre bouton Sign out qui fonctionne — la
  section username/rôle/logout de l'ancien `AppToolbar` mort n'a pas été
  reportée (aurait dupliqué, même problème que STEP6 avec le statut
  connexion).
- **Position corrigée** : `AppHeader` se rendait en bas de l'écran (dernier
  enfant de la `Column`, vestige du nom historique `AppBottomToolbar` selon
  `docs/SPECS_UI.md`). Le mockup montre la toolbar en haut, sous l'AppBar
  bleue de chaque page. Déplacé en conséquence — sinon la nouvelle toolbar
  aurait hérité de la mauvaise position sans le dire.
- **Refresh** : générique dans le nouveau design (pas lié à une page), mais
  chaque page garde encore son propre `RefreshAppBarButton` avec sa vraie
  logique de rechargement (page-spécifique, parfois avec teardown gRPC).
  Le Refresh de la nouvelle toolbar est donc un placeholder honnête (affiche
  un message expliquant d'utiliser le refresh de la page) plutôt que de
  faire semblant de recharger quelque chose — le vrai câblage attend la
  Phase 2 (retrait des AppBar par page, non fait, gros chantier séparé —
  9 pages couplent leur `TabBar` à `AppBar.bottom`, ~20 pages ont des
  callbacks Export/Refresh page-locaux).

**Tests mis à jour** : les deux fichiers `app_scaffold_wrapper_test.dart`
(`test/core/widgets/` et `test/widgets/`, deux fichiers de test distincts
et non dupliqués trouvés pendant la vérification) référençaient `AppHeader`
via `find.byType`/`tester.widget<AppHeader>`. `AppToolbar` étant un
`ConsumerWidget` qui lit `isConnected` en interne (pas un paramètre de
constructeur comme `AppHeader`), les tests qui vérifiaient
`toolbar.isConnected` ont été réécrits pour vérifier l'icône de statut
rendue (`find.byIcon(AppIcons.connected/.disconnected)`) plutôt qu'une
propriété de widget. Le groupe de tests `AppHeader` autonome (qui
instancie `AppHeader` directement, sans passer par `AppScaffoldWrapper`)
n'a pas été touché — `AppHeader` existe toujours tel quel, juste plus
monté nulle part par l'app.

**Non vérifié** (même limite que les sweeps précédents) : pas de SDK
Flutter dans cet environnement.

### Bloc 7 — SWEEP STEP8 : glyphes domaine dans AppIcons (commit `214d340`)
Reçu via `Claude_Design_sweeps/SWEEP_STEP8_domain_icons.md`. Édition
mono-fichier de `core/theme/app_icons.dart` — clés et sites d'appel
inchangés (le sweep le demandait explicitement), donc aucun autre fichier
touché ; le rail de nav et `AppToolbar` récupèrent le changement
automatiquement puisqu'ils lisent déjà `AppIcons` (STEP6/7).

**Décision de prudence** : le sweep lui-même signale 4 glyphes comme
"relativement récents" (`vital_signs`, `cell_tower`, `monitoring`,
`switch_access_shortcut`) et fournit des fallbacks explicites en cas
d'absence de la police Material Icons pour la version Flutter du projet.
Cet environnement n'a pas de SDK Flutter pour vérifier — plutôt que de
deviner et risquer une erreur de compilation sur un fichier à 100+ sites
d'appel, **les 4 fallbacks documentés par le sweep ont été appliqués
systématiquement** :
- `pqProfile`/`powerQualityLog` : `vital_signs` → `monitor_heart` (les
  deux — préserve le partage de glyphe voulu par le sweep entre ces deux
  clés, juste avec un glyphe plus sûr).
- `communicationLog`/`modem` : `cell_tower` → `sync_alt` (les deux, même
  logique).
- `qualityParams`/`loadProfile` : `monitoring` → `show_chart` (les deux,
  même logique).
- `disconnector` : `switch_access_shortcut` → `toggle_on` (seule clé sur ce
  glyphe, donc le fallback revient à ne rien changer).

**Effet net** : `loadProfile`, `powerQualityLog`, `communicationLog` et
`disconnector` finissent par ne pas changer du tout (le fallback = valeur
d'origine) — volontaire et documenté ici, pas un oubli. Vraiment changés :
`qualityParams`, `sag`, `swell`, `overcurrent`, `neutral`,
`energyRegister`, `ctvt`, `instant`, `average`, `profileStatus`,
`pqProfile`, `modem`, `pushSetupServer`.

**Collision intentionnelle notée** : `average` (`ssid_chart`) et `thd`
(`ssid_chart`, déjà existant, non touché) partagent maintenant le même
glyphe — c'est ce que demandait le sweep, signalé ici pour traçabilité,
pas un bug.

**Tests** : grep sur toute la suite de tests pour les anciens glyphes
littéraux (`Icons.tune`, `Icons.trending_down/up`, `Icons.transform`,
`Icons.electric_bolt`, `Icons.stacked_line_chart`, `Icons.router`,
`Icons.dns_outlined`, `Icons.playlist_add_check`, `Icons.graphic_eq`,
`Icons.flash_on`) — un seul hit (`Icons.electric_bolt` dans
`app_drawer_test.dart`), confirmé sans rapport (teste le logo de marque
"Viewer_NG" du rail de nav, une icône codée en dur séparément, pas
`AppIcons.instant`). Aucune mise à jour de test nécessaire.

**À vérifier avec le vrai SDK** (le sweep le demande explicitement) : que
les 4 fallbacks appliqués ici étaient bien nécessaires — si la police
Material Icons du projet supporte en fait `vital_signs`/`cell_tower`/
`monitoring`/`switch_access_shortcut`, le Claude Design peut redemander les
glyphes originaux en confirmant que `flutter analyze` passe avec eux.

### Bloc 8 — Passe 2, derniers restes (commit `f29e5d2`)
Fait de ma propre initiative (pas de nouveau sweep du projet design) en
reprenant la liste "Reporté" de ce document. Ferme les deux derniers points
de "Passe 2 — couleurs en dur → SemanticColors".

**`app.dart` — 3ᵉ bleu d'AppBar** : `Color(0xFF1e40af)` (utilisé 3 fois :
les deux seeds `ColorScheme.fromSeed` light/dark, et `AppBarTheme
.backgroundColor` global) → `SemanticColors.light.primary`. Une seule
source de vérité au lieu d'un hex dupliqué. `test/app_test.dart` mis à jour
(il vérifiait la valeur hex exacte).

**Boutons codés en dur sur les 3 pages identifiées dans l'écart signalé
précédemment** :
- `mobile_network_id_page.dart` — son helper `_actionButton` (Read/Write)
  codait **orange en dur pour Write** (violation directe de la règle "no
  orange") et un bleu approximatif pour Read. Migré vers
  `AppButton.primary`/`.secondary` + `AppIcons.write`/`.read`. Aussi migré
  Activate/Deactivate/Restart/Refresh (`DesignTokens.success`/`danger`
  comme couleur d'action — même violation que Connect/Disconnect corrigée
  en STEP6) vers `AppButton.primary`/`.danger`/`.secondary`, et le bouton
  de confirmation du dialogue "Restart Modem" (`FilledButton` brut) vers
  `AppButton.primary`. La légende de badges technologie (GSM/GPRS/LTE/
  NB-IoT, une couleur chacun dont un orange) **volontairement non
  touchée** — couleur de classification de données, même exception déjà
  établie pour les palettes calendrier/graphiques, pas une couleur
  d'action.
- `modem_config_page.dart` — même helper `_actionButton`, mais ici
  `isWrite` était dérivé de `color != null` alors que **tous** les appels
  'Write' passaient un argument `color` (silencieusement ignoré par le
  corps de la fonction) — donc littéralement **tous les boutons Write de
  cette page de ~1800 lignes rendaient en orange**. Corrigé en dérivant
  `isWrite` du texte du label (seuls 'Read'/'Write' sont jamais passés,
  vérifié par grep) — aucun des 25+ sites d'appel n'a eu besoin d'être
  touché. Aussi migré les 5 `FilledButton` restants utilisant
  `DesignTokens.success` comme couleur d'action (Add Row, deux Add to
  list, Add, Connect) vers `AppButton.primary`.
- `push_setup_server_page.dart` — boutons Start/Stop Server
  (`ElevatedButton` brut, `Colors.green`/`Colors.redAccent`) migrés vers
  `AppButton.primary`/`.danger`, en utilisant le paramètre `loading` au
  lieu d'échanger manuellement l'icône contre un spinner. La bannière
  d'erreur et la pastille de statut Running/Stopped **non touchées** —
  couleurs de statut légitimes (rouge=erreur, vert=en cours), pas des
  couleurs d'action ; utilisent encore `Colors.*` brut plutôt que
  `SemanticColors.of(context)` — nettoyage cosmétique restant si souhaité,
  hors du périmètre "couleurs de bouton" de cette passe.

**Tests** : aucun fichier de test n'existe pour ces 3 pages — seul
`app_test.dart` (pour le fix `app.dart`) a été mis à jour.

**Non vérifié** (même limite que les sweeps précédents) : pas de SDK
Flutter dans cet environnement.

### Bloc 9 — Passe 3 : calendar_profiles_page.dart, migration complète (commits `e14be06`…`5c1bdf2`)
`CALENDAR_full_migration.md` appliqué en 4 étapes + un passage de nettoyage,
chacune commit + push séparés (fichier de 4547 lignes, le plus lourd du repo).

**Écart vs le doc — Option A non suivie** : le doc proposait de faire
circuler `SemanticColors sc` en paramètre à travers ~36 signatures de
méthodes. Un survey du fichier réel montre qu'il s'agit d'une **seule
classe** (`_CalendarProfilesPageState`) : `context` (donc
`SemanticColors.of(context)`) est déjà disponible dans toutes les méthodes
sans changer aucune signature. Utilisé à la place : `final sc =
SemanticColors.of(context);` en local en tête de chaque méthode concernée
(38 méthodes). Résultat fonctionnellement identique, diff bien plus petit,
zéro signature touchée.

**Étape 1 — Couleurs (`e14be06`, + travail non commité séparément avant)** :
bloc top-level `const _cPrimary600`…`_cBg` (12 constantes) supprimé,
remplacé par `sc.xxx` dans les 38 méthodes qui les utilisaient (mapping
exact dans `CALENDAR_full_migration.md`, y compris `_cDanger→sc.error`,
`_cPrimary50→sc.surfaceVariant`, pas de `primaryContainer`). ~55 `const`
devenus invalides retirés. 25 ternaires `_isDark ? Color(0xFF…) : _cXxx`
collapsés en `sc.xxx` unique (23 directs + 2 cas particuliers vérifiés
valeur hex par valeur hex : fond de `_card()` et couleur de texte de
`_infoRow()`). Le getter `_isDark` devenu mort a été supprimé.

**Étape 2 — Boutons (`cc538e7`)** : 17 sites `ElevatedButton`/
`OutlinedButton` bruts → `AppButton` (Read→`.secondary`, Write/Activate/
Save/Add→`.primary`, Delete/Remove/"Activate Anyway"→`.danger`), plus les
3 helpers internes `_primaryBtn`/`_outlinedBtn`/`_actionBtn` migrés en
interne (signatures et sites d'appel inchangés, même schéma que le fix
`_actionButton` de `modem_config_page.dart` en Bloc 8) — sauf `_actionBtn`
dont le paramètre `color` est devenu sans objet (les 2 sites d'appel
voulaient tous les deux `.primary`) et a été retiré avec ses 2 arguments
d'appel. `_navBtn` (chevrons mois précédent/suivant, bouton carré 36×36
icône seule) **volontairement laissé en `OutlinedButton` brut** :
`AppButton` n'a pas de mode icône-seule (toujours un label), ne convient
pas à ce contrôle ; ses couleurs étaient déjà migrées vers `sc.*` en
étape 1.

**Étape 3 — Onglets (`24899e2`)** : les 3 paires `TabBar`/`TabBarView`
(externe Active/Passive/Special Days dans `AppBar.bottom`, 2 internes
Day/Week/Season) → `AppTabs`. `TabController` (`_outerTab`/`_innerActive`/
`_innerPassive`) et leur cycle de vie `initState`/`dispose` non touchés.

**Étape 4 — SnackBar (`24899e2`, même commit)** : `_snack()` délègue
maintenant à `feedback.info(msg)` au lieu de construire son propre
`SnackBar`/`ScaffoldMessenger`, corrigeant ses 9 sites d'appel d'un coup.

**Nettoyage complémentaire (`5c1bdf2`)** : après les 4 étapes, un balayage
de `Colors.white` restants a trouvé 6 sites hors du périmètre "boutons/
onglets/snackbar" strict mais clairement dans l'esprit de la passe couleurs :
`AppBar.foregroundColor`, texte des en-têtes de jours de la semaine, texte
de la carte du mois courant, texte de la puce de sélection de profil jour
→ `sc.onPrimary`/`sc.onSurfaceVariant` (texte sur fond coloré) ; 3 fonds
`Container` unis → `sc.surface` (cellule calendrier par défaut, barre
d'action passive, champ date picker) pour un vrai support dark mode. 2
ternaires `Theme.of(context).brightness == Brightness.dark ? Colors.white
: sc.primary` sur des `TextButton` (bouton "All months" x2) **laissés
tels quels** : contrairement aux ternaires `_isDark`/`_cXxx` de l'étape 1,
la valeur dark ici (`Colors.white`) ne correspond à aucune valeur de
`SemanticColors.dark` — choix de design distinct, préexistant, hors
périmètre de cette migration.

**Palette catégorielle non touchée** : `_seasonColor()` (couleurs de
saisons/types de jour) confirmée hors périmètre, même précédent que tous
les sweeps précédents. La palette similaire mais différente de
`calendar_controller.dart` reste confirmée morte/non câblée (zéro
référence à `CalendarProfilesController` dans `lib/`), non touchée non
plus.

**Test** : `test/features/pages/calendar_profiles_page_test.dart` existe
(420 lignes) — vérifié qu'aucune assertion ne dépend de `ElevatedButton`/
`FilledButton` (seul `OutlinedButton` est cherché, pour `_navBtn`, non
modifié), ni de couleurs, ni du contenu des SnackBar (seul `clearSnacks()`
est appelé, sans assertion de présence/contenu). `feedback.info()` dépend
de la clé globale `appMessengerKey` câblée uniquement dans le vrai
`app.dart` — le `_wrap()` du test (MaterialApp local sans cette clé) ne la
voit pas, donc les appels `_snack()` sont des no-op silencieux en test
(comportement déjà accepté ailleurs dans le repo pour `feedback.*`, aucune
régression puisqu'aucun test n'attendait de contenu SnackBar). **Trouvaille
préexistante, non liée à cette migration** : `_goToTab(tester, 'Seasons')`
(ligne ~324) cherche un texte `'Seasons'` qui n'existe nulle part dans le
fichier (le libellé a toujours été `'Season Profiles'`) — ce test semble
déjà cassé indépendamment de mes changements, signalé mais non corrigé
(hors périmètre de cette passe).

**Non vérifié** (même limite que tous les sweeps précédents) : pas de SDK
Flutter dans cet environnement — vérification par lecture manuelle du
diff + scripts Python de comptage d'équilibre `{}/()/[]` après chaque
étape, comparés à `git show HEAD:<file>` avant modification. À faire
tourner avec le vrai SDK (`flutter analyze` + `flutter test`) avant de
considérer cette passe définitivement close.

## ⏸️ Reporté — pas encore fait

- **Passe 2 — couleurs en dur → SemanticColors** (`SWEEP_STEP4_colors.md`) :
  **fermée** (Bloc 5 : `AppBar.backgroundColor` toutes pages ; Bloc 8 : 3ᵉ
  bleu `app.dart` + boutons mobile_network_id/modem_config/
  push_setup_server). Reste hors périmètre "couleurs de bouton" strict :
  la bannière d'erreur et la pastille de statut de `push_setup_server_page
  .dart` utilisent encore `Colors.*` brut au lieu de `SemanticColors.of
  (context)` (couleurs de statut déjà correctes sémantiquement, juste pas
  la bonne API) — cosmétique, pas une violation de règle.
- **Passe 3 — calendar_profiles migration complète** (`CALENDAR_full_migration.md`) :
  **fermée** (Bloc 9, commits `e14be06`…`5c1bdf2`) — couleurs, boutons,
  onglets et SnackBar tous migrés. Voir Bloc 9 pour l'écart documenté
  (paramètre `sc` local plutôt que threading) et les points laissés hors
  périmètre.
- **Passe 4 — i18n** (`STEP5_i18n.md`) : pas commencée. État confirmé du repo :
  `app.dart` n'a aucun `localizationsDelegates`/`supportedLocales`, `pubspec.yaml`
  a `intl` mais pas `flutter_localizations`. C'est une mise en place complète,
  pas un simple branchement.
- **Breadcrumb** : **fait sur 28/29 pages** (Bloc 5) — toutes sauf
  `connexion_page.dart` (login, pas d'AppBar) et `firmware_download_page.dart`
  (a déjà son propre breadcrumb hand-rolled, volontairement laissé tel quel
  pour ne pas dupliquer).
- **Retrait des AppBar par page au profit de la seule `AppToolbar` partagée**
  (Phase 2 de SWEEP STEP7) : décision explicite de ne PAS le faire en une
  passe mécanique (Bloc 5, confirmé Bloc 6) — trop couplé aux `TabBar`
  (9 pages) et callbacks Export/Refresh page-locaux (~20 pages). Chantier
  de redesign par page, à faire si souhaité. En attendant, `AppToolbar`
  (Bloc 6) coexiste avec l'AppBar de chaque page — pas de doublon visuel
  car `AppToolbar` est en haut sous l'AppBar bleue, `Breadcrumb` (Bloc 5)
  entre les deux.
- **i18n réelle pour le sélecteur de langue** de `AppToolbar` (Bloc 6) :
  actuellement visuel uniquement (persiste EN/FR, ne retraduit rien) —
  bloqué sur la Passe 4 ci-dessus.
- **Refresh de `AppToolbar`** (Bloc 6) : placeholder qui explique sa limite
  au lieu de recharger quoi que ce soit — vrai câblage par page prévu avec
  la Phase 2 (retrait des AppBar).
- **Historique de navigation** : `pushReplacementNamed` pas encore remplacé par
  `pushNamed`.

## 🚫 Pourquoi PATCHES_STEP1 §3 (calendar_profiles) n'a pas été appliqué tel quel (historique — résolu en Bloc 9)

1. Les `const _cPrimary600 = Color(0xFF1976D2)` … `_cBg` sont **top-level**,
   référencées dans ~12 méthodes qui n'ont pas `context` — les passer en locales
   de `build()` casse la compilation de ces méthodes.
2. Le patch référence `_sc.primaryContainer`, **champ inexistant** dans notre
   `SemanticColors` (champs réels : `primary, onPrimary, secondary, success,
   warning, error, info, surface, surfaceVariant, background, onSurface,
   onSurfaceVariant, outline`).

Stratégie initialement documentée dans `CALENDAR_full_migration.md`
(Option A) : faire circuler `SemanticColors sc` en paramètre des méthodes
`_buildX(...)`. **Non suivie en pratique** — voir Bloc 9 : la classe entière
a déjà `context` disponible partout (une seule `State`), donc `final sc =
SemanticColors.of(context);` en local par méthode suffit, sans toucher
aucune signature. Migration effectivement terminée, palette catégorielle
de données (saisons/journées) non touchée comme prévu.

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

1. ~~Passe 2 — couleurs en dur → SemanticColors~~ fermée (Bloc 8).
2. ~~Passe 3 — calendar_profiles complet~~ fermée (Bloc 9).
3. Passe 4 — i18n (`STEP5_i18n.md`).
4. Historique de navigation (`pushReplacementNamed` → `pushNamed`, à
   auditer ailleurs dans l'app — 0 occurrence dans calendar_profiles_page).
5. Retrait des AppBar par page au profit de `AppToolbar` seule (Phase 2
   SWEEP STEP7) — chantier par page, voir "Reporté" ci-dessus.
