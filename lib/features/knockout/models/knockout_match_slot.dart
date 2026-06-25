import 'qualified_team.dart';

class KnockoutMatchSlot {
  final int matchNumber;
  final String round;
  final String slotA;
  final String slotB;
  final QualifiedTeam? teamA;
  final QualifiedTeam? teamB;

  const KnockoutMatchSlot({
    required this.matchNumber,
    required this.round,
    required this.slotA,
    required this.slotB,
    this.teamA,
    this.teamB,
  });
}
