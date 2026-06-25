import '../../matches/models/team_info.dart';
import '../../standings/models/group_standing.dart';
import '../../../core/i18n/localized_text.dart';
import 'qualification_type.dart';

class QualifiedTeam {
  final TeamInfo team;
  final String groupId;
  final LocalizedText groupName;
  final int groupPosition;
  final GroupStanding standing;
  final QualificationType qualificationType;

  const QualifiedTeam({
    required this.team,
    required this.groupId,
    required this.groupName,
    required this.groupPosition,
    required this.standing,
    required this.qualificationType,
  });
}
