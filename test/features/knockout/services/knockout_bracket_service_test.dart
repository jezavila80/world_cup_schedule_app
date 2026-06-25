import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/features/matches/models/world_cup_match.dart';
import 'package:world_cup_schedule_app/features/matches/models/team_info.dart';
import 'package:world_cup_schedule_app/features/matches/models/localized_entity.dart';
import 'package:world_cup_schedule_app/core/i18n/localized_text.dart';
import 'package:world_cup_schedule_app/features/standings/models/group_standing.dart';
import 'package:world_cup_schedule_app/features/knockout/services/knockout_bracket_service.dart';
import 'package:world_cup_schedule_app/features/matches/models/match_result_status.dart';

void main() {
  group('KnockoutBracketService Tests', () {
    final service = KnockoutBracketService();

    final teamA1 = TeamInfo(id: 't_a1', fifaCode: 'A1', name: LocalizedText(en: 'Team A1', es: 'Equipo A1'));
    final teamA2 = TeamInfo(id: 't_a2', fifaCode: 'A2', name: LocalizedText(en: 'Team A2', es: 'Equipo A2'));
    final teamA3 = TeamInfo(id: 't_a3', fifaCode: 'A3', name: LocalizedText(en: 'Team A3', es: 'Equipo A3'));
    final teamA4 = TeamInfo(id: 't_a4', fifaCode: 'A4', name: LocalizedText(en: 'Team A4', es: 'Equipo A4'));

    final groupNameA = LocalizedText(en: 'Group A', es: 'Grupo A');
    final round32Stage = LocalizedEntity(id: 'round_of_32', name: LocalizedText(en: 'Round of 32', es: 'Dieciseisavos'));
    final naGroup = LocalizedEntity(id: 'na', name: LocalizedText(en: 'N/A', es: 'N/A'));
    final defaultVenue = LocalizedEntity(id: 'venue', name: LocalizedText(en: 'Venue', es: 'Sede'));

    WorldCupMatch makeKnockoutMatch({
      required String id,
      required String homeTeamId,
      required String awayTeamId,
    }) {
      return WorldCupMatch(
        id: id,
        date: '2026-06-28',
        timeLocal: '20:00',
        timezone: 'Europe/London',
        homeTeam: TeamInfo(id: homeTeamId, fifaCode: '', name: LocalizedText(en: homeTeamId, es: homeTeamId)),
        awayTeam: TeamInfo(id: awayTeamId, fifaCode: '', name: LocalizedText(en: awayTeamId, es: awayTeamId)),
        group: naGroup,
        stage: round32Stage,
        stadium: defaultVenue,
        city: defaultVenue,
        country: defaultVenue,
        startDateTime: DateTime.parse('2026-06-28T19:00:00Z'),
        estimatedDurationMinutes: 120,
        isFavorite: false,
        resultStatus: MatchResultStatus.pending,
      );
    }

    GroupStanding makeStanding({
      required TeamInfo team,
      required String groupId,
      required int position,
      int played = 3,
      int points = 0,
    }) {
      return GroupStanding(
        groupId: groupId,
        groupName: groupNameA,
        team: team,
        played: played,
        wins: 0,
        draws: 0,
        losses: 0,
        goalsFor: 0,
        goalsAgainst: 0,
        goalDifference: 0,
        points: points,
      );
    }

    List<WorldCupMatch> generateMockRoundOf32Matches() {
      return List.generate(16, (index) {
        final matchNum = 73 + index;
        return makeKnockoutMatch(
          id: 'M0$matchNum',
          homeTeamId: 'group_a_winners',
          awayTeamId: 'group_b_runners-up',
        );
      });
    }

    test('1. calculateBracketSlots returns all 16 slots corresponding to matches 73 to 88', () {
      final matches = generateMockRoundOf32Matches();
      final slots = service.calculateBracketSlots(matches, {});
      expect(slots.length, 16);
      expect(slots[0].matchNumber, 73);
      expect(slots[15].matchNumber, 88);
    });

    test('2. Winner slot from an incomplete group resolves to null', () {
      final matches = [makeKnockoutMatch(id: 'M073', homeTeamId: 'group_a_winners', awayTeamId: 'group_b_runners-up')];
      final standings = {
        'group_a': [
          makeStanding(team: teamA1, groupId: 'group_a', position: 1, played: 2, points: 6),
          makeStanding(team: teamA2, groupId: 'group_a', position: 2, played: 2, points: 4),
          makeStanding(team: teamA3, groupId: 'group_a', position: 3, played: 2, points: 3),
          makeStanding(team: teamA4, groupId: 'group_a', position: 4, played: 2, points: 1),
        ]
      };
      final slots = service.calculateBracketSlots(matches, standings);
      expect(slots.first.teamA, isNull);
    });

    test('3. Winner slot from a complete group resolves to the correct team', () {
      final matches = [makeKnockoutMatch(id: 'M073', homeTeamId: 'group_a_winners', awayTeamId: 'group_b_runners-up')];
      final standings = {
        'group_a': [
          makeStanding(team: teamA1, groupId: 'group_a', position: 1, played: 3, points: 6),
          makeStanding(team: teamA2, groupId: 'group_a', position: 2, played: 3, points: 4),
          makeStanding(team: teamA3, groupId: 'group_a', position: 3, played: 3, points: 3),
          makeStanding(team: teamA4, groupId: 'group_a', position: 4, played: 3, points: 1),
        ]
      };
      final slots = service.calculateBracketSlots(matches, standings);
      expect(slots.first.teamA, isNotNull);
      expect(slots.first.teamA!.team.id, 't_a1');
    });

    test('4. Runner-up slot from an incomplete group resolves to null', () {
      final matches = [makeKnockoutMatch(id: 'M073', homeTeamId: 'group_a_winners', awayTeamId: 'group_a_runners-up')];
      final standings = {
        'group_a': [
          makeStanding(team: teamA1, groupId: 'group_a', position: 1, played: 2, points: 6),
          makeStanding(team: teamA2, groupId: 'group_a', position: 2, played: 2, points: 4),
          makeStanding(team: teamA3, groupId: 'group_a', position: 3, played: 2, points: 3),
          makeStanding(team: teamA4, groupId: 'group_a', position: 4, played: 2, points: 1),
        ]
      };
      final slots = service.calculateBracketSlots(matches, standings);
      expect(slots.first.teamB, isNull);
    });

    test('5. Runner-up slot from a complete group resolves to the correct team', () {
      final matches = [makeKnockoutMatch(id: 'M073', homeTeamId: 'group_a_winners', awayTeamId: 'group_a_runners-up')];
      final standings = {
        'group_a': [
          makeStanding(team: teamA1, groupId: 'group_a', position: 1, played: 3, points: 6),
          makeStanding(team: teamA2, groupId: 'group_a', position: 2, played: 3, points: 4),
          makeStanding(team: teamA3, groupId: 'group_a', position: 3, played: 3, points: 3),
          makeStanding(team: teamA4, groupId: 'group_a', position: 4, played: 3, points: 1),
        ]
      };
      final slots = service.calculateBracketSlots(matches, standings);
      expect(slots.first.teamB, isNotNull);
      expect(slots.first.teamB!.team.id, 't_a2');
    });
  });
}
