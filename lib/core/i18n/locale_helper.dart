import 'package:flutter/material.dart';

class LocaleHelper {
  static String supportedLanguageCode(BuildContext context) {
    try {
      final locale = Localizations.localeOf(context);
      final languageCode = locale.languageCode;

      if (languageCode == 'es') return 'es';
      if (languageCode == 'en') return 'en';
    } catch (_) {
      // Fallback in case of exceptions or uninitialized localization context
    }
    return 'en';
  }
}
