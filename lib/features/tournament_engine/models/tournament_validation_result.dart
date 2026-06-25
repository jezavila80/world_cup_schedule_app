import 'validation_check.dart';
import 'validation_issue.dart';

class TournamentValidationResult {
  final bool isValid;
  final List<ValidationCheck> checks;
  final List<ValidationIssue> issues;

  TournamentValidationResult({
    required this.isValid,
    required this.checks,
    required this.issues,
  });
}
