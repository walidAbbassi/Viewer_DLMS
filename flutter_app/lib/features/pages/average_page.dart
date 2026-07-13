import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:intl/intl.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/theme/semantic_colors.dart';
import '../../core/services/feedback_service.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../core/widgets/breadcrumb.dart';
import '../../grpc/meter_client.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';
import '../../state/app_controller.dart';

class AveragePage extends ConsumerStatefulWidget {
  const AveragePage({super.key});

  @override
  ConsumerState<AveragePage> createState() => _AveragePageState();
}

class _AveragePageState extends ConsumerState<AveragePage> {
  late IMeterClient _client;

  bool _isLoading = false;
  String? _error;
  DateTime? _lastRead;
  List<AverageRegister> _registers = [];
  String? _selectedRegisterId;
  AverageRegister? _selectedRegisterDetail;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAverageRegisters();
    });
  }

  Future<void> _loadAverageRegisters() async {
    if (!ref.read(appControllerProvider).isConnected) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _client.getAverage();
      final registers = <AverageRegister>[];

      for (final item in response.items) {
        final parts = item.value.split(' ');
        final valueStr = parts.isNotEmpty ? parts[0] : '0';
        final value = double.tryParse(valueStr) ?? 0.0;
        final unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        registers.add(AverageRegister(
          id: item.description,
          description: item.description,
          obisCode: _extractObisFromDescription(item.description),
          value: value,
          unit: unit,
        ));
      }

      setState(() {
        _registers = registers;
        _lastRead = DateTime.now();
        _isLoading = false;
      });

      if (mounted && registers.isNotEmpty) {
        feedback.success('${registers.length} average values loaded');
      }
    } catch (e) {
      final msg = _getErrorMessage(e);
      if (mounted) {
        feedback.error(msg);
      }
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  String _extractObisFromDescription(String description) {
    final match = RegExp(r'\(([0-9.]+)\)').firstMatch(description);
    return match?.group(1) ?? '';
  }

  void _selectRegisterDetail(String registerId) {
    final register = _registers.firstWhere(
      (r) => r.id == registerId,
      orElse: () => throw Exception('Register not found'),
    );
    setState(() {
      _selectedRegisterId = registerId;
      _selectedRegisterDetail = register;
    });
  }

  String _getErrorMessage(dynamic e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) return msg;
    }
    final errorStr = e.toString();
    if (errorStr.contains('connection') ||
        errorStr.contains('Connection') ||
        errorStr.contains('SocketException')) {
      return 'Connection to meter failed. Please check if the meter is connected.';
    } else if (errorStr.contains('timeout') || errorStr.contains('Timeout')) {
      return 'Request timeout. The meter is not responding.';
    } else if (errorStr.contains('RpcError') || errorStr.contains('grpc')) {
      return 'Communication error with meter. Please verify meter connection.';
    }
    return 'Unable to read average values. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appControllerProvider);
    final sc = SemanticColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Average'),
        backgroundColor: sc.primary,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (_lastRead != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Center(
                child: Text(
                  'Last read: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(_lastRead!)}',
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ),
            ),
          RefreshAppBarButton(onPressed: _loadAverageRegisters),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: const Breadcrumb(
                segments: ['Menu', 'Electricity Objects', 'Average']),
          ),
          Expanded(
            child: Column(
              children: [
                if (_error != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    color: DesignTokens.danger,
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(color: Colors.white)),
                        ),
                        IconButton(
                          key: const Key(AverageKeys.dismissErrorBtn),
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => setState(() => _error = null),
                        ),
                      ],
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: DesignTokens.surfaceOf(context),
                    border: Border(
                      bottom: BorderSide(
                          color: DesignTokens.borderOf(context), width: 1),
                    ),
                  ),
                  child: Text(
                    'Instantaneous Average Values',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                  ),
                ),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading average values from meter…'),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(child: _buildTotalPanel()),
              ),
              Expanded(
                flex: 2,
                child: SingleChildScrollView(child: _buildDetailPanel()),
              ),
            ],
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [_buildTotalPanel(), _buildDetailPanel()],
            ),
          );
        }
      },
    );
  }

  Widget _buildTotalPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.search,
                      color: DesignTokens.isDark(context)
                          ? Colors.white
                          : DesignTokens.primary600,
                      size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Absolute Total',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildTotalTable(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPanel() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.manage_search,
                      color: DesignTokens.isDark(context)
                          ? Colors.white
                          : DesignTokens.primary600,
                      size: 24),
                  const SizedBox(width: 12),
                  Text(
                    'Absolute Detail',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: DesignTokens.textPrimaryOf(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildDropdown(),
              const SizedBox(height: 24),
              if (_selectedRegisterDetail != null)
                _buildDetailTable()
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Text(
                      'Select a register from the dropdown above',
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignTokens.textSecondaryOf(context),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      key: const Key(AverageKeys.registerDropdown),
      isExpanded: true,
      value: _selectedRegisterId,
      decoration: InputDecoration(
        labelText: 'Select Average Register',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        filled: true,
        fillColor:
            DesignTokens.isDark(context) ? DesignTokens.darkFill : Colors.white,
      ),
      items: _registers.map((register) {
        return DropdownMenuItem(
          value: register.id,
          child: Text(
            register.description,
            style: const TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) _selectRegisterDetail(value);
      },
    );
  }

  Widget _buildTotalTable() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
      },
      border: TableBorder.all(
        color: DesignTokens.borderOf(context),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: DesignTokens.primary600.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader('Description'),
            _buildTableHeader('Value'),
          ],
        ),
        ..._registers.map((r) => _buildTableRow(
            r.description, '${r.value.toStringAsFixed(2)} ${r.unit}')),
      ],
    );
  }

  Widget _buildDetailTable() {
    final r = _selectedRegisterDetail!;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(3),
      },
      border: TableBorder.all(
        color: DesignTokens.borderOf(context),
        width: 1,
        borderRadius: BorderRadius.circular(8),
      ),
      children: [
        TableRow(
          decoration: BoxDecoration(
            color: DesignTokens.primary600.withOpacity(0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          children: [
            _buildTableHeader('Property'),
            _buildTableHeader('Value'),
          ],
        ),
        _buildTableRow('Description', r.description),
        if (r.obisCode.isNotEmpty) _buildTableRow('OBIS Code', r.obisCode),
        _buildTableRow(
            'Current Value', '${r.value.toStringAsFixed(2)} ${r.unit}'),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        text,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: DesignTokens.textPrimaryOf(context),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(label,
              softWrap: true,
              style: TextStyle(
                  fontSize: 14, color: DesignTokens.textPrimaryOf(context))),
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: SelectableText(
            value,
            style: TextStyle(
              fontSize: 14,
              fontFamily: 'monospace',
              color: DesignTokens.textPrimaryOf(context),
            ),
          ),
        ),
      ],
    );
  }
}

class AverageRegister {
  final String id;
  final String description;
  final String obisCode;
  final double value;
  final String unit;

  const AverageRegister({
    required this.id,
    required this.description,
    required this.obisCode,
    required this.value,
    required this.unit,
  });
}
