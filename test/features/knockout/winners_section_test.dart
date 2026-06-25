import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/features/knockout/widgets/qualified_teams_section.dart';
import 'package:world_cup_schedule_app/features/knockout/models/knockout_qualification_result.dart';
import 'package:world_cup_schedule_app/features/standings/models/group_standing.dart';
import 'package:world_cup_schedule_app/features/matches/models/team_info.dart';
import 'package:world_cup_schedule_app/features/matches/models/flag_style.dart';
import 'package:world_cup_schedule_app/features/matches/data/flag_style_repository.dart';
import 'package:world_cup_schedule_app/core/i18n/localized_text.dart';
import 'package:world_cup_schedule_app/core/i18n/app_translations.dart';

class FakeFlagStyleRepository implements FlagStyleRepository {
  @override
  FlagStyle? getFlagStyle(String teamName) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    AppTranslations.setTranslations({
      'qualifiedStatus': {'en': 'Qualified', 'es': 'Clasificado'},
      'pendingStatus': {'en': 'Pending', 'es': 'Pendiente'},
    });
  });

  group('QualifiedTeamsSection Widget Tests', () {
    final fakeFlagStyleRepository = FakeFlagStyleRepository();

    final teamMexico = TeamInfo(id: 'mexico', fifaCode: 'MEX', name: LocalizedText(en: 'Mexico', es: 'México'));
    final teamCanada = TeamInfo(id: 'canada', fifaCode: 'CAN', name: LocalizedText(en: 'Canada', es: 'Canadá'));
    final teamArgentina = TeamInfo(id: 'argentina', fifaCode: 'ARG', name: LocalizedText(en: 'Argentina', es: 'Argentina'));
    final teamUSA = TeamInfo(id: 'usa', fifaCode: 'USA', name: LocalizedText(en: 'USA', es: 'EE.UU.'));
    final teamSouthAfrica = TeamInfo(id: 'south_africa', fifaCode: 'RSA', name: LocalizedText(en: 'South Africa', es: 'Sudáfrica'));

    testWidgets('1. Displays points & positive GD formatting (+5) & Qualified badge for complete group', (WidgetTester tester) async {
      // Group A complete: Mexico first with 7 points, +5 GD
      final groupStandings = {
        'group_a': [
          GroupStanding(
            team: teamMexico,
            played: 3,
            wins: 2,
            draws: 1,
            losses: 0,
            goalsFor: 6,
            goalsAgainst: 1,
            goalDifference: 5,
            points: 7,
            groupId: 'group_a',
            groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
          ),
          GroupStanding(
            team: teamCanada,
            played: 3,
            wins: 1,
            draws: 2,
            losses: 0,
            goalsFor: 4,
            goalsAgainst: 2,
            goalDifference: 2,
            points: 5,
            groupId: 'group_a',
            groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
          ),
          GroupStanding(
            team: teamUSA,
            played: 3,
            wins: 1,
            draws: 0,
            losses: 2,
            goalsFor: 3,
            goalsAgainst: 5,
            goalDifference: -2,
            points: 3,
            groupId: 'group_a',
            groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
          ),
          GroupStanding(
            team: teamSouthAfrica,
            played: 3,
            wins: 0,
            draws: 1,
            losses: 2,
            goalsFor: 1,
            goalsAgainst: 6,
            goalDifference: -5,
            points: 1,
            groupId: 'group_a',
            groupName: LocalizedText(en: 'Group A', es: 'Grupo A'),
          ),
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QualifiedTeamsSection(
              groupStandings: groupStandings,
              qualificationResult: KnockoutQualificationResult(
                groupWinners: [],
                groupRunnersUp: [],
                bestThirdPlacedTeams: [],
                eliminatedThirdPlacedTeams: [],
                allQualifiedTeams: [],
              ),
              flagStyleRepository: fakeFlagStyleRepository,
              lang: 'es',
            ),
          ),
        ),
      );

      // Verify points and goal difference text
      expect(find.text('7 pts (+5)'), findsOneWidget);
      expect(find.text('5 pts (+2)'), findsOneWidget);

      // Group has all played=3, so group is complete. Badge should show "Clasificado" (es)
      expect(find.text('Clasificado'), findsNWidgets(2));
    });

    testWidgets('2. Displays zero GD formatting (+0) & pending badge for incomplete group', (WidgetTester tester) async {
      // Group B incomplete: Canada has 2 matches played, 4 points, 0 GD
      final groupStandings = {
        'group_b': [
          GroupStanding(
            team: teamCanada,
            played: 2, // incomplete
            wins: 1,
            draws: 1,
            losses: 0,
            goalsFor: 2,
            goalsAgainst: 2,
            goalDifference: 0,
            points: 4,
            groupId: 'group_b',
            groupName: LocalizedText(en: 'Group B', es: 'Grupo B'),
          )
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QualifiedTeamsSection(
              groupStandings: groupStandings,
              qualificationResult: KnockoutQualificationResult(
                groupWinners: [],
                groupRunnersUp: [],
                bestThirdPlacedTeams: [],
                eliminatedThirdPlacedTeams: [],
                allQualifiedTeams: [],
              ),
              flagStyleRepository: fakeFlagStyleRepository,
              lang: 'en',
            ),
          ),
        ),
      );

      // Verify points and goal difference text with +0 format
      expect(find.text('4 pts (+0)'), findsOneWidget);

      // Group is incomplete. Badge should show "Pending" (en)
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('3. Displays negative GD formatting (-2) & Pending badge for incomplete group', (WidgetTester tester) async {
      // Group C incomplete: Argentina has 1 match played, 0 points, -2 GD
      final groupStandings = {
        'group_c': [
          GroupStanding(
            team: teamArgentina,
            played: 1, // incomplete
            wins: 0,
            draws: 0,
            losses: 1,
            goalsFor: 0,
            goalsAgainst: 2,
            goalDifference: -2,
            points: 0,
            groupId: 'group_c',
            groupName: LocalizedText(en: 'Group C', es: 'Grupo C'),
          )
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QualifiedTeamsSection(
              groupStandings: groupStandings,
              qualificationResult: KnockoutQualificationResult(
                groupWinners: [],
                groupRunnersUp: [],
                bestThirdPlacedTeams: [],
                eliminatedThirdPlacedTeams: [],
                allQualifiedTeams: [],
              ),
              flagStyleRepository: fakeFlagStyleRepository,
              lang: 'es',
            ),
          ),
        ),
      );

      // Verify points and goal difference text with -2 format
      expect(find.text('0 pts (-2)'), findsOneWidget);

      // Badge should show "Pendiente" (es)
      expect(find.text('Pendiente'), findsOneWidget);
    });
  });
}
