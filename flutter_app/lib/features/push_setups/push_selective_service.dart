import 'dart:convert';
import 'package:flutter/services.dart';
import 'push_selective_config.dart';

class PushSelectiveService {
  static Future<List<PushSelectiveConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/push_selective.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = PushSelectivesConfigData.fromJson(jsonData);
      return configData.pushSelectives;
    } catch (e, st) {
      // ignore: avoid_print
      print('[PushSelectiveService] loadConfig error: $e\n$st');
      return [];
    }
  }
}
