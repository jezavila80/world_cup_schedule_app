import 'package:flutter/material.dart';
import '../models/validation_issue.dart';
import '../models/validation_severity.dart';
import '../../../../core/i18n/app_translations.dart';

class ValidationIssueTile extends StatelessWidget {
  final ValidationIssue issue;
  final String lang;

  const ValidationIssueTile({
    super.key,
    required this.issue,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final messageText = lang == 'es' ? issue.message.es : issue.message.en;

    Color severityColor;
    IconData severityIcon;
    String severityLabel;

    switch (issue.severity) {
      case ValidationSeverity.error:
        severityColor = Colors.red;
        severityIcon = Icons.cancel;
        severityLabel = AppTranslations.translate('validationError', lang);
        break;
      case ValidationSeverity.warning:
        severityColor = Colors.orange;
        severityIcon = Icons.warning;
        severityLabel = AppTranslations.translate('validationWarning', lang);
        break;
      case ValidationSeverity.info:
        severityColor = Colors.blue;
        severityIcon = Icons.info;
        severityLabel = 'INFO';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          severityIcon,
          color: severityColor,
        ),
        title: Text(
          messageText,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
        subtitle: issue.details != null
            ? Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  issue.details!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              )
            : null,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            severityLabel.toUpperCase(),
            style: TextStyle(
              color: severityColor,
              fontWeight: FontWeight.bold,
              fontSize: 9,
            ),
          ),
        ),
      ),
    );
  }
}
