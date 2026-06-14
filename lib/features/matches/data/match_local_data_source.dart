import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/world_cup_match.dart';

class MatchLocalDataSource {
  static const String _assetPath = 'assets/data/world_cup_2026_matches.json';

  /// Loads the matches JSON file from assets and decodes it.
  Future<List<WorldCupMatch>> getMatches() async {
    final String response = await rootBundle.loadString(_assetPath);
    final decoded = json.decode(response);
    
    final List<dynamic> matchesList;
    if (decoded is Map<String, dynamic>) {
      matchesList = decoded['matches'] as List<dynamic>;
    } else if (decoded is List<dynamic>) {
      matchesList = decoded;
    } else {
      throw const FormatException('Formato de JSON de partidos inválido');
    }
    
    return matchesList
        .map((json) => WorldCupMatch.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
