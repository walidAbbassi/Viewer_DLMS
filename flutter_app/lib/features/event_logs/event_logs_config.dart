class EventLogsConfig {
  final String id;
  final String name;
  final String description;
  final String dataSource;
  final String? statColumnName;
  final List<StatColumn>? statColumns;
  
  const EventLogsConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.dataSource,
    this.statColumnName,
    this.statColumns,
  });
  
  factory EventLogsConfig.fromJson(Map<String, dynamic> json) {
    return EventLogsConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      dataSource: json['dataSource'] as String,
      statColumnName: json['statColumnName'] as String?,
      statColumns: json['statColumns'] != null
          ? (json['statColumns'] as List)
              .map((e) => StatColumn.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
}

class StatColumn {
  final int value;
  final String label;
  final String color;

  StatColumn({required this.value, required this.label, required this.color});

  factory StatColumn.fromJson(Map<String, dynamic> json) {
    return StatColumn(
      value: json['value'] as int,
      label: json['label'] as String,
      color: json['color'] as String,
    );
  }
}


class EventLogsConfigData {
  final List<EventLogsConfig> eventLogs;

  const EventLogsConfigData({required this.eventLogs});

  factory EventLogsConfigData.fromJson(Map<String, dynamic> json) {
    return EventLogsConfigData(
      eventLogs: (json['eventLogs'] as List)
          .map(
            (item) => EventLogsConfig.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }
}



