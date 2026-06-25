import '../../../core/i18n/localized_text.dart';
import 'validation_severity.dart';

class ValidationIssue {
  final String id;
  final ValidationSeverity severity;
  final LocalizedText message;
  final String? details;

  ValidationIssue({
    required this.id,
    required this.severity,
    required this.message,
    this.details,
  });
}
