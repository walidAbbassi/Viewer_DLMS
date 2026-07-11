import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'partial_read_pickers_material.dart';

typedef PartialReadDatePicker = Future<DateTime?> Function(
  BuildContext context,
  DateTime initialDate,
);

typedef PartialReadTimePicker = Future<TimeOfDay?> Function(
  BuildContext context,
  TimeOfDay initialTime,
);

typedef PartialReadSecondsPicker = Future<int?> Function(
  BuildContext context,
  int initialSeconds,
);

abstract interface class PartialReadPickers {
  Future<DateTime?> pickDate(
    BuildContext context,
    DateTime initialDate,
  );

  Future<TimeOfDay?> pickTime24h(
    BuildContext context,
    TimeOfDay initialTime,
  );

  Future<int?> pickSeconds(
    BuildContext context,
    int initialSeconds,
  );
}

PartialReadPickers _pickers = const MaterialPartialReadPickers();

PartialReadPickers get partialReadPickers => _pickers;

@visibleForTesting
set partialReadPickers(PartialReadPickers value) {
  _pickers = value;
}

Future<DateTime?> partialReadDefaultDatePicker(
  BuildContext context,
  DateTime initialDate,
) {
  return _pickers.pickDate(context, initialDate);
}

Future<TimeOfDay?> partialReadDefaultTimePicker24h(
  BuildContext context,
  TimeOfDay initialTime,
) {
  return _pickers.pickTime24h(context, initialTime);
}

Future<int?> partialReadDefaultSecondsPickerDialog(
  BuildContext context,
  int initialSeconds,
) {
  return _pickers.pickSeconds(context, initialSeconds);
}
