import 'package:flutter/material.dart';

class InputField extends StatelessWidget {
  final String label;
  final bool obscure;
  final TextEditingController? controller;

  const InputField({
    super.key,
    required this.label,
    this.obscure = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
