import 'package:flutter/material.dart';
import '../models/validation_check.dart';
import '../../../../core/i18n/app_translations.dart';

class ValidationCheckTile extends StatelessWidget {
  final ValidationCheck check;
  final String lang;

  const ValidationCheckTile({
    super.key,
    required this.check,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final titleText = lang == 'es' ? check.title.es : check.title.en;
    final statusText = check.passed
        ? AppTranslations.translate('validationPassed', lang)
        : AppTranslations.translate('validationError', lang);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: check.passed ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          check.passed ? Icons.check_circle_outline : Icons.error_outline,
          color: check.passed ? Colors.green : Colors.red,
        ),
        title: Text(
          titleText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: check.details != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  check.details!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (check.passed ? Colors.green : Colors.red).withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            statusText.toUpperCase(),
            style: TextStyle(
              color: check.passed ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }
}
