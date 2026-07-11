/// A single object entry in a push selective config.
class PushSelectiveObject {
  final String label;
  final String captureObjects;
  final String filterBuffer;

  const PushSelectiveObject({
    required this.label,
    required this.captureObjects,
    required this.filterBuffer,
  });

  factory PushSelectiveObject.fromJson(Map<String, dynamic> json) {
    return PushSelectiveObject(
      label: (json['label'] as String?) ?? '',
      captureObjects: (json['captureObjects'] as String?) ?? '',
      filterBuffer: (json['filterBuffer'] as String?) ?? '',
    );
  }
}

/// Config for a single Push Selective entry.
class PushSelectiveConfig {
  final String id;
  final String label;
  final List<PushSelectiveObject> objects;

  const PushSelectiveConfig({
    required this.id,
    required this.label,
    required this.objects,
  });

  factory PushSelectiveConfig.fromJson(Map<String, dynamic> json) {
    return PushSelectiveConfig(
      id: (json['id'] as String?) ?? '',
      label: (json['label'] as String?) ?? '',
      objects: (json['objects'] as List? ?? [])
          .map((o) => PushSelectiveObject.fromJson(o as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PushSelectivesConfigData {
  final List<PushSelectiveConfig> pushSelectives;

  const PushSelectivesConfigData({required this.pushSelectives});

  factory PushSelectivesConfigData.fromJson(Map<String, dynamic> json) {
    return PushSelectivesConfigData(
      pushSelectives: (json['pushSelectives'] as List? ?? [])
          .map((item) =>
              PushSelectiveConfig.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
