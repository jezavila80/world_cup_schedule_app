import '../../../core/i18n/localized_text.dart';
import 'match_result_status.dart';
import 'match_lifecycle_status.dart';
import 'team_info.dart';
import 'localized_entity.dart';

enum MatchStatus {
  live,
  today,
  upcoming,
  finished,
}

class WorldCupMatch {
  final String id;
  final String date;
  final String timeLocal;
  final String timezone;
  final TeamInfo homeTeam;
  final TeamInfo awayTeam;
  final LocalizedEntity group;
  final LocalizedEntity stage;
  final LocalizedEntity stadium;
  final LocalizedEntity city;
  final LocalizedEntity country;
  final bool isFavorite;
  final DateTime startDateTime;
  final int estimatedDurationMinutes;
  final int? homeScore;
  final int? awayScore;
  final MatchResultStatus resultStatus;

  WorldCupMatch({
    required this.id,
    required this.date,
    required this.timeLocal,
    required this.timezone,
    required this.homeTeam,
    required this.awayTeam,
    required this.group,
    required this.stage,
    required this.stadium,
    required this.city,
    required this.country,
    required this.startDateTime,
    required this.estimatedDurationMinutes,
    this.isFavorite = false,
    this.homeScore,
    this.awayScore,
    this.resultStatus = MatchResultStatus.pending,
  });

  static String _getTimezoneForCity(String city) {
    switch (city) {
      case 'Mexico City':
      case 'Zapopan':
      case 'Guadalupe':
        return 'America/Mexico_City';
      case 'Toronto':
      case 'New Jersey':
      case 'Foxborough':
      case 'Philadelphia':
      case 'Atlanta':
      case 'Miami':
        return 'America/New_York';
      case 'Los Angeles':
      case 'Santa Clara':
      case 'Vancouver':
      case 'Seattle':
        return 'America/Los_Angeles';
      case 'Houston':
      case 'Arlington':
      case 'Kansas City':
        return 'America/Chicago';
      default:
        return 'America/Mexico_City';
    }
  }

  static int _getOffsetHours(String timezone) {
    switch (timezone) {
      case 'America/New_York':
        return -4;
      case 'America/Chicago':
        return -5;
      case 'America/Mexico_City':
        return -6;
      case 'America/Los_Angeles':
        return -7;
      default:
        return -6;
    }
  }

  static TeamInfo _parseTeamInfo(dynamic json, String fallbackKey) {
    if (json == null) {
      return TeamInfo(
        id: fallbackKey.toLowerCase(),
        fifaCode: '',
        name: LocalizedText(en: fallbackKey, es: fallbackKey),
      );
    }
    if (json is String) {
      return TeamInfo(
        id: json.toLowerCase(),
        fifaCode: '',
        name: LocalizedText(en: json, es: json),
      );
    }
    if (json is Map) {
      final map = json.cast<String, dynamic>();
      final nameJson = map['name'];
      if (nameJson is Map) {
        return TeamInfo.fromJson(map);
      }
      final nameStr = (map['name'] ?? fallbackKey) as String;
      return TeamInfo(
        id: (map['id'] ?? nameStr.toLowerCase()) as String,
        fifaCode: (map['fifaCode'] ?? '') as String,
        name: LocalizedText(en: nameStr, es: nameStr),
      );
    }
    return TeamInfo(
      id: fallbackKey.toLowerCase(),
      fifaCode: '',
      name: LocalizedText(en: fallbackKey, es: fallbackKey),
    );
  }

  static LocalizedEntity _parseLocalizedEntity(dynamic json, String fallbackKey) {
    if (json == null) {
      return LocalizedEntity(
        id: fallbackKey.toLowerCase().replaceAll(' ', '_'),
        name: LocalizedText(en: fallbackKey, es: fallbackKey),
      );
    }
    if (json is String) {
      return LocalizedEntity(
        id: json.toLowerCase().replaceAll(' ', '_'),
        name: LocalizedText(en: json, es: json),
      );
    }
    if (json is Map) {
      final map = json.cast<String, dynamic>();
      final nameJson = map['name'];
      if (nameJson is Map) {
        return LocalizedEntity.fromJson(map);
      }
      final nameStr = (map['name'] ?? fallbackKey) as String;
      return LocalizedEntity(
        id: (map['id'] ?? nameStr.toLowerCase().replaceAll(' ', '_')) as String,
        name: LocalizedText(en: nameStr, es: nameStr),
      );
    }
    return LocalizedEntity(
      id: fallbackKey.toLowerCase().replaceAll(' ', '_'),
      name: LocalizedText(en: fallbackKey, es: fallbackKey),
    );
  }

  /// Factory constructor to create a WorldCupMatch from a JSON object.
  factory WorldCupMatch.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    
    final homeTeam = _parseTeamInfo(json['homeTeam'], 'Home');
    final awayTeam = _parseTeamInfo(json['awayTeam'], 'Away');
    final group = _parseLocalizedEntity(json['group'], 'Group');
    final stage = _parseLocalizedEntity(json['stage'], 'Stage');

    LocalizedEntity stadium;
    LocalizedEntity city;
    LocalizedEntity country;

    if (json['venue'] is Map) {
      final venue = (json['venue'] as Map).cast<String, dynamic>();
      stadium = _parseLocalizedEntity(venue['stadium'], 'Stadium');
      city = _parseLocalizedEntity(venue['city'], 'City');
      country = _parseLocalizedEntity(venue['country'], 'Country');
    } else {
      stadium = _parseLocalizedEntity(json['stadium'], 'Stadium');
      city = _parseLocalizedEntity(json['city'], 'City');
      country = _parseLocalizedEntity(json['country'], 'Country');
    }

    final isFavorite = json['isFavorite'] as bool? ?? false;
    final estimatedDurationMinutes = json['estimatedDurationMinutes'] as int? ?? 120;
    final homeScore = json['homeScore'] as int?;
    final awayScore = json['awayScore'] as int?;
    final resultStatus = json['resultStatus'] == 'completed'
        ? MatchResultStatus.completed
        : MatchResultStatus.pending;

    DateTime startDateTime;
    String date;
    String timeLocal;
    String timezone;

    if (json['kickoff'] is Map) {
      final kickoff = (json['kickoff'] as Map).cast<String, dynamic>();
      startDateTime = DateTime.parse(kickoff['utcDateTime'] as String);
      timezone = _getTimezoneForCity(city.name.en);
      final offsetHours = _getOffsetHours(timezone);
      final localTime = startDateTime.toUtc().add(Duration(hours: offsetHours));
      
      date = "${localTime.year}-${localTime.month.toString().padLeft(2, '0')}-${localTime.day.toString().padLeft(2, '0')}";
      timeLocal = "${localTime.hour.toString().padLeft(2, '0')}:${localTime.minute.toString().padLeft(2, '0')}";
    } else {
      date = json['date'] as String? ?? '';
      timeLocal = json['timeLocal'] as String? ?? '';
      timezone = json['timezone'] as String? ?? 'America/Mexico_City';
      startDateTime = json['startDateTime'] != null 
          ? DateTime.parse(json['startDateTime'] as String)
          : DateTime.now();
    }

    return WorldCupMatch(
      id: id,
      date: date,
      timeLocal: timeLocal,
      timezone: timezone,
      homeTeam: homeTeam,
      awayTeam: awayTeam,
      group: group,
      stage: stage,
      stadium: stadium,
      city: city,
      country: country,
      startDateTime: startDateTime,
      estimatedDurationMinutes: estimatedDurationMinutes,
      isFavorite: isFavorite,
      homeScore: homeScore,
      awayScore: awayScore,
      resultStatus: resultStatus,
    );
  }

  /// Converts the WorldCupMatch instance to a JSON object.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'timeLocal': timeLocal,
      'timezone': timezone,
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'group': group.toJson(),
      'stage': stage.toJson(),
      'venue': {
        'stadium': stadium.toJson(),
        'city': city.toJson(),
        'country': country.toJson(),
      },
      'startDateTime': startDateTime.toIso8601String(),
      'estimatedDurationMinutes': estimatedDurationMinutes,
      'isFavorite': isFavorite,
      'homeScore': homeScore,
      'awayScore': awayScore,
      'resultStatus': resultStatus == MatchResultStatus.completed ? 'completed' : 'pending',
    };
  }

  /// Calculates the status of the match relative to the current timestamp.
  MatchStatus getStatus(DateTime now) {
    final start = startDateTime;
    final end = start.add(Duration(minutes: estimatedDurationMinutes));

    if (now.isBefore(start)) {
      final localStart = start.toLocal();
      final localNow = now.toLocal();
      if (localStart.year == localNow.year &&
          localStart.month == localNow.month &&
          localStart.day == localNow.day) {
        return MatchStatus.today;
      }
      return MatchStatus.upcoming;
    } else if (now.isBefore(end)) {
      return MatchStatus.live;
    } else {
      return MatchStatus.finished;
    }
  }

  /// Calculates the lifecycle status of the match relative to the current timestamp.
  MatchLifecycleStatus getLifecycleStatus(DateTime now) {
    final start = startDateTime;
    final end = start.add(Duration(minutes: estimatedDurationMinutes));

    if (now.isBefore(start)) {
      final localStart = start.toLocal();
      final localNow = now.toLocal();
      if (localStart.year == localNow.year &&
          localStart.month == localNow.month &&
          localStart.day == localNow.day) {
        return MatchLifecycleStatus.today;
      }
      return MatchLifecycleStatus.upcoming;
    } else if (now.isBefore(end)) {
      return MatchLifecycleStatus.live;
    } else {
      return MatchLifecycleStatus.finished;
    }
  }

  /// Helper to check if results can be edited (only finished matches).
  bool canEditResult(DateTime now) {
    return getLifecycleStatus(now) == MatchLifecycleStatus.finished;
  }

  static String normalizeText(String value) {
    return value
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .trim();
  }

  bool matchesSearchQuery(String query) {
    final normalizedQuery = normalizeText(query);

    return normalizeText(homeTeam.name.en).contains(normalizedQuery) ||
        normalizeText(homeTeam.name.es).contains(normalizedQuery) ||
        normalizeText(awayTeam.name.en).contains(normalizedQuery) ||
        normalizeText(awayTeam.name.es).contains(normalizedQuery) ||
        normalizeText(city.name.en).contains(normalizedQuery) ||
        normalizeText(city.name.es).contains(normalizedQuery) ||
        normalizeText(stadium.name.en).contains(normalizedQuery) ||
        normalizeText(stadium.name.es).contains(normalizedQuery);
  }

  /// Creates a copy of this match but with the given fields replaced with new values.
  WorldCupMatch copyWith({
    String? id,
    String? date,
    String? timeLocal,
    String? timezone,
    TeamInfo? homeTeam,
    TeamInfo? awayTeam,
    LocalizedEntity? group,
    LocalizedEntity? stage,
    LocalizedEntity? stadium,
    LocalizedEntity? city,
    LocalizedEntity? country,
    bool? isFavorite,
    DateTime? startDateTime,
    int? estimatedDurationMinutes,
    int? homeScore,
    int? awayScore,
    MatchResultStatus? resultStatus,
  }) {
    return WorldCupMatch(
      id: id ?? this.id,
      date: date ?? this.date,
      timeLocal: timeLocal ?? this.timeLocal,
      timezone: timezone ?? this.timezone,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      group: group ?? this.group,
      stage: stage ?? this.stage,
      stadium: stadium ?? this.stadium,
      city: city ?? this.city,
      country: country ?? this.country,
      isFavorite: isFavorite ?? this.isFavorite,
      startDateTime: startDateTime ?? this.startDateTime,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      resultStatus: resultStatus ?? this.resultStatus,
    );
  }
}
