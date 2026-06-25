import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/features/standings/services/group_standings_service.dart';
import 'package:world_cup_schedule_app/features/standings/models/group_standing.dart';
import 'package:world_cup_schedule_app/features/matches/models/world_cup_match.dart';
import 'package:world_cup_schedule_app/features/matches/models/team_info.dart';
import 'package:world_cup_schedule_app/features/matches/models/match_result_status.dart';
import 'package:world_cup_schedule_app/features/matches/models/localized_entity.dart';
import 'package:world_cup_schedule_app/core/i18n/localized_text.dart';

void main() {
  group('GroupStandingsService Tests', () {
    final standingsService = GroupStandingsService();

    final mexico = TeamInfo(id: 'mexico', fifaCode: 'MEX', name: LocalizedText(en: 'Mexico', es: 'México'));
    final canada = TeamInfo(id: 'canada', fifaCode: 'CAN', name: LocalizedText(en: 'Canada', es: 'Canadá'));
    final usa = TeamInfo(id: 'usa', fifaCode: 'USA', name: LocalizedText(en: 'USA', es: 'EE.UU.'));
    final southAfrica = TeamInfo(id: 'south_africa', fifaCode: 'RSA', name: LocalizedText(en: 'South Africa', es: 'Sudáfrica'));

    final groupA = LocalizedEntity(id: 'group_a', name: LocalizedText(en: 'Group A', es: 'Grupo A'));
    final groupStage = LocalizedEntity(id: 'group_stage', name: LocalizedText(en: 'Group Stage', es: 'Fase de Grupos'));
    final knockoutStage = LocalizedEntity(id: 'knockout_stage', name: LocalizedText(en: 'Knockout Stage', es: 'Eliminatorias'));
    final defaultVenue = LocalizedEntity(id: 'venue', name: LocalizedText(en: 'Venue', es: 'Sede'));

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

    test('1. Victoria local suma 3 puntos al local y 0 al visitante', () {
      final match = makeMatch(
        id: 'M001',
        homeTeam: mexico,
        awayTeam: canada,
        homeScore: 2,
        awayScore: 0,
        resultStatus: MatchResultStatus.completed,
      );

      final standings = standingsService.calculateStandings([match]);
      final standingsA = standings['group_a']!;

      final mexStanding = standingsA.firstWhere((s) => s.team.id == 'mexico');
      final canStanding = standingsA.firstWhere((s) => s.team.id == 'canada');

      expect(mexStanding.points, 3);
      expect(mexStanding.wins, 1);
      expect(mexStanding.played, 1);
      expect(mexStanding.goalsFor, 2);
      expect(mexStanding.goalsAgainst, 0);
      expect(mexStanding.goalDifference, 2);

      expect(canStanding.points, 0);
      expect(canStanding.losses, 1);
      expect(canStanding.played, 1);
      expect(canStanding.goalsFor, 0);
      expect(canStanding.goalsAgainst, 2);
      expect(canStanding.goalDifference, -2);
    });

    test('2. Victoria visitante suma 3 puntos al visitante y 0 al local', () {
      final match = makeMatch(
        id: 'M001',
        homeTeam: mexico,
        awayTeam: canada,
        homeScore: 1,
        awayScore: 3,
        resultStatus: MatchResultStatus.completed,
      );

      final standings = standingsService.calculateStandings([match]);
      final standingsA = standings['group_a']!;

      final mexStanding = standingsA.firstWhere((s) => s.team.id == 'mexico');
      final canStanding = standingsA.firstWhere((s) => s.team.id == 'canada');

      expect(mexStanding.points, 0);
      expect(mexStanding.losses, 1);

      expect(canStanding.points, 3);
      expect(canStanding.wins, 1);
    });

    test('3. Empate suma 1 punto a cada equipo', () {
      final match = makeMatch(
        id: 'M001',
        homeTeam: mexico,
        awayTeam: canada,
        homeScore: 1,
        awayScore: 1,
        resultStatus: MatchResultStatus.completed,
      );

      final standings = standingsService.calculateStandings([match]);
      final standingsA = standings['group_a']!;

      final mexStanding = standingsA.firstWhere((s) => s.team.id == 'mexico');
      final canStanding = standingsA.firstWhere((s) => s.team.id == 'canada');

      expect(mexStanding.points, 1);
      expect(mexStanding.draws, 1);

      expect(canStanding.points, 1);
      expect(canStanding.draws, 1);
    });

    test('4. Ignora partidos sin resultado (pending)', () {
      final match = makeMatch(
        id: 'M001',
        homeTeam: mexico,
        awayTeam: canada,
        homeScore: 3,
        awayScore: 0,
        resultStatus: MatchResultStatus.pending,
      );

      final standings = standingsService.calculateStandings([match]);
      final standingsA = standings['group_a']!;

      final mexStanding = standingsA.firstWhere((s) => s.team.id == 'mexico');
      expect(mexStanding.played, 0);
      expect(mexStanding.points, 0);
    });

    test('5. Ignora partidos que no sean group_stage', () {
      final match = makeMatch(
        id: 'M001',
        homeTeam: mexico,
        awayTeam: canada,
        homeScore: 2,
        awayScore: 1,
        resultStatus: MatchResultStatus.completed,
        stage: knockoutStage,
      );

      // Since the match stage is knockout, it shouldn't even discover any teams/groups
      final standings = standingsService.calculateStandings([match]);
      expect(standings.containsKey('group_a'), false);
    });

    test('6. Ordenamiento completo (Puntos, DG, GF, Alfabético)', () {
      // Setup a group with 4 teams: Mexico, Canada, USA, South Africa
      // Match 1: Mexico 3 - 0 South Africa (completed)
      // Match 2: Canada 2 - 1 USA (completed)
      // Match 3: USA 2 - 2 Mexico (completed)
      // Match 4: Canada 1 - 1 South Africa (completed)

      final matches = [
        makeMatch(id: '1', homeTeam: mexico, awayTeam: southAfrica, homeScore: 3, awayScore: 0, resultStatus: MatchResultStatus.completed),
        makeMatch(id: '2', homeTeam: canada, awayTeam: usa, homeScore: 2, awayScore: 1, resultStatus: MatchResultStatus.completed),
        makeMatch(id: '3', homeTeam: usa, awayTeam: mexico, homeScore: 2, awayScore: 2, resultStatus: MatchResultStatus.completed),
        makeMatch(id: '4', homeTeam: canada, awayTeam: southAfrica, homeScore: 1, awayScore: 1, resultStatus: MatchResultStatus.completed),
      ];

      final standings = standingsService.calculateStandings(matches);
      final standingsA = standings['group_a']!;

      // Canada: wins against USA (3 pts), draws with SA (1 pt) -> 4 pts, GF=3, GC=2, DG=1
      // Mexico: wins against SA (3 pts), draws with USA (1 pt) -> 4 pts, GF=5, GC=2, DG=3
      // USA: lost to Canada (0 pt), draws with Mexico (1 pt) -> 1 pt, GF=3, GC=4, DG=-1
      // South Africa: lost to Mexico (0 pt), draws with Canada (1 pt) -> 1 pt, GF=1, GC=4, DG=-3

      // Sorting order should be:
      // 1. Mexico (4 pts, DG=+3)
      // 2. Canada (4 pts, DG=+1)
      // 3. USA (1 pt, DG=-1)
      // 4. South Africa (1 pt, DG=-3)

      expect(standingsA[0].team.id, 'mexico');
      expect(standingsA[1].team.id, 'canada');
      expect(standingsA[2].team.id, 'usa');
      expect(standingsA[3].team.id, 'south_africa');
    });

    test('7. Ordenamiento desempate por goles a favor', () {
      // Two teams with same points and same goal difference:
      // Mexico: points=3, played=1, wins=1, goalsFor=3, goalsAgainst=2, goalDifference=1
      // Canada: points=3, played=1, wins=1, goalsFor=2, goalsAgainst=1, goalDifference=1
      // Mexico has more goals for (3 > 2), so Mexico should be ranked higher than Canada.
      final matches = [
        makeMatch(id: '1', homeTeam: mexico, awayTeam: usa, homeScore: 3, awayScore: 2, resultStatus: MatchResultStatus.completed),
        makeMatch(id: '2', homeTeam: canada, awayTeam: southAfrica, homeScore: 2, awayScore: 1, resultStatus: MatchResultStatus.completed),
      ];

      final standings = standingsService.calculateStandings(matches);
      final standingsA = standings['group_a']!;

      expect(standingsA[0].team.id, 'mexico');
      expect(standingsA[1].team.id, 'canada');
    });

    test('8. Ordenamiento desempate alfabético por nombre en inglés', () {
      // Canada and Mexico have exact same stats:
      // Canada: points=1, played=1, draws=1, goalsFor=1, goalsAgainst=1, goalDifference=0
      // Mexico: points=1, played=1, draws=1, goalsFor=1, goalsAgainst=1, goalDifference=0
      // Alphabetically 'Canada' comes before 'Mexico', so Canada should be ranked higher.
      final matches = [
        makeMatch(id: '1', homeTeam: canada, awayTeam: usa, homeScore: 1, awayScore: 1, resultStatus: MatchResultStatus.completed),
        makeMatch(id: '2', homeTeam: mexico, awayTeam: southAfrica, homeScore: 1, awayScore: 1, resultStatus: MatchResultStatus.completed),
      ];

      final standings = standingsService.calculateStandings(matches);
      final standingsA = standings['group_a']!;

      expect(standingsA[0].team.id, 'canada');
      expect(standingsA[1].team.id, 'mexico');
    });
  });
}
