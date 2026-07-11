import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../util/grpc_error.dart';
import '../../state/app_controller.dart';
import '../../core/widget_keys.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../grpc/meter_client.dart';
import '../push_setups/push_actions_config.dart';

class PushActionPage extends StatefulWidget {
  final PushActionConfig config;

  const PushActionPage({super.key, required this.config});

  @override
  State<PushActionPage> createState() => _PushActionPageState();
}

class _PushActionPageState extends State<PushActionPage>
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
                tabs:
                    widget.config.tabs!.map((t) => Tab(text: t.label)).toList(),
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
                    .map((t) => _ScheduleSection(
                          label: t.label,
                          dataSource: t.dataSource,
                        ))
                    .toList(),
              )
            : _ScheduleSection(
                label: widget.config.label,
                dataSource: widget.config.dataSource ?? '',
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COSEM DateTime model (shared with comm-window logic)
// ─────────────────────────────────────────────────────────────────────────────

class _CosemDateTime {
  int day;
  int month;
  int year;
  int weekday;
  int hour;
  int minute;
  int second;
  int millisecond;

  _CosemDateTime({
    this.day = 1,
    this.month = 1,
    this.year = 2000,
    this.weekday = 1,
    this.hour = 0,
    this.minute = 0,
    this.second = 0,
    this.millisecond = 0,
  });

  _CosemDateTime copy() => _CosemDateTime(
        day: day,
        month: month,
        year: year,
        weekday: weekday,
        hour: hour,
        minute: minute,
        second: second,
        millisecond: millisecond,
      );

  static const _dayWildcards = {0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF'};
  static const _monthWildcards = {0xFD: 'FD', 0xFE: 'FE', 0xFF: 'FF'};
  static const _yearWildcards = {0xFFFF: 'FFFF'};
  static const _byteWildcards = {0xFF: 'FF'};
  static const _millisecondWildcards = {0xFF: 'FF'};

  // Parses the format returned by the server:
  // "DD-MM-YYYY WD:W HH:MM:SS.MSS" (wildcards as uppercase hex: FF / FFFF)
  static _CosemDateTime? parse(String s) {
    try {
      final sp = s.split(' ');
      if (sp.length != 3) return null;
      final dateParts = sp[0].split('-');
      if (dateParts.length != 3) return null;
      if (!sp[1].startsWith('WD:')) return null;
      final wd = sp[1].substring(3);
      final dotIdx = sp[2].indexOf('.');
      if (dotIdx < 0) return null;
      final timeParts = sp[2].substring(0, dotIdx).split(':');
      if (timeParts.length != 3) return null;
      final msStr = sp[2].substring(dotIdx + 1);

      int f(String v, {int wildcard = 0xFF}) {
        final u = v.toUpperCase();
        if (u == 'FFFF') return 0xFFFF;
        if (u == 'FF') return 0xFF;
        if (u == 'FE') return 0xFE;
        if (u == 'FD') return 0xFD;
        return int.tryParse(v) ?? wildcard;
      }

      return _CosemDateTime(
        day: f(dateParts[0]),
        month: f(dateParts[1]),
        year: f(dateParts[2], wildcard: 0xFFFF),
        weekday: f(wd),
        hour: f(timeParts[0]),
        minute: f(timeParts[1]),
        second: f(timeParts[2]),
        millisecond: f(msStr),
      );
    } catch (_) {
      return null;
    }
  }

  static String _fmt(int v, Map<int, String> wildcards, {int pad = 0}) =>
      wildcards[v] ?? v.toString().padLeft(pad, '0');

  String get display => '${_fmt(day, _dayWildcards, pad: 2)}'
      '-${_fmt(month, _monthWildcards, pad: 2)}'
      '-${_fmt(year, _yearWildcards, pad: 4)} '
      'WD:${_fmt(weekday, _byteWildcards)} '
      '${_fmt(hour, _byteWildcards, pad: 2)}'
      ':${_fmt(minute, _byteWildcards, pad: 2)}'
      ':${_fmt(second, _byteWildcards, pad: 2)}'
      '.${_fmt(millisecond, _millisecondWildcards, pad: 2)}';
}

// ─────────────────────────────────────────────────────────────────────────────
// Execution time entry model
// ─────────────────────────────────────────────────────────────────────────────

class _ExecTime {
  String time;
  _CosemDateTime? dt;

  _ExecTime({required this.time, this.dt});
}

// ─────────────────────────────────────────────────────────────────────────────
// Schedule section — main content for one data source
// ─────────────────────────────────────────────────────────────────────────────

class _ScheduleSection extends StatefulWidget {
  const _ScheduleSection({
    required this.label,
    required this.dataSource,
  });
  final String label;
  final String dataSource;

  @override
  State<_ScheduleSection> createState() => _ScheduleSectionState();
}

class _ScheduleSectionState extends State<_ScheduleSection> {
  late final IMeterClient _client;

  // ── Execution time state ─────────────────────────────────────────────────
  final List<_ExecTime> _execTimes = [];
  bool _execTimeReading = false;
  bool _execTimeWriting = false;

  // ── Type state ───────────────────────────────────────────────────────────
  int _scheduleType = 0;
  bool _typeReading = false;

  // ── Script table state ───────────────────────────────────────────────────
  final _scriptTableCtrl = TextEditingController();

  // ── Script selector state ────────────────────────────────────────────────
  int _scriptSelectorIndex = 0;
  final _scriptSelectorIndexCtrl = TextEditingController(text: '0');
  final _scriptTextCtrl = TextEditingController();
  bool _executedScriptReading = false;
  bool _executedScriptWriting = false;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _loadAll();
  }

  Future<void> _loadAll() async {
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    if (!isConnected) return;
    await _loadExecutionTime();
    await _loadScheduleType();
    await _loadExecutedScript();
  }

  @override
  void dispose() {
    _client.close();
    _scriptTableCtrl.dispose();
    _scriptSelectorIndexCtrl.dispose();
    _scriptTextCtrl.dispose();
    super.dispose();
  }

  // ── Load helpers ──────────────────────────────────────────────────────────

  Future<void> _loadExecutionTime() async {
    if (widget.dataSource.isEmpty) return;
    setState(() => _execTimeReading = true);
    try {
      final times = await _client.getExecutionTime(widget.dataSource);
      if (mounted) {
        setState(() {
          _execTimes.clear();
          for (final t in times) {
            _execTimes.add(_ExecTime(time: t, dt: _CosemDateTime.parse(t)));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content:
                Text('Read execution time failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _execTimeReading = false);
    }
  }

  Future<void> _loadScheduleType() async {
    if (widget.dataSource.isEmpty) return;
    setState(() => _typeReading = true);
    try {
      final value = await _client.getPushActionType(widget.dataSource);
      if (mounted) setState(() => _scheduleType = value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content:
                Text('Read schedule type failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _typeReading = false);
    }
  }

  Future<void> _loadScriptSelector() async {
    if (widget.dataSource.isEmpty) return;
    setState(() => _executedScriptReading = true);
    try {
      final value = await _client.getScriptSelector(widget.dataSource);
      if (mounted) {
        setState(() {
          _scriptSelectorIndex = value.selector;
          _scriptSelectorIndexCtrl.text = value.selector.toString();
          _scriptTextCtrl.text = value.scriptText;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content:
                Text('Read script selector failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _executedScriptReading = false);
    }
  }

  Future<void> _writeExecutedScript() async {
    setState(() => _executedScriptWriting = true);
    try {
      await _client.setPushActionExecutedScript(
        widget.dataSource,
        int.tryParse(_scriptSelectorIndexCtrl.text) ?? 0,
        _scriptTableCtrl.text,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content:
                Text('Write executed script failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _executedScriptWriting = false);
    }
  }

  Future<void> _loadExecutedScript() async {
    if (widget.dataSource.isEmpty) return;
    setState(() => _executedScriptReading = true);
    try {
      final value =
          await _client.getPushActionExecutedScript(widget.dataSource);
      if (mounted) {
        setState(() {
          _scriptSelectorIndex = value.scriptSelector;
          _scriptSelectorIndexCtrl.text = value.scriptSelector.toString();
          _scriptTableCtrl.text = value.scriptTable;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content:
                Text('Read executed script failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _executedScriptReading = false);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildExecutionTimeSection()),
              const SizedBox(width: 16),
              Expanded(child: _buildTypeSection()),
            ],
          ),
          const SizedBox(height: 16),
          _buildExecutedScriptSection(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Execution time section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildExecutionTimeSection() {
    return Container(
      height: 280,
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
                Icon(Icons.schedule, size: 15, color: DesignTokens.primary600),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Execution time',
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
                    key: const Key(PushActionKeys.execTimeReadBtn),
                    onTap: _execTimeReading || _execTimeWriting
                        ? null
                        : _loadExecutionTime,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _execTimeReading
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
                    key: const Key(PushActionKeys.execTimeWriteBtn),
                    onTap: _execTimeReading || _execTimeWriting
                        ? null
                        : () async {
                            final times = _execTimes
                                .where((t) => t.dt != null)
                                .map((t) => (
                                      day: t.dt!.day,
                                      month: t.dt!.month,
                                      year: t.dt!.year,
                                      weekday: t.dt!.weekday,
                                      hour: t.dt!.hour,
                                      minute: t.dt!.minute,
                                      second: t.dt!.second,
                                    ))
                                .toList();
                            print(times);
                            setState(() => _execTimeWriting = true);
                            try {
                              await _client.setExecutionTime(
                                  widget.dataSource, times);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(
                                      'Write failed: ${extractGrpcMessage(e)}'),
                                  backgroundColor: Colors.red.shade700,
                                ));
                              }
                            } finally {
                              if (mounted)
                                setState(() => _execTimeWriting = false);
                            }
                          },
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _execTimeWriting
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
                // Add button
                Tooltip(
                  message: 'Add execution time',
                  child: InkWell(
                    key: const Key(PushActionKeys.addExecTimeBtn),
                    onTap: _showAddExecTimeDialog,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: DesignTokens.primary600,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.add, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text('Add',
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
          // ── Column header
          Container(
            color: DesignTokens.surfaceAltOf(context),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    child: Text('Execution time',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: DesignTokens.textSecondaryOf(context))),
                  ),
                ),
                const SizedBox(width: 40),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── Rows
          Expanded(
            child: _execTimes.isEmpty
                ? Center(
                    child: Text(
                      'No execution times defined. Press Add to create one.',
                      style: TextStyle(
                          fontSize: 12,
                          color: DesignTokens.textSecondaryOf(context)),
                    ),
                  )
                : ListView.separated(
                    itemCount: _execTimes.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: DesignTokens.borderOf(context)),
                    itemBuilder: (_, i) {
                      final t = _execTimes[i];
                      return Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              child: Text(
                                t.time,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: DesignTokens.textPrimaryOf(context),
                                    fontFamily: 'monospace'),
                              ),
                            ),
                          ),
                          InkWell(
                            key: Key(PushActionKeys.execTimeDeleteBtn(i)),
                            onTap: () => setState(() => _execTimes.removeAt(i)),
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

  Future<void> _showAddExecTimeDialog() async {
    final dt = _CosemDateTime();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _ExecTimeDialog(dt: dt),
    );
    if (result == true && mounted) {
      setState(
          () => _execTimes.add(_ExecTime(time: dt.display, dt: dt.copy())));
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Type section (read-only)
  // ─────────────────────────────────────────────────────────────────────────

  static const _typeLabels = {
    0: '0: Not defined',
    1: '1: Wildcard in date allowed',
    2: '2: All time values are the same, wildcards in date not allowed',
    3: '3: All time values are the same, wildcards in date are allowed',
    4: '4: All time may be different, wildcards in date not allowed',
    5: '5: All time may be different, wildcards in date are allowed',
  };

  Widget _buildTypeSection() {
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
                Icon(Icons.category_outlined,
                    size: 14, color: DesignTokens.primary600),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Type',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Read only
                Tooltip(
                  message: 'Read',
                  child: InkWell(
                    key: const Key(PushActionKeys.scheduleTypeReadBtn),
                    onTap: _typeReading ? null : _loadScheduleType,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _typeReading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.visibility_outlined,
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
            child: _dropdownField<int>(
              label: 'Schedule type',
              value: _scheduleType.clamp(0, 5),
              items: _typeLabels.entries
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child:
                            Text(e.value, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
              onChanged: null, // read-only
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Executed script section
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildExecutedScriptSection() {
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
                Icon(Icons.code, size: 14, color: DesignTokens.primary600),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    'Executed script',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Read',
                  child: InkWell(
                    key: const Key(PushActionKeys.executedScriptReadBtn),
                    onTap: _executedScriptReading || _executedScriptWriting
                        ? null
                        : _loadExecutedScript,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _executedScriptReading
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
                Tooltip(
                  message: 'Write',
                  child: InkWell(
                    key: const Key(PushActionKeys.executedScriptWriteBtn),
                    onTap: _executedScriptReading || _executedScriptWriting
                        ? null
                        : _writeExecutedScript,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: _executedScriptWriting
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : Icon(Icons.edit_outlined,
                              size: 15, color: DesignTokens.primary600),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // ── Script table + Script selector in the same row
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _buildSubSection(
                    title: 'Script table',
                    icon: Icons.table_chart_outlined,
                    child: TextField(
                      key: const Key(PushActionKeys.scriptTableField),
                      controller: _scriptTableCtrl,
                      style: TextStyle(
                          color: DesignTokens.textPrimaryOf(context)),
                      decoration: InputDecoration(
                        labelText: 'Script table (logical name)',
                        labelStyle: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textSecondaryOf(context)),
                        isDense: true,
                        filled: true,
                        fillColor: DesignTokens.isDark(context)
                            ? DesignTokens.darkFill
                            : DesignTokens.surface,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
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
                    ),
                  ),
                ),
                VerticalDivider(
                    width: 1, color: DesignTokens.borderOf(context)),
                Expanded(
                  child: _buildSubSection(
                    title: 'Script selector',
                    icon: Icons.tune,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Selector index input
                        TextField(
                          key: const Key(PushActionKeys.scriptSelectorField),
                          controller: _scriptSelectorIndexCtrl,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          onChanged: (v) =>
                              _scriptSelectorIndex = int.tryParse(v) ?? 0,
                          style: TextStyle(
                              fontSize: 13,
                              color: DesignTokens.textPrimaryOf(context)),
                          decoration: InputDecoration(
                            labelText: 'Selector (index)',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondaryOf(context)),
                            isDense: true,
                            filled: true,
                            fillColor: DesignTokens.isDark(context)
                                ? DesignTokens.darkFill
                                : DesignTokens.surface,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                  color: DesignTokens.borderOf(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                  color: DesignTokens.borderOf(context)),
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
                        ),
                        const SizedBox(height: 8),
                        // Script text area
                        TextField(
                          key: const Key(PushActionKeys.scriptTextField),
                          controller: _scriptTextCtrl,
                          style: TextStyle(
                              fontSize: 12,
                              color: DesignTokens.textPrimaryOf(context),
                              fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            labelText: 'Script',
                            labelStyle: TextStyle(
                                fontSize: 12,
                                color: DesignTokens.textSecondaryOf(context)),
                            alignLabelWithHint: true,
                            isDense: true,
                            filled: true,
                            fillColor: DesignTokens.isDark(context)
                                ? DesignTokens.darkFill
                                : DesignTokens.surface,
                            contentPadding: const EdgeInsets.all(10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                  color: DesignTokens.borderOf(context)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide(
                                  color: DesignTokens.borderOf(context)),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// A sub-section within the executed script section (title + content only).
  Widget _buildSubSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          color: DesignTokens.surfaceAltOf(context).withOpacity(0.5),
          child: Row(
            children: [
              Icon(icon,
                  size: 13, color: DesignTokens.textSecondaryOf(context)),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textSecondaryOf(context)),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: child,
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Shared widget helpers
  // ─────────────────────────────────────────────────────────────────────────

  Widget _dropdownField<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?>? onChanged,
  }) {
    return InputDecorator(
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
              fontSize: 12, color: DesignTokens.textPrimaryOf(context)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Execution time add dialog
// ─────────────────────────────────────────────────────────────────────────────

class _ExecTimeDialog extends StatefulWidget {
  const _ExecTimeDialog({required this.dt});
  final _CosemDateTime dt;

  @override
  State<_ExecTimeDialog> createState() => _ExecTimeDialogState();
}

class _ExecTimeDialogState extends State<_ExecTimeDialog> {
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
                value: i, child: Text(i.toString().padLeft(2, '0')))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _minuteItems => [
        ...List.generate(
            60,
            (i) => DropdownMenuItem(
                value: i, child: Text(i.toString().padLeft(2, '0')))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _secondItems => [
        ...List.generate(
            60,
            (i) => DropdownMenuItem(
                value: i, child: Text(i.toString().padLeft(2, '0')))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  List<DropdownMenuItem<int>> get _millisecondItems => [
        ...List.generate(
            60,
            (i) => DropdownMenuItem(
                value: i, child: Text(i.toString().padLeft(2, '0')))),
        const DropdownMenuItem(value: _timeWildFF, child: Text('FF')),
      ];

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.schedule, size: 18, color: DesignTokens.primary600),
          const SizedBox(width: 8),
          const Text('Add execution time', style: TextStyle(fontSize: 15)),
        ],
      ),
      content: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _dtDropdown('Day', widget.dt.day, _dayItems,
                  (v) => setState(() => widget.dt.day = v ?? widget.dt.day),
                  key: const Key(PushActionKeys.execTimeDayDropdown)),
              _dtDropdown(
                  'Month',
                  widget.dt.month,
                  _monthItems,
                  (v) =>
                      setState(() => widget.dt.month = v ?? widget.dt.month),
                  key: const Key(PushActionKeys.execTimeMonthDropdown)),
              _dtDropdown('Year', widget.dt.year, _yearItems,
                  (v) => setState(() => widget.dt.year = v ?? widget.dt.year),
                  key: const Key(PushActionKeys.execTimeYearDropdown)),
              _dtDropdown(
                  'Weekday',
                  widget.dt.weekday,
                  _weekdayItems,
                  (v) => setState(
                      () => widget.dt.weekday = v ?? widget.dt.weekday),
                  key: const Key(PushActionKeys.execTimeWeekdayDropdown)),
              _dtDropdown('Hour', widget.dt.hour, _hourItems,
                  (v) => setState(() => widget.dt.hour = v ?? widget.dt.hour),
                  key: const Key(PushActionKeys.execTimeHourDropdown)),
              _dtDropdown(
                  'Minute',
                  widget.dt.minute,
                  _minuteItems,
                  (v) =>
                      setState(() => widget.dt.minute = v ?? widget.dt.minute),
                  key: const Key(PushActionKeys.execTimeMinuteDropdown)),
              _dtDropdown(
                  'Second',
                  widget.dt.second,
                  _secondItems,
                  (v) =>
                      setState(() => widget.dt.second = v ?? widget.dt.second),
                  key: const Key(PushActionKeys.execTimeSecondDropdown)),
              _dtDropdown(
                  'Millisecond',
                  widget.dt.millisecond,
                  _millisecondItems,
                  (v) => setState(() =>
                      widget.dt.millisecond = v ?? widget.dt.millisecond),
                  key: const Key(PushActionKeys.execTimeMsDropdown)),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          key: const Key(PushActionKeys.execTimeCancelBtn),
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key(PushActionKeys.execTimeAddBtn),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _dtDropdown(String label, int value, List<DropdownMenuItem<int>> items,
      ValueChanged<int?> onChanged, {Key? key}) {
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
            key: key,
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