import 'dart:convert';

import 'package:flutter/services.dart';

import 'quality_config.dart';

class QualityService {
  static Future<List<QualityConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/quality.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = QualityConfigData.fromJson(jsonData);
      return configData.qualityPages;
    } catch (_) {
      return [];
    }
  }
}
