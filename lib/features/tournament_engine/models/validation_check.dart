import '../../../core/i18n/localized_text.dart';

class ValidationCheck {
  final String id;
  final LocalizedText title;
  final bool passed;
  final String? details;

  ValidationCheck({
    required this.id,
    required this.title,
    required this.passed,
    this.details,
  });
}
