import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/export/export_registry.dart';
import '../../core/theme/design_tokens.dart';
import '../../grpc/configuration_client.dart';
import '../../grpc/generated/configuration.pb.dart'
    show ExportTemplateFileEntry, GetExportTemplatesResponse;
import '../../core/navigation/app_route_observer.dart';
import '../../core/widget_keys.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';

// ---------------------------------------------------------------------------
// Export format definition
// ---------------------------------------------------------------------------

enum ExportFormat {
  xml('XML', Icons.code, Color(0xFF1565C0), Color(0xFFE3F2FD)),
  csv('CSV', Icons.table_chart, Color(0xFF2E7D32), Color(0xFFE8F5E9)),
  pdf('PDF', Icons.picture_as_pdf, Color(0xFFC62828), Color(0xFFFFEBEE)),
  docx('DOCX', Icons.description, Color(0xFF1565C0), Color(0xFFE3F2FD));

  const ExportFormat(this.label, this.icon, this.color, this.bgColor);

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
}

// ---------------------------------------------------------------------------
// Template model  in-memory only, persistence handled by the backend
// ---------------------------------------------------------------------------

class FormatTemplate {
  FormatTemplate({this.templateName = '', this.description = ''});

  String templateName;
  String description;

  bool get isConfigured => templateName.trim().isNotEmpty;
}

// ---------------------------------------------------------------------------
// TemplateConfigPage  lists all registered exportable pages
// ---------------------------------------------------------------------------

class TemplateConfigPage extends StatefulWidget {
  const TemplateConfigPage({super.key});

  @override
  State<TemplateConfigPage> createState() => _TemplateConfigPageState();
}

class _TemplateConfigPageState extends State<TemplateConfigPage> {
  @override
  Widget build(BuildContext context) {
    final pages = ExportRegistry.instance.availablePages;

    return Scaffold(
      backgroundColor: DesignTokens.backgroundOf(context),
      appBar: AppBar(
        title: const Text('Export Templates'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          RefreshAppBarButton(
              onPressed: () => setState(() {}), checkConnection: false),
        ],
      ),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            Expanded(
              child: pages.isEmpty
                  ? const _EmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(24),
                      itemCount: pages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, i) => _PageCard(info: pages[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        border:
            Border(bottom: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Export Templates',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: DesignTokens.textPrimaryOf(context)),
          ),
          const SizedBox(height: 4),
          Text(
            'Assign an export template per format for each exportable page.',
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            children:
                ExportFormat.values.map((f) => _FormatChip(format: f)).toList(),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _PageCard extends StatelessWidget {
  const _PageCard({required this.info});

  final ExportedPageInfo info;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: DesignTokens.surfaceOf(context),
      shape: RoundedRectangleBorder(
        borderRadius: DesignTokens.brMd,
        side: BorderSide(color: DesignTokens.borderOf(context)),
      ),
      child: InkWell(
        key: Key(TemplateConfigKeys.pageCard(info.id)),
        borderRadius: DesignTokens.brMd,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PageTemplateAssignmentPage(pageId: info.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: DesignTokens.isDark(context)
                    ? DesignTokens.darkSurfaceAlt
                    : DesignTokens.primary50,
                child: Icon(info.icon,
                    color: DesignTokens.isDark(context)
                        ? Colors.white
                        : DesignTokens.primary600,
                    size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.label,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: DesignTokens.textPrimaryOf(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'id: ${info.id}',
                      style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondaryOf(context)),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: ExportFormat.values
                          .map((f) => _FormatChip(format: f))
                          .toList(),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right,
                  color: DesignTokens.textSecondaryOf(context)),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _FormatChip extends StatelessWidget {
  const _FormatChip({required this.format});

  final ExportFormat format;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: format.bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: format.color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(format.icon, size: 14, color: format.color),
          const SizedBox(width: 4),
          Text(
            format.label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: format.color,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.layers_clear,
              size: 64, color: DesignTokens.textSecondaryOf(context)),
          const SizedBox(height: 16),
          Text(
            'No exportable pages registered.',
            style: TextStyle(
                fontSize: 16, color: DesignTokens.textSecondaryOf(context)),
          ),
          const SizedBox(height: 8),
          Text(
            'Call ExportRegistry.instance.register() in main.dart.',
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PageTemplateAssignmentPage  all formats on one scrollable page
// ---------------------------------------------------------------------------

class PageTemplateAssignmentPage extends StatefulWidget {
  const PageTemplateAssignmentPage({super.key, required this.pageId});

  final String pageId;

  @override
  State<PageTemplateAssignmentPage> createState() =>
      _PageTemplateAssignmentPageState();
}

class _PageTemplateAssignmentPageState extends State<PageTemplateAssignmentPage>
    implements RouteAware {
  // Selected template file per format
  final Map<ExportFormat, String?> _selected = {
    for (final f in ExportFormat.values) f: null,
  };

  ExportedPageInfo? _info;

  // Files loaded from the backend per format type
  Map<ExportFormat, List<String>> _filesByFormat = {};
  bool _filesLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _info = ExportRegistry.instance.availablePages
        .cast<ExportedPageInfo?>()
        .firstWhere((p) => p?.id == widget.pageId, orElse: () => null);
    _loadTemplateFiles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    appRouteObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPush() {}
  @override
  void didPopNext() {}
  @override
  void didPushNext() {}
  @override
  void didPop() {}

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _loadTemplateFiles() async {
    if (mounted) setState(() => _filesLoading = true);
    try {
      // Run both calls in parallel
      final results = await Future.wait([
        ConfigurationClient().listExportTemplateFiles(),
        ConfigurationClient().getExportTemplates(widget.pageId),
      ]);

      final entries = results[0] as List<ExportTemplateFileEntry>;
      final current = results[1] as GetExportTemplatesResponse;

      // Build available files map
      final map = <ExportFormat, List<String>>{};
      for (final entry in entries) {
        final format = ExportFormat.values
            .where((f) => f.name.toLowerCase() == entry.type.toLowerCase())
            .firstOrNull;
        if (format != null) {
          map[format] = List<String>.from(entry.files);
        }
      }

      // Pre-select saved templates (only if the file still exists in the list)
      final savedByFormat = {
        ExportFormat.xml: current.xmlTemplate,
        ExportFormat.csv: current.csvTemplate,
        ExportFormat.pdf: current.pdfTemplate,
        ExportFormat.docx: current.docxTemplate,
      };

      if (mounted) {
        setState(() {
          _filesByFormat = map;
          for (final f in ExportFormat.values) {
            final saved = savedByFormat[f] ?? '';
            final files = map[f] ?? [];
            _selected[f] =
                (saved.isNotEmpty && files.contains(saved)) ? saved : null;
          }
          _filesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _filesLoading = false);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await ConfigurationClient().setExportTemplates(
        pageName: widget.pageId,
        xmlTemplate: _selected[ExportFormat.xml] ?? '',
        csvTemplate: _selected[ExportFormat.csv] ?? '',
        pdfTemplate: _selected[ExportFormat.pdf] ?? '',
        docxTemplate: _selected[ExportFormat.docx] ?? '',
      );
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            const SnackBar(
              content: Text('Templates saved successfully.'),
              backgroundColor: DesignTokens.success,
            ),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text('Failed to save templates: $e'),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final label = _info?.label ?? widget.pageId;

    return Scaffold(
      backgroundColor: DesignTokens.backgroundOf(context),
      appBar: AppBar(
        title: Text('Templates — $label'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
      ),
      body: _filesLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tokens reference card
                  if (_info != null && _info!.tokens.isNotEmpty)
                    _TokensCard(tokens: _info!.tokens),

                  if (_info != null && _info!.tokens.isNotEmpty)
                    const SizedBox(height: 16),

                  // One card per format
                  ...ExportFormat.values.map((f) => _FormatRow(
                        format: f,
                        availableFiles: _filesByFormat[f] ?? [],
                        selected: _selected[f],
                        onChanged: (v) {
                          setState(() => _selected[f] = v);
                          print('Selected ${f.label} template: $v');
                        },
                      )),

                  const SizedBox(height: 32),

                  // Set button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      key: const Key(TemplateConfigKeys.setTemplatesBtn),
                      onPressed: _saving ? null : _save,
                      icon: _saving
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(_saving ? 'Saving…' : 'Set Templates'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tokens reference panel
// ---------------------------------------------------------------------------

class _TokensCard extends StatefulWidget {
  const _TokensCard({required this.tokens});
  final Map<String, String> tokens;

  @override
  State<_TokensCard> createState() => _TokensCardState();
}

class _TokensCardState extends State<_TokensCard> {
  bool _expanded = true;

  Future<void> _copy(String token) async {
    await Clipboard.setData(ClipboardData(text: '{{ $token }}'));
    if (mounted) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            content: Text('Copied {{ $token }}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = DesignTokens.isDark(context);
    final headerFg = isDark ? Colors.white : DesignTokens.primary600;
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: DesignTokens.brMd,
        border: Border.all(color: DesignTokens.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          InkWell(
            key: const Key(TemplateConfigKeys.tokensExpandBtn),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? DesignTokens.darkSurfaceAlt
                    : DesignTokens.primary50,
                borderRadius: _expanded
                    ? const BorderRadius.vertical(top: Radius.circular(12))
                    : DesignTokens.brMd,
                border: _expanded
                    ? Border(
                        bottom: BorderSide(
                            color: DesignTokens.primary600.withOpacity(0.2)))
                    : null,
              ),
              child: Row(
                children: [
                  Icon(Icons.code, size: 18, color: headerFg),
                  const SizedBox(width: 10),
                  Text(
                    'Available Template Tokens',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: headerFg,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: headerFg,
                  ),
                ],
              ),
            ),
          ),

          // Token list
          if (_expanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tap a token to copy it. Use {{ token }} syntax in your template.',
                    style: TextStyle(
                        fontSize: 12,
                        color: DesignTokens.textSecondaryOf(context)),
                  ),
                  const SizedBox(height: 12),
                  ...widget.tokens.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Token chip
                            GestureDetector(
                              key: Key(TemplateConfigKeys.tokenCopyBtn(e.key)),
                              onTap: () => _copy(e.key),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: const Color(0xFF4CAF50)
                                          .withOpacity(0.4)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.content_copy,
                                        size: 11, color: Color(0xFF2E7D32)),
                                    const SizedBox(width: 4),
                                    Text(
                                      '{{ ${e.key} }}',
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 12,
                                        color: Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Description
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        DesignTokens.textSecondaryOf(context),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// One format row: colored banner + dropdown
// ---------------------------------------------------------------------------

class _FormatRow extends StatelessWidget {
  const _FormatRow({
    required this.format,
    required this.availableFiles,
    required this.selected,
    required this.onChanged,
  });

  final ExportFormat format;
  final List<String> availableFiles;
  final String? selected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final f = format;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          borderRadius: DesignTokens.brMd,
          border: Border.all(color: DesignTokens.borderOf(context)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colored banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: f.bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                border: Border(
                  bottom: BorderSide(color: f.color.withOpacity(0.2)),
                ),
              ),
              child: Row(
                children: [
                  Icon(f.icon, size: 20, color: f.color),
                  const SizedBox(width: 10),
                  Text(
                    '${f.label} Template',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: f.color,
                    ),
                  ),
                  const Spacer(),
                  if (selected != null && selected!.isNotEmpty)
                    Icon(Icons.check_circle, size: 16, color: f.color),
                ],
              ),
            ),

            // Dropdown
            Padding(
              padding: const EdgeInsets.all(16),
              child: availableFiles.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 14),
                      decoration: BoxDecoration(
                        border:
                            Border.all(color: DesignTokens.borderOf(context)),
                        borderRadius: DesignTokens.brSm,
                      ),
                      child: Text(
                        'No ${f.label} template files available.',
                        style: TextStyle(
                            color: DesignTokens.textSecondaryOf(context),
                            fontSize: 13),
                      ),
                    )
                  : DropdownButtonFormField<String>(
                      key: Key(TemplateConfigKeys.formatDropdown(f.name)),
                      value: selected,
                      decoration: DesignTokens.inputDecoration(
                        hint: 'Select a ${f.label} template file',
                      ),
                      items: availableFiles
                          .map((file) => DropdownMenuItem(
                                value: file,
                                child:
                                    Text(file, overflow: TextOverflow.ellipsis),
                              ))
                          .toList(),
                      onChanged: onChanged,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
