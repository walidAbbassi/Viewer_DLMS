import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/meter_client.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/export/export_registry.dart';
import '../../core/widget_keys.dart';
import '../../state/device_id_cache.dart';
import '../../state/app_controller.dart';

/// Energy Register Page - Dynamically loads objects from meter
class EnergyRegisterPage extends ConsumerStatefulWidget {
  const EnergyRegisterPage({super.key});

  @override
  ConsumerState<EnergyRegisterPage> createState() => _EnergyRegisterPageState();
}

class _EnergyRegisterPageState extends ConsumerState<EnergyRegisterPage>
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'energy_register';

  @override
  String get exportPageLabel => 'Energy Register';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'registers': _registers
            .map((r) => {
                  'id': r.id,
                  'name': r.name,
                  'description': r.description,
                  'obisCode': r.obisCode,
                  'value': r.value,
                  'unit': r.unit,
                })
            .toList(),
      };

  // ---------------------------------------------------------------------------

  late IMeterClient _client;

  // State
  bool _isLoading = false;
  String? _error;
  DateTime? _lastRead;
  List<EnergyRegister> _registers = [];
  String? _selectedRegisterId;
  EnergyRegister? _selectedRegisterDetail;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEnergyRegisters();
    });
  }

  /// Charge directement les valeurs d'énergie depuis le backend
  Future<void> _loadEnergyRegisters() async {
    if (!ref.read(appControllerProvider).isConnected) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Appel direct à GetEnergyRegister qui filtre et lit les valeurs
      final response = await _client.getEnergyRegister();

      final registers = <EnergyRegister>[];

      for (var i = 0; i < response.items.length; i++) {
        final item = response.items[i];
        // Parser la valeur et l'unité depuis la string "value unit"
        final parts = item.value.split(' ');
        final valueStr = parts.isNotEmpty ? parts[0] : '0';
        final value = double.tryParse(valueStr) ?? 0.0;
        final unit = parts.length > 1 ? parts.sublist(1).join(' ') : '';

        registers.add(EnergyRegister(
          id: '$i', // index guarantees uniqueness even when descriptions are identical
          name: item.description,
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
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text('${registers.length} energy registers loaded'),
                ],
              ),
              backgroundColor: DesignTokens.success,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
            ),
          );
      }
    } catch (e) {
      final msg = _getErrorMessage(e);
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(SnackBar(
            content: Text(msg),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 8),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 80, left: 16, right: 16),
          ));
      }
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  /// Extrait le code OBIS de la description si présent (ex: "RegisterName (1.8.0)")
  String _extractObisFromDescription(String description) {
    final match = RegExp(r'\(([0-9.]+)\)').firstMatch(description);
    return match?.group(1) ?? '';
  }

  /// Lit les détails d'un registre spécifique
  Future<void> _readRegisterDetail(String registerId) async {
    try {
      // Trouver le registre correspondant
      final register = _registers.firstWhere(
        (r) => r.id == registerId,
        orElse: () => throw Exception('Register not found'),
      );

      setState(() {
        _selectedRegisterDetail = register;
      });
    } catch (e) {
      setState(() {
        _error = 'Unable to read register detail: ${e.toString()}';
      });
    }
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
    return 'Unable to read energy registers. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(appControllerProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Register'),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          // Timestamp in app bar
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
          RefreshAppBarButton(onPressed: _loadEnergyRegisters),
          ExportActionButton(
            key: const Key(EnergyRegisterKeys.exportBtn),
            pageId: exportPageId,
            pageType: 'energy_register',
            dataGetter: getExportData,
            iconColor: Colors.white,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Error banner
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
                        key: const Key(EnergyRegisterKeys.dismissErrorBtn),
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => setState(() => _error = null),
                      ),
                    ],
                  ),
                ),

              // Page header subtitle
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
                  'Energy Register Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignTokens.textPrimaryOf(context),
                  ),
                ),
              ),

              // Main content
              Expanded(child: _buildContent()),
            ],
          ),
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: Center(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Lottie.asset(
                          'assets/animations/data.json',
                          width: 200,
                          height: 200,
                          errorBuilder: (context, err, stack) => const Text(
                            'Failed to load animation',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Loading energy registers from meter…',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 1024;

        if (isDesktop) {
          // Desktop: side-by-side layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(child: _buildAbsoluteTotalPanel()),
              ),
              Expanded(
                flex: 2,
                child:
                    SingleChildScrollView(child: _buildAbsoluteDetailPanel()),
              ),
            ],
          );
        } else {
          // Mobile: stacked layout
          return SingleChildScrollView(
            child: Column(
              children: [
                _buildAbsoluteTotalPanel(),
                _buildAbsoluteDetailPanel(),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildAbsoluteTotalPanel() {
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
              // Header with magnifying glass icon
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

  Widget _buildAbsoluteDetailPanel() {
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
              // Header with search icon
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
              _buildRegisterDropdown(),
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

  Widget _buildRegisterDropdown() {
    return DropdownButtonFormField<String>(
      key: const Key(EnergyRegisterKeys.registerDropdown),
      isExpanded: true,
      decoration: InputDecoration(
        labelText: 'Select Energy Register',
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: DesignTokens.borderOf(context))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
                color: DesignTokens.isDark(context)
                    ? DesignTokens.darkFocus
                    : DesignTokens.primary600,
                width: 1.2)),
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
        if (value != null) {
          setState(() => _selectedRegisterId = value);
          _readRegisterDetail(value);
        }
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
        // Header row with tinted background
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
        // Data rows
        ..._registers.map((register) => _buildTableRow(
              register.description,
              '${register.value.toStringAsFixed(2)} ${register.unit}',
            )),
      ],
    );
  }

  Widget _buildDetailTable() {
    final register = _selectedRegisterDetail!;
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
        // Header row
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
        _buildTableRow('Description', register.description),
        if (register.obisCode.isNotEmpty)
          _buildTableRow('OBIS Code', register.obisCode),
        _buildTableRow('Current Value',
            '${register.value.toStringAsFixed(2)} ${register.unit}'),
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
          child: Text(
            label,
            softWrap: true,
            style: TextStyle(
              fontSize: 14,
              color: DesignTokens.textPrimaryOf(context),
            ),
          ),
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

/// Call once at startup (e.g. in main.dart) to make the Energy Register page
/// available in the export templates screen.
void registerEnergyRegisterPage() {
  ExportRegistry.instance.register(
    const ExportedPageInfo(
      id: 'energy_register',
      label: 'Energy Register',
      icon: Icons.bolt_outlined,
      builder: _buildEnergyRegisterPage,
      tokens: {
        'registers': 'List of energy register entries',
        'registers[].id': 'Register identifier',
        'registers[].name': 'Register name',
        'registers[].description': 'Register description',
        'registers[].obisCode': 'OBIS code',
        'registers[].value': 'Numeric value',
        'registers[].unit': 'Unit (e.g. kWh)',
      },
    ),
  );
}

Widget _buildEnergyRegisterPage(BuildContext _) => const EnergyRegisterPage();

// Data model
class EnergyRegister {
  final String id;
  final String name;
  final String description;
  final String obisCode;
  final double value;
  final String unit;

  const EnergyRegister({
    required this.id,
    required this.name,
    required this.description,
    required this.obisCode,
    required this.value,
    required this.unit,
  });
}
