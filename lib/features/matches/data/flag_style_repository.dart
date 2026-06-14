import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/flag_style.dart';

class FlagStyleRepository {
  final String assetPath;
  final Map<String, FlagStyle> _stylesMap = {};

  FlagStyleRepository({
    this.assetPath = 'assets/data/team_flag_styles_2026.json',
  });

  /// Loads the flag styles from the JSON asset and populates the cache.
  Future<void> load() async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      _stylesMap.clear();

      for (final item in jsonList) {
        final style = FlagStyle.fromJson(item as Map<String, dynamic>);
        // Cache by teamId, displayName, and fifaCode for robust lookup
        _stylesMap[style.teamId.toLowerCase()] = style;
        _stylesMap[style.displayName.toLowerCase()] = style;
        _stylesMap[style.fifaCode.toLowerCase()] = style;
      }
    } catch (e) {
      // Fallback/log
      debugPrint('Error loading flag styles: $e');
    }
  }

  /// Retrieves the FlagStyle for a given team name or ID. Returns null if not found.
  FlagStyle? getFlagStyle(String teamName) {
    return _stylesMap[teamName.toLowerCase()];
  }
}
