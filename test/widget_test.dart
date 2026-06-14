import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:world_cup_schedule_app/core/i18n/localized_text.dart';
import 'package:world_cup_schedule_app/features/matches/models/world_cup_match.dart';
import 'package:world_cup_schedule_app/features/matches/models/flag_style.dart';
import 'package:world_cup_schedule_app/features/matches/models/match_result_status.dart';
import 'package:world_cup_schedule_app/features/matches/models/team_info.dart';
import 'package:world_cup_schedule_app/features/matches/models/localized_entity.dart';
import 'package:world_cup_schedule_app/features/matches/filters/filter_state.dart';
import 'package:world_cup_schedule_app/features/matches/screens/about_screen.dart';
import 'package:world_cup_schedule_app/features/matches/screens/match_detail_screen.dart';
import 'package:world_cup_schedule_app/features/matches/data/match_repository.dart';
import 'package:world_cup_schedule_app/features/matches/data/flag_style_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_cup_schedule_app/features/matches/services/match_result_service.dart';

void main() {
  group('WorldCupMatch Model Tests', () {
    test('should parse WorldCupMatch from JSON correctly', () {
      final json = {
        "id": "M001",
        "matchNumber": 1,
        "stage": "Group Stage",
        "group": "A",
        "homeTeam": {
          "name": "Mexico",
          "fifaCode": "MEX",
          "type": "team"
        },
        "awayTeam": {
          "name": "South Africa",
          "fifaCode": "RSA",
          "type": "team"
        },
        "kickoff": {
          "sourceLocalDateTime": "2026-06-11T20:00:00+01:00",
          "sourceTimezone": "Europe/London",
          "utcDateTime": "2026-06-11T19:00:00Z",
          "mexicoCityDateTime": "2026-06-11T13:00:00-06:00",
          "mexicoCityDate": "2026-06-11",
          "mexicoCityTime": "13:00"
        },
        "venue": {
          "stadium": "Mexico City Stadium",
          "city": "Mexico City",
          "country": "Mexico"
        },
        "estimatedDurationMinutes": 120,
        "status": "scheduled",
        "isFavorite": false
      };

      final match = WorldCupMatch.fromJson(json);

      expect(match.id, 'M001');
      expect(match.homeTeam.name.en, 'Mexico');
      expect(match.awayTeam.name.en, 'South Africa');
      expect(match.startDateTime, DateTime.parse("2026-06-11T19:00:00Z"));
      expect(match.estimatedDurationMinutes, 120);
      expect(match.isFavorite, false);
      expect(match.stadium.name.en, 'Mexico City Stadium');
      expect(match.city.name.en, 'Mexico City');
      expect(match.country.name.en, 'Mexico');
      expect(match.date, '2026-06-11');
      expect(match.timeLocal, '13:00');
      expect(match.timezone, 'America/Mexico_City');
    });

    test('copyWith should copy properties correctly', () {
      final match = WorldCupMatch(
        id: "M001",
        date: "2026-06-11",
        timeLocal: "18:00",
        timezone: "America/Mexico_City",
        homeTeam: TeamInfo(id: "mexico", fifaCode: "MEX", name: LocalizedText(en: "Mexico", es: "México")),
        awayTeam: TeamInfo(id: "south_africa", fifaCode: "RSA", name: LocalizedText(en: "South Africa", es: "Sudáfrica")),
        group: LocalizedEntity(id: "a", name: LocalizedText(en: "Group A", es: "Grupo A")),
        stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
        stadium: LocalizedEntity(id: "estadio_azteca", name: LocalizedText(en: "Estadio Azteca", es: "Estadio Azteca")),
        city: LocalizedEntity(id: "mexico_city", name: LocalizedText(en: "Mexico City", es: "Ciudad de México")),
        country: LocalizedEntity(id: "mexico", name: LocalizedText(en: "Mexico", es: "México")),
        startDateTime: DateTime.parse("2026-06-12T00:00:00Z"),
        estimatedDurationMinutes: 105,
        isFavorite: false,
      );

      final updatedMatch = match.copyWith(
        isFavorite: true,
        estimatedDurationMinutes: 120,
      );

      expect(updatedMatch.id, 'M001');
      expect(updatedMatch.isFavorite, true);
      expect(updatedMatch.estimatedDurationMinutes, 120);
    });

    group('getStatus Tests', () {
      final start = DateTime.parse("2026-06-11T12:00:00Z"); // local: 2026-06-11T06:00:00-06:00
      final match = WorldCupMatch(
        id: "M001",
        date: "2026-06-11",
        timeLocal: "18:00",
        timezone: "America/Mexico_City",
        homeTeam: TeamInfo(id: "mexico", fifaCode: "MEX", name: LocalizedText(en: "Mexico", es: "México")),
        awayTeam: TeamInfo(id: "south_africa", fifaCode: "RSA", name: LocalizedText(en: "South Africa", es: "Sudáfrica")),
        group: LocalizedEntity(id: "a", name: LocalizedText(en: "Group A", es: "Grupo A")),
        stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
        stadium: LocalizedEntity(id: "estadio_azteca", name: LocalizedText(en: "Estadio Azteca", es: "Estadio Azteca")),
        city: LocalizedEntity(id: "mexico_city", name: LocalizedText(en: "Mexico City", es: "Ciudad de México")),
        country: LocalizedEntity(id: "mexico", name: LocalizedText(en: "Mexico", es: "México")),
        startDateTime: start,
        estimatedDurationMinutes: 100,
        isFavorite: false,
      );

      test('should return live if current time is within duration', () {
        final now = start.add(const Duration(minutes: 50));
        expect(match.getStatus(now), MatchStatus.live);
      });

      test('should return finished if current time is after duration', () {
        final now = start.add(const Duration(minutes: 101));
        expect(match.getStatus(now), MatchStatus.finished);
      });

      test('should return today if match is in the future but same calendar day local', () {
        final now = start.subtract(const Duration(hours: 2));
        expect(match.getStatus(now), MatchStatus.today);
      });

      test('should return upcoming if match is in the future and different calendar day local', () {
        final now = start.subtract(const Duration(hours: 7));
        expect(match.getStatus(now), MatchStatus.upcoming);
      });
    });
  });

  group('FlagStyle Model Tests', () {
    test('should parse FlagStyle from JSON correctly', () {
      final json = {
        "teamId": "mexico",
        "displayName": "Mexico",
        "fifaCode": "MEX",
        "iso2Code": "MX",
        "flagColors": ["#006847", "#FFFFFF", "#CE1126"],
        "orientation": "vertical",
        "pattern": "verticalStripes",
        "notes": "Simplified tricolor without coat of arms"
      };

      final style = FlagStyle.fromJson(json);

      expect(style.teamId, 'mexico');
      expect(style.displayName, 'Mexico');
      expect(style.fifaCode, 'MEX');
      expect(style.iso2Code, 'MX');
      expect(style.flagColors.length, 3);
      expect(style.flagColors[0], const Color(0xFF006847));
      expect(style.flagColors[1], const Color(0xFFFFFFFF));
      expect(style.flagColors[2], const Color(0xFFCE1126));
      expect(style.orientation, 'vertical');
      expect(style.pattern, FlagPattern.verticalStripes);
    });
  });

  group('FilterState Tests', () {
    final mockNow = DateTime.parse("2026-06-12T12:00:00Z");
    final mockNowLocal = mockNow.toLocal();

    // match1 is today
    final match1 = WorldCupMatch(
      id: "M001",
      date: "2026-06-12",
      timeLocal: "18:00",
      timezone: "America/Mexico_City",
      homeTeam: TeamInfo(id: "mexico", fifaCode: "MEX", name: LocalizedText(en: "Mexico", es: "México")),
      awayTeam: TeamInfo(id: "south_africa", fifaCode: "RSA", name: LocalizedText(en: "South Africa", es: "Sudáfrica")),
      group: LocalizedEntity(id: "a", name: LocalizedText(en: "Group A", es: "Grupo A")),
      stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
      stadium: LocalizedEntity(id: "estadio_azteca", name: LocalizedText(en: "Estadio Azteca", es: "Estadio Azteca")),
      city: LocalizedEntity(id: "mexico_city", name: LocalizedText(en: "Mexico City", es: "Ciudad de México")),
      country: LocalizedEntity(id: "mexico", name: LocalizedText(en: "Mexico", es: "México")),
      startDateTime: mockNowLocal.add(const Duration(hours: 1)),
      estimatedDurationMinutes: 100,
      isFavorite: true,
    );

    // match2 is tomorrow
    final match2 = WorldCupMatch(
      id: "M002",
      date: "2026-06-13",
      timeLocal: "20:00",
      timezone: "America/New_York",
      homeTeam: TeamInfo(id: "usa", fifaCode: "USA", name: LocalizedText(en: "USA", es: "EEUU")),
      awayTeam: TeamInfo(id: "italy", fifaCode: "ITA", name: LocalizedText(en: "Italy", es: "Italia")),
      group: LocalizedEntity(id: "b", name: LocalizedText(en: "Group B", es: "Grupo B")),
      stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
      stadium: LocalizedEntity(id: "metlife", name: LocalizedText(en: "MetLife Stadium", es: "Estadio MetLife")),
      city: LocalizedEntity(id: "east_rutherford", name: LocalizedText(en: "East Rutherford", es: "East Rutherford")),
      country: LocalizedEntity(id: "usa", name: LocalizedText(en: "USA", es: "EEUU")),
      startDateTime: mockNowLocal.add(const Duration(days: 1, hours: 1)),
      estimatedDurationMinutes: 100,
      isFavorite: false,
    );

    // match3 is 2 days from now (day after tomorrow)
    final match3 = WorldCupMatch(
      id: "M003",
      date: "2026-06-14",
      timeLocal: "15:00",
      timezone: "America/Vancouver",
      homeTeam: TeamInfo(id: "canada", fifaCode: "CAN", name: LocalizedText(en: "Canada", es: "Canadá")),
      awayTeam: TeamInfo(id: "brazil", fifaCode: "BRA", name: LocalizedText(en: "Brazil", es: "Brasil")),
      group: LocalizedEntity(id: "c", name: LocalizedText(en: "Group C", es: "Grupo C")),
      stage: LocalizedEntity(id: "round_of_16", name: LocalizedText(en: "Round of 16", es: "Octavos de Final")),
      stadium: LocalizedEntity(id: "bc_place", name: LocalizedText(en: "BC Place", es: "Estadio BC Place")),
      city: LocalizedEntity(id: "vancouver", name: LocalizedText(en: "Vancouver", es: "Vancouver")),
      country: LocalizedEntity(id: "canada", name: LocalizedText(en: "Canada", es: "Canadá")),
      startDateTime: mockNowLocal.add(const Duration(days: 2, hours: 1)),
      estimatedDurationMinutes: 100,
      isFavorite: false,
    );

    // match4 is 4 days from now
    final match4 = WorldCupMatch(
      id: "M004",
      date: "2026-06-16",
      timeLocal: "15:00",
      timezone: "America/Vancouver",
      homeTeam: TeamInfo(id: "argentina", fifaCode: "ARG", name: LocalizedText(en: "Argentina", es: "Argentina")),
      awayTeam: TeamInfo(id: "france", fifaCode: "FRA", name: LocalizedText(en: "France", es: "Francia")),
      group: LocalizedEntity(id: "d", name: LocalizedText(en: "Group D", es: "Grupo D")),
      stage: LocalizedEntity(id: "round_of_16", name: LocalizedText(en: "Round of 16", es: "Octavos de Final")),
      stadium: LocalizedEntity(id: "bc_place", name: LocalizedText(en: "BC Place", es: "Estadio BC Place")),
      city: LocalizedEntity(id: "vancouver", name: LocalizedText(en: "Vancouver", es: "Vancouver")),
      country: LocalizedEntity(id: "canada", name: LocalizedText(en: "Canada", es: "Canadá")),
      startDateTime: mockNowLocal.add(const Duration(days: 4, hours: 1)),
      estimatedDurationMinutes: 100,
      isFavorite: false,
    );

    final matchesList = [match1, match2, match3, match4];

    test('should return all matches with default FilterState', () {
      const filters = FilterState();
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 4);
    });

    test('should filter by search query correctly', () {
      const filters = FilterState(searchQuery: 'italy');
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'M002');
    });

    test('should filter by host country correctly', () {
      const filters = FilterState(hostCountry: 'Mexico');
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'M001');
    });

    test('should filter by favorites only correctly', () {
      const filters = FilterState(showOnlyFavorites: true);
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'M001');
    });

    test('should filter by stage correctly', () {
      const filtersGroup = FilterState(stage: 'Group Stage');
      expect(filtersGroup.apply(matchesList, mockNow).length, 2);

      const filtersElim = FilterState(stage: 'Eliminatorias');
      final filtered = filtersElim.apply(matchesList, mockNow);
      expect(filtered.length, 2);
    });

    test('should filter by tomorrow status correctly', () {
      const filters = FilterState(status: 'tomorrow');
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 1);
      expect(filtered.first.id, 'M002');
    });

    test('should filter by next3days status correctly (Option B)', () {
      const filters = FilterState(status: 'next3days');
      final filtered = filters.apply(matchesList, mockNow);
      expect(filtered.length, 3);
      expect(filtered.any((m) => m.id == 'M001'), true);
      expect(filtered.any((m) => m.id == 'M002'), true);
      expect(filtered.any((m) => m.id == 'M003'), true);
      expect(filtered.any((m) => m.id == 'M004'), false);
    });

    test('should report active filters correctly', () {
      const filtersDefault = FilterState();
      expect(filtersDefault.hasActiveFilters, false);

      const filtersActive = FilterState(hostCountry: 'USA');
      expect(filtersActive.hasActiveFilters, true);
    });

    test('should filter by results filter correctly', () {
      final withResult = match1.copyWith(
        homeScore: 2,
        awayScore: 1,
        resultStatus: MatchResultStatus.completed,
      );
      final withoutResult = match2;
      final testMatches = [withResult, withoutResult];

      const filterWith = FilterState(resultsFilter: 'with_result');
      expect(filterWith.apply(testMatches, mockNow).length, 1);
      expect(filterWith.apply(testMatches, mockNow).first.id, 'M001');

      const filterWithout = FilterState(resultsFilter: 'without_result');
      expect(filterWithout.apply(testMatches, mockNow).length, 1);
      expect(filterWithout.apply(testMatches, mockNow).first.id, 'M002');
    });
  });

  group('AboutScreen Widget Tests', () {
    testWidgets('AboutScreen should render app title, version, and feature details', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AboutScreen(),
        ),
      );

      expect(find.text('Acerca de la App'), findsOneWidget);
      expect(find.text('World Cup Schedule App'), findsOneWidget);
      expect(find.text('v0.6.0'), findsOneWidget);
      expect(find.text('Personal FIFA World Cup 2026 Match Tracker'), findsOneWidget);
      expect(find.text('Calendario de Partidos'), findsOneWidget);
      expect(find.text('Favoritos Offline'), findsOneWidget);
      expect(find.text('Filtros Avanzados'), findsOneWidget);
      expect(find.text('Estatus en Tiempo Real'), findsOneWidget);
      expect(find.text('Marcadores Offline'), findsOneWidget);
    });
  });

  group('MatchDetailScreen Promo Image Widget Tests', () {
    final fakeMatchRepository = FakeMatchRepository();
    final fakeFlagStyleRepository = FakeFlagStyleRepository();

    final promoMatch = WorldCupMatch(
      id: "M041",
      date: "2026-06-12",
      timeLocal: "18:00",
      timezone: "America/Mexico_City",
      homeTeam: TeamInfo(id: "argentina", fifaCode: "ARG", name: LocalizedText(en: "Argentina", es: "Argentina")),
      awayTeam: TeamInfo(id: "austria", fifaCode: "AUT", name: LocalizedText(en: "Austria", es: "Austria")),
      group: LocalizedEntity(id: "a", name: LocalizedText(en: "Group A", es: "Grupo A")),
      stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
      stadium: LocalizedEntity(id: "estadio_azteca", name: LocalizedText(en: "Estadio Azteca", es: "Estadio Azteca")),
      city: LocalizedEntity(id: "mexico_city", name: LocalizedText(en: "Mexico City", es: "Ciudad de México")),
      country: LocalizedEntity(id: "mexico", name: LocalizedText(en: "Mexico", es: "México")),
      startDateTime: DateTime.parse("2026-06-12T00:00:00Z"),
      estimatedDurationMinutes: 105,
      isFavorite: false,
    );

    final regularMatch = WorldCupMatch(
      id: "M001",
      date: "2026-06-11",
      timeLocal: "18:00",
      timezone: "America/Mexico_City",
      homeTeam: TeamInfo(id: "mexico", fifaCode: "MEX", name: LocalizedText(en: "Mexico", es: "México")),
      awayTeam: TeamInfo(id: "south_africa", fifaCode: "RSA", name: LocalizedText(en: "South Africa", es: "Sudáfrica")),
      group: LocalizedEntity(id: "a", name: LocalizedText(en: "Group A", es: "Grupo A")),
      stage: LocalizedEntity(id: "group_stage", name: LocalizedText(en: "Group Stage", es: "Fase de Grupos")),
      stadium: LocalizedEntity(id: "estadio_azteca", name: LocalizedText(en: "Estadio Azteca", es: "Estadio Azteca")),
      city: LocalizedEntity(id: "mexico_city", name: LocalizedText(en: "Mexico City", es: "Ciudad de México")),
      country: LocalizedEntity(id: "mexico", name: LocalizedText(en: "Mexico", es: "México")),
      startDateTime: DateTime.parse("2026-06-12T00:00:00Z"),
      estimatedDurationMinutes: 105,
      isFavorite: false,
    );

    testWidgets('should render promo image for Argentina vs Austria/Australia match', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MatchDetailScreen(
            match: promoMatch,
            matchRepository: fakeMatchRepository,
            flagStyleRepository: fakeFlagStyleRepository,
            onFavoriteToggled: () {},
          ),
        ),
      );

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);
      final Image image = tester.widget(imageFinder);
      final AssetImage assetImage = image.image as AssetImage;
      expect(assetImage.assetName, 'assets/icons/match_promo.jpg');
    });

    testWidgets('should not render promo image for regular matches', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: MatchDetailScreen(
            match: regularMatch,
            matchRepository: fakeMatchRepository,
            flagStyleRepository: fakeFlagStyleRepository,
            onFavoriteToggled: () {},
          ),
        ),
      );

      expect(find.byType(Image), findsNothing);
    });
  });

  group('MatchResultService Settings Tests', () {
    test('should return false by default and true after calling setSubscriptionPopupShown', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final service = MatchResultService(prefs);

      expect(service.isSubscriptionPopupShown(), isFalse);
      await service.setSubscriptionPopupShown();
      expect(service.isSubscriptionPopupShown(), isTrue);
    });
  });
}

class FakeMatchRepository implements MatchRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeFlagStyleRepository implements FlagStyleRepository {
  @override
  FlagStyle? getFlagStyle(String teamName) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
