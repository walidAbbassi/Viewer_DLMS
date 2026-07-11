import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/design_tokens.dart';
import 'partial_read_pickers.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';

class PartialReadWidget extends StatefulWidget {
  final String featureKey;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? startDeviation;
  final String? endDeviation;
  final String? startStatus;
  final String? endStatus;
  final Function(DateTime, String, String)? onStartChanged;
  final Function(DateTime, String, String)? onEndChanged;
  final VoidCallback? onRead;
  final bool initiallyExpanded;

  final PartialReadDatePicker datePicker;
  final PartialReadTimePicker timePicker;
  final PartialReadSecondsPicker secondsPicker;

  const PartialReadWidget({
    super.key,
    required this.featureKey,
    this.startDate,
    this.endDate,
    this.startDeviation,
    this.endDeviation,
    this.startStatus,
    this.endStatus,
    this.onStartChanged,
    this.onEndChanged,
    this.onRead,
    this.initiallyExpanded = true,
    this.datePicker = partialReadDefaultDatePicker,
    this.timePicker = partialReadDefaultTimePicker24h,
    this.secondsPicker = partialReadDefaultSecondsPickerDialog,
  });

  @override
  State<PartialReadWidget> createState() => _PartialReadWidgetState();
}

class _PartialReadWidgetState extends State<PartialReadWidget> {
  late DateTime _startDate;
  late DateTime _endDate;
  late TextEditingController _startDeviationController;
  late TextEditingController _endDeviationController;
  late String _startStatus;
  late String _endStatus;
  late bool _isExpanded;

  final List<String> _statusOptions = ['Default', 'Summer', 'Winter'];

  @override
  void initState() {
    super.initState();
    _startDate =
        widget.startDate ?? DateTime.now().subtract(const Duration(days: 7));
    _endDate = widget.endDate ?? DateTime.now();
    _startDeviationController =
        TextEditingController(text: widget.startDeviation ?? '8000');
    _endDeviationController =
        TextEditingController(text: widget.endDeviation ?? '8000');
    _startStatus = widget.startStatus ?? 'Default';
    _endStatus = widget.endStatus ?? 'Default';
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void dispose() {
    _startDeviationController.dispose();
    _endDeviationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await widget.datePicker(
      context,
      isStart ? _startDate : _endDate,
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _startDate.hour,
            _startDate.minute,
            _startDate.second,
          );
          widget.onStartChanged
              ?.call(_startDate, _startDeviationController.text, _startStatus);
        } else {
          _endDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            _endDate.hour,
            _endDate.minute,
            _endDate.second,
          );
          widget.onEndChanged
              ?.call(_endDate, _endDeviationController.text, _endStatus);
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final currentDateTime = isStart ? _startDate : _endDate;

    final TimeOfDay? picked = await widget.timePicker(
      context,
      TimeOfDay(hour: currentDateTime.hour, minute: currentDateTime.minute),
    );

    if (picked != null) {
      if (context.mounted) {
        final int? seconds = await widget.secondsPicker(
          context,
          currentDateTime.second,
        );

        if (seconds != null) {
          setState(() {
            if (isStart) {
              _startDate = DateTime(
                _startDate.year,
                _startDate.month,
                _startDate.day,
                picked.hour,
                picked.minute,
                seconds,
              );
              widget.onStartChanged?.call(
                  _startDate, _startDeviationController.text, _startStatus);
            } else {
              _endDate = DateTime(
                _endDate.year,
                _endDate.month,
                _endDate.day,
                picked.hour,
                picked.minute,
                seconds,
              );
              widget.onEndChanged
                  ?.call(_endDate, _endDeviationController.text, _endStatus);
            }
          });
        }
      }
    }
  }

  Widget _buildDateTimeRow({
    required String label,
    required DateTime dateTime,
    required TextEditingController deviationController,
    required String status,
    required bool isStart,
  }) {
    final textColor = DesignTokens.textPrimaryOf(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Date selector
              Expanded(
                flex: 2,
                child: InkWell(
                  key: Key('partial_read_${isStart ? 'start' : 'end'}_date_picker'),
                  onTap: () => _selectDate(context, isStart),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      labelStyle: TextStyle(color: textColor),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      prefixIcon: Icon(Icons.calendar_today,
                          size: 18, color: textColor),
                    ),
                    child: Text(
                      DateFormat('yyyy-MM-dd').format(dateTime),
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Time selector
              Expanded(
                flex: 2,
                child: InkWell(
                  key: Key('partial_read_${isStart ? 'start' : 'end'}_time_picker'),
                  onTap: () => _selectTime(context, isStart),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Time',
                      labelStyle: TextStyle(color: textColor),
                      border: const OutlineInputBorder(),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      prefixIcon:
                          Icon(Icons.access_time, size: 18, color: textColor),
                    ),
                    child: Text(
                      DateFormat('HH:mm:ss').format(dateTime),
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Deviation (hex input)
              Expanded(
                flex: 1,
                child: TextField(
                  controller: deviationController,
                  decoration: InputDecoration(
                    labelText: 'Deviation',
                    labelStyle: TextStyle(color: textColor),
                    hintText: '0000',
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    prefixText: '0x',
                    prefixStyle: TextStyle(color: textColor),
                    counterText: '',
                  ),
                  style: TextStyle(
                      fontSize: 14, fontFamily: 'monospace', color: textColor),
                  maxLength: 4,
                  onChanged: (value) {
                    // Validate hex input
                    if (value.isNotEmpty &&
                        !RegExp(r'^[0-9A-Fa-f]+$').hasMatch(value)) {
                      deviationController.text =
                          value.substring(0, value.length - 1);
                      deviationController.selection =
                          TextSelection.fromPosition(
                        TextPosition(offset: deviationController.text.length),
                      );
                    }
                    if (isStart) {
                      widget.onStartChanged?.call(
                          _startDate, deviationController.text, _startStatus);
                    } else {
                      widget.onEndChanged?.call(
                          _endDate, deviationController.text, _endStatus);
                    }
                  },
                ),
              ),
              const SizedBox(width: 12),
              // Status dropdown
              Expanded(
                flex: 1,
                child: DropdownButtonFormField<String>(
                  value: status,
                  dropdownColor: DesignTokens.surfaceOf(context),
                  style: TextStyle(fontSize: 14, color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Status',
                    labelStyle: TextStyle(color: textColor),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                  ),
                  items: _statusOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value,
                          style: TextStyle(fontSize: 14, color: textColor)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        if (isStart) {
                          _startStatus = newValue;
                          widget.onStartChanged?.call(_startDate,
                              _startDeviationController.text, _startStatus);
                        } else {
                          _endStatus = newValue;
                          widget.onEndChanged?.call(_endDate,
                              _endDeviationController.text, _endStatus);
                        }
                      });
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final accent = isDark ? Colors.white : DesignTokens.primary600;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border: Border.all(color: DesignTokens.borderOf(context)),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            key: const Key('partial_read_expand_btn'),
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              children: [
                Icon(Icons.date_range, color: accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Partial Read Configuration',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
                const Spacer(),
                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: accent,
                ),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            _buildDateTimeRow(
              label: 'Start Date & Time',
              dateTime: _startDate,
              deviationController: _startDeviationController,
              status: _startStatus,
              isStart: true,
            ),
            const SizedBox(height: 12),
            _buildDateTimeRow(
              label: 'End Date & Time',
              dateTime: _endDate,
              deviationController: _endDeviationController,
              status: _endStatus,
              isStart: false,
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                key: const Key('partial_read_read_btn'),
                onPressed:
                    userRights.hasRightForFeature('Get', widget.featureKey)
                        ? widget.onRead
                        : null,
                icon: const Icon(Icons.visibility),
                label: const Text('Read'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
