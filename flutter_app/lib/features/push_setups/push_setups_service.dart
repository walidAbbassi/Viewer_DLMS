import 'dart:convert';

import 'package:flutter/services.dart';

import 'push_setups_config.dart';

class PushSetupsService {
  static Future<List<PushSetupConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/push_setups.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = PushSetupsConfigData.fromJson(jsonData);
      return configData.pushSetups;
    } catch (e) {
      // Return empty list if config file is not found or invalid
      return [];
    }
  }
}
