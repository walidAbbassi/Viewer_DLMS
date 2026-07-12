import 'package:flutter/material.dart';
import '../../util/grpc_error.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/services/feedback_service.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/read_only_value.dart';
import '../../core/widgets/refresh_action_button.dart';
import '../../grpc/meter_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_controller.dart';
import '../../state/app_state.dart';
import '../../core/user_rights.dart';
import '../../core/feature_keys.dart';
import '../../core/widget_keys.dart';
import '../../core/widgets/app_skeleton.dart';
import '../../core/export/exportable_page.dart';
import '../../core/export/export_action_button.dart';
import '../../core/export/export_registry.dart';
import '../../state/device_id_cache.dart';

class FirmwareVersionPage extends ConsumerStatefulWidget {
  const FirmwareVersionPage({super.key});

  @override
  ConsumerState<FirmwareVersionPage> createState() =>
      _FirmwareVersionPageState();
}

class _FirmwareVersionPageState extends ConsumerState<FirmwareVersionPage>
    implements ExportablePage {
  // ---- ExportablePage -------------------------------------------------------

  @override
  String get exportPageId => 'firmware_version';

  @override
  String get exportPageLabel => 'Firmware Version';

  @override
  Map<String, dynamic> getExportData() => {
        'deviceId': DeviceIdCache.data,
        'fields': {
          for (final name in _fieldOrder) name: _values[name] ?? '',
        },
      };

  // ---------------------------------------------------------------------------

  late IMeterClient _client;

  Map<String, String> _values = {};
  List<String> _fieldOrder = [];

  // State
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    if (ref.read(appControllerProvider).isConnected) {
      _readFirmwareVersion();
    }
  }

  @override
  void dispose() {
    _client.close();
    super.dispose();
  }

  Future<void> _readFirmwareVersion() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _client.getFirmwareVersion();
      final fields = response.items;

      setState(() {
        _values = {for (final entry in fields) entry.name: entry.value};
        _fieldOrder = [for (final entry in fields) entry.name];
        _isLoading = false;
      });

      if (mounted) {
        feedback.success('Loaded ${fields.length} firmware version fields');
      }
    } catch (e) {
      final msg = extractGrpcMessage(e);
      if (mounted) {
        feedback.error(msg);
      }
      setState(() {
        _error = msg;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isConnected = ref.watch(appControllerProvider).isConnected;
    ref.listen<AppState>(appControllerProvider, (prev, next) {
      if (!(prev?.isConnected ?? false) && next.isConnected) {
        _readFirmwareVersion();
      }
    });

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firmware Version'),
        backgroundColor:
            isDark ? const Color(0xFF1e3a6e) : DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          ExportActionButton(
            key: const Key(FirmwareVersionKeys.exportBtn),
            pageId: exportPageId,
            pageType: 'firmware_version',
            dataGetter: getExportData,
            iconColor: Colors.white,
          ),
          RefreshAppBarButton(
            key: const Key(FirmwareVersionKeys.refreshBtn),
            onPressed: _readFirmwareVersion,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF0f172a), Color(0xFF1e293b)]
                : [DesignTokens.background, DesignTokens.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Error banner
            if (_error != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: DesignTokens.danger.withOpacity(0.1),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: DesignTokens.danger),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_error!,
                          style: TextStyle(color: DesignTokens.danger)),
                    ),
                    IconButton(
                      key: const Key(FirmwareVersionKeys.dismissErrorBtn),
                      icon: const Icon(Icons.close),
                      onPressed: () => setState(() => _error = null),
                    ),
                  ],
                ),
              ),
            // Content
            Expanded(
              child: _isLoading
                  ? _buildPageSkeleton()
                  : _fieldOrder.isEmpty
                      ? _buildPageSkeleton()
                      : SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 800),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Meter Identification',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: isDark
                                              ? const Color(0xFF60A5FA)
                                              : DesignTokens.primary600,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Read-only meter identification data',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDark
                                              ? const Color(0xFF94A3B8)
                                              : DesignTokens.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 32),
                                      ...List.generate(_fieldOrder.length,
                                          (index) {
                                        final fieldName = _fieldOrder[index];
                                        return Column(
                                          children: [
                                            if (index > 0)
                                              const SizedBox(height: 20),
                                            _buildFieldRow(fieldName,
                                                _values[fieldName] ?? ''),
                                          ],
                                        );
                                      }),
                                      const SizedBox(height: 32),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          AppButton.secondary(
                                            key: const Key(
                                                FirmwareVersionKeys.readBtn),
                                            icon: AppIcons.read,
                                            label: 'Read',
                                            onPressed: (!isConnected ||
                                                    _isLoading ||
                                                    !userRights
                                                        .hasRightForFeature(
                                                            'Get',
                                                            FeatureKeys
                                                                .fwVersion))
                                                ? null
                                                : _readFirmwareVersion,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldRow(String label, String value) {
    // ReadOnlyValue renders its own label + value + copy, so no extra label
    // column here.
    return ReadOnlyValue(
      key: Key(FirmwareVersionKeys.fieldKey(label)),
      label: label,
      value: value,
    );
  }

  Widget _buildPageSkeleton() {
    return IgnorePointer(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SkeletonBox(width: 220, height: 28),
                    const SizedBox(height: 10),
                    const SkeletonBox(width: 300, height: 14),
                    const SizedBox(height: 32),
                    ...List.generate(
                      7,
                      (_) => const Padding(
                        padding: EdgeInsets.only(bottom: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                                width: 250, child: SkeletonBox(height: 14)),
                            SizedBox(width: 24),
                            Expanded(child: SkeletonBox(height: 48)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SkeletonBox(width: 88, height: 44, borderRadius: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Call once at startup (e.g. in main.dart) to make the Firmware Version page
/// available in the export templates screen.
void registerFirmwareVersionPage() {
  ExportRegistry.instance.register(
    const ExportedPageInfo(
      id: 'firmware_version',
      label: 'Firmware Version',
      icon: Icons.memory_outlined,
      builder: _buildFirmwareVersionPage,
      tokens: {
        'fields.*': 'Firmware field value – e.g. fields.Firmware_Version',
      },
    ),
  );
}

Widget _buildFirmwareVersionPage(BuildContext _) => const FirmwareVersionPage();
