import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import '../../grpc/meter_client.dart';
import '../../state/device_id_cache.dart';
import '../theme/design_tokens.dart';
// ---------------------------------------------------------------------------
// Export format options
// ---------------------------------------------------------------------------

enum _ExportFmt {
  xml('XML', Icons.code, Color(0xFF1565C0), Color(0xFFE3F2FD)),
  csv('CSV', Icons.table_chart, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  pdf('PDF', Icons.picture_as_pdf, Color(0xFFC62828), Color(0xFFFFEBEE)),
  docx('DOCX', Icons.description, Color(0xFF6A1B9A), Color(0xFFF3E5F5));

  const _ExportFmt(this.label, this.icon, this.color, this.bgColor);

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

// ---------------------------------------------------------------------------
// Public widget – drop into any AppBar actions list.
//
// Usage:
//   actions: [
//     ExportActionButton(
//       pageId: exportPageId,
//       dataGetter: getExportData,
//     ),
//   ]
// ---------------------------------------------------------------------------

class ExportActionButton extends StatelessWidget {
  const ExportActionButton({
    super.key,
    required this.pageId,
    required this.dataGetter,
    this.pageType = '',
    this.iconColor,
    this.chartImageGetter,
    this.onChartTabRequested,
  });

  /// Corresponds to [ExportablePage.exportPageId].
  final String pageId;

  /// Category of the page (e.g. "load_profile", "event_logs", "device_id").
  final String pageType;

  /// Callback that provides the current page data snapshot as a [Map].
  final Map<String, dynamic> Function() dataGetter;

  /// Override the icon colour (defaults to AppBar's foreground colour).
  final Color? iconColor;

  /// Optional callback that captures the page chart as a base64 PNG string.
  /// When provided a "Include chart" toggle appears for PDF/DOCX exports.
  final Future<String?> Function()? chartImageGetter;

  /// Called when the user enables the "Include chart" toggle so the page
  /// can automatically switch to its Chart tab.
  final VoidCallback? onChartTabRequested;

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        expand: false,
        builder: (ctx, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            child: _ExportSheet(
              pageId: pageId,
              pageType: pageType,
              dataGetter: dataGetter,
              chartImageGetter: chartImageGetter,
              onChartTabRequested: onChartTabRequested,
              scrollController: scrollController,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Export page data',
      icon: Icon(Icons.upload_file, color: iconColor),
      onPressed: () => _open(context),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom sheet contents
// ---------------------------------------------------------------------------

class _ExportSheet extends StatefulWidget {
  const _ExportSheet({
    required this.pageId,
    required this.dataGetter,
    required this.scrollController,
    this.pageType = '',
    this.chartImageGetter,
    this.onChartTabRequested,
  });

  final String pageId;
  final String pageType;
  final Map<String, dynamic> Function() dataGetter;
  final ScrollController scrollController;
  final Future<String?> Function()? chartImageGetter;
  final VoidCallback? onChartTabRequested;

  @override
  State<_ExportSheet> createState() => _ExportSheetState();
}

class _ExportSheetState extends State<_ExportSheet> {
  _ExportFmt _format = _ExportFmt.xml;
  String? _folderPath;
  bool _exporting = false;
  bool _includeChart = false;
  // Shown inline inside the sheet – a SnackBar fired from a bottom sheet can
  // be hidden behind it on small screens, even with floating behaviour.
  String? _validationError;

  Future<void> _pickFolder() async {
    final path = await FilePicker.platform.getDirectoryPath(
      dialogTitle: 'Select export destination folder',
    );
    if (path != null && mounted) {
      setState(() {
        _folderPath = path;
        _validationError = null;
      });
    }
  }

  Future<void> _export() async {
    if (_folderPath == null) {
      setState(
          () => _validationError = 'Please select a destination folder first.');
      return;
    }

    setState(() => _exporting = true);
    try {
      final rawData = Map<String, dynamic>.from(widget.dataGetter());

      // Capture chart image for PDF / DOCX when the toggle is on
      final supportsChart =
          _format == _ExportFmt.pdf || _format == _ExportFmt.docx;
      if (_includeChart && supportsChart && widget.chartImageGetter != null) {
        final img = await widget.chartImageGetter!();
        if (img != null) rawData['chart_image_base64'] = img;
      }

      final data = json.encode(rawData);
      final fileNameSuffix = DeviceIdCache.data.entries
          .where((e) => e.value.trim().isNotEmpty)
          .map((e) => e.value.trim().replaceAll(RegExp(r'[^\w.-]'), '_'))
          .join('_');
      final ok = await MeterClient().exportData(
        pageId: widget.pageId,
        type: _format.name,
        data: data,
        folderPath: _folderPath!,
        pageType: widget.pageType,
        fileNameSuffix: fileNameSuffix,
      );
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ok
                ? 'Exported as ${_format.label} successfully.'
                : 'Export failed.'),
            backgroundColor: ok ? DesignTokens.success : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      final msg = e is GrpcError
          ? (e.message?.isNotEmpty == true ? e.message! : e.toString())
          : e.toString().replaceFirst('Exception: ', '');
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final f = _format;
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: DesignTokens.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Title
            Row(
              children: [
                Icon(Icons.upload_file, color: DesignTokens.primary600),
                const SizedBox(width: 10),
                const Text(
                  'Export page data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Page: ${widget.pageId}',
              style: const TextStyle(
                  fontSize: 12, color: DesignTokens.textSecondary),
            ),

            const SizedBox(height: 24),

            // --- Format dropdown ---
            const Text(
              'Export type',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondary),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<_ExportFmt>(
              key: ValueKey(f),
              value: _format,
              decoration: InputDecoration(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                    borderRadius: DesignTokens.brSm,
                    borderSide: const BorderSide(color: DesignTokens.gray200)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: DesignTokens.brSm,
                    borderSide: const BorderSide(color: DesignTokens.gray200)),
                prefixIcon: Icon(f.icon, color: f.color, size: 18),
                filled: true,
                fillColor: f.bgColor,
              ),
              items: _ExportFmt.values
                  .map((fmt) => DropdownMenuItem(
                        value: fmt,
                        child: Row(
                          children: [
                            Icon(fmt.icon, color: fmt.color, size: 16),
                            const SizedBox(width: 8),
                            Text(fmt.label,
                                style: TextStyle(
                                    color: fmt.color,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _format = v);
              },
            ),

            const SizedBox(height: 20),

            // --- Include chart toggle (PDF / DOCX only) ---
            if (widget.chartImageGetter != null &&
                (_format == _ExportFmt.pdf || _format == _ExportFmt.docx)) ...[
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _includeChart,
                onChanged: (v) {
                  setState(() => _includeChart = v);
                  if (v && widget.onChartTabRequested != null) {
                    widget.onChartTabRequested!();
                  }
                },
                title: const Text(
                  'Include chart',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                subtitle: const Text(
                  'Embeds the chart as an image in the exported file.\n'
                  'Navigate to the Chart tab first to ensure it is rendered.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(height: 4),
            ],

            // --- Folder picker ---
            const Text(
              'Destination folder',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondary),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      border: Border.all(color: DesignTokens.gray200),
                      borderRadius: DesignTokens.brSm,
                      color: DesignTokens.surface,
                    ),
                    child: Text(
                      _folderPath ?? 'No folder selected',
                      style: TextStyle(
                        fontSize: 13,
                        color: _folderPath != null
                            ? DesignTokens.textPrimary
                            : DesignTokens.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _pickFolder,
                  icon: const Icon(Icons.folder_open, size: 16),
                  label: const Text('Browse'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // --- Inline validation error ---
            // Shown inside the sheet so it is always visible regardless of
            // screen size (a SnackBar would be hidden behind the sheet).
            if (_validationError != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: TextStyle(
                          color: Colors.orange.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => setState(() => _validationError = null),
                      child: Icon(Icons.close,
                          size: 16, color: Colors.orange.shade700),
                    ),
                  ],
                ),
              ),

            // --- Export button ---
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _exporting ? null : _export,
                icon: _exporting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(f.icon, size: 16),
                label: Text(_exporting ? 'Exporting…' : 'Export as ${f.label}'),
                style: FilledButton.styleFrom(
                    backgroundColor: f.color,
                    padding: const EdgeInsets.symmetric(vertical: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
