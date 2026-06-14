import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/storage/favorites_storage.dart';
import 'core/i18n/app_translations.dart';
import 'features/matches/data/match_local_data_source.dart';
import 'features/matches/data/match_repository.dart';
import 'features/matches/data/flag_style_repository.dart';
import 'features/matches/services/match_result_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences for persistence
  final prefs = await SharedPreferences.getInstance();
  final favoritesStorage = FavoritesStorage(prefs);
  final matchResultService = MatchResultService(prefs);

  // Initialize Data Sources and Repository
  final localDataSource = MatchLocalDataSource();
  final matchRepository = MatchRepository(
    localDataSource: localDataSource,
    favoritesStorage: favoritesStorage,
    resultService: matchResultService,
  );

  // Initialize and preload Flag Styles
  final flagStyleRepository = FlagStyleRepository();
  await flagStyleRepository.load();

  // Initialize and preload translations
  await AppTranslations.load();

  runApp(
    WorldCupApp(
      matchRepository: matchRepository,
      flagStyleRepository: flagStyleRepository,
    ),
  );
}
