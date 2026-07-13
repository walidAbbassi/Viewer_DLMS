// core/widgets/language_selector_widget.dart
//
// Visual-only language toggle (EN/FR). Persists the user's choice, but does
// NOT retranslate any UI string yet — there is no `localeProvider` or
// `flutter_localizations` wiring in this app (see docs/SPECS_UI.md "Known
// gaps"). That's a separate, larger i18n project (Passe 4). This widget
// only gives the toolbar a working, persisted "EN"/"FR" label + menu so the
// UI matches the design proposal without pretending the app is localized.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/semantic_colors.dart';

const _kLanguagePrefKey = 'ui_language_code';

/// Holds the currently-selected language code ("EN"/"FR"), loaded from and
/// persisted to [SharedPreferences]. Shared across the app so every
/// [LanguageSelectorWidget] instance stays in sync.
final ValueNotifier<String> currentLanguageCode = ValueNotifier<String>('EN');

Future<void> loadPersistedLanguage() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getString(_kLanguagePrefKey);
  if (saved != null && saved.isNotEmpty) {
    currentLanguageCode.value = saved;
  }
}

Future<void> _setLanguage(String code) async {
  currentLanguageCode.value = code;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kLanguagePrefKey, code);
}

/// Small "EN"/"FR" tap target that opens a menu to switch the persisted
/// language preference. Visual-only — see file header.
class LanguageSelectorWidget extends StatelessWidget {
  const LanguageSelectorWidget({super.key});

  static const _options = ['EN', 'FR'];

  @override
  Widget build(BuildContext context) {
    final colors = SemanticColors.of(context);
    return ValueListenableBuilder<String>(
      valueListenable: currentLanguageCode,
      builder: (context, code, _) {
        return Tooltip(
          message: 'Change language',
          child: PopupMenuButton<String>(
            key: const Key('toolbar_language_btn'),
            initialValue: code,
            tooltip: '',
            onSelected: _setLanguage,
            itemBuilder: (context) => _options
                .map((o) => PopupMenuItem<String>(value: o, child: Text(o)))
                .toList(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                code,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                  letterSpacing: .5,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
