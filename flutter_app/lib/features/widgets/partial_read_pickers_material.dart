import 'package:flutter/material.dart';

import '../../core/theme/design_tokens.dart';
import 'partial_read_pickers.dart';

class MaterialPartialReadPickers implements PartialReadPickers {
  const MaterialPartialReadPickers();

  @override
  Future<DateTime?> pickDate(
    BuildContext context,
    DateTime initialDate,
  ) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  @override
  Future<TimeOfDay?> pickTime24h(
    BuildContext context,
    TimeOfDay initialTime,
  ) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
  }

  @override
  Future<int?> pickSeconds(
    BuildContext context,
    int initialSeconds,
  ) {
    int selectedSeconds = initialSeconds;

    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Seconds'),
          content: SizedBox(
            width: 200,
            height: 200,
            child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$selectedSeconds seconds',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 40,
                        perspective: 0.005,
                        diameterRatio: 1.2,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: selectedSeconds,
                        ),
                        onSelectedItemChanged: (index) {
                          setState(() {
                            selectedSeconds = index;
                          });
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            return Center(
                              child: Text(
                                index.toString().padLeft(2, '0'),
                                style: TextStyle(
                                  fontSize: 18,
                                  color: index == selectedSeconds
                                      ? DesignTokens.primary600
                                      : Colors.grey,
                                  fontWeight: index == selectedSeconds
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            );
                          },
                          childCount: 60,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              key: const Key('partial_read_pickers_cancel_btn'),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              key: const Key('partial_read_pickers_ok_btn'),
              onPressed: () => Navigator.of(context).pop(selectedSeconds),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
