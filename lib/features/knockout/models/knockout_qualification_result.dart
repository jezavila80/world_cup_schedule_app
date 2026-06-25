import 'qualified_team.dart';

class KnockoutQualificationResult {
  final List<QualifiedTeam> groupWinners;
  final List<QualifiedTeam> groupRunnersUp;
  final List<QualifiedTeam> bestThirdPlacedTeams;
  final List<QualifiedTeam> allQualifiedTeams;
  final List<QualifiedTeam> eliminatedThirdPlacedTeams;

  const KnockoutQualificationResult({
    required this.groupWinners,
    required this.groupRunnersUp,
    required this.bestThirdPlacedTeams,
    required this.allQualifiedTeams,
    required this.eliminatedThirdPlacedTeams,
  });
}
