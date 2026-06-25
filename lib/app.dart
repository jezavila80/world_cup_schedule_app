import 'package:flutter/material.dart';
import 'features/matches/data/match_repository.dart';
import 'features/matches/data/flag_style_repository.dart';
import 'features/matches/screens/match_list_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/settings/locale_controller.dart';
import 'core/app_info/app_info.dart';

class WorldCupApp extends StatelessWidget {
  final MatchRepository matchRepository;
  final FlagStyleRepository flagStyleRepository;
  final LocaleController localeController;
  final AppInfo appInfo;

  const WorldCupApp({
    super.key,
    required this.matchRepository,
    required this.flagStyleRepository,
    required this.localeController,
    required this.appInfo,
  });

  @override
  Widget build(BuildContext context) {
    return AppInfoScope(
      appInfo: appInfo,
      child: ListenableBuilder(
        listenable: localeController,
        builder: (context, _) {
          return MaterialApp(
            locale: localeController.appLocale,
          title: 'FIFA World Cup 2026',
          debugShowCheckedModeBanner: false,
          supportedLocales: const [
            Locale('en'),
            Locale('es'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (locale == null) return const Locale('en');

            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }

            return const Locale('en');
          },
      themeMode: ThemeMode.dark, // Defaulting to an immersive dark mode
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E1A), // Deep stadium night background
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FF87), // Vibrant stadium pitch green
          secondary: Color(0xFFFFD700), // Championship Gold
          surface: Color(0xFF151D30), // Sleek deep slate blue for cards
          error: Color(0xFFFF4D4D),
          onPrimary: Colors.black,
          onSecondary: Colors.black,
          onSurface: Colors.white,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF151D30),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(
              color: const Color(0xFF1E294B).withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0A0E1A),
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF0A0E1A),
          selectedItemColor: Color(0xFF00FF87),
          unselectedItemColor: Color(0xFF64748B),
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          titleSmall: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          bodyMedium: TextStyle(
            color: Color(0xFFCBD5E1), // Light muted gray
            fontSize: 14,
            height: 1.4,
          ),
          bodySmall: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
          ),
        ),
      ),
          home: MatchListScreen(
            matchRepository: matchRepository,
            flagStyleRepository: flagStyleRepository,
            localeController: localeController,
          ),
        );
      },
    ),
  );
}
}
