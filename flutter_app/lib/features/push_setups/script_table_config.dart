/// Config for a single script table entry.
class ScriptTableConfig {
  final String id;
  final String label;
  final String datasource;

  const ScriptTableConfig({
    required this.id,
    required this.label,
    required this.datasource,
  });

  factory ScriptTableConfig.fromJson(Map<String, dynamic> json) {
    return ScriptTableConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      datasource: json['datasource'] as String,
    );
  }
}

/// Wrapper that parses the top-level scriptTables array.
class ScriptTablesConfigData {
  final List<ScriptTableConfig> scriptTables;

  const ScriptTablesConfigData({required this.scriptTables});

  factory ScriptTablesConfigData.fromJson(Map<String, dynamic> json) {
    final list = (json['scriptTables'] as List<dynamic>)
        .map((e) => ScriptTableConfig.fromJson(e as Map<String, dynamic>))
        .toList();
    return ScriptTablesConfigData(scriptTables: list);
  }
}
