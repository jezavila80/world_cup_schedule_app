import 'package:shared_preferences/shared_preferences.dart';
import 'app_language.dart';

const String appLanguagePreferenceKey = 'app_language_preference';

class LanguageSettingsService {
  final SharedPreferences _prefs;

  LanguageSettingsService(this._prefs);

  Future<AppLanguage> getSavedLanguage() async {
    try {
      final value = _prefs.getString(appLanguagePreferenceKey);
      if (value == null) {
        return AppLanguage.system;
      }
      switch (value) {
        case 'system':
          return AppLanguage.system;
        case 'en':
          return AppLanguage.english;
        case 'es':
          return AppLanguage.spanish;
        default:
          return AppLanguage.system;
      }
    } catch (_) {
      return AppLanguage.system;
    }
  }

  Future<void> saveLanguage(AppLanguage language) async {
    try {
      String value;
      switch (language) {
        case AppLanguage.system:
          value = 'system';
          break;
        case AppLanguage.english:
          value = 'en';
          break;
        case AppLanguage.spanish:
          value = 'es';
          break;
      }
      await _prefs.setString(appLanguagePreferenceKey, value);
    } catch (_) {
      // Fail silently
    }
  }
}
