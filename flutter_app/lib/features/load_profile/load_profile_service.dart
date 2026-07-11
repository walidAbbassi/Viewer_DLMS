import 'dart:convert';
import 'package:flutter/services.dart';
import 'load_profile_config.dart';

class LoadProfileService {
  static Future<List<LoadProfileConfig>> loadConfig() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/config/load_profiles.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final configData = LoadProfileConfigData.fromJson(jsonData);
      return configData.loadProfiles;
    } catch (e) {
      // Return empty list if config file is not found or invalid
      return [];
    }
  }

}






