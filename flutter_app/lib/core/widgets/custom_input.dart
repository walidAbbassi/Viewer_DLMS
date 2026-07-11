import 'package:flutter/material.dart';

class CustomInput extends StatefulWidget {
  final String initialValue;          // initial input value
  final bool showRead;                // show/hide Read button
  final bool showWrite;               // show/hide Write button
  final void Function(String value)? onRead;
  final void Function(String value)? onWrite;

  const CustomInput({
    super.key,
    this.initialValue = "",
    this.showRead = true,
    this.showWrite = true,
    this.onRead,
    this.onWrite,
  });

  @override
  State<CustomInput> createState() => _CustomInputState();
}

class _CustomInputState extends State<CustomInput> {
  late TextEditingController _controller;
  String _status = "";

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  void _handleRead() {
    final value = _controller.text.trim();
    if (widget.onRead != null) {
      widget.onRead!(value);
    }
    setState(() => _status = "✅ Read with: $value");
  }

  void _handleWrite() {
    final value = _controller.text.trim();
    if (widget.onWrite != null) {
      widget.onWrite!(value);
    }
    setState(() => _status = "✅ Write with: $value");
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Input field
            TextField(
              key: const Key('custom_input_text_field'),
              controller: _controller,
              decoration: InputDecoration(
                labelText: "Enter value",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.edit),
              ),
            ),
            const SizedBox(height: 16),

            // Buttons (conditionally rendered)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.showRead)
                  ElevatedButton.icon(
                    key: const Key('custom_input_read_btn'),
                    onPressed: _handleRead,
                    icon: const Icon(Icons.download),
                    label: const Text("Read"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                if (widget.showWrite)
                  ElevatedButton.icon(
                    key: const Key('custom_input_write_btn'),
                    onPressed: _handleWrite,
                    icon: const Icon(Icons.upload),
                    label: const Text("Write"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // Status text
            Text(
              _status,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
