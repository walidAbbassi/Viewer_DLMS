import 'package:flutter/material.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/theme/design_tokens.dart';

class Class7InfoWidget extends StatefulWidget {
  final String featureKey;
  final int? maxRecord;
  final int? recordNumber;
  final int? capturePeriod;

  final Future<void> Function(int value)? onSetMaxRecord;
  final Future<void> Function(int value)? onSetRecordNumber;
  final Future<void> Function(int value)? onSetCapturePeriod;

  final Future<int> Function()? onReadMaxRecord;
  final Future<int> Function()? onReadRecordNumber;
  final Future<int> Function()? onReadCapturePeriod;

  final bool initiallyExpanded;
  final bool maxRecordWriteEnabled;
  final bool recordNumberWriteEnabled;
  final bool allDisabled;

  const Class7InfoWidget({
    Key? key,
    required this.featureKey,
    this.maxRecord,
    this.recordNumber,
    this.capturePeriod,
    this.onSetMaxRecord,
    this.onSetRecordNumber,
    this.onSetCapturePeriod,
    this.onReadMaxRecord,
    this.onReadRecordNumber,
    this.onReadCapturePeriod,
    this.initiallyExpanded = true,
    this.maxRecordWriteEnabled = true,
    this.recordNumberWriteEnabled = true,
    this.allDisabled = false,
  }) : super(key: key);

  @override
  State<Class7InfoWidget> createState() => _Class7InfoWidgetState();
}

class _Class7InfoWidgetState extends State<Class7InfoWidget> {
  late TextEditingController _maxRecordController;
  late TextEditingController _recordNumberController;
  late TextEditingController _capturePeriodController;

  String _maxRecordError = '';
  String _recordNumberError = '';
  String _capturePeriodError = '';

  bool _loadingMaxRead = false;
  bool _loadingMaxWrite = false;
  bool _loadingRecordRead = false;
  bool _loadingRecordWrite = false;
  bool _loadingPeriodRead = false;
  bool _loadingPeriodWrite = false;

  late bool _isExpanded;

  @override
  void initState() {
    super.initState();

    _maxRecordController =
        TextEditingController(text: widget.maxRecord?.toString() ?? '');
    _recordNumberController =
        TextEditingController(text: widget.recordNumber?.toString() ?? '');
    _capturePeriodController =
        TextEditingController(text: widget.capturePeriod?.toString() ?? '');

    _isExpanded = widget.initiallyExpanded;
  }

  @override
  void didUpdateWidget(covariant Class7InfoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.maxRecord != oldWidget.maxRecord && !_loadingMaxRead && !_loadingMaxWrite) {
      _maxRecordController.text = widget.maxRecord?.toString() ?? '';
    }

    if (widget.recordNumber != oldWidget.recordNumber && !_loadingRecordRead && !_loadingRecordWrite) {
      _recordNumberController.text = widget.recordNumber?.toString() ?? '';
    }

    if (widget.capturePeriod != oldWidget.capturePeriod && !_loadingPeriodRead && !_loadingPeriodWrite) {
      _capturePeriodController.text = widget.capturePeriod?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _maxRecordController.dispose();
    _recordNumberController.dispose();
    _capturePeriodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final accent = isDark ? Colors.white : Colors.blue;
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
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Class 7 Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
                const Spacer(),
                Icon(Icons.expand_more, color: accent),
              ],
            ),
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 16),
            Column(
              children: [
                _buildField(
                  label: 'Max Record',
                  controller: _maxRecordController,
                  loadingRead: _loadingMaxRead,
                  loadingWrite: _loadingMaxWrite,
                  readDisabled: widget.allDisabled,
                  writeDisabled: widget.allDisabled || !widget.maxRecordWriteEnabled,
                  onRead: widget.onReadMaxRecord == null
                      ? null
                      : () async {
                          if (_loadingMaxRead || _loadingMaxWrite) return;
                          setState(() {
                            _loadingMaxRead = true;
                            _maxRecordError = '';
                          });
                          try {
                            final value = await widget.onReadMaxRecord!();
                            _maxRecordController.text = value.toString();
                          } catch (e) {
                            _maxRecordError = "Error: $e";
                          }
                          setState(() => _loadingMaxRead = false);
                        },
                  onWrite: widget.onSetMaxRecord == null
                      ? null
                      : () async {
                          if (_loadingMaxRead || _loadingMaxWrite) return;
                          setState(() {
                            _loadingMaxWrite = true;
                            _maxRecordError = '';
                          });
                          try {
                            final value =
                                int.tryParse(_maxRecordController.text);
                            if (value != null) {
                              await widget.onSetMaxRecord!(value);
                            }
                          } catch (e) {
                            _maxRecordError = "Error: $e";
                          }
                          setState(() => _loadingMaxWrite = false);
                        },
                ),
                const SizedBox(height: 12),
                _buildField(
                  label: 'Record Number',
                  controller: _recordNumberController,
                  loadingRead: _loadingRecordRead,
                  loadingWrite: _loadingRecordWrite,
                  readDisabled: widget.allDisabled,
                  writeDisabled: widget.allDisabled || !widget.recordNumberWriteEnabled,
                  onRead: widget.onReadRecordNumber == null
                      ? null
                      : () async {
                          if (_loadingRecordRead || _loadingRecordWrite) return;
                          setState(() {
                            _loadingRecordRead = true;
                            _recordNumberError = '';
                          });
                          try {
                            final value = await widget.onReadRecordNumber!();
                            _recordNumberController.text = value.toString();
                          } catch (e) {
                            _recordNumberError = "Error: $e";
                          }
                          setState(() => _loadingRecordRead = false);
                        },
                  onWrite: widget.onSetRecordNumber == null
                      ? null
                      : () async {
                          if (_loadingRecordRead || _loadingRecordWrite) return;
                          setState(() {
                            _loadingRecordWrite = true;
                            _recordNumberError = '';
                          });
                          try {
                            final value =
                                int.tryParse(_recordNumberController.text);
                            if (value != null) {
                              await widget.onSetRecordNumber!(value);
                            }
                          } catch (e) {
                            _recordNumberError = "Error: $e";
                          }
                          setState(() => _loadingRecordWrite = false);
                        },
                ),
                const SizedBox(height: 12),
                _buildField(
                  label: 'Capture Period',
                  controller: _capturePeriodController,
                  loadingRead: _loadingPeriodRead,
                  loadingWrite: _loadingPeriodWrite,
                  readDisabled: widget.allDisabled,
                  writeDisabled: widget.allDisabled,
                  onRead: widget.onReadCapturePeriod == null
                      ? null
                      : () async {
                          if (_loadingPeriodRead || _loadingPeriodWrite) return;
                          setState(() {
                            _loadingPeriodRead = true;
                            _capturePeriodError = '';
                          });
                          try {
                            final value = await widget.onReadCapturePeriod!();
                            _capturePeriodController.text = value.toString();
                          } catch (e) {
                            _capturePeriodError = "Error: $e";
                          }
                          setState(() => _loadingPeriodRead = false);
                        },
                  onWrite: widget.onSetCapturePeriod == null
                      ? null
                      : () async {
                          if (_loadingPeriodRead || _loadingPeriodWrite) return;
                          setState(() {
                            _loadingPeriodWrite = true;
                            _capturePeriodError = '';
                          });
                          try {
                            final value =
                                int.tryParse(_capturePeriodController.text);
                            if (value != null) {
                              await widget.onSetCapturePeriod!(value);
                            }
                          } catch (e) {
                            _capturePeriodError = "Error: $e";
                          }
                          setState(() => _loadingPeriodWrite = false);
                        },
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ✅ READ + WRITE UI
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required bool loadingRead,
    required bool loadingWrite,
    bool readDisabled = false,
    bool writeDisabled = false,
    Future<void> Function()? onRead,
    Future<void> Function()? onWrite,
  }) {
    final loading = loadingRead || loadingWrite;
    String errorText = '';
    if (label == 'Max Record') errorText = _maxRecordError;
    if (label == 'Record Number') errorText = _recordNumberError;
    if (label == 'Capture Period') errorText = _capturePeriodError;

    final isDark = DesignTokens.isDark(context);
    final textColor = DesignTokens.textPrimaryOf(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, color: textColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: TextStyle(color: textColor),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  filled: isDark,
                  fillColor: isDark ? DesignTokens.darkFill : null,
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: DesignTokens.borderOf(context)),
                  ),
                ),
                enabled: !loading,
              ),
            ),
            if (onRead != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton.icon(
                  icon: loadingRead
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.visibility),
                  label: const Text("Read"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(90, 36),
                  ),
                  onPressed: (loadingRead ||
                          readDisabled ||
                          !userRights.hasRightForFeature(
                              'Get', widget.featureKey))
                      ? null
                      : onRead,
                ),
              ),
            if (onWrite != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: ElevatedButton.icon(
                  icon: loadingWrite
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.edit),
                  label: const Text("Write"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    minimumSize: const Size(90, 36),
                  ),
                  onPressed: (loadingWrite ||
                          writeDisabled ||
                          !userRights.hasRightForFeature(
                              'Set', widget.featureKey))
                      ? null
                      : onWrite,
                ),
              ),
          ],
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              errorText,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
