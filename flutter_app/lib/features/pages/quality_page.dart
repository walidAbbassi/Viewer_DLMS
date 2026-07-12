// ignore_for_file: invalid_use_of_visible_for_testing_member



import 'package:flutter/material.dart';
import 'package:flutter_python_grpc/core/theme/design_tokens.dart';
import 'package:flutter_python_grpc/core/widgets/number_input_field.dart';
import 'package:flutter_python_grpc/core/widgets/refresh_action_button.dart';
import 'package:flutter_python_grpc/grpc/generated/meter.pb.dart';
import 'package:flutter_python_grpc/grpc/meter_client.dart';
import 'package:collection/collection.dart';
import 'package:grpc/grpc.dart';
import '../quality/quality_config.dart';
import 'package:flutter/services.dart';
import '../../util/value_format.dart';

class QualityPage extends StatefulWidget {
  final QualityConfig config;

  const QualityPage({super.key, required this.config});

  @override
  State<QualityPage> createState() => _QualityPageState();
}

class _QualityPageState extends State<QualityPage>
    with SingleTickerProviderStateMixin {
  late IMeterClient _client;
  TabController? _tabController;
  bool _loading = false;
  List<QualityObject> _objects = [];
  final Map<String, TextEditingController> _controllers =
      <String, TextEditingController>{};
  final Map<String, String> _displayValues = <String, String>{};
  String? _activeEditItemId;
  bool _isPulling = false;
  final Map<String, QualityConfigValue> _configValueByItem = {};

  @override
  void initState() {
    super.initState();
    _client = meterClientFactory();
    _initControllers();

    final tabCount = widget.config.tabs?.length ?? 0;
    
    if (tabCount > 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await _readCurrentTabValues();
      });
      _tabController = TabController(
        length: tabCount,
        vsync: this,
      );

      _tabController!.addListener(() {
        if (!_tabController!.indexIsChanging) {
          _readCurrentTabValues();
        }
      });
    }
    else {
         WidgetsBinding.instance.addPostFrameCallback((_) async {
          await _readAllConfiguredValues();
      });
    }


   
  }

  Future<void> _readConfigItem(QualityItemConfig item) async {
  setState(() => _loading = true);

  try {
    final values = await _client.readQualityConfig(
      item.dataSource,
    );

    if (item.structure != null &&
        item.structure!.isNotEmpty) {
      for (int i = 0;
          i < item.structure!.length &&
              i < values.length;
          i++) {
        final child = item.structure![i];

        _configValueByItem[child.id] =
            values[i];

        _controllers[child.id]?.text =
            values[i].value.toString();
      }
    } else if (values.isNotEmpty) {
      _configValueByItem[item.id] =
          values.first;

      _controllers[item.id]?.text =
          values.first.value.toString();
    }
  } catch (e) {
    if (mounted) {
      _showErrorMessage(
        context,
        _extractErrorMessage(e),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

Future<void> _writeConfigItem(
  QualityItemConfig item,
) async {
  setState(() => _loading = true);

  try {
    final values = <QualityConfigValue>[];

    if (item.structure != null &&
        item.structure!.isNotEmpty) {
      for (final child in item.structure!) {
        final cached =
            _configValueByItem[child.id];

        values.add(
          QualityConfigValue()
            ..value = int.tryParse(
                  _controllers[child.id]
                          ?.text
                          .trim() ??
                      '',
                )??
                0 
            ..type = cached?.type ?? '',
        );
      }

      await _client.WriteQualityConfig(
        item.dataSource,
        values,
        true,
      );
    } else {
      final cached =
          _configValueByItem[item.id];

      values.add(
        QualityConfigValue()
          ..value = int.tryParse(
                _controllers[item.id]
                        ?.text
                        .trim() ??
                    '',
              ) ??
              0
          ..type = cached?.type ?? '',
      );

      await _client.WriteQualityConfig(
        item.dataSource,
        values,
        false,
      );
    }

    _showSnackBar(
      '${item.label} written successfully',
    );
  } catch (e) {
    if (mounted) {
      _showErrorMessage(
        context,
        _extractErrorMessage(e),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _loading = false);
    }
  }
}

  Future<void> _readCurrentTabValues() async {
    if (_tabController == null) {
      return;
    }
    
    final tabIndex = _tabController!.index;
    final tab = widget.config.tabs![tabIndex];
    final items = _getItemsForTab(tabIndex);
    
    setState(() => _loading = true);
    try {
      if (tab.type == 'config') {
        // Read config-type items via readQualityConfig
        for (final item in items) {
          await _readConfigItem(item);
        }
      } else {
        // Read no_config items via getQualityObjects
        _objects = await _client.getQualityObjects(
          items.map((e) => e.dataSource).toList(),
        );
        for (final obj in _objects) {
          final item = items.firstWhereOrNull(
            (e) => e.dataSource == obj.name,
          );
          if (item != null) {
            _controllers[item.id]?.text = _formatEditableValue(obj);
            _displayValues[item.id] = _formatDisplayValue(obj);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  
  List<QualityItemConfig> _getItemsForTab(int tabIndex) {
    final tab = widget.config.tabs![tabIndex];

    if (tab.sections != null) {
      return tab.sections!
          .expand((section) => section.objects)
          .toList();
    }

    return tab.items ?? [];
  }


  @override
  void dispose() {
    _tabController?.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  

  void _initControllers() {
  for (final item in _allItems) {
    _controllers.putIfAbsent(
      item.id,
      () => TextEditingController(),
    );

    if (item.structure != null) {
      for (final child in item.structure!) {
        _controllers.putIfAbsent(
          child.id,
          () => TextEditingController(),
        );
      }
    }
  }
}


  QualityObject? _getObjectForItem(QualityItemConfig item) {
  return _objects.firstWhereOrNull(
    (e) => e.name == item.dataSource,
  );
}

int _getAllowedDecimals(QualityObject? object) {
  if (object == null) {
    return 10;
  }

  if (object.scaler >= 0) {
    return 0;
  }

  return object.scaler.abs();
}

List<TextInputFormatter> _getInputFormatters(QualityObject? object) {
  final decimals = _getAllowedDecimals(object);

  if (decimals == 0) {
    return [
      FilteringTextInputFormatter.allow(
        RegExp(r'^-?\d*'),
      ),
    ];
  }

  return [
    FilteringTextInputFormatter.allow(
      RegExp(
        '^-?\\d*([\\.,]\\d{0,$decimals})?',
      ),
    ),
  ];
}

  List<QualityItemConfig> get _allItems {
    if (widget.config.tabs != null) {
      return widget.config.tabs!.expand<QualityItemConfig>((tab) {
        if (tab.sections != null) {
          return tab.sections!
              .expand<QualityItemConfig>((section) => section.objects);
        }
        return tab.items ?? const <QualityItemConfig>[];
      }).toList(growable: false);
    }
    if (widget.config.sections != null) {
      return widget.config.sections!
          .expand((section) => section.objects)
          .toList(growable: false);
    }
    return widget.config.items ?? <QualityItemConfig>[];
  }

  Future<void> _readAllConfiguredValues() async {
    setState(() => _loading = true);
    try {
      // Determine if current context is config or no_config type
      final pageType = widget.config.tabs != null
          ? widget.config.tabs![_tabController?.index ?? 0].type
          : (widget.config.type ?? 'no_config');

      if (pageType == 'config') {
        // Read config-type items via readQualityConfig
        for (final item in _allItems) {
          await _readConfigItem(item);
        }
      } else {
        // Read no_config items via getQualityObjects
        _objects = await _client.getQualityObjects(
          _allItems.map((e) => e.dataSource).toList(),
        );
        for (final obj in _objects) {
          final item = _allItems.firstWhereOrNull(
            (e) => e.dataSource == obj.name,
          );
          if (item != null) {
            _controllers[item.id]?.text = _formatEditableValue(obj);
            _displayValues[item.id] = _formatDisplayValue(obj, item);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is GrpcError) {
      final msg = e.message;
      if (msg != null && msg.isNotEmpty) {
        return msg;
      }
      return e.toString();
    }
    final raw = e.toString();
    return raw.replaceFirst('Exception: ', '');
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 8),
        ),
      );
  }

  Future<void> _readItem(QualityItemConfig item) async {
    setState(() => _loading = true);
    try {
      // Determine current page/tab type
      final pageType = widget.config.tabs != null
          ? widget.config.tabs![_tabController?.index ?? 0].type
          : (widget.config.type ?? 'no_config');

      if (pageType == 'config') {
        // Use config read for config-type pages
        await _readConfigItem(item);
      } else {
        // Use no_config read for no_config pages
        final object =
            (await _client.getQualityObjects([item.dataSource])).firstOrNull;
        if (object != null) {
          final config_item = _allItems.firstWhereOrNull(
            (e) => e.dataSource == item.dataSource,
          );
          if (config_item != null) {
            _controllers[config_item.id]?.text = _formatEditableValue(object);
            _displayValues[config_item.id] =
                _formatDisplayValue(object, config_item);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(context, _extractErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  
Future<void> _startPulling() async {
  while (_isPulling && mounted) {
    final hasTabs = widget.config.tabs != null && widget.config.tabs!.isNotEmpty;
    final currentTabType = hasTabs
        ? widget.config.tabs![_tabController?.index ?? 0].type
        : null;

    if (hasTabs && currentTabType == 'no_config') {
      await _readCurrentTabValues();
    } else {
      await _readAllConfiguredValues();
    }

    await Future.delayed(
      const Duration(seconds: 1),
    );
  }
}

  Future<void> _writeItem(QualityItemConfig item) async {
    setState(() => _loading = true);

    try {
      // Determine current page/tab type
      final pageType = widget.config.tabs != null
          ? widget.config.tabs![_tabController?.index ?? 0].type
          : (widget.config.type ?? 'no_config');

      if (pageType == 'config') {
        // Use WriteQualityConfig for config-type pages
        await _writeConfigItem(item);
      } else {
        // Use updateQualityObject for no_config pages
        final dataSource = item.dataSource;
        final raw =
            (_controllers[item.id]?.text.trim() ?? '').replaceAll(',', '.');

        final object = _objects.firstWhereOrNull(
          (e) => e.name == item.dataSource,
        );

        if (object == null) {
          _showSnackBar(
            'Invalid value for ${item.label}',
            isError: true,
          );
          return;
        }

        num? value;

        if (object.scaler == 0) {
          value = int.tryParse(raw);
        } else {
          final decimals = object.scaler.abs();
          final parsed = double.tryParse(raw);

          if (parsed != null) {
            value = double.parse(
              parsed.toStringAsFixed(decimals),
            );
          }
        }

        if (value == null) {
          _showSnackBar(
            'Invalid number for ${item.label}',
            isError: true,
          );
          return;
        }

        await _client.updateQualityObject(
          dataSource,
          value.toDouble(),
          object.scaler,
        );

        _showSnackBar(
          '${item.label} written successfully',
        );
      }
    } catch (e) {
      _showErrorMessage(
        context,
        _extractErrorMessage(e),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  
  String _formatEditableValue(QualityObject object) {
    if (object.scaler == 0) {
      return object.value.toInt().toString();
    }

    return object.value.toStringAsFixed(
      object.scaler.abs(),
    );
  }


  String _formatDisplayValue(QualityObject object, [QualityItemConfig? item]) {
    // Prefer unit from config item if available
    final unit = (item?.unit?.trim() ?? object.unit.trim()).trim();
    if (object.scaler == 0) {
      return formatValue(object.value.toInt(), unit);
    }
    return formatValue(object.value, unit, decimals: object.scaler.abs());
  }

  
Future<void> _readStructure(QualityItemConfig item) async {
  if (item.structure == null) {
    return;
  }

  final pageType = widget.config.tabs != null
      ? widget.config.tabs![_tabController?.index ?? 0].type
      : (widget.config.type ?? 'no_config');

  if (pageType == 'config') {
    // For structured config items, backend expects the parent datasource.
    await _readConfigItem(item);
    return;
  }

  for (final child in item.structure!) {
    await _readItem(child);
  }
}

Future<void> _writeStructure(QualityItemConfig item) async {
  if (item.structure == null) {
    return;
  }

  final pageType = widget.config.tabs != null
      ? widget.config.tabs![_tabController?.index ?? 0].type
      : (widget.config.type ?? 'no_config');

  if (pageType == 'config') {
    // For structured config items, backend expects the parent datasource.
    await _writeConfigItem(item);
    return;
  }

  for (final child in item.structure!) {
    await _writeItem(child);
  }
}


  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
      ),
    );
  }

  Widget _buildConfigSection(List<QualityItemConfig> items) {
  return Wrap(
    spacing: 12,
    runSpacing: 12,
    children: items.map((item) {
      // Normal item
      if (item.structure == null || item.structure!.isEmpty) {
        return SizedBox(
          width: 320,
          child: NumberInputField(
            key: Key('quality_config_${item.id}'),
            label: item.label,
            controller: _controllers[item.id]!,
            hasButtons: true,
            onRead: () => _readItem(item),
            onWrite: () => _writeItem(item),
          ),
        );
      }

      // Structured item
      return SizedBox(
        width: 500,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: Theme.of(context).textTheme.titleSmall,
                ),

                const SizedBox(height: 12),

                ...item.structure!.map((child) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: _controllers[child.id],
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        labelText: child.label,
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _readStructure(item),
                      icon: const Icon(Icons.visibility),
                      label: const Text('Read'),
                    ),

                    const SizedBox(width: 8),

                    ElevatedButton.icon(
                      onPressed: () => _writeStructure(item),
                      icon: const Icon(Icons.edit),
                      label: const Text('Write'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}

 Widget _buildNoConfigTable(List<QualityItemConfig> items) {
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
        // Pull button
        Padding(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.centerLeft,
            child: ElevatedButton.icon(
              onPressed: 
                        () async {
                                if (_isPulling) {
                                  setState(() {
                                    _isPulling = false;
                                  });
                                } else {
                                  setState(() {
                                    _isPulling = true;
                                  });

                                  _startPulling();
                                }
                              }
                        ,
              icon:  Icon(_isPulling ? Icons.stop : Icons.play_arrow,),
              label:  Text(_isPulling ? 'Stop' : 'Pull'),
            ),
          ),
        ),

        Container(
          color: DesignTokens.surfaceAltOf(context),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(
            children: [
              _noConfigHeaderCell('Description', flex: 3),
              _noConfigHeaderCell('Value', flex: 5),
            ],
          ),
        ),
        Divider(height: 1, color: DesignTokens.borderOf(context)),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                'No objects configured.',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignTokens.textSecondaryOf(context),
                ),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: DesignTokens.borderOf(context)),
            itemBuilder: (_, i) {
              final item = items[i];
              final controller = _controllers[item.id]!;
              final isEditing = _activeEditItemId == item.id;
              final displayValue = _displayValues[item.id] ?? '-';

              return Container(
                color: i.isOdd
                    ? DesignTokens.surfaceAltOf(context)
                        .withValues(alpha: 0.5)
                    : null,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _activeEditItemId = isEditing ? null : item.id;
                    });
                  },
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignTokens.textPrimaryOf(context),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: isEditing
                            ? Row(
                                children: [
                                  Expanded(
                                    child: Builder(
                                    builder: (_) {
                                      final object = _getObjectForItem(item);

                                      return TextField(
                                        controller: controller,
                                        keyboardType: const TextInputType.numberWithOptions(
                                          decimal: true,
                                          signed: true,
                                        ),
                                        inputFormatters: _getInputFormatters(object),
                                        decoration: const InputDecoration(
                                          isDense: true,
                                          border: OutlineInputBorder(),
                                        ),
                                      );
                                    },
                                  ),
                                  ),
                                  IconButton(
                                    tooltip: 'Read',
                                    onPressed: () => _readItem(item),
                                    icon: const Icon(Icons.visibility),
                                  ),
                                  IconButton(
                                    tooltip: 'Write',
                                    onPressed: () => _writeItem(item),
                                    icon: const Icon(Icons.edit),
                                  ),
                                ],
                              )
                            : Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  displayValue,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        DesignTokens.textPrimaryOf(context),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}

  Widget _noConfigHeaderCell(String text, {required int flex}) {
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

  Widget _buildSectionContent({required String type, required List<QualityItemConfig> items}) {
    if (type == 'config') {
      return _buildConfigSection(items);
    }
    return _buildNoConfigTable(items);
  }

  Widget _buildSection(QualitySectionConfig section, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        _buildSectionContent(type: type, items: section.objects),
      ],
    );
  }

  Widget _buildSections(List<QualitySectionConfig> sections, String type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < sections.length; i++) ...[
          _buildSection(sections[i], type),
          if (i < sections.length - 1) const SizedBox(height: 20),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasTabs = widget.config.tabs != null && widget.config.tabs!.isNotEmpty;

    return Stack(
          children: [Scaffold(
      appBar: AppBar(
        title: Text(widget.config.name),
        backgroundColor: DesignTokens.primary600,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          RefreshAppBarButton(onPressed: _readAllConfiguredValues),
        ],
        bottom: hasTabs
            ? TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                isScrollable: true,
                tabs: [
                  for (final tab in widget.config.tabs!) Tab(text: tab.label),
                ],
              )
            : null,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: hasTabs
                ? TabBarView(
                    controller: _tabController,
                    children: [
                      for (final tab in widget.config.tabs!)
                        SingleChildScrollView(
                          child: tab.sections != null
                            ? _buildSections(tab.sections!, tab.type)
                              : _buildSectionContent(
                              type: tab.type,
                                  items:
                                      tab.items ?? const <QualityItemConfig>[],
                                ),
                        ),
                    ],
                  )
                : SingleChildScrollView(
                    child: widget.config.sections != null
                        ? _buildSections(
                          widget.config.sections!,
                          widget.config.type ?? 'no_config',
                          )
                        : _buildSectionContent(
                            type: widget.config.type ?? 'no_config',
                            items:
                                widget.config.items ?? const <QualityItemConfig>[],
                          ),
                  ),
          ),
          
        ],
      ),
    ),
    if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(alpha: 0.25),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            )]);
  }

}
