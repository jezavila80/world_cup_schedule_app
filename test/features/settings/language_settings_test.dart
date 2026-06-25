import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:world_cup_schedule_app/core/settings/app_language.dart';
import 'package:world_cup_schedule_app/core/settings/language_settings_service.dart';
import 'package:world_cup_schedule_app/core/settings/locale_controller.dart';

void main() {
  group('LanguageSettingsService Tests', () {
    late SharedPreferences prefs;
    late LanguageSettingsService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = LanguageSettingsService(prefs);
    });

    test('1. Retorna system si no hay preferencia guardada', () async {
      final lang = await service.getSavedLanguage();
      expect(lang, AppLanguage.system);
    });

    test('2. Guarda english correctamente', () async {
      await service.saveLanguage(AppLanguage.english);
      final lang = await service.getSavedLanguage();
      expect(lang, AppLanguage.english);
      expect(prefs.getString(appLanguagePreferenceKey), 'en');
    });

    test('3. Guarda spanish correctamente', () async {
      await service.saveLanguage(AppLanguage.spanish);
      final lang = await service.getSavedLanguage();
      expect(lang, AppLanguage.spanish);
      expect(prefs.getString(appLanguagePreferenceKey), 'es');
    });

    test('4. Guarda system correctamente', () async {
      await service.saveLanguage(AppLanguage.system);
      final lang = await service.getSavedLanguage();
      expect(lang, AppLanguage.system);
      expect(prefs.getString(appLanguagePreferenceKey), 'system');
    });

    test('5. Retorna system si encuentra valor inválido', () async {
      await prefs.setString(appLanguagePreferenceKey, 'invalid_language');
      final lang = await service.getSavedLanguage();
      expect(lang, AppLanguage.system);
    });
  });

  group('LocaleController Tests', () {
    late SharedPreferences prefs;
    late LanguageSettingsService service;
    late LocaleController controller;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      service = LanguageSettingsService(prefs);
      controller = LocaleController(service);
    });

    test('1. appLocale es null cuando selectedLanguage es system', () {
      expect(controller.selectedLanguage, AppLanguage.system);
      expect(controller.appLocale, isNull);
    });

    test('2. appLocale es Locale("en") cuando selectedLanguage es english', () async {
      await controller.changeLanguage(AppLanguage.english);
      expect(controller.selectedLanguage, AppLanguage.english);
      expect(controller.appLocale, const Locale('en'));
    });

    test('3. appLocale es Locale("es") cuando selectedLanguage es spanish', () async {
      await controller.changeLanguage(AppLanguage.spanish);
      expect(controller.selectedLanguage, AppLanguage.spanish);
      expect(controller.appLocale, const Locale('es'));
    });

    test('4. Notifica cambios al cambiar idioma', () async {
      var listenerCalledCount = 0;
      controller.addListener(() {
        listenerCalledCount++;
      });

      await controller.changeLanguage(AppLanguage.spanish);
      expect(listenerCalledCount, 1);

      // Changing to the same language should not notify again
      await controller.changeLanguage(AppLanguage.spanish);
      expect(listenerCalledCount, 1);

      await controller.changeLanguage(AppLanguage.system);
      expect(listenerCalledCount, 2);
    });
  });
}
