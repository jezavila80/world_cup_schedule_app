import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/storage/favorites_storage.dart';
import 'core/i18n/app_translations.dart';
import 'features/matches/data/match_local_data_source.dart';
import 'features/matches/data/match_repository.dart';
import 'features/matches/data/flag_style_repository.dart';
import 'features/matches/services/match_result_service.dart';
import 'core/settings/language_settings_service.dart';
import 'core/settings/locale_controller.dart';
import 'core/app_info/app_info.dart';
import 'core/app_info/app_version_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Display errors on screen instead of a gray screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 50),
                const SizedBox(height: 16),
                const Text(
                  'Error de Renderizado (UI Crash)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: SingleChildScrollView(
                      child: Text(
                        '${details.exception}\n\n${details.stack}',
                        style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontFamily: 'monospace'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  // Initialize SharedPreferences for persistence
  final prefs = await SharedPreferences.getInstance();
  final favoritesStorage = FavoritesStorage(prefs);
  final matchResultService = MatchResultService(prefs);
  final languageSettingsService = LanguageSettingsService(prefs);
  final localeController = LocaleController(languageSettingsService);
  await localeController.loadSavedLanguage();

  // Initialize AppVersionService and preload/cache AppInfo
  final appVersionService = AppVersionService();
  await appVersionService.initialize();
  final appInfo = appVersionService.getAppInfoSync();

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
      localeController: localeController,
      appInfo: appInfo,
    ),
  );
}
