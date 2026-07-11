class PushSetupTab {
  final String label;
  final String dataSource;

  const PushSetupTab({required this.label, required this.dataSource});

  factory PushSetupTab.fromJson(Map<String, dynamic> json) {
    return PushSetupTab(
      label: json['label'] as String,
      dataSource: json['dataSource'] as String,
    );
  }
}

/// A single push setup entry.
///
/// Either [dataSource] (single table) or [tabs] (multiple named tables)
/// will be non-null — never both.
class PushSetupConfig {
  final String id;
  final String label;

  /// Used when the push setup is backed by a single data source.
  final String? dataSource;

  /// Used when the push setup exposes several named tables.
  final List<PushSetupTab>? tabs;

  const PushSetupConfig({
    required this.id,
    required this.label,
    this.dataSource,
    this.tabs,
  }) : assert(
          (dataSource != null) != (tabs != null),
          'Exactly one of dataSource or tabs must be provided',
        );

  factory PushSetupConfig.fromJson(Map<String, dynamic> json) {
    final rawTabs = json['tabs'];
    return PushSetupConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      dataSource: rawTabs == null ? json['dataSource'] as String? : null,
      tabs: rawTabs != null
          ? (rawTabs as List)
              .map((t) => PushSetupTab.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PushSetupsConfigData {
  final List<PushSetupConfig> pushSetups;

  const PushSetupsConfigData({required this.pushSetups});

  factory PushSetupsConfigData.fromJson(Map<String, dynamic> json) {
    return PushSetupsConfigData(
      pushSetups: (json['pushSetups'] as List)
          .map((item) => PushSetupConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
