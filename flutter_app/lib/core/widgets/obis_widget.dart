import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ObisWidgetData {
  final TextEditingController classController = TextEditingController();
  final TextEditingController obisController = TextEditingController();
  final TextEditingController attributeController = TextEditingController();
}

class ObisWidget extends StatelessWidget {
  final ObisWidgetData data;
  final VoidCallback? onDelete;

  const ObisWidget({super.key, required this.data, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: data.classController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Class",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: data.obisController,
                decoration: const InputDecoration(
                  labelText: "OBIS Code (Hex)",
                  border: OutlineInputBorder(),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9a-fA-F]')),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: data.attributeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Attribute",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            )
          ],
        ),
      ),
    );
  }
}
