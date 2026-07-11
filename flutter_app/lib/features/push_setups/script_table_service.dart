import 'dart:convert';
import 'package:flutter/services.dart';
import 'script_table_config.dart';

class ScriptTableService {
  static Future<List<ScriptTableConfig>> loadConfig() async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/config/script_tables.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return ScriptTablesConfigData.fromJson(jsonData).scriptTables;
    } catch (e) {
      return [];
    }
  }
}
