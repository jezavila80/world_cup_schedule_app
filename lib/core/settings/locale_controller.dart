import 'package:flutter/material.dart';
import 'app_language.dart';
import 'language_settings_service.dart';

class LocaleController extends ChangeNotifier {
  final LanguageSettingsService languageSettingsService;

  LocaleController(this.languageSettingsService);

  AppLanguage _selectedLanguage = AppLanguage.system;

  AppLanguage get selectedLanguage => _selectedLanguage;

  Locale? get appLocale {
    switch (_selectedLanguage) {
      case AppLanguage.system:
        return null;
      case AppLanguage.english:
        return const Locale('en');
      case AppLanguage.spanish:
        return const Locale('es');
    }
  }

  Future<void> loadSavedLanguage() async {
    _selectedLanguage = await languageSettingsService.getSavedLanguage();
    notifyListeners();
  }

  Future<void> changeLanguage(AppLanguage language) async {
    if (_selectedLanguage == language) return;
    _selectedLanguage = language;
    await languageSettingsService.saveLanguage(language);
    notifyListeners();
  }
}
