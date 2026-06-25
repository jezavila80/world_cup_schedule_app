import '../../standings/models/group_standing.dart';
import '../models/knockout_qualification_result.dart';
import '../models/qualified_team.dart';
import '../models/qualification_type.dart';
import '../../tournament_engine/services/standing_sort_service.dart';

class KnockoutQualificationService {
  final StandingSortService _sortService = StandingSortService();
  /// Checks if a single group stands complete (all teams have played 3 matches).
  bool isGroupComplete(List<GroupStanding> standings) {
    if (standings.length < 4) return false;
    return standings.every((s) => s.played == 3);
  }

  /// Checks if all 12 groups (A to L) are fully completed.
  bool areAllGroupsComplete(Map<String, List<GroupStanding>> groupStandings) {
    if (groupStandings.length < 12) return false;
    return groupStandings.values.every((list) => isGroupComplete(list));
  }

  /// Calculates the current qualified teams based on group standings.
  KnockoutQualificationResult calculateQualifiedTeams(
    Map<String, List<GroupStanding>> groupStandings,
  ) {
    final List<QualifiedTeam> groupWinners = [];
    final List<QualifiedTeam> groupRunnersUp = [];
    final List<QualifiedTeam> allThirds = [];

    final allGroupsFinished = areAllGroupsComplete(groupStandings);

    groupStandings.forEach((groupId, standingsList) {
      if (standingsList.isEmpty) return;

      final groupFinished = isGroupComplete(standingsList);

      // Winners and runners-up are resolved if their group is complete
      if (groupFinished) {
        groupWinners.add(QualifiedTeam(
          team: standingsList[0].team,
          groupId: groupId,
          groupName: standingsList[0].groupName,
          groupPosition: 1,
          standing: standingsList[0],
          qualificationType: QualificationType.groupWinner,
        ));

        if (standingsList.length > 1) {
          groupRunnersUp.add(QualifiedTeam(
            team: standingsList[1].team,
            groupId: groupId,
            groupName: standingsList[1].groupName,
            groupPosition: 2,
            standing: standingsList[1],
            qualificationType: QualificationType.groupRunnerUp,
          ));
        }
      }

      // Collect third place teams (we collect them regardless of group completion to rank them later)
      if (standingsList.length > 2) {
        allThirds.add(QualifiedTeam(
          team: standingsList[2].team,
          groupId: groupId,
          groupName: standingsList[2].groupName,
          groupPosition: 3,
          standing: standingsList[2],
          qualificationType: QualificationType.bestThirdPlace,
        ));
      }
    });

    final List<GroupStanding> thirdPlaceStandings = allThirds.map((qt) => qt.standing).toList();
    final List<GroupStanding> sortedThirdStandings = _sortService.sortThirdPlaces(thirdPlaceStandings);

    final List<QualifiedTeam> sortedThirds = sortedThirdStandings.map((standing) {
      return allThirds.firstWhere((qt) => qt.team.id == standing.team.id);
    }).toList();

    allThirds.clear();
    allThirds.addAll(sortedThirds);

    List<QualifiedTeam> bestThirdPlacedTeams = [];
    List<QualifiedTeam> eliminatedThirdPlacedTeams = [];

    // Third-placed teams are only resolved as qualified or eliminated if all groups are complete
    if (allGroupsFinished) {
      bestThirdPlacedTeams = allThirds.take(8).toList();
      eliminatedThirdPlacedTeams = allThirds.skip(8).toList();
    }

    final List<QualifiedTeam> allQualifiedTeams = [
      ...groupWinners,
      ...groupRunnersUp,
      ...bestThirdPlacedTeams,
    ];

    return KnockoutQualificationResult(
      groupWinners: groupWinners,
      groupRunnersUp: groupRunnersUp,
      bestThirdPlacedTeams: bestThirdPlacedTeams,
      allQualifiedTeams: allQualifiedTeams,
      eliminatedThirdPlacedTeams: eliminatedThirdPlacedTeams,
    );
  }

  /// Calculates the qualification status of a specific team in a group.
  /// Returns one of: 'qualified', 'best_third', 'eliminated', 'pending'.
  String getTeamQualificationStatus({
    required String teamId,
    required String groupId,
    required Map<String, List<GroupStanding>> groupStandings,
    required KnockoutQualificationResult qualificationResult,
  }) {
    final standings = groupStandings[groupId];
    if (standings == null) return 'pending';

    final groupFinished = isGroupComplete(standings);
    final index = standings.indexWhere((s) => s.team.id == teamId);
    if (index == -1) return 'pending';

    final position = index + 1;

    if (position <= 2) {
      return groupFinished ? 'qualified' : 'pending';
    } else if (position == 3) {
      final allGroupsFinished = areAllGroupsComplete(groupStandings);
      if (!allGroupsFinished) return 'pending';

      final isBestThird = qualificationResult.bestThirdPlacedTeams.any((t) => t.team.id == teamId);
      return isBestThird ? 'best_third' : 'eliminated';
    } else {
      // 4th place
      return groupFinished ? 'eliminated' : 'pending';
    }
  }
}

