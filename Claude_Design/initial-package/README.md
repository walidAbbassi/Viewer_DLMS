# Viewer_NG — Paquet de correction UI/UX (drop-in)

Code Dart prêt à intégrer dans `flutter_app/lib/`, issu de la revue UI/UX
(juillet 2026). L'app n'est **pas** refondue : on uniformise couleurs, feedback,
boutons, navigation, données, onglets, icônes.

## Contenu
```
flutter_app/lib/
├── core/theme/semantic_colors.dart     # palette unique (light+dark), fin de l'orange
├── core/theme/app_icons.dart           # icônes domaine DLMS/COSEM smart metering
├── core/services/feedback_service.dart # message = couleur du type (erreur = rouge)
├── core/widgets/app_snackbar.dart      # (voir feedback_service)
├── core/widgets/app_button.dart        # primary / secondary / danger
├── core/widgets/read_only_value.dart   # donnée non éditable + copie
├── core/widgets/app_tabs.dart          # onglets pilule uniques
├── core/widgets/breadcrumb.dart        # fil d'Ariane global
└── util/value_format.dart              # fin des « 0 unknown »
PATCHES.md                              # diffs commentés par page
```

## Ordre de pose
1. Copier `core/theme/semantic_colors.dart` + `core/theme/app_icons.dart`.
2. Brancher les tokens + `scaffoldMessengerKey` dans `app.dart` (cf. PATCHES §0).
3. Copier `core/services/feedback_service.dart` puis migrer les SnackBar (cf. §2, §2bis).
4. Copier les widgets `app_button` / `read_only_value` / `app_tabs` / `breadcrumb`.
5. Copier `util/value_format.dart` et migrer les pages Quality (§5).
6. Appliquer les patchs pages (device_id, date_time, firmware_download, scaffold_wrapper).
7. `flutter analyze` puis test rendu **clair ET sombre** sur chaque page modifiée.

## Mapping icônes par page (rail)
| Page | Icône |
|------|-------|
| Meter Connexion | `AppIcons.connection` |
| Device ID | `AppIcons.deviceId` |
| Firmware Version | `AppIcons.firmwareVersion` |
| Date time | `AppIcons.clock` |
| Activity Calendars | `AppIcons.calendar` |
| LoadProfile 1/2 | `AppIcons.loadProfile` |
| PQ Profile | `AppIcons.pqProfile` |
| Energy Register | `AppIcons.energyRegister` |
| CT VT Management | `AppIcons.ctvt` |
| Event / Fraud / Power logs | `AppIcons.eventLog` / `AppIcons.fraud` / `AppIcons.powerFailure` |
| Sag / Swell / THD / Neutral / Overcurrent / Power Factor | `AppIcons.sag` / `swell` / `thd` / `neutral` / `overcurrent` / `powerFactor` |
| Firmware Download | `AppIcons.firmwareUpgrade` |
| SIM Config / Modem | `AppIcons.sim` / `AppIcons.modem` |
| Manual DLMS | `AppIcons.manualDlms` |
| Configuration | `AppIcons.configuration` |
| Chip statut compteur | `AppIcons.meter` (vert=connecté / rouge=déconnecté) |

## Spec & gouvernance
- OpenSpec : `openspec/changes/2026-07-11-ui-ux-consistency/` (proposal, design, tasks).
- Skill agent : `.claude/commands/viewer-ng-ui-consistency.md` (règles à respecter en codant).

## Critères d'acceptation
- Aucune bannière verte pour une erreur / un refus.
- Aucun bouton orange ; règle de couleur constante partout.
- Une seule navigation (rail) ; plus de barre du bas.
- Valeurs en lecture seule ≠ champs de saisie.
- Un seul style d'onglets ; fil d'Ariane cohérent ; dark mode correct.

## État (Claude Code)
Tout le contenu listé ci-dessus a été appliqué (commit `a947679`), à l'exception de :
- `app_snackbar.dart` — supprimé, le SnackBar est construit inline dans `feedback_service.dart`.
- Le mapping icônes par page — pas encore appliqué au rail lui-même (fichiers d'icônes créés,
  mais pas branchés page par page dans la navigation).
