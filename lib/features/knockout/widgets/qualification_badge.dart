import 'package:flutter/material.dart';
import '../../../core/i18n/app_translations.dart';

class QualificationBadge extends StatelessWidget {
  final String status; // 'qualified', 'best_third', 'eliminated', 'pending'
  final String lang;

  const QualificationBadge({
    super.key,
    required this.status,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    String translationKey;

    switch (status) {
      case 'qualified':
        color = const Color(0xFF00FF87);
        translationKey = 'qualifiedStatus';
        break;
      case 'best_third':
        color = const Color(0xFF00FF87);
        translationKey = 'bestThirdStatus';
        break;
      case 'eliminated':
        color = const Color(0xFFFF4D4D);
        translationKey = 'eliminatedStatus';
        break;
      case 'pending':
      default:
        color = const Color(0xFF94A3B8);
        translationKey = 'pendingStatus';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 0.8,
        ),
      ),
      child: Text(
        AppTranslations.translate(translationKey, lang),
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
