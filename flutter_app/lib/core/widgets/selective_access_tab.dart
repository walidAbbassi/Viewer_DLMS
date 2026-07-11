

import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

// coverage:ignore-start
Widget buildReadonlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value),
          readOnly: true,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: DesignTokens.surfaceAlt,
          ),
        ),
      ],
    );
  }

  Widget buildNumberField(String label, int value, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: TextEditingController(text: value.toString())
            ..selection = TextSelection.collapsed(offset: value.toString().length),
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 13),
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          onChanged: (v) {
            final parsed = int.tryParse(v);
            if (parsed != null) {
              onChanged(parsed);
            }
          },
        ),
      ],
    );
  }


  Widget buildPanel({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: DesignTokens.surface,
        border: Border.all(color: DesignTokens.gray800),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: DesignTokens.primary600,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }


  Widget buildButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        elevation: 0,
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }


  Widget buildOutlineButton(String label, VoidCallback onPressed) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: DesignTokens.primary600,
        side: const BorderSide(color: DesignTokens.primary600),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
    );
  }

  Widget buildTerminalLine(TerminalLine line) {
    Color tagColor;
    Color tagBgColor;

    switch (line.kind) {
      case 'req':
        tagColor = const Color(0xFFC7D2FE);
        tagBgColor = const Color(0xFF312E81);
        break;
      case 'err':
        tagColor = const Color(0xFFFCA5A5);
        tagBgColor = const Color(0xFF7F1D1D);
        break;
      default:
        tagColor = const Color(0xFF93C5FD);
        tagBgColor = const Color(0xFF1E3A8A);
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[${line.timestamp}]',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tagBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              line.tag,
              style: TextStyle(
                color: tagColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              line.message,
              style: const TextStyle(color: Color(0xFFD1E3F8), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
// coverage:ignore-end

  class TerminalLine {
  final String timestamp;
  final String tag;
  final String message;
  final String kind;

  TerminalLine({
    required this.timestamp,
    required this.tag,
    required this.message,
    required this.kind,
  });
}