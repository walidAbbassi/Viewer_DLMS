import 'dart:convert';

import 'package:flutter/services.dart';

import 'push_actions_config.dart';

class PushActionsService {
  static Future<List<PushActionConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/push_actions.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = PushActionsConfigData.fromJson(jsonData);
      return configData.pushActions;
    } catch (e) {
      // Return empty list if config file is not found or invalid
      return [];
    }
  }
}
