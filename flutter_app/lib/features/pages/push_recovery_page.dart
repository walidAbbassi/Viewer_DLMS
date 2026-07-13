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
import '../push_setups/push_recovery_config.dart';
import '../../core/widget_keys.dart';

class PushRecoveryPage extends StatefulWidget {
  final PushRecoveryConfig config;

  const PushRecoveryPage({super.key, required this.config});

  @override
  State<PushRecoveryPage> createState() => _PushRecoveryPageState();
}

class _PushRecoveryPageState extends State<PushRecoveryPage> {
  late final IMeterClient _client;
  late List<String> _liveValues;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _liveValues = widget.config.objects.map((o) => o.value).toList();
    final isConnected = ProviderScope.containerOf(context, listen: false)
        .read(appControllerProvider)
        .isConnected;
    if (isConnected) _loadValues();
  }

  Future<void> _loadValues() async {
    if (widget.config.objects.isEmpty) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = widget.config.objects.map((o) {
        return GetPushRecoveryObjectsRequestItem()
          ..datasource = o.datasource
          ..attribute = int.tryParse(o.attribute) ?? 2;
      }).toList();
      final response = await _client.getPushRecoveryObjects(items);
      if (!mounted) return;
      setState(() {
        for (int i = 0;
            i < response.results.length && i < _liveValues.length;
            i++) {
          _liveValues[i] = response.results[i];
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = extractGrpcMessage(e);
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _client.close();
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
      ),
      drawer: const AppDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Breadcrumb(
                segments: ['Menu', 'Push Recovery', widget.config.label]),
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
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
                      // Card header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: DesignTokens.surfaceAltOf(context),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(8)),
                    border: Border(
                        bottom:
                            BorderSide(color: DesignTokens.borderOf(context))),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.restore,
                          size: 15, color: DesignTokens.primary600),
                      const SizedBox(width: 8),
                      Text(
                        'Recovery Objects',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: DesignTokens.textPrimaryOf(context),
                        ),
                      ),
                      const Spacer(),
                      if (_loading)
                        const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else if (_error != null)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 14, color: Colors.red.shade400),
                            const SizedBox(width: 4),
                            Text(
                              'Load failed',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.red.shade400),
                            ),
                            const SizedBox(width: 6),
                            InkWell(
                              key: const Key(PushRecoveryKeys.refreshBtn),
                              onTap: ProviderScope.containerOf(context,
                                      listen: false)
                                      .read(appControllerProvider)
                                      .isConnected
                                  ? _loadValues
                                  : null,
                              child: Icon(Icons.refresh,
                                  size: 14, color: DesignTokens.primary600),
                            ),
                          ],
                        ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: DesignTokens.primary600.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: DesignTokens.primary600.withOpacity(0.25)),
                        ),
                        child: Text(
                          '${objects.length} object${objects.length == 1 ? '' : 's'}',
                          style: TextStyle(
                              fontSize: 11, color: DesignTokens.primary600),
                        ),
                      ),
                    ],
                  ),
                ),
                // Column headers
                Container(
                  color: DesignTokens.surfaceAltOf(context),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  child: Row(
                    children: [
                      _headerCell('Description', flex: 3),
                      _headerCell('Type', flex: 2),
                      _headerCell('Value', flex: 2),
                      _headerCell('Scale/Unit Attr.', flex: 2),
                      _headerCell('Attribute', flex: 1),
                      _headerCell('Datasource', flex: 3),
                    ],
                  ),
                ),
                Divider(height: 1, color: DesignTokens.borderOf(context)),
                // Rows
                if (objects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'No recovery objects defined.',
                        style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textSecondaryOf(context)),
                      ),
                    ),
                  )
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: objects.length,
                    separatorBuilder: (_, __) => Divider(
                        height: 1, color: DesignTokens.borderOf(context)),
                    itemBuilder: (_, i) => _buildRow(objects[i], i),
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

  Widget _buildRow(PushRecoveryObject obj, int index) {
    return Container(
      color: index.isOdd
          ? DesignTokens.surfaceAltOf(context).withOpacity(0.5)
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          _dataCell(
            obj.description,
            flex: 3,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: DesignTokens.textPrimaryOf(context)),
          ),
          _dataCell(obj.type, flex: 2, chip: true),
          _dataCell(
            _liveValues[index],
            flex: 2,
            mono: true,
            loading: _loading,
          ),
          _dataCell(obj.scaleUnitAttrib, flex: 2),
          _dataCell(obj.attribute, flex: 1),
          _dataCell(obj.datasource, flex: 3, mono: true),
        ],
      ),
    );
  }

  Widget _dataCell(String text,
      {required int flex,
      bool mono = false,
      bool chip = false,
      bool loading = false,
      TextStyle? style}) {
    Widget child;
    if (chip) {
      child = Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: DesignTokens.primary600.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: DesignTokens.primary600.withOpacity(0.25)),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: 11, color: DesignTokens.primary600),
        ),
      );
    } else if (loading) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              color: DesignTokens.textSecondaryOf(context),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: DesignTokens.textSecondaryOf(context),
              fontFamily: mono ? 'monospace' : null,
            ),
          ),
        ],
      );
    } else {
      child = Text(
        text,
        style: style ??
            TextStyle(
              fontSize: 12,
              color: DesignTokens.textPrimaryOf(context),
              fontFamily: mono ? 'monospace' : null,
            ),
      );
    }

    return Expanded(
      flex: flex,
      child: Padding(padding: const EdgeInsets.only(right: 8), child: child),
    );
  }
}
