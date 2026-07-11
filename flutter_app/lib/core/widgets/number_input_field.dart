import 'package:flutter/material.dart';

class NumberInputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool hasButtons;
  final VoidCallback? onRead;
  final VoidCallback? onWrite;

  const NumberInputField({
    super.key,
    required this.label,
    required this.controller,
    this.hasButtons = false,
    this.onRead,
    this.onWrite,
  });

  String get _baseKey =>
      key is ValueKey ? (key as ValueKey).value.toString() : 'field';

  @override
  Widget build(BuildContext context) {
    return Card(
      key: Key('${_baseKey}_card'),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// LABEL + ICONS
            Row(
              children: [
                Expanded(child: Text(label)),

                if (hasButtons) ...[
                  IconButton(
                    key: Key('${_baseKey}_read_btn'),
                    icon: const Icon(Icons.visibility),
                    onPressed: onRead,
                  ),
                  IconButton(
                    key: Key('${_baseKey}_write_btn'),
                    icon: const Icon(Icons.edit),
                    onPressed: onWrite,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            TextField(
              key: Key('${_baseKey}_input'),
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}