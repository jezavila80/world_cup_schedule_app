import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/match_result_status.dart';

class MatchResultService {
  final SharedPreferences _prefs;
  static const String _key = 'world_cup_match_scores';

  MatchResultService(this._prefs);

  /// Load scores from SharedPreferences. Returns a map of matchId -> score data
  Map<String, MatchScoreData> getScores() {
    final jsonStr = _prefs.getString(_key);
    if (jsonStr == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded.map((key, value) => MapEntry(
            key,
            MatchScoreData.fromJson(value as Map<String, dynamic>),
          ));
    } catch (_) {
      return {};
    }
  }

  /// Save score for a specific match
  Future<bool> saveScore(String matchId, int homeScore, int awayScore) async {
    final scores = getScores();
    scores[matchId] = MatchScoreData(
      homeScore: homeScore,
      awayScore: awayScore,
      resultStatus: MatchResultStatus.completed,
    );
    final serialized = scores.map((key, value) => MapEntry(key, value.toJson()));
    return _prefs.setString(_key, jsonEncode(serialized));
  }

  /// Checks if the subscription popup was already shown using a serialized JSON settings object.
  bool isSubscriptionPopupShown() {
    final jsonStr = _prefs.getString('world_cup_app_settings');
    if (jsonStr == null) return false;
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonStr);
      return decoded['subscription_popup_shown'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Persists that the subscription popup has been shown inside a serialized JSON settings object.
  Future<bool> setSubscriptionPopupShown() async {
    final data = {'subscription_popup_shown': true};
    return _prefs.setString('world_cup_app_settings', jsonEncode(data));
  }
}

class MatchScoreData {
  final int homeScore;
  final int awayScore;
  final MatchResultStatus resultStatus;

  MatchScoreData({
    required this.homeScore,
    required this.awayScore,
    required this.resultStatus,
  });

  factory MatchScoreData.fromJson(Map<String, dynamic> json) {
    return MatchScoreData(
      homeScore: json['homeScore'] as int,
      awayScore: json['awayScore'] as int,
      resultStatus: json['resultStatus'] == 'completed'
          ? MatchResultStatus.completed
          : MatchResultStatus.pending,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'homeScore': homeScore,
      'awayScore': awayScore,
      'resultStatus': resultStatus == MatchResultStatus.completed ? 'completed' : 'pending',
    };
  }
}
