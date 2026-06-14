import 'dart:convert';
import 'package:flutter/services.dart';

class AppTranslations {
  static Map<String, dynamic> _translations = {};

  static Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString('assets/data/app_translations.json');
      _translations = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Fallback
      _translations = {};
    }
  }

  static String translate(String key, String languageCode) {
    final translation = _translations[key];
    if (translation is Map) {
      return translation[languageCode] ?? translation['en'] ?? key;
    }
    return key;
  }
}
