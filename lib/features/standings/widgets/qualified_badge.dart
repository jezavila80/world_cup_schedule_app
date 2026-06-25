import 'package:flutter/material.dart';
import '../../../core/i18n/app_translations.dart';

class QualifiedBadge extends StatelessWidget {
  final String lang;

  const QualifiedBadge({
    super.key,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF00FF87).withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF00FF87).withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: Text(
        AppTranslations.translate('qualifiedBadge', lang),
        style: const TextStyle(
          color: Color(0xFF00FF87),
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
