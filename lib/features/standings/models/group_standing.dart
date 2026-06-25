import '../../../core/i18n/localized_text.dart';
import '../../matches/models/team_info.dart';

class GroupStanding {
  final String groupId;
  final LocalizedText groupName;
  final TeamInfo team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;
  final int goalDifference;
  final int points;

  const GroupStanding({
    required this.groupId,
    required this.groupName,
    required this.team,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
    required this.goalDifference,
    required this.points,
  });
}
