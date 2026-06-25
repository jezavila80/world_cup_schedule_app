import '../models/group_standing.dart';
import '../../matches/models/world_cup_match.dart';
import '../../matches/models/match_result_status.dart';
import '../../matches/models/team_info.dart';
import '../../../core/i18n/localized_text.dart';
import '../../tournament_engine/services/standing_sort_service.dart';

class GroupStandingsService {
  final StandingSortService _sortService = StandingSortService();

  /// Calculates real-time group standings from a list of matches.
  Map<String, List<GroupStanding>> calculateStandings(List<WorldCupMatch> matches) {
    // 1. Filter completed group stage matches
    final completedGroupMatches = matches.where((m) =>
        m.stage.id == 'group_stage' &&
        m.resultStatus == MatchResultStatus.completed).toList();

    // 2. Discover all unique groups and the teams belonging to them.
    // This ensures all teams are listed (even if they have played 0 matches).
    final Map<String, LocalizedText> groupNames = {};
    final Map<String, Map<String, TeamInfo>> groupTeams = {}; // groupId -> teamId -> TeamInfo

    for (final match in matches) {
      if (match.stage.id == 'group_stage') {
        final gId = match.group.id;
        groupNames[gId] = match.group.name;
        
        groupTeams.putIfAbsent(gId, () => {});
        groupTeams[gId]![match.homeTeam.id] = match.homeTeam;
        groupTeams[gId]![match.awayTeam.id] = match.awayTeam;
      }
    }

    // 3. Keep track of stats per team
    final Map<String, _TeamStats> stats = {};

    // Initialize stats for every discovered group stage team
    groupTeams.forEach((gId, teamsMap) {
      teamsMap.forEach((teamId, teamInfo) {
        stats[teamId] = _TeamStats(teamId: teamId, teamInfo: teamInfo, groupId: gId);
      });
    });

    // 4. Process each completed group stage match
    for (final match in completedGroupMatches) {
      final homeId = match.homeTeam.id;
      final awayId = match.awayTeam.id;
      final homeScore = match.homeScore ?? 0;
      final awayScore = match.awayScore ?? 0;

      final homeStats = stats[homeId];
      final awayStats = stats[awayId];

      if (homeStats == null || awayStats == null) continue;

      homeStats.played++;
      awayStats.played++;

      homeStats.goalsFor += homeScore;
      homeStats.goalsAgainst += awayScore;
      awayStats.goalsFor += awayScore;
      awayStats.goalsAgainst += homeScore;

      if (homeScore > awayScore) {
        homeStats.wins++;
        homeStats.points += 3;
        awayStats.losses++;
      } else if (awayScore > homeScore) {
        awayStats.wins++;
        awayStats.points += 3;
        homeStats.losses++;
      } else {
        homeStats.draws++;
        homeStats.points += 1;
        awayStats.draws++;
        awayStats.points += 1;
      }
    }

    // 5. Convert stats to GroupStanding list per group and sort
    final Map<String, List<GroupStanding>> standingsMap = {};

    groupTeams.forEach((gId, teamsMap) {
      final List<GroupStanding> standingsList = [];
      teamsMap.forEach((teamId, teamInfo) {
        final teamStats = stats[teamId]!;
        standingsList.add(GroupStanding(
          groupId: gId,
          groupName: groupNames[gId]!,
          team: teamInfo,
          played: teamStats.played,
          wins: teamStats.wins,
          draws: teamStats.draws,
          losses: teamStats.losses,
          goalsFor: teamStats.goalsFor,
          goalsAgainst: teamStats.goalsAgainst,
          goalDifference: teamStats.goalsFor - teamStats.goalsAgainst,
          points: teamStats.points,
        ));
      });

      standingsMap[gId] = _sortService.sortGroupStandings(standingsList);
    });

    return standingsMap;
  }
}

class _TeamStats {
  final String teamId;
  final TeamInfo teamInfo;
  final String groupId;
  int played = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
  int points = 0;

  _TeamStats({
    required this.teamId,
    required this.teamInfo,
    required this.groupId,
  });
}
