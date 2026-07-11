class BitDescripTableEntry {
  final String mask;
  final String bitValue;
  final String description;

  const BitDescripTableEntry({
    required this.mask,
    required this.bitValue,
    required this.description,
  });

  factory BitDescripTableEntry.fromJson(Map<String, dynamic> json) {
    return BitDescripTableEntry(
      mask: json['mask'] as String,
      bitValue: json['bitValue'] as String,
      description: json['description'] as String,
    );
  }
}

class BitDescription {
  final int totalBitsNum;
  final List<BitDescripTableEntry> bitsDescripTable;

  const BitDescription({
    required this.totalBitsNum,
    required this.bitsDescripTable,
  });

  factory BitDescription.fromJson(Map<String, dynamic> json) {
    return BitDescription(
      totalBitsNum: json['totalBitsNum'] as int,
      bitsDescripTable: (json['bitsDescripTable'] as List)
          .map((e) => BitDescripTableEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LoadProfileConfig {
  final String id;
  final String name;
  final String description;
  final List<String>? columns; // Optional - columns now come from gRPC headerTypes
  final String dataSource; // Used as objectName for gRPC call
  final BitDescription? bitDescription; // Optional - present only for status profiles

  LoadProfileConfig({
    required this.id,
    required this.name,
    required this.description,
    this.columns, // Optional
    required this.dataSource,
    this.bitDescription,
  });

  factory LoadProfileConfig.fromJson(Map<String, dynamic> json) {
    return LoadProfileConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      columns: json['columns'] != null ? List<String>.from(json['columns'] as List) : null,
      dataSource: json['dataSource'] as String,
      bitDescription: json['bitDescription'] != null
          ? BitDescription.fromJson(json['bitDescription'] as Map<String, dynamic>)
          : null,
    );
  }
}

class LoadProfileConfigData {
  final List<LoadProfileConfig> loadProfiles;

  LoadProfileConfigData({required this.loadProfiles});

  factory LoadProfileConfigData.fromJson(Map<String, dynamic> json) {
    return LoadProfileConfigData(
      loadProfiles: (json['loadProfiles'] as List)
          .map((item) => LoadProfileConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

