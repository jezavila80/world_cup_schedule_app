# Implementation Plan: Language Settings Preference (v0.7.5-like implementation, version number unchanged)

Allow users to select their preferred language (System, Spanish, English) manually in the application settings. The preference will be stored locally via `SharedPreferences` for offline use and will update the application language dynamically without restarting.

## User Review Required

> [!NOTE]
> The app version in `pubspec.yaml` and the UI should remain as `v0.8.1` as requested, but a note will be added in `README.md` under the version history / roadmap detailing the addition of the language settings preference.

> [!IMPORTANT]
> The settings option will be accessible via a dedicated Settings Gear icon (`Icons.settings`) in the `MatchListScreen` header, next to the trophy icon.

## Proposed Changes

### Configuration & Architecture

#### [NEW] [app_language.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/settings/app_language.dart)
Define the `AppLanguage` enum:
```dart
enum AppLanguage {
  system,
  english,
  spanish,
}
```

#### [NEW] [language_settings_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/settings/language_settings_service.dart)
Implement the persistence layer using `SharedPreferences`:
* Load and save options: `'system'`, `'en'`, `'es'`.
* Fallback to `AppLanguage.system` on errors or invalid values.

#### [NEW] [locale_controller.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/core/settings/locale_controller.dart)
Manage the reactive state of the current locale:
* Map `AppLanguage.system` to `null` (delegates resolution to system locale).
* Map `AppLanguage.english` to `Locale('en')`.
* Map `AppLanguage.spanish` to `Locale('es')`.
* Notify listeners on language changes.

---

### Core & Localization Integration

#### [MODIFY] [app_translations.json](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/assets/data/app_translations.json)
Add translation keys for Settings UI labels:
* `settings`: `{"en": "Settings", "es": "Configuración"}`
* `language`: `{"en": "Language", "es": "Idioma"}`
* `system`: `{"en": "System", "es": "Sistema"}`
* `spanish`: `{"en": "Spanish", "es": "Español"}`
* `english`: `{"en": "English", "es": "English"}`
* `languageSectionTitle`: `{"en": "LANGUAGE", "es": "IDIOMA"}`

#### [MODIFY] [app.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/app.dart)
* Accept `LocaleController` in the constructor or wrap the `MaterialApp` in a `ListenableBuilder` (using the `LocaleController` instance).
* Configure `locale: localeController.appLocale` and retain all `supportedLocales`, `localizationsDelegates`, and `localeResolutionCallback` logic.

#### [MODIFY] [main.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/main.dart)
* Initialize `LanguageSettingsService` with the shared `SharedPreferences` instance.
* Initialize `LocaleController`, load the saved language, and pass it to `WorldCupApp`.

---

### User Interface & Navigation

#### [NEW] [settings_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/settings/screens/settings_screen.dart)
* Build the `SettingsScreen` UI in deep night dark mode style.
* Implement a list of `RadioListTile<AppLanguage>` options to choose between System, Spanish, and English.
* Triggers `localeController.changeLanguage(newValue)` on tap.

#### [MODIFY] [match_list_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/matches/screens/match_list_screen.dart)
* Inject `LocaleController` to access current language values or listen to updates.
* Add a gear icon in `_buildHeader` next to the trophy. Tapping the gear icon navigates to `SettingsScreen`.

---

### Documentation

#### [MODIFY] [README.md](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/README.md)
Document the language selection feature under the version roadmap history.

---

## Verification Plan

### Automated Tests
* Create unit/widget tests in `test/features/settings/language_settings_test.dart` to cover:
  1. `LanguageSettingsService` returns `system` if no preference is saved.
  2. `LanguageSettingsService` saves `english`, `spanish`, and `system` properly.
  3. `LanguageSettingsService` falls back to `system` on invalid stored string.
  4. `LocaleController.appLocale` outputs correctly (`null` for system, `Locale('en')` for English, `Locale('es')` for Spanish).
  5. `LocaleController` notifies its listeners on language changes.
* Run all unit and widget tests:
  ```powershell
  flutter test
  ```

### Manual Verification
1. Open the app on a device or emulator.
2. Verify the language matches the system locale.
3. Open the header settings gear.
4. Select English or Spanish manually.
5. Verify the entire application updates its labels instantly.
6. Force close the app and reopen it. Verify the chosen language is persisted.
7. Reset to System and verify it follows the device settings.
