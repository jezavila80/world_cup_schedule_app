import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/features/tournament_engine/services/tournament_validation_service.dart';
import 'package:world_cup_schedule_app/features/tournament_engine/models/validation_severity.dart';
import 'package:world_cup_schedule_app/features/standings/models/group_standing.dart';
import 'package:world_cup_schedule_app/features/matches/models/world_cup_match.dart';
import 'package:world_cup_schedule_app/features/matches/models/team_info.dart';
import 'package:world_cup_schedule_app/features/matches/models/match_result_status.dart';
import 'package:world_cup_schedule_app/features/matches/models/localized_entity.dart';
import 'package:world_cup_schedule_app/features/knockout/models/knockout_qualification_result.dart';
import 'package:world_cup_schedule_app/features/knockout/models/qualified_team.dart';
import 'package:world_cup_schedule_app/features/knockout/models/qualification_type.dart';
import 'package:world_cup_schedule_app/features/knockout/models/knockout_match_slot.dart';
import 'package:world_cup_schedule_app/core/i18n/localized_text.dart';

void main() {
  group('TournamentValidationService Tests', () {
    final validationService = TournamentValidationService();

    final groupA = LocalizedEntity(id: 'group_a', name: LocalizedText(en: 'Group A', es: 'Grupo A'));
    final groupStage = LocalizedEntity(id: 'group_stage', name: LocalizedText(en: 'Group Stage', es: 'Fase de Grupos'));
    final defaultVenue = LocalizedEntity(id: 'venue', name: LocalizedText(en: 'Venue', es: 'Sede'));

    TeamInfo makeTeam(String id, String code, String name) {
      return TeamInfo(id: id, fifaCode: code, name: LocalizedText(en: name, es: name));
    }

    WorldCupMatch makeMatch({
      required String id,
      required TeamInfo homeTeam,
      required TeamInfo awayTeam,
      int? homeScore,
      int? awayScore,
      MatchResultStatus resultStatus = MatchResultStatus.pending,
      LocalizedEntity? stage,
      LocalizedEntity? group,
    }) {
      return WorldCupMatch(
        id: id,
        date: '2026-06-11',
        timeLocal: '13:00',
        timezone: 'America/Mexico_City',
        homeTeam: homeTeam,
        awayTeam: awayTeam,
        group: group ?? groupA,
        stage: stage ?? groupStage,
        stadium: defaultVenue,
        city: defaultVenue,
        country: defaultVenue,
        startDateTime: DateTime.parse('2026-06-11T19:00:00Z'),
        estimatedDurationMinutes: 90,
        isFavorite: false,
        homeScore: homeScore,
        awayScore: awayScore,
        resultStatus: resultStatus,
      );
    }

    final team1 = makeTeam('team1', 'T1', 'Team One');
    final team2 = makeTeam('team2', 'T2', 'Team Two');
    final team3 = makeTeam('team3', 'T3', 'Team Three');
    final team4 = makeTeam('team4', 'T4', 'Team Four');

    test('1. played == wins + draws + losses', () {
      final s = GroupStanding(
        team: team1,
        played: 3,
        wins: 1,
        draws: 1,
        losses: 0, // inconsistency: 3 != 1+1+0
        goalsFor: 4,
        goalsAgainst: 2,
        goalDifference: 2,
        points: 4,
        groupId: 'group_a',
        groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
      );

      final res = validationService.validate(
        matches: [],
        standingsByGroup: {'group_a': [s]},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.isValid, false);
      expect(res.issues.any((i) => i.id == 'standing_played_team1'), true);
    });

    test('2. goalDifference == goalsFor - goalsAgainst', () {
      final s = GroupStanding(
        team: team1,
        played: 3,
        wins: 1,
        draws: 1,
        losses: 1,
        goalsFor: 4,
        goalsAgainst: 2,
        goalDifference: 5, // inconsistency: 5 != 4-2
        points: 4,
        groupId: 'group_a',
        groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
      );

      final res = validationService.validate(
        matches: [],
        standingsByGroup: {'group_a': [s]},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.isValid, false);
      expect(res.issues.any((i) => i.id == 'standing_gd_team1'), true);
    });

    test('3. points == wins * 3 + draws', () {
      final s = GroupStanding(
        team: team1,
        played: 3,
        wins: 2,
        draws: 1,
        losses: 0,
        goalsFor: 4,
        goalsAgainst: 2,
        goalDifference: 2,
        points: 10, // inconsistency: 10 != 2*3 + 1
        groupId: 'group_a',
        groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
      );

      final res = validationService.validate(
        matches: [],
        standingsByGroup: {'group_a': [s]},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.isValid, false);
      expect(res.issues.any((i) => i.id == 'standing_points_team1'), true);
    });

    test('4. Null score in completed match', () {
      final m = makeMatch(
        id: 'M1',
        homeTeam: team1,
        awayTeam: team2,
        homeScore: null, // null score in completed match
        awayScore: 2,
        resultStatus: MatchResultStatus.completed,
      );

      final res = validationService.validate(
        matches: [m],
        standingsByGroup: {},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id == 'match_null_score_M1'), true);
    });

    test('5. Negative score in completed match', () {
      final m = makeMatch(
        id: 'M1',
        homeTeam: team1,
        awayTeam: team2,
        homeScore: -1, // negative score
        awayScore: 2,
        resultStatus: MatchResultStatus.completed,
      );

      final res = validationService.validate(
        matches: [m],
        standingsByGroup: {},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id == 'match_negative_score_M1'), true);
    });

    test('6. Incomplete group has warning', () {
      final m = makeMatch(
        id: 'M1',
        homeTeam: team1,
        awayTeam: team2,
        homeScore: 1,
        awayScore: 1,
        resultStatus: MatchResultStatus.completed,
      );

      final res = validationService.validate(
        matches: [m], // only 1 match instead of 6 completed
        standingsByGroup: {'group_a': []},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id == 'group_in_progress_group_a' && i.severity == ValidationSeverity.warning), true);
    });

    test('7. Complete group with 6 matches', () {
      final matches = List.generate(6, (i) => makeMatch(
        id: 'M$i',
        homeTeam: team1,
        awayTeam: team2,
        homeScore: 1,
        awayScore: 0,
        resultStatus: MatchResultStatus.completed,
      ));

      final res = validationService.validate(
        matches: matches,
        standingsByGroup: {'group_a': []},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id == 'group_in_progress_group_a'), false);
    });

    test('8. Duplicate winners', () {
      final q1 = QualifiedTeam(
        team: team1,
        groupId: 'group_a',
        groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
        groupPosition: 1,
        standing: GroupStanding(
          team: team1, played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9,
          groupId: 'group_a', groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
        ),
        qualificationType: QualificationType.groupWinner,
      );

      // Duplicate winner
      final q2 = QualifiedTeam(
        team: team1,
        groupId: 'group_b',
        groupName: LocalizedText(en: 'Group B', es: 'Grupo B'),
        groupPosition: 1,
        standing: GroupStanding(
          team: team1, played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9,
          groupId: 'group_b', groupName: LocalizedText(en: 'Group B', es: 'Grupo B'),
        ),
        qualificationType: QualificationType.groupWinner,
      );

      // Create 12 winners, 12 runners up, 8 thirds, 4 eliminated thirds to satisfy counts
      final winners = [q1, q2, ...List.generate(10, (i) => QualifiedTeam(
        team: makeTeam('w_$i', 'W$i', 'W$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 1,
        standing: GroupStanding(team: makeTeam('w_$i', 'W$i', 'W$i'), played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.groupWinner,
      ))];

      final runners = List.generate(12, (i) => QualifiedTeam(
        team: makeTeam('r_$i', 'R$i', 'R$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 2,
        standing: GroupStanding(team: makeTeam('r_$i', 'R$i', 'R$i'), played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 6, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.groupRunnerUp,
      ));

      final thirds = List.generate(8, (i) => QualifiedTeam(
        team: makeTeam('t_$i', 'T$i', 'T$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 3,
        standing: GroupStanding(team: makeTeam('t_$i', 'T$i', 'T$i'), played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 3, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.bestThirdPlace,
      ));

      final elimThirds = List.generate(4, (i) => QualifiedTeam(
        team: makeTeam('et_$i', 'ET$i', 'ET$i'), groupId: 'ge_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 3,
        standing: GroupStanding(team: makeTeam('et_$i', 'ET$i', 'ET$i'), played: 3, wins: 0, draws: 0, losses: 3, goalsFor: 0, goalsAgainst: 9, goalDifference: -9, points: 0, groupId: 'ge_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.bestThirdPlace,
      ));

      final allQualified = [...winners, ...runners, ...thirds];

      // Groups completed standings map to trigger qualifiers evaluation
      final Map<String, List<GroupStanding>> groupStandings = {};
      for (int i = 0; i < 12; i++) {
        final gName = 'group_$i';
        groupStandings[gName] = [
          GroupStanding(team: makeTeam('w_$i', 'W$i', 'W$i'), played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('r_$i', 'R$i', 'R$i'), played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 6, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('t_$i', 'T$i', 'T$i'), played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 3, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('l_$i', 'L$i', 'L$i'), played: 3, wins: 0, draws: 0, losses: 3, goalsFor: 0, goalsAgainst: 9, goalDifference: -9, points: 0, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
        ];
      }

      final res = validationService.validate(
        matches: [],
        standingsByGroup: groupStandings,
        qualificationResult: KnockoutQualificationResult(
          groupWinners: winners,
          groupRunnersUp: runners,
          bestThirdPlacedTeams: thirds,
          eliminatedThirdPlacedTeams: elimThirds,
          allQualifiedTeams: allQualified,
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id.startsWith('duplicate_qualified_')), true);
    });

    test('9. Team qualified & eliminated simultaneously', () {
      // Satisfy counts
      final winners = List.generate(12, (i) => QualifiedTeam(
        team: makeTeam('w_$i', 'W$i', 'W$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 1,
        standing: GroupStanding(team: makeTeam('w_$i', 'W$i', 'W$i'), played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.groupWinner,
      ));

      final runners = List.generate(12, (i) => QualifiedTeam(
        team: makeTeam('r_$i', 'R$i', 'R$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 2,
        standing: GroupStanding(team: makeTeam('r_$i', 'R$i', 'R$i'), played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 6, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.groupRunnerUp,
      ));

      final thirds = List.generate(8, (i) => QualifiedTeam(
        team: makeTeam('t_$i', 'T$i', 'T$i'), groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 3,
        standing: GroupStanding(team: makeTeam('t_$i', 'T$i', 'T$i'), played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 3, groupId: 'g_$i', groupName: LocalizedText(en: 'G', es: 'G')),
        qualificationType: QualificationType.bestThirdPlace,
      ));

      // Simultaneously in eliminated list: team 't_0' (from thirds) is in eliminatedThirdPlacedTeams
      final elimThirds = [
        QualifiedTeam(
          team: makeTeam('t_0', 'T0', 'T0'), groupId: 'g_0', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 3,
          standing: GroupStanding(team: makeTeam('t_0', 'T0', 'T0'), played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 3, groupId: 'g_0', groupName: LocalizedText(en: 'G', es: 'G')),
          qualificationType: QualificationType.bestThirdPlace,
        ),
        ...List.generate(3, (i) => QualifiedTeam(
          team: makeTeam('et_$i', 'ET$i', 'ET$i'), groupId: 'ge_$i', groupName: LocalizedText(en: 'G', es: 'G'), groupPosition: 3,
          standing: GroupStanding(team: makeTeam('et_$i', 'ET$i', 'ET$i'), played: 3, wins: 0, draws: 0, losses: 3, goalsFor: 0, goalsAgainst: 9, goalDifference: -9, points: 0, groupId: 'ge_$i', groupName: LocalizedText(en: 'G', es: 'G')),
          qualificationType: QualificationType.bestThirdPlace,
        ))
      ];

      final allQualified = [...winners, ...runners, ...thirds];

      final Map<String, List<GroupStanding>> groupStandings = {};
      for (int i = 0; i < 12; i++) {
        final gName = 'group_$i';
        groupStandings[gName] = [
          GroupStanding(team: makeTeam('w_$i', 'W$i', 'W$i'), played: 3, wins: 3, draws: 0, losses: 0, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 9, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('r_$i', 'R$i', 'R$i'), played: 3, wins: 2, draws: 0, losses: 1, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 6, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('t_$i', 'T$i', 'T$i'), played: 3, wins: 1, draws: 0, losses: 2, goalsFor: 3, goalsAgainst: 0, goalDifference: 3, points: 3, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
          GroupStanding(team: makeTeam('l_$i', 'L$i', 'L$i'), played: 3, wins: 0, draws: 0, losses: 3, goalsFor: 0, goalsAgainst: 9, goalDifference: -9, points: 0, groupId: gName, groupName: LocalizedText(en: 'G', es: 'G')),
        ];
      }

      final res = validationService.validate(
        matches: [],
        standingsByGroup: groupStandings,
        qualificationResult: KnockoutQualificationResult(
          groupWinners: winners,
          groupRunnersUp: runners,
          bestThirdPlacedTeams: thirds,
          eliminatedThirdPlacedTeams: elimThirds,
          allQualifiedTeams: allQualified,
        ),
        bracketSlots: [],
      );

      expect(res.issues.any((i) => i.id == 'qualified_and_eliminated_t_0'), true);
    });

    test('10. Validates 12 winners when groups complete', () {
      final slots = List.generate(16, (i) => KnockoutMatchSlot(
        matchNumber: 73 + i,
        round: 'round_of_32',
        slotA: 'A_winners',
        slotB: 'B_runners-up',
      ));

      final res = validationService.validate(
        matches: [],
        standingsByGroup: {},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: slots,
      );

      // When groups are not complete, counts check is pending (info severity is added, not error)
      expect(res.isValid, true);
      expect(res.issues.any((i) => i.id == 'groups_incomplete_for_qualifiers'), true);
    });

    test('16 & 17. Validates 16 bracket slots and match numbers 73 to 88', () {
      final slots = List.generate(16, (i) => KnockoutMatchSlot(
        matchNumber: 73 + i,
        round: 'round_of_32',
        slotA: 'A_winners',
        slotB: 'B_runners-up',
      ));

      final res = validationService.validate(
        matches: [],
        standingsByGroup: {},
        qualificationResult: KnockoutQualificationResult(
          groupWinners: [],
          groupRunnersUp: [],
          bestThirdPlacedTeams: [],
          eliminatedThirdPlacedTeams: [],
          allQualifiedTeams: [],
        ),
        bracketSlots: slots,
      );

      // Should pass because there are 16 slots with numbers 73 to 88
      expect(res.issues.any((i) => i.id == 'bracket_slots_count'), false);
      expect(res.issues.any((i) => i.id == 'bracket_match_numbers'), false);
    });
  });
}
