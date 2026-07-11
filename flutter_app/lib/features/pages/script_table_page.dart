import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../util/grpc_error.dart';
import '../../state/app_controller.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/meter_client.dart';
import '../push_setups/script_table_config.dart';
import '../../core/widget_keys.dart';

// ---------------------------------------------------------------------------
// Data model for a single script-table row.
// ---------------------------------------------------------------------------
class _ScriptRow {
  final int scriptIdentifier;
  final int serviceId;
  final int classId;
  final String logicalName;
  final int index;
  final String parameter;

  const _ScriptRow({
    required this.scriptIdentifier,
    required this.serviceId,
    required this.classId,
    required this.logicalName,
    required this.index,
    required this.parameter,
  });
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------
class ScriptTablePage extends ConsumerStatefulWidget {
  final ScriptTableConfig config;

  const ScriptTablePage({super.key, required this.config});

  @override
  ConsumerState<ScriptTablePage> createState() => _ScriptTablePageState();
}

class _ScriptTablePageState extends ConsumerState<ScriptTablePage> {
  late final IMeterClient _client;

  bool _reading = false;
  bool _executing = false;
  bool _isConnected = false;
  List<_ScriptRow> _rows = [];

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _read();
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _read() async {
    if (_reading || _executing) return;
    final isConnected = ref.read(appControllerProvider).isConnected;
    if (!isConnected) return;
    setState(() => _reading = true);
    try {
      final response = await _client.getScriptTable(widget.config.datasource);
      if (mounted) {
        setState(() {
          _rows = response.entries
              .map((e) => _ScriptRow(
                    scriptIdentifier: e.scriptIdentifier,
                    serviceId: e.serviceId,
                    classId: e.classId,
                    logicalName: e.logicalName,
                    index: e.index,
                    parameter: e.parameter,
                  ))
              .toList();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Read failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _reading = false);
    }
  }

  Future<void> _execute() async {
    if (_reading || _executing) return;
    setState(() => _executing = true);
    try {
      await _client.executeScriptTable(widget.config.datasource);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(const SnackBar(
            content: Text('Script table executed successfully'),
          ));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Execute failed: ${extractGrpcMessage(e)}'),
          ));
      }
    } finally {
      if (mounted) setState(() => _executing = false);
    }
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    _isConnected = ref.watch(appControllerProvider).isConnected;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.config.label),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      drawer: const AppDrawer(),
      body: Container(
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: _buildSection(),
        ),
      ),
    );
  }

  Widget _buildSection() {
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
          _buildSectionHeader(),
          _buildColumnHeaders(),
          Divider(height: 1, color: DesignTokens.borderOf(context)),
          _buildRows(),
        ],
      ),
    );
  }

  // Section header -----------------------------------------------------------
  Widget _buildSectionHeader() {
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
          Icon(Icons.code,
              size: 15, color: isDark ? Colors.white : DesignTokens.primary600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Various global meter',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: DesignTokens.textPrimaryOf(context),
              ),
            ),
          ),
          // Datasource chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: DesignTokens.primary600.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: DesignTokens.primary600.withOpacity(0.25)),
            ),
            child: Text(
              widget.config.datasource,
              style: TextStyle(fontSize: 11, color: DesignTokens.primary600),
            ),
          ),
          const SizedBox(width: 8),
          // Read button
          SizedBox(
            height: 30,
            child: OutlinedButton.icon(
              key: const Key(ScriptTableKeys.readBtn),
              onPressed: !_isConnected || _reading || _executing ? null : _read,
              icon: _reading
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.download_outlined, size: 14),
              label: const Text('Read', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? Colors.white : DesignTokens.primary600,
                side: BorderSide(
                    color: isDark ? Colors.white : DesignTokens.primary600),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Execute button
          SizedBox(
            height: 30,
            child: OutlinedButton.icon(
              key: const Key(ScriptTableKeys.executeBtn),
              onPressed:
                  !_isConnected || _reading || _executing ? null : _execute,
              icon: _executing
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.play_arrow_outlined, size: 14),
              label: const Text('Execute', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                foregroundColor:
                    isDark ? Colors.white : DesignTokens.primary600,
                side: BorderSide(
                    color: isDark ? Colors.white : DesignTokens.primary600),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Column headers -----------------------------------------------------------
  Widget _buildColumnHeaders() {
    return Container(
      color: DesignTokens.surfaceAltOf(context),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          _headerCell('Script Identifier', flex: 2),
          _headerCell('Service Id', flex: 2),
          _headerCell('Class Id', flex: 2),
          _headerCell('Logical Name', flex: 3),
          _headerCell('Index', flex: 1),
          _headerCell('Parameter', flex: 3),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {required int flex}) {
    return Expanded(
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
  }

  // Rows ---------------------------------------------------------------------
  Widget _buildRows() {
    if (_rows.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No script entries loaded. Press Read to fetch from the meter.',
            style: TextStyle(
                fontSize: 12, color: DesignTokens.textSecondaryOf(context)),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _rows.length,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: DesignTokens.borderOf(context)),
      itemBuilder: (_, i) => _buildRow(_rows[i], i),
    );
  }

  Widget _buildRow(_ScriptRow row, int index) {
    return Container(
      color: index.isOdd
          ? DesignTokens.surfaceAltOf(context).withOpacity(0.5)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _dataCell(row.scriptIdentifier.toString(), flex: 2, mono: true),
          _dataCell(row.serviceId.toString(), flex: 2, mono: true),
          _dataCell(row.classId.toString(), flex: 2, mono: true),
          _dataCell(row.logicalName, flex: 3, mono: true),
          _dataCell(row.index.toString(), flex: 1, mono: true),
          _dataCell(row.parameter, flex: 3),
        ],
      ),
    );
  }

  Widget _dataCell(String text, {required int flex, bool mono = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: DesignTokens.textPrimaryOf(context),
          fontFamily: mono ? 'monospace' : null,
        ),
      ),
    );
  }
}
