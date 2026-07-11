import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../state/app_controller.dart';
import '../push_setups/push_setups_config.dart';
import '../super_manual/super_manual_models.dart';
import '../../core/widget_keys.dart';

class PushSetupPage extends StatefulWidget {
  final PushSetupConfig config;

  const PushSetupPage({super.key, required this.config});

  @override
  State<PushSetupPage> createState() => _PushSetupPageState();
}

class _PushSetupPageState extends State<PushSetupPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final tabCount = widget.config.tabs?.length ?? 1;
    _tabController = TabController(length: tabCount, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTabs = widget.config.tabs != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.label),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        bottom: hasTabs
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  for (int i = 0; i < widget.config.tabs!.length; i++)
                    Tab(
                      key: Key(PushSetupKeys.tab(i)),
                      text: widget.config.tabs![i].label,
                    ),
                ],
              )
            : null,
      ),
      drawer: const AppDrawer(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              DesignTokens.backgroundOf(context),
              DesignTokens.surfaceOf(context)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: hasTabs
            ? TabBarView(
                controller: _tabController,
                children: widget.config.tabs!
                    .map((t) => _CaptureListSection(
                          label: t.label,
                          dataSource: t.dataSource,
                        ))
                    .toList(),
              )
            : _CaptureListSection(
                label: widget.config.label,
                dataSource: widget.config.dataSource ?? '',
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Communication window time model
// ─────────────────────────────────────────────────────────────────────────────

class _CosemDateTime {
  int day;
  int month;
  int year;
  int weekday;
  int hour;
  int minute;
  int second;

  _CosemDateTime({
    this.day = 1,
    this.month = 1,
    this.year = 2000,
    this.weekday = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
  });

  _CosemDateTime copy() => _CosemDateTime(
        day: day,
        month: month,
        year: year,
        weekday: weekday,
        hour: hour,
        minute: minute,
        second: second,
      );

  // Sentinel values displayed as special labels
  static const _dayWildcards = {0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF'};
  static const _monthWildcards = {0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF'};
  static const _yearWildcards = {0xFFFF: 'FFFF'};
  static const _byteWildcards = {0xFF: 'FF'};

  static String _fmt(int v, Map<int, String> wildcards, {int pad = 0}) =>
      wildcards[v] ?? v.toString().padLeft(pad, '0');

  String get display => '${_fmt(day, _dayWildcards, pad: 2)}'
      '-${_fmt(month, _monthWildcards, pad: 2)}'
      '-${_fmt(year, _yearWildcards, pad: 4)} '
      'WD:${_fmt(weekday, _byteWildcards)} '
      '${_fmt(hour, _byteWildcards, pad: 2)}'
      ':${_fmt(minute, _byteWildcards, pad: 2)}'
      ':${_fmt(second, _byteWildcards, pad: 2)}';
}

class _CommWindow {
  String start;
  String end;
  _CosemDateTime? startDt;
  _CosemDateTime? endDt;
  _CommWindow(
      {required this.start, required this.end, this.startDt, this.endDt});
}

// ─────────────────────────────────────────────────────────────────────────────
// Entry model for the capture list accumulator
// ─────────────────────────────────────────────────────────────────────────────

class _CaptureEntry {
  final int classId;
  final int attrId;
  final String logicalNameHex;
  final String objectName;
  final String attrName;
  int dataIndex;
  int restrictionType;
  // Data-index controller
  final dataIndexCtrl = TextEditingController();
  // Date-range restriction controllers
  final fromDateCtrl = TextEditingController();
  final toDateCtrl = TextEditingController();
  // Parsed DateTime counterparts (kept in sync with controllers)
  DateTime? fromDateTime;
  DateTime? toDateTime;
  // Entry-range restriction controllers
  final fromEntryCtrl = TextEditingController();
  final toEntryCtrl = TextEditingController();

  _CaptureEntry({
    required this.classId,
    required this.attrId,
    required this.logicalNameHex,
    required this.objectName,
    required this.attrName,
    this.dataIndex = 0,
    this.restrictionType = 0,
    String fromDate = '',
    String toDate = '',
    int fromEntry = 0,
    int toEntry = 0,
  }) {
    dataIndexCtrl.text = dataIndex != 0 ? '$dataIndex' : '';
    fromDateCtrl.text = fromDate;
    toDateCtrl.text = toDate;
    fromDateTime = fromDate.isNotEmpty ? DateTime.tryParse(fromDate) : null;
    toDateTime = toDate.isNotEmpty ? DateTime.tryParse(toDate) : null;
    fromEntryCtrl.text = fromEntry != 0 ? '$fromEntry' : '';
    toEntryCtrl.text = toEntry != 0 ? '$toEntry' : '';
  }

  void dispose() {
    dataIndexCtrl.dispose();
    fromDateCtrl.dispose();
    toDateCtrl.dispose();
    fromEntryCtrl.dispose();
    toEntryCtrl.dispose();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Capture List Reset Section
// ─────────────────────────────────────────────────────────────────────────────

class _CaptureListSection extends ConsumerStatefulWidget {
  const _CaptureListSection({
    required this.label,
    required this.dataSource,
  });
  final String label;
  final String dataSource;

  @override
  ConsumerState<_CaptureListSection> createState() =>
      _CaptureListSectionState();
}

class _CaptureListSectionState extends ConsumerState<_CaptureListSection> {
  late final IMeterClient _client;

  // ── Object list state ────────────────────────────────────────────────────
  List<DatamodelObject> _objects = [];
  bool _loadingObjects = true;
  String _filter = '';
  DatamodelObject? _selectedObject;

  // ── Attributes / methods state ───────────────────────────────────────────
  List<DatamodelAttribute> _attrs = [];
  bool _loadingAttrs = false;
  final Set<String> _checkedIds = {};
  final List<_CaptureEntry> _captureEntries = [];
  bool _loadingCaptureList = false;
  bool _writingCaptureList = false;

  // ── Push parameter state ─────────────────────────────────────────────────
  final _hScrollCtrl = ScrollController();
  final _randomStartCtrl = TextEditingController();
  final _retriesCtrl = TextEditingController();
  final _repDelayMinCtrl = TextEditingController();
  final _repDelayExpCtrl = TextEditingController();
  final _repDelayMaxCtrl = TextEditingController();
  DateTime? _lastConfirmDt;
  bool _randomStartReading = false;
  bool _randomStartWriting = false;
  bool _retriesReading = false;
  bool _retriesWriting = false;
  bool _repDelayReading = false;
  bool _repDelayWriting = false;
  bool _lastConfirmReading = false;
  bool _lastConfirmWriting = false;
  bool _pushing = false;
  bool _resetting = false;
  bool _isConnected = false;

  // ── Send destination state ──────────────────────────────────────────────
  int _transportService = 0;
  final _destinationCtrl = TextEditingController();
  int _messageType = 0;
  bool _sendDestReading = false;
  bool _sendDestWriting = false;

  // ── Communication window state ─────────────────────────────────────────
  final List<_CommWindow> _commWindows = [];
  bool _commWindowReading = false;
  bool _commWindowWriting = false;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!ref.read(appControllerProvider).isConnected) return;
    await _loadObjects();
    if (!mounted) return;
    await _loadCaptureList();
    if (!mounted) return;
    await _loadRandomisationStartInterval();
    if (!mounted) return;
    await _loadNumberOfRetries();
    if (!mounted) return;
    await _loadRepetitionDelay();
    if (!mounted) return;
    await _loadLastConfirmationDatetime();
    if (!mounted) return;
    await _loadSendDestination();
    if (!mounted) return;
    await _loadCommunicationWindow();
  }

  @override
  void dispose() {
    _client.close();
    _hScrollCtrl.dispose();
    for (final e in _captureEntries) e.dispose();
    _randomStartCtrl.dispose();
    _retriesCtrl.dispose();
    _repDelayMinCtrl.dispose();
    _repDelayExpCtrl.dispose();
    _repDelayMaxCtrl.dispose();
    _destinationCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRandomisationStartInterval() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _randomStartReading = true);
    try {
      final value =
          await _client.getRandomisationStartInterval(widget.dataSource);
      if (mounted) setState(() => _randomStartCtrl.text = value.toString());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read randomisation interval failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _randomStartReading = false);
    }
  }

  Future<void> _loadLastConfirmationDatetime() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _lastConfirmReading = true);
    try {
      final value =
          await _client.getLastConfirmationDatetime(widget.dataSource);
      final dt = DateTime.tryParse(value);
      if (mounted) setState(() => _lastConfirmDt = dt);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read last confirmation datetime failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _lastConfirmReading = false);
    }
  }

  Future<void> _loadSendDestination() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _sendDestReading = true);
    try {
      final value = await _client.getSendDestination(widget.dataSource);
      if (mounted) {
        setState(() {
          _transportService = value.tcpService;
          _destinationCtrl.text = value.destination;
          _messageType = value.message;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read send destination failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _sendDestReading = false);
    }
  }

  Future<void> _loadCommunicationWindow() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _commWindowReading = true);
    try {
      final windows = await _client.getCommunicationWindow(widget.dataSource);
      if (mounted) {
        setState(() {
          _commWindows.clear();
          for (final w in windows) {
            _commWindows.add(_CommWindow(start: w.startTime, end: w.endTime));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read communication window failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _commWindowReading = false);
    }
  }

  Future<void> _loadRepetitionDelay() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _repDelayReading = true);
    try {
      final value = await _client.getRepetitionDelay(widget.dataSource);
      if (mounted) {
        setState(() {
          _repDelayMinCtrl.text = value.min.toString();
          _repDelayExpCtrl.text = value.exponent.toString();
          _repDelayMaxCtrl.text = value.max.toString();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read repetition delay failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _repDelayReading = false);
    }
  }

  Future<void> _loadNumberOfRetries() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _retriesReading = true);
    try {
      final value = await _client.getNumberOfRetries(widget.dataSource);
      if (mounted) setState(() => _retriesCtrl.text = value.toString());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
                backgroundColor: Colors.red.shade700,
                content: Text(
                    'Read number of retries failed: ${extractGrpcMessage(e)}')),
          );
      }
    } finally {
      if (mounted) setState(() => _retriesReading = false);
    }
  }

  Future<void> _loadCaptureList() async {
    if (widget.dataSource.isEmpty) return;
    if (!mounted) return;
    setState(() => _loadingCaptureList = true);
    try {
      final items = await _client.getPushObjectList(widget.dataSource);
      if (!mounted) return;
      setState(() {
        _captureEntries
          ..forEach((old) => old.dispose())
          ..clear()
          ..addAll(items.map((e) => _CaptureEntry(
                classId: e.classId,
                attrId: e.attributeIndex,
                logicalNameHex: e.logicalName,
                objectName: e.objectName,
                attrName: e.objectName,
                dataIndex: e.dataIndex,
                restrictionType: e.restrictionType,
                fromDate: e.hasDateRange() ? e.dateRange.fromDate : '',
                toDate: e.hasDateRange() ? e.dateRange.toDate : '',
                fromEntry: e.hasEntryRange() ? e.entryRange.fromEntry : 0,
                toEntry: e.hasEntryRange() ? e.entryRange.toEntry : 0,
              )));
        // Refresh checkboxes for the currently visible object
        if (_selectedObject != null) {
          _checkedIds
            ..clear()
            ..addAll(_captureEntries
                .where((e) => e.objectName == _selectedObject!.name)
                .map((e) => '${e.attrId}'));
        }
        _loadingCaptureList = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingCaptureList = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(extractGrpcMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ));
      }
    }
  }

  Future<void> _loadObjects() async {
    setState(() => _loadingObjects = true);
    try {
      final list = await _client.getDatamodelObjects();
      if (mounted)
        setState(() {
          _objects = list;
          _loadingObjects = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingObjects = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(extractGrpcMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ));
      }
    }
  }

  Future<void> _selectObject(DatamodelObject obj) async {
    final moduleName = ref.read(appControllerProvider).moduleName ?? '';
    setState(() {
      _selectedObject = obj;
      _loadingAttrs = true;
      _attrs = [];
      // Restore checkboxes for this object from the accumulated capture list
      _checkedIds
        ..clear()
        ..addAll(_captureEntries
            .where((e) => e.objectName == obj.name)
            .map((e) => '${e.attrId}'));
    });
    try {
      final list = await _client.getDatamodelAttributesByObjectName(
          obj.name, moduleName);
      if (mounted)
        setState(() {
          _attrs = list;
          _loadingAttrs = false;
        });
    } catch (e) {
      if (mounted) {
        setState(() => _loadingAttrs = false);
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(extractGrpcMessage(e)),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
          ));
      }
    }
  }

  void _toggle(DatamodelAttribute attr) {
    final key = _attrKey(attr);
    setState(() {
      if (_checkedIds.contains(key)) {
        _checkedIds.remove(key);
        _captureEntries.removeWhere((e) =>
            e.objectName == _selectedObject!.name && e.attrId == attr.id);
      } else {
        _checkedIds.add(key);
        _captureEntries.add(_CaptureEntry(
          classId: _selectedObject!.classId,
          attrId: attr.id,
          logicalNameHex: _selectedObject!.logicalNameHex,
          objectName: _selectedObject!.name,
          attrName: attr.name,
        ));
      }
    });
  }

  void _selectAll() {
    setState(() {
      for (final attr in _attrs) {
        final key = _attrKey(attr);
        if (!_checkedIds.contains(key)) {
          _checkedIds.add(key);
          _captureEntries.add(_CaptureEntry(
            classId: _selectedObject!.classId,
            attrId: attr.id,
            logicalNameHex: _selectedObject!.logicalNameHex,
            objectName: _selectedObject!.name,
            attrName: attr.name,
          ));
        }
      }
    });
  }

  void _clearAll() {
    setState(() {
      _checkedIds.clear();
      if (_selectedObject != null) {
        _captureEntries
            .where((e) => e.objectName == _selectedObject!.name)
            .toList()
            .forEach((e) {
          e.dispose();
          _captureEntries.remove(e);
        });
      }
    });
  }

  String _attrKey(DatamodelAttribute a) => '${a.id}';

  // ── Derived lists ────────────────────────────────────────────────────────

  bool _isMethod(DatamodelAttribute a) {
    final rights = a.accessRights.toLowerCase();
    return rights.contains('action') ||
        rights.contains('execute') ||
        rights.contains('method');
  }

  List<DatamodelObject> get _filteredObjects {
    if (_filter.isEmpty) return _objects;
    final lower = _filter.toLowerCase();
    return _objects.where((o) {
      return o.name.toLowerCase().contains(lower) ||
          o.logicalName.toLowerCase().contains(lower);
    }).toList();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    _isConnected = ref.watch(appControllerProvider).isConnected;
    return LayoutBuilder(builder: (context, constraints) {
      final availW = constraints.maxWidth - 32; // 2 × 16 padding
      final objW = (availW * 0.20).clamp(180.0, 300.0);
      final captureW = (availW * 0.30).clamp(300.0, 460.0);
      final pushW = (availW * 0.18).clamp(180.0, 280.0);
      final bottomH = (constraints.maxHeight * 0.30).clamp(280.0, 340.0);

      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildObjectListPanel(width: objW),
                  const SizedBox(width: 12),
                  Expanded(child: _buildAttributesPanel()),
                  const SizedBox(width: 12),
                  _buildCaptureTablePanel(width: captureW),
                  const SizedBox(width: 12),
                  _buildPushParametersColumn(width: pushW),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: bottomH,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _buildCommunicationWindowSection()),
                  const SizedBox(width: 12),
                  SizedBox(width: pushW, child: _buildSendDestSection()),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Object list panel (left) ──────────────────────────────────────────────

  Widget _buildObjectListPanel({required double width}) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          borderRadius: DesignTokens.brMd,
          border: Border.all(color: DesignTokens.borderOf(context)),
          boxShadow: DesignTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            _panelHeader(
              icon: Icons.list_alt,
              label: 'Object List',
              trailing: _loadingObjects
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      '${_filteredObjects.length}',
                      style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondaryOf(context)),
                    ),
            ),
            // Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 4),
              child: TextField(
                key: const Key('push_setup_filter_field'),
                decoration: InputDecoration(
                  hintStyle: TextStyle(
                      fontSize: 12,
                      color: DesignTokens.textSecondaryOf(context)),
                  prefixIcon: const Icon(Icons.search, size: 16),
                  isDense: true,
                  filled: true,
                  fillColor: DesignTokens.isDark(context)
                      ? DesignTokens.darkFill
                      : DesignTokens.surface,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                    borderSide: BorderSide(
                        color: DesignTokens.isDark(context)
                            ? DesignTokens.darkFocus
                            : DesignTokens.primary600,
                        width: 1.2),
                  ),
                ),
                onChanged: (v) => setState(() => _filter = v),
              ),
            ),
            const Divider(height: 1),
            // List
            Expanded(
              child: _loadingObjects
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredObjects.isEmpty
                      ? Center(
                          child: Text(
                            'No objects',
                            style: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondaryOf(context)),
                          ),
                        )
                      : ListView.separated(
                          itemCount: _filteredObjects.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1, color: DesignTokens.borderOf(context)),
                          itemBuilder: (_, i) {
                            final obj = _filteredObjects[i];
                            return DictionaryListItem(
                              key: ValueKey('${obj.name}_${obj.logicalName}'),
                              object: obj,
                              active: obj == _selectedObject,
                              onTap: () => _selectObject(obj),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Attributes & methods panel (right) ────────────────────────────────────

  Widget _buildAttributesPanel() {
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
          _panelHeader(
            icon: Icons.tune,
            label: _selectedObject != null
                ? 'Attributes & Methods — ${_selectedObject!.name}'
                : 'Attributes & Methods',
            trailing: _selectedObject != null && _attrs.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        key: const Key(PushSetupKeys.selectAllBtn),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: _selectAll,
                        child: const Text('Select all',
                            style: TextStyle(fontSize: 11)),
                      ),
                      TextButton(
                        key: const Key(PushSetupKeys.clearAllBtn),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                        onPressed: _clearAll,
                        child:
                            const Text('Clear', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  )
                : null,
          ),
          const Divider(height: 1),
          Expanded(
            child: _buildAttributesBody(),
          ),
          // ── Selection summary bar ─────────────────────────────────────
          if (_selectedObject != null && _checkedIds.isNotEmpty)
            _buildSelectionBar(),
        ],
      ),
    );
  }

  Widget _buildAttributesBody() {
    if (_selectedObject == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_back,
                size: 32, color: DesignTokens.borderOf(context)),
            const SizedBox(height: 10),
            Text(
              'Select an object from the list on the left.',
              style: TextStyle(
                  fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
            ),
          ],
        ),
      );
    }

    if (_loadingAttrs) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_attrs.isEmpty) {
      return Center(
        child: Text(
          'No attributes found for this object.',
          style: TextStyle(
              fontSize: 13, color: DesignTokens.textSecondaryOf(context)),
        ),
      );
    }

    final attributes = _attrs.where((a) => !_isMethod(a)).toList();
    final methods = _attrs.where((a) => _isMethod(a)).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (attributes.isNotEmpty)
            ..._buildGroup('Attributes', Icons.input, attributes),
          if (attributes.isNotEmpty && methods.isNotEmpty)
            const SizedBox(height: 8),
          if (methods.isNotEmpty)
            ..._buildGroup('Methods', Icons.play_circle_outline, methods),
        ],
      ),
    );
  }

  List<Widget> _buildGroup(
      String title, IconData icon, List<DatamodelAttribute> items) {
    return [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Icon(icon, size: 14, color: DesignTokens.primary600),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DesignTokens.primary600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: DesignTokens.primary600.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${items.length}',
                style: TextStyle(fontSize: 10, color: DesignTokens.primary600),
              ),
            ),
          ],
        ),
      ),
      ...items.map((a) => _buildAttrRow(a)),
    ];
  }

  Widget _buildAttrRow(DatamodelAttribute attr) {
    final key = _attrKey(attr);
    final checked = _checkedIds.contains(key);
    return InkWell(
      onTap: () => _toggle(attr),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) => _toggle(attr),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          attr.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: DesignTokens.textPrimaryOf(context),
                            fontWeight:
                                checked ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      _accessBadge(attr.accessRights),
                    ],
                  ),
                  if (attr.description.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      attr.description,
                      style: TextStyle(
                          fontSize: 11,
                          color: DesignTokens.textSecondaryOf(context)),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accessBadge(String rights) {
    if (rights.isEmpty) return const SizedBox.shrink();
    final lower = rights.toLowerCase();
    Color color;
    if (lower.contains('read') && lower.contains('write')) {
      color = Colors.green;
    } else if (lower.contains('write')) {
      color = Colors.orange;
    } else if (lower.contains('action') || lower.contains('execute')) {
      color = Colors.purple;
    } else {
      color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        rights,
        style:
            TextStyle(fontSize: 9, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildSelectionBar() {
    final count = _checkedIds.length;
    return Container(
      decoration: BoxDecoration(
        color: DesignTokens.primary600.withOpacity(0.08),
        border: Border(
            top: BorderSide(color: DesignTokens.primary600.withOpacity(0.2))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 16, color: DesignTokens.primary600),
          const SizedBox(width: 8),
          Text(
            '$count item${count == 1 ? '' : 's'} selected',
            style: TextStyle(
              fontSize: 13,
              color: DesignTokens.primary600,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panelHeader(
      {required IconData icon, required String label, Widget? trailing}) {
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
          Icon(icon, size: 15, color: DesignTokens.primary600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimaryOf(context),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ],
        ],
      ),
    );
  }

  // ── Capture table panel (right) ──────────────────────────────────────────

  Widget _buildCaptureTablePanel({required double width}) {
    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: DesignTokens.surfaceOf(context),
          borderRadius: DesignTokens.brMd,
          border: Border.all(color: DesignTokens.borderOf(context)),
          boxShadow: DesignTokens.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _panelHeader(
              icon: Icons.playlist_add_check,
              label: 'Capture List',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Load from device button
                  Tooltip(
                    message: 'Load from device',
                    child: InkWell(
                      key: const Key(PushSetupKeys.captureLoadBtn),
                      onTap: !_isConnected || _loadingCaptureList
                          ? null
                          : _loadCaptureList,
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _loadingCaptureList
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.visibility_outlined,
                                size: 16, color: DesignTokens.primary600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  // Write to device button
                  Tooltip(
                    message: 'Write to device',
                    child: InkWell(
                      key: const Key(PushSetupKeys.captureWriteBtn),
                      onTap: (!_isConnected ||
                              _loadingCaptureList ||
                              _writingCaptureList ||
                              _captureEntries.isEmpty)
                          ? null
                          : () async {
                              setState(() => _writingCaptureList = true);
                              try {
                                final items = _captureEntries.map((e) {
                                  final item = PushObjectItem()
                                    ..classId = e.classId
                                    ..attributeIndex = e.attrId
                                    ..logicalName = e.logicalNameHex
                                    ..objectName = e.objectName
                                    ..dataIndex =
                                        int.tryParse(e.dataIndexCtrl.text) ?? 0
                                    ..restrictionType = e.restrictionType;
                                  if (e.restrictionType == 1) {
                                    item.dateRange =
                                        PushObjectRestrictionDateRange()
                                          ..fromDate = e.fromDateCtrl.text
                                          ..toDate = e.toDateCtrl.text;
                                  } else if (e.restrictionType == 2) {
                                    item.entryRange =
                                        PushObjectRestrictionEntryRange()
                                          ..fromEntry = int.tryParse(
                                                  e.fromEntryCtrl.text) ??
                                              0
                                          ..toEntry = int.tryParse(
                                                  e.toEntryCtrl.text) ??
                                              0;
                                  }
                                  return item;
                                }).toList();
                                await _client.setPushObjectList(
                                    widget.dataSource, items);
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context)
                                    ..clearSnackBars()
                                    ..showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Write failed: ${extractGrpcMessage(e)}'),
                                        backgroundColor: Colors.red.shade700,
                                      ),
                                    );
                                }
                              } finally {
                                if (mounted)
                                  setState(() => _writingCaptureList = false);
                              }
                            },
                      borderRadius: BorderRadius.circular(4),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: _writingCaptureList
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Icon(Icons.edit_outlined,
                                size: 16,
                                color: _captureEntries.isEmpty
                                    ? DesignTokens.borderOf(context)
                                    : DesignTokens.primary600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: DesignTokens.primary600.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_captureEntries.length}',
                      style: TextStyle(
                          fontSize: 11, color: DesignTokens.primary600),
                    ),
                  ),
                  if (_captureEntries.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    InkWell(
                      key: const Key(PushSetupKeys.captureClearBtn),
                      onTap: () => setState(() {
                        for (final e in _captureEntries) e.dispose();
                        _captureEntries.clear();
                        _checkedIds.clear();
                      }),
                      borderRadius: BorderRadius.circular(4),
                      child: Tooltip(
                        message: 'Clear all',
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(Icons.delete_sweep,
                              size: 16,
                              color: DesignTokens.textSecondaryOf(context)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Divider(height: 1),
            if (_captureEntries.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.playlist_add,
                          size: 32, color: DesignTokens.borderOf(context)),
                      const SizedBox(height: 8),
                      Text(
                        'No items selected.\nCheck attributes to\nadd them here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textSecondaryOf(context)),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // Column headers
              Container(
                color: DesignTokens.surfaceAltOf(context),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _hScrollCtrl,
                  child: Row(
                    children: [
                      // drag handle placeholder
                      const SizedBox(width: 28),
                      _tableHeaderCell('Class ID', width: 64),
                      _tableHeaderCell('Attr ID', width: 56),
                      _tableHeaderCell('Data Idx', width: 58),
                      _tableHeaderCell('Restriction', width: 130),
                      _tableHeaderCell('Restriction Value', width: 250),
                      _tableHeaderCell('Object Name', width: 200),
                      _tableHeaderCell('Hex Logical Name', width: 200),
                      const SizedBox(width: 30),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              // Rows (reorderable)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _hScrollCtrl,
                  child: SizedBox(
                    width: 1016,
                    child: ReorderableListView.builder(
                      buildDefaultDragHandles: false,
                      itemCount: _captureEntries.length,
                      onReorder: (oldIndex, newIndex) {
                        setState(() {
                          if (newIndex > oldIndex) newIndex--;
                          final item = _captureEntries.removeAt(oldIndex);
                          _captureEntries.insert(newIndex, item);
                        });
                      },
                      itemBuilder: (_, i) {
                        final e = _captureEntries[i];
                        return SizedBox(
                          key: ValueKey('${e.objectName}_${e.attrId}_$i'),
                          width: 1016,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    color: DesignTokens.borderOf(context)),
                              ),
                            ),
                            child: Row(
                              children: [
                                ReorderableDragStartListener(
                                  index: i,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 8),
                                    child: Icon(Icons.drag_handle,
                                        size: 16,
                                        color: DesignTokens.textSecondaryOf(
                                            context)),
                                  ),
                                ),
                                _tableDataCell('${e.classId}', width: 64),
                                _tableDataCell('${e.attrId}', width: 56),
                                SizedBox(
                                  width: 58,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: _restrictionField(
                                        e.dataIndexCtrl, '0',
                                        digits: true),
                                  ),
                                ),
                                SizedBox(
                                  width: 130,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: DropdownButton<int>(
                                      value: e.restrictionType,
                                      isDense: true,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: DesignTokens.textPrimaryOf(
                                              context)),
                                      onChanged: (v) {
                                        if (v != null)
                                          setState(() => e.restrictionType = v);
                                      },
                                      items: const [
                                        DropdownMenuItem(
                                            value: 0, child: Text('None')),
                                        DropdownMenuItem(
                                            value: 1,
                                            child: Text('Range by date')),
                                        DropdownMenuItem(
                                            value: 2,
                                            child: Text('Range by entry')),
                                      ],
                                    ),
                                  ),
                                ),
                                _buildRestrictionValueCell(e),
                                _tableDataCell(e.objectName, width: 200),
                                _tableDataCell(
                                  e.logicalNameHex.isNotEmpty
                                      ? e.logicalNameHex
                                      : '—',
                                  width: 200,
                                ),
                                InkWell(
                                  onTap: () => _removeEntry(e),
                                  borderRadius: BorderRadius.circular(4),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(Icons.close,
                                        size: 13,
                                        color: DesignTokens.textSecondaryOf(
                                            context)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictionValueCell(_CaptureEntry e) {
    return SizedBox(
      width: 250,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: switch (e.restrictionType) {
          1 => Row(children: [
              _buildDateTimeSelector(
                entry: e,
                label: 'From',
                current: e.fromDateTime,
                onPicked: (dt) {
                  e.fromDateTime = dt;
                  e.fromDateCtrl.text = '${dt.year.toString().padLeft(4, '0')}-'
                      '${dt.month.toString().padLeft(2, '0')}-'
                      '${dt.day.toString().padLeft(2, '0')} '
                      '${dt.hour.toString().padLeft(2, '0')}:'
                      '${dt.minute.toString().padLeft(2, '0')}:'
                      '${dt.second.toString().padLeft(2, '0')}';
                },
              ),
              const SizedBox(width: 4),
              _buildDateTimeSelector(
                entry: e,
                label: 'To',
                current: e.toDateTime,
                onPicked: (dt) {
                  e.toDateTime = dt;
                  e.toDateCtrl.text = '${dt.year.toString().padLeft(4, '0')}-'
                      '${dt.month.toString().padLeft(2, '0')}-'
                      '${dt.day.toString().padLeft(2, '0')} '
                      '${dt.hour.toString().padLeft(2, '0')}:'
                      '${dt.minute.toString().padLeft(2, '0')}:'
                      '${dt.second.toString().padLeft(2, '0')}';
                },
              ),
            ]),
          2 => Row(children: [
              Expanded(
                  child:
                      _restrictionField(e.fromEntryCtrl, 'From', digits: true)),
              const SizedBox(width: 4),
              Expanded(
                  child: _restrictionField(e.toEntryCtrl, 'To', digits: true)),
            ]),
          _ => Center(
              child: Text('—',
                  style: TextStyle(
                      fontSize: 11,
                      color: DesignTokens.textSecondaryOf(context)))),
        },
      ),
    );
  }

  Widget _buildDateTimeSelector({
    required _CaptureEntry entry,
    required String label,
    required DateTime? current,
    required void Function(DateTime) onPicked,
  }) {
    final display = current == null
        ? label
        : '${current.year.toString().padLeft(4, '0')}-'
            '${current.month.toString().padLeft(2, '0')}-'
            '${current.day.toString().padLeft(2, '0')} '
            '${current.hour.toString().padLeft(2, '0')}:'
            '${current.minute.toString().padLeft(2, '0')}:'
            '${current.second.toString().padLeft(2, '0')}';
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () async {
          final base = current ?? DateTime.now();
          final date = await showDatePicker(
            context: context,
            initialDate: base,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (date == null || !mounted) return;
          final time = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.fromDateTime(base),
          );
          if (time == null || !mounted) return;
          final sec = await _showSecondsPicker(context, base.second);
          if (sec == null || !mounted) return;
          setState(() => onPicked(DateTime(
              date.year, date.month, date.day, time.hour, time.minute, sec)));
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: DesignTokens.borderOf(context)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today_outlined,
                  size: 11, color: DesignTokens.primary600),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  display,
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: 'monospace',
                    color: current == null
                        ? DesignTokens.textSecondaryOf(context)
                        : DesignTokens.textPrimaryOf(context),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _restrictionField(TextEditingController ctrl, String hint,
      {bool digits = false}) {
    return TextField(
      controller: ctrl,
      style:
          TextStyle(fontSize: 11, color: DesignTokens.textPrimaryOf(context)),
      keyboardType: digits ? TextInputType.number : TextInputType.text,
      inputFormatters: digits ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            fontSize: 10, color: DesignTokens.textSecondaryOf(context)),
        isDense: true,
        filled: true,
        fillColor: DesignTokens.isDark(context)
            ? DesignTokens.darkFill
            : DesignTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkFocus
                  : DesignTokens.primary600,
              width: 1.2),
        ),
      ),
    );
  }

  Widget _tableHeaderCell(String text, {double? width}) {
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: DesignTokens.textSecondaryOf(context),
        ),
      ),
    );
    return width != null ? SizedBox(width: width, child: cell) : cell;
  }

  Widget _tableDataCell(String text, {double? width}) {
    final cell = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 12, color: DesignTokens.textPrimaryOf(context)),
        overflow: TextOverflow.ellipsis,
      ),
    );
    return width != null ? SizedBox(width: width, child: cell) : cell;
  }

  void _removeEntry(_CaptureEntry entry) {
    entry.dispose();
    setState(() {
      _captureEntries.remove(entry);
      if (_selectedObject?.name == entry.objectName) {
        _checkedIds.remove('${entry.attrId}');
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Push parameters column
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildPushParametersColumn({required double width}) {
    return SizedBox(
      width: width,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildParamSection(
              icon: Icons.shuffle,
              title: 'Randomisation start interval',
              reading: _randomStartReading,
              writing: _randomStartWriting,
              readKey: const Key(PushSetupKeys.randomStartReadBtn),
              writeKey: const Key(PushSetupKeys.randomStartWriteBtn),
              onRead: () => _loadRandomisationStartInterval(),
              onWrite: () async {
                final value = int.tryParse(_randomStartCtrl.text);
                if (value == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Invalid interval value')),
                    );
                  return;
                }
                setState(() => _randomStartWriting = true);
                try {
                  await _client.setRandomisationStartInterval(
                      widget.dataSource, value);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Text(
                                'Write randomisation interval failed: ${extractGrpcMessage(e)}')),
                      );
                  }
                } finally {
                  if (mounted) setState(() => _randomStartWriting = false);
                }
              },
              child: _numField(
                widgetKey: const Key(PushSetupKeys.randomStartField),
                controller: _randomStartCtrl,
                label: 'Interval',
              ),
            ),
            const SizedBox(height: 10),
            _buildParamSection(
              icon: Icons.replay,
              title: 'Number of retries',
              reading: _retriesReading,
              writing: _retriesWriting,
              readKey: const Key(PushSetupKeys.retriesReadBtn),
              writeKey: const Key(PushSetupKeys.retriesWriteBtn),
              onRead: () => _loadNumberOfRetries(),
              onWrite: () async {
                final value = int.tryParse(_retriesCtrl.text);
                if (value == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Invalid retries value')),
                    );
                  return;
                }
                setState(() => _retriesWriting = true);
                try {
                  await _client.setNumberOfRetries(widget.dataSource, value);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Text(
                                'Write number of retries failed: ${extractGrpcMessage(e)}')),
                      );
                  }
                } finally {
                  if (mounted) setState(() => _retriesWriting = false);
                }
              },
              child: _numField(
                widgetKey: const Key(PushSetupKeys.retriesField),
                controller: _retriesCtrl,
                label: 'Retries',
              ),
            ),
            const SizedBox(height: 10),
            _buildParamSection(
              icon: Icons.timer_outlined,
              title: 'Repetition delay',
              reading: _repDelayReading,
              writing: _repDelayWriting,
              readKey: const Key(PushSetupKeys.repDelayReadBtn),
              writeKey: const Key(PushSetupKeys.repDelayWriteBtn),
              onRead: () => _loadRepetitionDelay(),
              onWrite: () async {
                final min = int.tryParse(_repDelayMinCtrl.text);
                final exponent = int.tryParse(_repDelayExpCtrl.text);
                final max = int.tryParse(_repDelayMaxCtrl.text);
                if (min == null || exponent == null || max == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('Invalid repetition delay values')),
                    );
                  return;
                }
                setState(() => _repDelayWriting = true);
                try {
                  await _client.setRepetitionDelay(
                      widget.dataSource, min, exponent, max);
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Text(
                                'Write repetition delay failed: ${extractGrpcMessage(e)}')),
                      );
                  }
                } finally {
                  if (mounted) setState(() => _repDelayWriting = false);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _numField(
                      widgetKey: const Key(PushSetupKeys.repDelayMinField),
                      controller: _repDelayMinCtrl,
                      label: 'repetition_delay_min'),
                  const SizedBox(height: 8),
                  _numField(
                      widgetKey: const Key(PushSetupKeys.repDelayExpField),
                      controller: _repDelayExpCtrl,
                      label: 'repetition_delay_exponent'),
                  const SizedBox(height: 8),
                  _numField(
                      widgetKey: const Key(PushSetupKeys.repDelayMaxField),
                      controller: _repDelayMaxCtrl,
                      label: 'repetition_delay_max'),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildParamSection(
              icon: Icons.event_available,
              title: 'Last confirmation datetime',
              reading: _lastConfirmReading,
              writing: _lastConfirmWriting,
              readKey: const Key(PushSetupKeys.lastConfirmReadBtn),
              writeKey: const Key(PushSetupKeys.lastConfirmWriteBtn),
              onRead: () => _loadLastConfirmationDatetime(),
              onWrite: () async {
                if (_lastConfirmDt == null) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('No datetime selected')),
                    );
                  return;
                }
                setState(() => _lastConfirmWriting = true);
                try {
                  await _client.setLastConfirmationDatetime(
                      widget.dataSource, _lastConfirmDt!.toIso8601String());
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context)
                      ..clearSnackBars()
                      ..showSnackBar(
                        SnackBar(
                            backgroundColor: Colors.red.shade700,
                            content: Text(
                                'Write last confirmation datetime failed: ${extractGrpcMessage(e)}')),
                      );
                  }
                } finally {
                  if (mounted) setState(() => _lastConfirmWriting = false);
                }
              },
              child: _dateTimeField(),
            ),
            const SizedBox(height: 10),
            _buildPushResetRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildParamSection({
    required IconData icon,
    required String title,
    required bool reading,
    required bool writing,
    required VoidCallback onRead,
    required VoidCallback onWrite,
    required Widget child,
    Key? readKey,
    Key? writeKey,
  }) {
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
          // ── Section header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceAltOf(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                  bottom: BorderSide(color: DesignTokens.borderOf(context))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 14, color: DesignTokens.primary600),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Read button
                Tooltip(
                  message: 'Read',
                  child: InkWell(
                    key: readKey,
                    onTap: !_isConnected || reading || writing ? null : onRead,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: reading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.visibility_outlined,
                              size: 15, color: DesignTokens.primary600),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                // Write button
                Tooltip(
                  message: 'Write',
                  child: InkWell(
                    key: writeKey,
                    onTap: !_isConnected || reading || writing ? null : onWrite,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: writing
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.edit_outlined,
                              size: 15, color: DesignTokens.primary600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Content
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _numField(
      {Key? widgetKey,
      required TextEditingController controller,
      required String label}) {
    return TextField(
      key: widgetKey,
      controller: controller,
      keyboardType:
          const TextInputType.numberWithOptions(decimal: false, signed: false),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: 12, color: DesignTokens.textSecondaryOf(context)),
        isDense: true,
        filled: true,
        fillColor: DesignTokens.isDark(context)
            ? DesignTokens.darkFill
            : DesignTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkFocus
                  : DesignTokens.primary600,
              width: 1.2),
        ),
      ),
      style:
          TextStyle(fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
    );
  }

  Widget _dateTimeField() {
    final dt = _lastConfirmDt?.toLocal();
    final display = dt == null
        ? 'Not set'
        : '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')} '
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:'
            '${dt.second.toString().padLeft(2, '0')}';
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            decoration: BoxDecoration(
              border: Border.all(color: DesignTokens.borderOf(context)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              display,
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
                color: _lastConfirmDt == null
                    ? DesignTokens.textSecondaryOf(context)
                    : DesignTokens.textPrimaryOf(context),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          key: const Key(PushSetupKeys.lastConfirmDtBtn),
          onTap: () async {
            final now = _lastConfirmDt ?? DateTime.now();
            final date = await showDatePicker(
              context: context,
              initialDate: now,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (date == null || !mounted) return;
            final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(now),
            );
            if (time == null || !mounted) return;
            final sec = await _showSecondsPicker(context, now.second);
            if (sec == null || !mounted) return;
            setState(() {
              _lastConfirmDt = DateTime(
                  date.year, date.month, date.day, time.hour, time.minute, sec);
            });
          },
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: DesignTokens.primary600.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.calendar_today,
                size: 16, color: DesignTokens.primary600),
          ),
        ),
      ],
    );
  }

  Future<int?> _showSecondsPicker(BuildContext context, int initialSecond) {
    int selected = initialSecond.clamp(0, 59);
    final controller = FixedExtentScrollController(initialItem: selected);
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select seconds'),
        content: SizedBox(
          height: 160,
          width: 120,
          child: StatefulBuilder(
            builder: (ctx, setS) => ListWheelScrollView.useDelegate(
              controller: controller,
              itemExtent: 40,
              physics: const FixedExtentScrollPhysics(),
              onSelectedItemChanged: (i) => setS(() => selected = i),
              childDelegate: ListWheelChildBuilderDelegate(
                childCount: 60,
                builder: (ctx, i) => Center(
                  child: Text(
                    i.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          selected == i ? FontWeight.bold : FontWeight.normal,
                      color: selected == i
                          ? Theme.of(ctx).colorScheme.primary
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, selected),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildSendDestSection() {
    const transportOptions = [
      (label: 'TCP', value: 0),
      (label: 'UDP', value: 1),
      (label: 'Reserved for FTP', value: 2),
      (label: 'Reserved for SMTP', value: 3),
      (label: 'SMS', value: 4),
      (label: 'HDLC', value: 5),
      (label: 'Reserved for M-bus', value: 6),
      (label: 'Reserved for ZigBee', value: 7),
      (label: 'Manufacturer Specific', value: 8),
    ];
    const messageOptions = [
      (label: 'A-XDR encoded xdlms apdu', value: 0),
      (label: 'XML encoded xdlms apdu', value: 1),
      (label: 'Manufacturer Specific', value: 2),
    ];

    return _buildParamSection(
      icon: Icons.send_to_mobile,
      title: 'Send Destination and method',
      reading: _sendDestReading,
      writing: _sendDestWriting,
      readKey: const Key(PushSetupKeys.sendDestReadBtn),
      writeKey: const Key(PushSetupKeys.sendDestWriteBtn),
      onRead: () => _loadSendDestination(),
      onWrite: () async {
        setState(() => _sendDestWriting = true);
        try {
          await _client.setSendDestination(
            widget.dataSource,
            _transportService,
            _destinationCtrl.text,
            _messageType,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                    backgroundColor: Colors.red.shade700,
                    content: Text(
                        'Write send destination failed: ${extractGrpcMessage(e)}')),
              );
          }
        } finally {
          if (mounted) setState(() => _sendDestWriting = false);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Transport service dropdown
          _dropdownField<int>(
            widgetKey: const Key(PushSetupKeys.transportServiceDropdown),
            label: 'Transport service',
            value: _transportService,
            items: transportOptions
                .map((o) => DropdownMenuItem(
                      value: o.value,
                      child:
                          Text(o.label, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _transportService = v ?? 0),
          ),
          const SizedBox(height: 8),
          // Destination (IP + port)
          TextField(
            key: const Key(PushSetupKeys.destinationField),
            controller: _destinationCtrl,
            decoration: InputDecoration(
              labelText: 'Destination',
              labelStyle: TextStyle(
                  fontSize: 12, color: DesignTokens.textSecondaryOf(context)),
              hintText: '192.168.1.1:4059',
              hintStyle: TextStyle(
                  fontSize: 12, color: DesignTokens.textSecondaryOf(context)),
              isDense: true,
              filled: true,
              fillColor: DesignTokens.isDark(context)
                  ? DesignTokens.darkFill
                  : DesignTokens.surface,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: DesignTokens.borderOf(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(color: DesignTokens.borderOf(context)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide(
                    color: DesignTokens.isDark(context)
                        ? DesignTokens.darkFocus
                        : DesignTokens.primary600,
                    width: 1.2),
              ),
            ),
            style: TextStyle(
                fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
          ),
          const SizedBox(height: 8),
          // Message dropdown
          _dropdownField<int>(
            widgetKey: const Key(PushSetupKeys.messageTypeDropdown),
            label: 'Message',
            value: _messageType,
            items: messageOptions
                .map((o) => DropdownMenuItem(
                      value: o.value,
                      child:
                          Text(o.label, style: const TextStyle(fontSize: 13)),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _messageType = v ?? 0),
          ),
        ],
      ),
    );
  }

  Widget _dropdownField<T>({
    Key? widgetKey,
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return InputDecorator(
      key: widgetKey,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
            fontSize: 12, color: DesignTokens.textSecondaryOf(context)),
        isDense: true,
        filled: true,
        fillColor: DesignTokens.isDark(context)
            ? DesignTokens.darkFill
            : DesignTokens.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(color: DesignTokens.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: BorderSide(
              color: DesignTokens.isDark(context)
                  ? DesignTokens.darkFocus
                  : DesignTokens.primary600,
              width: 1.2),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isDense: true,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: TextStyle(
              fontSize: 13, color: DesignTokens.textPrimaryOf(context)),
        ),
      ),
    );
  }

  Widget _buildPushResetRow() {
    final busy = _pushing || _resetting;
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            key: const Key(PushSetupKeys.pushBtn),
            style: FilledButton.styleFrom(
              backgroundColor: DesignTokens.primary600,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: busy ? null : () async {
                    try {
                      await _client.pushSetupPush(widget.dataSource);
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green.shade700,
                              content: const Text('Push sent successfully'),
                            ),
                          );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content:
                                  Text('Push failed: ${extractGrpcMessage(e)}'),
                            ),
                          );
                      }
                    } finally {
                      if (mounted) setState(() => _pushing = false);
                    }
                  },
            icon: _pushing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.send, size: 16),
            label: const Text('Push', style: TextStyle(fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            key: const Key(PushSetupKeys.resetBtn),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade600,
              side: BorderSide(color: Colors.red.shade300),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: !_isConnected || busy
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirm Reset'),
                        content: Text(
                          'Are you sure you want to reset the push setup for "${widget.dataSource}"?\n\nThis action cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            key: const Key(PushSetupKeys.resetConfirmCancelBtn),
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            key: const Key(PushSetupKeys.resetConfirmBtn),
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.red.shade600,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed != true || !mounted) return;
                    setState(() => _resetting = true);
                    try {
                      await _client.pushSetupReset(widget.dataSource);
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green.shade700,
                              content:
                                  const Text('Push setup reset successfully'),
                            ),
                          );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context)
                          ..clearSnackBars()
                          ..showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.red.shade700,
                              content: Text(
                                  'Reset failed: ${extractGrpcMessage(e)}'),
                            ),
                          );
                      }
                    } finally {
                      if (mounted) setState(() => _resetting = false);
                    }
                  },
            icon: _resetting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.red.shade600),
                  )
                : const Icon(Icons.restart_alt, size: 16),
            label: const Text('Reset', style: TextStyle(fontSize: 13)),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Communication window section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildCommunicationWindowSection() {
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
          // ── Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: DesignTokens.surfaceAltOf(context),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(8)),
              border: Border(
                  bottom: BorderSide(color: DesignTokens.borderOf(context))),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time,
                    size: 15, color: DesignTokens.primary600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Communication window',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                  ),
                ),
                // Read
                Tooltip(
                  message: 'Read',
                  child: InkWell(
                    key: const Key(PushSetupKeys.commWindowReadBtn),
                    onTap: !_isConnected ||
                            _commWindowReading ||
                            _commWindowWriting
                        ? null
                        : () async {
                            await _loadCommunicationWindow();
                          },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _commWindowReading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.visibility_outlined,
                              size: 15, color: DesignTokens.primary600),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                // Write
                Tooltip(
                  message: 'Write',
                  child: InkWell(
                    key: const Key(PushSetupKeys.commWindowWriteBtn),
                    onTap: !_isConnected ||
                            _commWindowReading ||
                            _commWindowWriting
                        ? null
                        : () async {
                            final windows = _commWindows
                                .where(
                                    (w) => w.startDt != null && w.endDt != null)
                                .map((w) => (
                                      start: (
                                        day: w.startDt!.day,
                                        month: w.startDt!.month,
                                        year: w.startDt!.year,
                                        weekday: w.startDt!.weekday,
                                        hour: w.startDt!.hour,
                                        minute: w.startDt!.minute,
                                        second: w.startDt!.second,
                                      ),
                                      end: (
                                        day: w.endDt!.day,
                                        month: w.endDt!.month,
                                        year: w.endDt!.year,
                                        weekday: w.endDt!.weekday,
                                        hour: w.endDt!.hour,
                                        minute: w.endDt!.minute,
                                        second: w.endDt!.second,
                                      ),
                                    ))
                                .toList();
                            setState(() => _commWindowWriting = true);
                            try {
                              await _client.setCommunicationWindow(
                                  widget.dataSource, windows);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                  ..clearSnackBars()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'Write failed: ${extractGrpcMessage(e)}'),
                                      backgroundColor: Colors.red.shade700,
                                    ),
                                  );
                              }
                            } finally {
                              if (mounted)
                                setState(() => _commWindowWriting = false);
                            }
                          },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _commWindowWriting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.edit_outlined,
                              size: 15, color: DesignTokens.primary600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add row button
                Tooltip(
                  message: 'Add window',
                  child: InkWell(
                    key: const Key(PushSetupKeys.commWindowAddBtn),
                    onTap: _isConnected ? _showAddWindowDialog : null,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          const Text('Add',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Column headers
          Container(
            color: DesignTokens.surfaceAltOf(context),
            child: Row(
              children: [
                Expanded(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text('Start time',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondaryOf(context))),
                )),
                Expanded(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Text('End time',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textSecondaryOf(context))),
                )),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Rows
          Expanded(
            child: _commWindows.isEmpty
                ? Center(
                    child: Text(
                      'No windows defined. Press Add to create one.',
                      style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondaryOf(context)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _commWindows.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: DesignTokens.borderOf(context)),
                    itemBuilder: (_, i) {
                      final w = _commWindows[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                w.start,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.textPrimaryOf(context),
                                    fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                w.end,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.textPrimaryOf(context),
                                    fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          InkWell(
                            key: Key(PushSetupKeys.commWindowDeleteBtn(i)),
                            onTap: () =>
                                setState(() => _commWindows.removeAt(i)),
                            borderRadius: BorderRadius.circular(4),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Icon(Icons.delete_outline,
                                  size: 15, color: Colors.red.shade400),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddWindowDialog() async {
    final start = _CosemDateTime();
    final end = _CosemDateTime();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CommWindowDialog(start: start, end: end),
    );
    if (result == true && mounted) {
      setState(() => _commWindows.add(_CommWindow(
            start: start.display,
            end: end.display,
            startDt: start.copy(),
            endDt: end.copy(),
          )));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Communication window add dialog
// ─────────────────────────────────────────────────────────────────────────────

class _CommWindowDialog extends StatefulWidget {
  const _CommWindowDialog({required this.start, required this.end});
  final _CosemDateTime start;
  final _CosemDateTime end;

  @override
  State<_CommWindowDialog> createState() => _CommWindowDialogState();
}

class _CommWindowDialogState extends State<_CommWindowDialog> {
  // Wildcard sentinel values
  static const int _dayWildFD = 0xFD;
  static const int _dayWildFE = 0xFE;
  static const int _dayWildFF = 0xFF;
  static const int _monthWildFD = 0xFD;
  static const int _monthWildFE = 0xFE;
  static const int _monthWildFF = 0xFF;
  static const int _yearWildFFFF = 0xFFFF;
  static const int _weekdayWildFF = 0xFF;
  static const int _timeWildFF = 0xFF;

  List<DropdownMenuItem<int>> get _dayItems => [
        ...List.generate(
            31, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
        const DropdownMenuItem(value: _dayWildFD, child: Text('FD')),
        const DropdownMenuItem(value: _dayWildFE, child: Text('FE')),
        const DropdownMenuItem(value: _dayWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _monthItems => [
        ...List.generate(
            12, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
        const DropdownMenuItem(value: _monthWildFD, child: Text('FD')),
        const DropdownMenuItem(value: _monthWildFE, child: Text('FE')),
        const DropdownMenuItem(value: _monthWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _yearItems => [
        ...List.generate(
            100,
            (i) =>
                DropdownMenuItem(value: 2000 + i, child: Text('${2000 + i}'))),
        const DropdownMenuItem(value: _yearWildFFFF, child: Text('FFFF')),
      ];

  List<DropdownMenuItem<int>> get _weekdayItems => [
        ...List.generate(
            7, (i) => DropdownMenuItem(value: i + 1, child: Text('${i + 1}'))),
        const DropdownMenuItem(value: _weekdayWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _hourItems => [
        ...List.generate(
            24,
            (i) => DropdownMenuItem(
                value: i, child: Text('${i.toString().padLeft(2, '0')}'))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _minuteItems => [
        ...List.generate(
            60,
            (i) => DropdownMenuItem(
                value: i, child: Text('${i.toString().padLeft(2, '0')}'))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _secondItems => [
        ...List.generate(
            60,
            (i) => DropdownMenuItem(
                value: i, child: Text('${i.toString().padLeft(2, '0')}'))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.access_time, size: 18, color: DesignTokens.primary600),
          const SizedBox(width: 8),
          const Text('Add communication window',
              style: TextStyle(fontSize: 15)),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _dtSection('Start time', widget.start),
              const SizedBox(height: 16),
              _dtSection('End time', widget.end),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key(PushSetupKeys.commWindowDialogCancelBtn),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key(PushSetupKeys.commWindowDialogAddBtn),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _dtSection(String label, _CosemDateTime dt) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: DesignTokens.primary600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _dtDropdown('Day', dt.day, _dayItems,
                (v) => setState(() => dt.day = v ?? dt.day)),
            _dtDropdown('Month', dt.month, _monthItems,
                (v) => setState(() => dt.month = v ?? dt.month)),
            _dtDropdown('Year', dt.year, _yearItems,
                (v) => setState(() => dt.year = v ?? dt.year)),
            _dtDropdown('Weekday', dt.weekday, _weekdayItems,
                (v) => setState(() => dt.weekday = v ?? dt.weekday)),
            _dtDropdown('Hour', dt.hour, _hourItems,
                (v) => setState(() => dt.hour = v ?? dt.hour)),
            _dtDropdown('Minute', dt.minute, _minuteItems,
                (v) => setState(() => dt.minute = v ?? dt.minute)),
            _dtDropdown('Second', dt.second, _secondItems,
                (v) => setState(() => dt.second = v ?? dt.second)),
          ],
        ),
      ],
    );
  }

  Widget _dtDropdown(String label, int value, List<DropdownMenuItem<int>> items,
      ValueChanged<int?> onChanged) {
    return SizedBox(
      width: 100,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
              fontSize: 11, color: DesignTokens.textSecondaryOf(context)),
          isDense: true,
          filled: true,
          fillColor: DesignTokens.isDark(context)
              ? DesignTokens.darkFill
              : DesignTokens.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: DesignTokens.borderOf(context))),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: DesignTokens.borderOf(context))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                  color: DesignTokens.isDark(context)
                      ? DesignTokens.darkFocus
                      : DesignTokens.primary600,
                  width: 1.2)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: value,
            isDense: true,
            isExpanded: true,
            items: items,
            onChanged: onChanged,
            style: TextStyle(
                fontSize: 12, color: DesignTokens.textPrimaryOf(context)),
          ),
        ),
      ),
    );
  }
}
