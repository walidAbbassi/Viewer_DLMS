/// A single object entry in a push recovery config.
class PushRecoveryObject {
  final String description;
  final String type;
  final String value;
  final String scaleUnitAttrib;
  final String attribute;
  final String datasource;

  const PushRecoveryObject({
    required this.description,
    required this.type,
    required this.value,
    required this.scaleUnitAttrib,
    required this.attribute,
    required this.datasource,
  });

  factory PushRecoveryObject.fromJson(Map<String, dynamic> json) {
    return PushRecoveryObject(
      description: json['description'] as String,
      type: json['type'] as String,
      value: json['value'] as String,
      scaleUnitAttrib: json['scaleUnitAttrib'] as String,
      attribute: json['attribute'] as String,
      datasource: json['datasource'] as String,
    );
  }
}

/// Config for a single Push Recovery entry.
class PushRecoveryConfig {
  final String id;
  final String label;
  final List<PushRecoveryObject> objects;

  const PushRecoveryConfig({
    required this.id,
    required this.label,
    required this.objects,
  });

  factory PushRecoveryConfig.fromJson(Map<String, dynamic> json) {
    return PushRecoveryConfig(
      id: json['id'] as String,
      label: json['label'] as String,
      objects: (json['objects'] as List)
          .map((o) =>
              PushRecoveryObject.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PushRecoveriesConfigData {
  final List<PushRecoveryConfig> pushRecoveries;

  const PushRecoveriesConfigData({required this.pushRecoveries});

  factory PushRecoveriesConfigData.fromJson(Map<String, dynamic> json) {
    return PushRecoveriesConfigData(
      pushRecoveries: (json['pushRecoveries'] as List)
          .map((item) =>
              PushRecoveryConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
