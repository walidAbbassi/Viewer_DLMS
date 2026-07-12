// core/widgets/read_only_value.dart
//
// Affiche une donnée NON modifiable : label + valeur en texte sélectionnable +
// bouton copier. Ne PAS utiliser de TextField pour de la lecture seule (les
// valeurs ne doivent plus ressembler à des champs de saisie — cf. Device ID,
// Firmware Version). Réserver TextField aux champs réellement `Set`.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/semantic_colors.dart';
import '../services/feedback_service.dart';

class ReadOnlyValue extends StatelessWidget {
  const ReadOnlyValue({
    super.key,
    required this.label,
    required this.value,
    this.monospace = false,
  });

  final String label;
  final String value;
  final bool monospace;

  @override
  Widget build(BuildContext context) {
    final c = SemanticColors.of(context);
    final shown = value.trim().isEmpty ? '—' : value;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 220,
            child: Text(label,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.onSurfaceVariant)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SelectableText(
              shown,
              style: TextStyle(
                fontSize: 14,
                color: c.onSurface,
                fontFamily: monospace ? 'monospace' : null,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Copier',
            icon: Icon(Icons.content_copy, size: 16, color: c.onSurfaceVariant),
            onPressed: shown == '—'
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: value));
                    feedback.info('Copié');
                  },
          ),
        ],
      ),
    );
  }
}
