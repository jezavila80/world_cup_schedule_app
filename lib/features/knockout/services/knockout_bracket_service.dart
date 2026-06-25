import '../../matches/models/world_cup_match.dart';
import '../../standings/models/group_standing.dart';
import '../models/knockout_match_slot.dart';
import '../models/knockout_qualification_result.dart';
import '../models/qualified_team.dart';
import '../models/qualification_type.dart';
import 'knockout_qualification_service.dart';

class KnockoutBracketService {
  final KnockoutQualificationService _qualificationService = KnockoutQualificationService();

  /// Calculates the match slots for the Round of 32.
  List<KnockoutMatchSlot> calculateBracketSlots(
    List<WorldCupMatch> allMatches,
    Map<String, List<GroupStanding>> groupStandings,
  ) {
    // Filter round of 32 matches (M73 to M88)
    final roundOf32Matches = allMatches.where((m) => m.stage.id == 'round_of_32').toList();
    
    // Sort them by matchNumber (73 to 88)
    roundOf32Matches.sort((a, b) {
      final numA = int.tryParse(a.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final numB = int.tryParse(b.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      return numA.compareTo(numB);
    });

    final List<KnockoutMatchSlot> slots = [];

    for (var match in roundOf32Matches) {
      final matchNum = int.tryParse(match.id.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      final slotAId = match.homeTeam.id;
      final slotBId = match.awayTeam.id;

      final teamA = _resolveSlot(slotAId, groupStandings);
      final teamB = _resolveSlot(slotBId, groupStandings);

      slots.add(KnockoutMatchSlot(
        matchNumber: matchNum,
        round: match.stage.name.en,
        slotA: slotAId,
        slotB: slotBId,
        teamA: teamA,
        teamB: teamB,
      ));
    }

    return slots;
  }

  QualifiedTeam? _resolveSlot(
    String slotId,
    Map<String, List<GroupStanding>> groupStandings,
  ) {
    if (slotId.contains('_winners')) {
      final groupId = _extractGroupId(slotId, '_winners');
      final standings = groupStandings[groupId];
      if (standings != null && standings.isNotEmpty && _qualificationService.isGroupComplete(standings)) {
        return QualifiedTeam(
          team: standings[0].team,
          groupId: groupId,
          groupName: standings[0].groupName,
          groupPosition: 1,
          standing: standings[0],
          qualificationType: QualificationType.groupWinner,
        );
      }
    } else if (slotId.contains('_runners-up')) {
      final groupId = _extractGroupId(slotId, '_runners-up');
      final standings = groupStandings[groupId];
      if (standings != null && standings.length > 1 && _qualificationService.isGroupComplete(standings)) {
        return QualifiedTeam(
          team: standings[1].team,
          groupId: groupId,
          groupName: standings[1].groupName,
          groupPosition: 2,
          standing: standings[1],
          qualificationType: QualificationType.groupRunnerUp,
        );
      }
    }
    // Third place slots or incomplete groups return null (TBD)
    return null;
  }

  String _extractGroupId(String slotId, String suffix) {
    return slotId.replaceAll(suffix, '');
  }
}
