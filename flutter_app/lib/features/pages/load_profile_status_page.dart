import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:grpc/grpc.dart' show GrpcError;

import '../../core/theme/design_tokens.dart';
import '../../core/widgets/app_drawer.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/generated/meter.pb.dart';
import '../../grpc/meter_client.dart';
import '../../state/app_controller.dart';
import '../load_profile/load_profile_config.dart';
import '../load_profile/load_profile_service.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/export/export_registry.dart';
import '../../state/device_id_cache.dart';
import '../../core/widget_keys.dart';

/// Page for status profiles: calls [getBitStatus] and renders each bit
/// as a colored circle + description.
class LoadProfileStatusPage extends StatefulWidget {
  final LoadProfileConfig config;

  const LoadProfileStatusPage({super.key, required this.config});

  @override
  State<LoadProfileStatusPage> createState() => _LoadProfileStatusPageState();
}

class _LoadProfileStatusPageState extends State<LoadProfileStatusPage>
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'load_profile_status_${widget.config.id}';

  @override
  String get exportPageLabel => widget.config.name;

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'name': widget.config.name,
        'description': widget.config.description,
        'dataSource': widget.config.dataSource,
        'bits': _bits
                ?.map((b) => {
                      'mask': b.mask,
                      'bitValue': b.bitValue,
                      'description': b.description,
                      'isActive': b.isActive,
                    })
                .toList() ??
            [],
      };

  // ---------------------------------------------------------------------------

  late IMeterClient _client;

  List<BitStatus>? _bits;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    // Don't auto-load — defer to build() where we can check isConnected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isConnected = ProviderScope.containerOf(context, listen: false)
          .read(appControllerProvider)
          .isConnected;
      if (isConnected) _load();
    });
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final desc = widget.config.bitDescription!;
      final descJson = jsonEncode(
        desc.bitsDescripTable
            .map((e) => {
                  'mask': e.mask,
                  'bitValue': e.bitValue,
                  'description': e.description,
                })
            .toList(),
      );
      final response =
          await _client.getBitStatus(widget.config.dataSource, descJson);
      if (mounted) {
        setState(() {
          _bits = response.bits;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = _extractErrorMessage(e);
          _isLoading = false;
        });
      }
    }
  }

  /// Returns the Blue Book abbreviation for a bit description string.
  String _abbreviationFrom(String description) {
    final d = description.toLowerCase();
    if (d.contains('power down')) return 'PDN';
    if (d.contains('clock invalid')) return 'CIV';
    if (d.contains('data not valid')) return 'DNV';
    if (d.contains('daylight saving')) return 'DST';
    if (d.contains('clock adjusted')) return 'CAD';
    if (d.contains('capturing')) return 'CD';
    if (d.contains('critical error') || d.contains('error')) return 'ERR';
    if (d.contains('net-metering') || d.contains('net metering')) return 'NM';
    return '-';
  }

  String _extractErrorMessage(Object e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) return msg;
      return e.toString();
    }
    return e.toString().replaceFirst('Exception: ', '');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0f172a) : null,
      appBar: AppBar(
        title: Text(widget.config.name),
        backgroundColor:
            isDark ? const Color(0xFF1e3a6e) : DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          ExportActionButton(
            key: const Key(LoadProfileStatusKeys.exportBtn),
            pageId: exportPageId,
            pageType: 'load_profile_status',
            dataGetter: getExportData,
            iconColor: Colors.white,
          ),
          RefreshAppBarButton(
            key: const Key(LoadProfileStatusKeys.refreshBtn),
            onPressed: _load,
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildSkeletonTable();
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                key: const Key(LoadProfileStatusKeys.retryBtn),
                onPressed: ProviderScope.containerOf(context, listen: false)
                        .read(appControllerProvider)
                        .isConnected
                    ? _load
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_bits == null || _bits!.isEmpty) {
      return _buildSkeletonTable();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor =
        isDark ? Colors.greenAccent.shade400 : Colors.green.shade800;
    final inactiveColor = isDark ? Colors.red.shade300 : Colors.red.shade700;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
            isDark ? const Color(0xFF1e3a5f) : DesignTokens.primary50),
        border: TableBorder.all(
            color: isDark ? const Color(0xFF334155) : DesignTokens.gray200,
            width: 1),
        columns: [
          DataColumn(
              label: Text('Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Bit Value',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Abbreviation',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Bit Description',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
        ],
        rows: _bits!.map((bit) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: bit.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bit.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: bit.isActive ? activeColor : inactiveColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(
                Text(
                  bit.bitValue,
                  style: TextStyle(
                    fontSize: 13,
                    fontFamily: 'monospace',
                    color:
                        isDark ? const Color(0xFFCBD5E1) : Colors.grey.shade700,
                  ),
                ),
              ),
              DataCell(
                Text(
                  _abbreviationFrom(bit.description),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: bit.isActive ? activeColor : inactiveColor,
                  ),
                ),
              ),
              DataCell(
                Text(
                  bit.description,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ); // end DataTable scroll
  }

  Widget _buildSkeletonTable() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final entries = widget.config.bitDescription?.bitsDescripTable ?? [];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: DataTable(
        headingRowColor: WidgetStateProperty.all(
            isDark ? const Color(0xFF1e3a5f) : DesignTokens.primary50),
        border: TableBorder.all(
            color: isDark ? const Color(0xFF334155) : DesignTokens.gray200,
            width: 1),
        columns: [
          DataColumn(
              label: Text('Status',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Bit Value',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Abbreviation',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
          DataColumn(
              label: Text('Bit Description',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF1F5F9) : null))),
        ],
        rows: entries.map((entry) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark
                            ? const Color(0xFF475569)
                            : DesignTokens.gray300,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '—',
                      style: TextStyle(
                        color: isDark
                            ? const Color(0xFF64748B)
                            : DesignTokens.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              DataCell(Text(
                '—',
                style: TextStyle(
                  fontSize: 13,
                  color:
                      isDark ? const Color(0xFF475569) : DesignTokens.gray400,
                ),
              )),
              DataCell(Text(
                _abbreviationFrom(entry.description),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : DesignTokens.textSecondary,
                ),
              )),
              DataCell(Text(
                entry.description,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFF94A3B8) : null,
                ),
              )),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// Call once at startup to register all status-profile pages in [ExportRegistry].
Future<void> registerAllLoadProfileStatusPages() async {
  final configs = await LoadProfileService.loadConfig();
  for (final config in configs) {
    if (config.bitDescription == null) continue;
    ExportRegistry.instance.register(
      ExportedPageInfo(
        id: 'load_profile_status_${config.id}',
        label: config.name,
        icon: Icons.toggle_on_outlined,
        builder: (_) => LoadProfileStatusPage(config: config),
        tokens: const {
          'name': 'Profile name',
          'description': 'Profile description',
          'dataSource': 'DLMS data source reference',
          'bits': 'List of bit status entries',
          'bits[].mask': 'Bit mask (hex string)',
          'bits[].bitValue': 'Raw bit value string',
          'bits[].description': 'Human-readable bit description',
          'bits[].isActive': 'Whether the bit is active',
        },
      ),
    );
  }
}
