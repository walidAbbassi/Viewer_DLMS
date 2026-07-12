# SWEEP — SnackBar → feedback service (étape 3)

Branche : `ui_ux_design` (Viewer_DLMS). À coller tel quel comme instruction à Claude Code.

═══════════════════════════════════════════════════════════════════
## PROMPT À DONNER À CLAUDE CODE

> Sur la branche `ui_ux_design`, remplace **toutes** les SnackBar colorées par le service `feedback` global (`lib/core/services/feedback_service.dart`, déjà présent — instance `feedback`).
>
> **Règle de mapping (la couleur vient du TYPE, jamais d'un `backgroundColor`) :**
> - `backgroundColor: Colors.red` / `Colors.red.shade###` / `Colors.redAccent` / `DesignTokens.danger` / `DesignTokens.error` → `feedback.error(<message>)`
> - `backgroundColor: DesignTokens.warning` / `Colors.orange###` → `feedback.warning(<message>)`
> - `backgroundColor: Colors.green` / `Colors.green.shade###` / `DesignTokens.success` → `feedback.success(<message>)`
> - SnackBar sans couleur explicite (info neutre) → `feedback.info(<message>)`
>
> `<message>` = le texte du `content:` (le `Text('…')`, ou la string de la `Row`/`Text` dans le content). Si le content est une `Row` avec icône + texte, ne garde que le texte.
>
> **Procédure par occurrence :**
> 1. Remplace le bloc `ScaffoldMessenger.of(context)…showSnackBar(SnackBar(… content: … backgroundColor: … …))` (y compris les variantes `..clearSnackBars()..showSnackBar(...)`) par le seul appel `feedback.<type>('…');`.
> 2. Ajoute l'import s'il manque : `import 'package:flutter_python_grpc/core/services/feedback_service.dart';` (ou chemin relatif `../../core/services/feedback_service.dart` selon le style du fichier).
> 3. Ne touche PAS aux `Colors.red.shade400` utilisés comme `color:` d'une `Icon`/`Text`/`BorderSide` (ce ne sont pas des SnackBar) — ceux-là seront traités séparément avec `SemanticColors`.
> 4. `flutter analyze` à la fin ; corrige les imports/messages inutilisés.

═══════════════════════════════════════════════════════════════════
## FICHIERS / LIGNES CONCERNÉS (SnackBar uniquement)

- configuration_page.dart : 3140 (error)
- connexion_page.dart : 695 (error)  ⚠ ligne 1863 = couleur de texte, NE PAS toucher
- energy_register_page.dart : 124 (success), 138 (error)
- event_logs_page.dart : 998 (error), 1940 (success), 1959 (warning)
- fresnel_diagram_page.dart : 236 (error), 303 (error), 713 (success), 725 (error/danger)
- load_profile_page.dart : 388 (error), 400 (success), 1107 (error)
- meter_connexion_page.dart : 418 (error), 433 (success), 746 (error)
- mobile_network_id_page.dart : 807 (success), 822 (error/danger)
- modem_config_page.dart : 789, 1051, 1114, 1486, 1544 (tous success)
- push_action_page.dart : 283, 304, 331, 354, 382, 511 (error)
- push_setup_page.dart : 335, 360, 389, 419, 448, 471, 522, 545, 580, 1206, 1661, 1676, 1707, 1721, 1754, 1769, 1813, 1828, 2148, 2305 (success), 2316, 2367, 2384 (success), 2396, 2533 (error)
- push_setup_server_page.dart : 200 (error/redAccent), 223 (success)
- script_table_page.dart : 92 (error), 118 (error)
- super_manual_tool_page.dart : 121 (error), 888 (error)
- template_config_page.dart : 403 (success), 414 (error)

**NON-SnackBar (à ignorer dans ce sweep — traitement `SemanticColors` séparé) :**
push_action:623, push_recovery:146/151, push_selective:400/407, push_setup:2342/2343/2411/2669,
push_setup_server:89, load_profile_status:213/214, connexion:1863 → ce sont des `color:` d'Icon/Text/Border.

**Note Claude Code (voir STATUS_FROM_CLAUDE_CODE.md)** : vérifié par grep sur le repo réel —
`event_logs_page.dart` était déjà migré (passe précédente). `mobile_network_id_page.dart` et
`modem_config_page.dart` utilisent `showDialog`, pas de SnackBar. `push_setup_server_page.dart`
n'a ni l'un ni l'autre. Ces 4 fichiers ont donc été exclus du sweep mécanique.

═══════════════════════════════════════════════════════════════════
## APRÈS
- Vérifier qu'aucune SnackBar d'erreur n'est verte, et qu'aucun refus (« Denied », « Failed », « Error ») ne passe en success.
- Étape 4 (séparée) : remplacer les branches `Color(0xFF…)` de dark-mode et les `Colors.red.shade###` restants (icônes/textes) par `SemanticColors.of(context)`.
