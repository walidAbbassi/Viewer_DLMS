import 'dart:convert';

import 'package:flutter/services.dart';

import 'event_logs_config.dart';

class EventLogsService {
  static Future<List<EventLogsConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/event_logs.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = EventLogsConfigData.fromJson(jsonData);
      return configData.eventLogs;
    } catch (e) {
      print(e);
      // Return empty list if config file is not found or invalid
      return [];
    }
  }
}



