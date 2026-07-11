import 'dart:convert';
import 'package:flutter/services.dart';
import 'push_recovery_config.dart';

class PushRecoveryService {
  static Future<List<PushRecoveryConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/push_recovery.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = PushRecoveriesConfigData.fromJson(jsonData);
      return configData.pushRecoveries;
    } catch (e) {
      return [];
    }
  }
}
