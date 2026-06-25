import 'package:flutter/material.dart';

class LocaleHelper {
  static String supportedLanguageCode(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;

    if (languageCode == 'es') return 'es';
    if (languageCode == 'en') return 'en';

    return 'en';
  }
}
