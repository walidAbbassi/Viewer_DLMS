class PushActionTab {
  final String label;
  final String dataSource;

  const PushActionTab({required this.label, required this.dataSource});

  factory PushActionTab.fromJson(Map<String, dynamic> json) {
    return PushActionTab(
      label: json['label'] as String,
      dataSource: json['dataSource'] as String,
    );
  }
}

/// A single push action entry.
///
/// Either [dataSource] (single table) or [tabs] (multiple named tables)
/// will be non-null — never both.
class PushActionConfig {
  final String id;
  final String label;

  /// Used when the push action is backed by a single data source.
  final String? dataSource;

  /// Used when the push action exposes several named tables.
  final List<PushActionTab>? tabs;

  const PushActionConfig({
    required this.id,
    required this.label,
    this.dataSource,
    this.tabs,
  }) : assert(
          (dataSource != null) != (tabs != null),
          'Exactly one of dataSource or tabs must be provided',
        );

  factory PushActionConfig.fromJson(Map<String, dynamic> json) {
    final rawTabs = json['tabs'];
    return PushActionConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      dataSource: rawTabs == null ? json['dataSource'] as String? : null,
      tabs: rawTabs != null
          ? (rawTabs as List)
              .map((t) => PushActionTab.fromJson(t as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class PushActionsConfigData {
  final List<PushActionConfig> pushActions;

  const PushActionsConfigData({required this.pushActions});

  factory PushActionsConfigData.fromJson(Map<String, dynamic> json) {
    return PushActionsConfigData(
      pushActions: (json['pushActions'] as List)
          .map((item) =>
              PushActionConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
