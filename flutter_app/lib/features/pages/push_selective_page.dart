import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../util/grpc_error.dart';
import '../../state/app_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/meter_client.dart';
import '../push_setups/push_selective_config.dart';
import '../../core/widget_keys.dart';

// ---------------------------------------------------------------------------
// Row model shared by capture objects list and filter buffer table.
// ---------------------------------------------------------------------------
class _FilterRow {
  final int classId;
  final String objectName;
  final int attribute;
  final int value;
  final String logicalName;

  const _FilterRow({
    required this.classId,
    required this.objectName,
    required this.attribute,
    required this.value,
    required this.logicalName,
  });
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class PushSelectivePage extends StatefulWidget {
  final PushSelectiveConfig config;

  const PushSelectivePage({super.key, required this.config});

  @override
  State<PushSelectivePage> createState() => _PushSelectivePageState();
}

class _PushSelectivePageState extends State<PushSelectivePage>
    with TickerProviderStateMixin {
  late final IMeterClient _client;

  // Per-object filter buffer contents (starts empty, filled by drag-drop)
  late final List<List<_FilterRow>> _filterBuffers;

  // Per-object capture objects (lazy-loaded when tab becomes visible)
  late final List<List<_FilterRow>> _captureItems;
  late final List<bool> _captureLoading;
  late final List<bool> _captureLoaded;
  late final List<String?> _captureErrors;
  late final List<TextEditingController> _captureSearchControllers;

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    final n = widget.config.objects.length;
    _filterBuffers = List.generate(n, (_) => <_FilterRow>[]);
    _captureItems = List.generate(n, (_) => <_FilterRow>[]);
    _captureLoading = List.generate(n, (_) => false);
    _captureLoaded = List.generate(n, (_) => false);
    _captureErrors = List.generate(n, (_) => null);
    _captureSearchControllers =
        List.generate(n, (_) => TextEditingController());
    _tabController = TabController(length: n, vsync: this);
    _tabController.addListener(_onTabChanged);
    // Load the initially visible tab immediately
    if (n > 0) {
      final isConnected = ProviderScope.containerOf(context, listen: false)
          .read(appControllerProvider)
          .isConnected;
      if (isConnected) {
        _loadCaptureObjects(0, widget.config.objects[0].captureObjects);
      }
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return; // still animating
    final i = _tabController.index;
    if (!_captureLoaded[i] && !_captureLoading[i]) {
      _loadCaptureObjects(i, widget.config.objects[i].captureObjects);
    }
  }

  Future<void> _loadCaptureObjects(int index, String datasource) async {
    print('Loading capture objects for datasource: $datasource');
    if (_captureLoading[index]) return;
    setState(() {
      _captureLoading[index] = true;
      _captureErrors[index] = null;
    });
    try {
      final response = await _client.getPushSelectiveCaptureObjects(datasource);
      if (!mounted) return;
      setState(() {
        _captureItems[index] = response.entries
            .map((e) => _FilterRow(
                  classId: e.classId,
                  objectName: e.name,
                  attribute: e.attributeIndex,
                  value: e.dataIndex,
                  logicalName: e.obisCode,
                ))
            .toList();
        _captureLoaded[index] = true;
        _captureLoading[index] = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _captureErrors[index] = extractGrpcMessage(e);
        _captureLoading[index] = false;
      });
    }
  }

  void _retryLoadCaptureObjects(int index) {
    setState(() {
      _captureLoaded[index] = false;
      _captureErrors[index] = null;
    });
    _loadCaptureObjects(index, widget.config.objects[index].captureObjects);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    for (final c in _captureSearchControllers) c.dispose();
    _client.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final objects = widget.config.objects;
    final sc = SemanticColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.label),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Theme(
            data: Theme.of(context).copyWith(
              tabBarTheme: const TabBarThemeData(
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
              ),
            ),
            child: TabBar(
              controller: _tabController,
              isScrollable: objects.length > 3,
              indicatorColor: Colors.white,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle:
                  const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              tabs: [
                for (int i = 0; i < objects.length; i++)
                  Tab(
                    key: Key(PushSelectiveKeys.tab(i)),
                    child: Text(
                      objects[i].label.isNotEmpty
                          ? objects[i].label
                          : objects[i].captureObjects,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Breadcrumb(
                segments: ['Menu', 'Push Selective', widget.config.label]),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignTokens.backgroundOf(context),
                    DesignTokens.surfaceOf(context),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (int i = 0; i < objects.length; i++)
                    _buildObjectTab(i, objects[i]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Tab content per PushSelectiveObject
  // -------------------------------------------------------------------------
  Widget _buildObjectTab(int index, PushSelectiveObject obj) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: _buildObjectCard(index, obj),
    );
  }

  // -------------------------------------------------------------------------
  // Card per PushSelectiveObject
  // -------------------------------------------------------------------------
  Widget _buildObjectCard(int index, PushSelectiveObject obj) {
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: DesignTokens.brMd,
        border: Border.all(color: DesignTokens.borderOf(context)),
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCardHeader(obj.label),
          // Two-column body
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left – Capture Objects (fixed 260 px)
                SizedBox(
                  width: 260,
                  child: _buildCapturePanel(index, obj),
                ),
                Container(width: 1, color: DesignTokens.borderOf(context)),
                // Right – Filter Buffer (fills remaining width)
                Expanded(child: _buildFilterBufferPanel(index, obj)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHeader(String title) {
    final isDark = DesignTokens.isDark(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceAltOf(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border:
            Border(bottom: BorderSide(color: DesignTokens.borderOf(context))),
      ),
      child: Row(
        children: [
          Icon(Icons.filter_list,
              size: 15, color: isDark ? Colors.white : DesignTokens.primary600),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Left column — Capture Objects list (draggable items)
  // -------------------------------------------------------------------------
  Widget _buildCapturePanel(int index, PushSelectiveObject obj) {
    final items = _captureItems[index];
    final isLoading = _captureLoading[index];
    final error = _captureErrors[index];
    final searchCtrl = _captureSearchControllers[index];
    final query = searchCtrl.text.trim().toLowerCase();
    final filtered = query.isEmpty
        ? items
        : items
            .where((r) =>
                r.objectName.toLowerCase().contains(query) ||
                r.logicalName.toLowerCase().contains(query))
            .toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub-header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: DesignTokens.surfaceAltOf(context),
            border: Border(
                bottom: BorderSide(color: DesignTokens.borderOf(context))),
          ),
          child: Row(
            children: [
              Icon(Icons.list_alt,
                  size: 13,
                  color: DesignTokens.isDark(context)
                      ? Colors.white
                      : DesignTokens.primary600),
              const SizedBox(width: 5),
              Text(
                'Capture Objects',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textSecondaryOf(context),
                ),
              ),
              const SizedBox(width: 4),
              Flexible(child: _dsChip(obj.captureObjects)),
            ],
          ),
        ),
        // Search field (only when items are loaded)
        if (!isLoading && error == null && items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 2),
            child: SizedBox(
              height: 28,
              child: TextField(
                key: Key(PushSelectiveKeys.searchField(index)),
                controller: searchCtrl,
                style: const TextStyle(fontSize: 11),
                decoration: InputDecoration(
                  hintText: 'Search by name…',
                  hintStyle: TextStyle(
                      fontSize: 11,
                      color: DesignTokens.textSecondaryOf(context)),
                  prefixIcon: Icon(Icons.search,
                      size: 14, color: DesignTokens.textSecondaryOf(context)),
                  suffixIcon: query.isNotEmpty
                      ? InkWell(
                          key: Key(PushSelectiveKeys.searchClearBtn(index)),
                          onTap: () {
                            searchCtrl.clear();
                            setState(() {});
                          },
                          child: Icon(Icons.close,
                              size: 12,
                              color: DesignTokens.textSecondaryOf(context)),
                        )
                      : null,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide:
                        BorderSide(color: DesignTokens.borderOf(context)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide:
                        BorderSide(color: DesignTokens.borderOf(context)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: DesignTokens.primary600),
                  ),
                ),
              ),
            ),
          ),
        // Loading
        if (isLoading)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        // Error
        else if (error != null)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.error_outline, size: 24, color: Colors.red.shade400),
                const SizedBox(height: 6),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.red.shade400),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  key: Key(PushSelectiveKeys.captureRetryBtn(index)),
                  onPressed: ProviderScope.containerOf(context, listen: false)
                          .read(appControllerProvider)
                          .isConnected
                      ? () => _retryLoadCaptureObjects(index)
                      : null,
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Retry', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          )
        // Empty
        else if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.drag_indicator,
                    size: 24, color: DesignTokens.borderOf(context)),
                const SizedBox(height: 6),
                Text(
                  'No capture objects loaded',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 11,
                      color: DesignTokens.textSecondaryOf(context)),
                ),
              ],
            ),
          )
        else if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11, color: DesignTokens.textSecondaryOf(context)),
            ),
          )
        else
          ...filtered.map((row) => _buildDraggableItem(row)),
      ],
    );
  }

  Widget _buildDraggableItem(_FilterRow row) {
    final content = Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: DesignTokens.surfaceOf(context),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: DesignTokens.borderOf(context)),
      ),
      child: Row(
        children: [
          Icon(Icons.drag_indicator,
              size: 14, color: DesignTokens.textSecondaryOf(context)),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.objectName.isNotEmpty ? row.objectName : row.logicalName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
                Text(
                  '${row.logicalName}  ·  Class ${row.classId} · Attr ${row.attribute}',
                  style: TextStyle(
                      fontSize: 10,
                      color: DesignTokens.textSecondaryOf(context),
                      fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return Draggable<_FilterRow>(
      data: row,
      feedback: Material(
        elevation: 6,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 220,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: DesignTokens.primary600,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            row.objectName.isNotEmpty ? row.objectName : row.logicalName,
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: content),
      child: content,
    );
  }

  // -------------------------------------------------------------------------
  // Right column — Filter Buffer table (drag target)
  // -------------------------------------------------------------------------
  Widget _buildFilterBufferPanel(int index, PushSelectiveObject obj) {
    return DragTarget<_FilterRow>(
      onAccept: (row) {
        setState(() {
          if (!_filterBuffers[index]
              .any((r) => r.logicalName == row.logicalName)) {
            _filterBuffers[index].add(row);
          }
        });
      },
      builder: (context, candidateData, _) {
        final hovered = candidateData.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          decoration: hovered
              ? BoxDecoration(
                  color: DesignTokens.primary600.withOpacity(0.04),
                  border: Border.all(
                      color: DesignTokens.primary600.withOpacity(0.35),
                      width: 1.5),
                )
              : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sub-header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: hovered
                      ? DesignTokens.primary600.withOpacity(0.06)
                      : DesignTokens.surfaceAltOf(context),
                  border: Border(
                      bottom:
                          BorderSide(color: DesignTokens.borderOf(context))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.table_rows_outlined,
                        size: 13,
                        color: DesignTokens.isDark(context)
                            ? Colors.white
                            : DesignTokens.primary600),
                    const SizedBox(width: 5),
                    Text(
                      'Filter Buffer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textSecondaryOf(context),
                      ),
                    ),
                    const Spacer(),
                    hovered
                        ? Text(
                            'Drop to add',
                            style: TextStyle(
                                fontSize: 10,
                                color: DesignTokens.primary600,
                                fontStyle: FontStyle.italic),
                          )
                        : _dsChip(obj.filterBuffer),
                  ],
                ),
              ),
              // Column headers
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                color: DesignTokens.surfaceAltOf(context),
                child: Row(
                  children: [
                    _headerCell('Class ID', flex: 1),
                    _headerCell('Object Name', flex: 3),
                    _headerCell('Attribute', flex: 1),
                    _headerCell('Value', flex: 1),
                    _headerCell('Logical Name', flex: 3),
                    const SizedBox(width: 24), // room for delete icon
                  ],
                ),
              ),
              Divider(height: 1, color: DesignTokens.borderOf(context)),
              // Rows or empty placeholder
              if (_filterBuffers[index].isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    children: [
                      Icon(Icons.drag_handle,
                          size: 24, color: DesignTokens.borderOf(context)),
                      const SizedBox(height: 6),
                      Text(
                        'Drag capture objects here',
                        style: TextStyle(
                            fontSize: 11,
                            color: DesignTokens.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(_filterBuffers[index].length, (ri) {
                  final row = _filterBuffers[index][ri];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (ri > 0)
                        Divider(
                            height: 1, color: DesignTokens.borderOf(context)),
                      Container(
                        color: ri.isOdd
                            ? DesignTokens.surfaceAltOf(context)
                                .withOpacity(0.5)
                            : null,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        child: Row(
                          children: [
                            _dataCell(row.classId.toString(),
                                flex: 1, mono: true),
                            _dataCell(row.objectName, flex: 3),
                            _dataCell(row.attribute.toString(),
                                flex: 1, mono: true),
                            _dataCell(row.value.toString(),
                                flex: 1, mono: true),
                            _dataCell(row.logicalName, flex: 3, mono: true),
                            SizedBox(
                              width: 24,
                              child: InkWell(
                                key: Key(PushSelectiveKeys.removeBtn(index, ri)),
                                onTap: () => setState(() {
                                  _filterBuffers[index].removeAt(ri);
                                }),
                                borderRadius: BorderRadius.circular(4),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Icon(Icons.close,
                                      size: 12,
                                      color: DesignTokens.textSecondaryOf(
                                          context)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
            ],
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  Widget _dsChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: DesignTokens.primary600.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DesignTokens.primary600.withOpacity(0.25)),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 10, color: DesignTokens.primary600),
        ),
      );

  Widget _headerCell(String text, {required int flex}) => Expanded(
        flex: flex,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: DesignTokens.textSecondaryOf(context),
          ),
        ),
      );

  Widget _dataCell(String text, {required int flex, bool mono = false}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: DesignTokens.textPrimaryOf(context),
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      );
}
