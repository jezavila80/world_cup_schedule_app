# Implementation Plan: Tournament Engine Validation (v0.8.1)

Implement an internal validation engine for tournament statistics (standings, qualified teams, best thirds, bracket slots, and match scores) to ensure mathematical and logical correctness. Add a debug validation dashboard and upgrade the Winners list display with detailed points/goal differences and status badges.

## User Review Required

> [!NOTE]
> The validation dashboard will be accessible via a debug tile in the `SettingsScreen` labeled "Tournament Validation" / "Validación del Torneo".

> [!IMPORTANT]
> A new shared `StandingSortService` will unify sorting logic across standings, winners, best thirds, and the qualification and validation engines.

---

## Proposed Changes

### Component: Tournament Engine Validation Model & Service

#### [NEW] [validation_severity.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/models/validation_severity.dart)
Enum for severity levels:
```dart
enum ValidationSeverity {
  info,
  warning,
  error,
}
```

#### [NEW] [validation_check.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/models/validation_check.dart)
Represents a high-level test category validation:
```dart
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
```

#### [NEW] [validation_issue.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/models/validation_issue.dart)
Represents a specific validation failure or warning:
```dart
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
```

#### [NEW] [tournament_validation_result.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/models/tournament_validation_result.dart)
Wraps overall validation state:
```dart
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
```

#### [NEW] [standing_sort_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/services/standing_sort_service.dart)
Unifies group and third-place sorting:
* Criterios: Puntos -> Diferencia de Goles -> Goles a Favor -> Nombre de Selección (en inglés, A-Z).

#### [NEW] [tournament_validation_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/services/tournament_validation_service.dart)
Core business rules engine checking:
* **Standings Rules**: `played == wins + draws + losses`, `goalDifference == goalsFor - goalsAgainst`, `points == (wins * 3) + draws`, exactly 4 teams per completed group, maximum 4 teams per group, unique teams.
* **Match Results**: completed match scores $\ge 0$ and non-null, pending matches do not affect standings.
* **Groups Completeness**: group finished status, transition of qualification badge status.
* **Automatic Qualifiers**: when all groups completed, checks counts (12 winners, 12 runners-up, 8 best thirds, 4 eliminated thirds, 32 qualified, 16 eliminated, 48 total evaluated). No duplicates, no overlap between qualified & eliminated.
* **Best Thirds**: ranking sorted properly, best 8 selected, other 4 eliminated.
* **Bracket**: 16 slots with expected numbers (73 to 88), correct mapping to group outcomes.

---

### Component: Tournament Validation UI Dashboard

#### [NEW] [validation_check_tile.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/widgets/validation_check_tile.dart)
A widget showing check title, status (Passed/Failed), and icon (green check / red error).

#### [NEW] [validation_issue_tile.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/widgets/validation_issue_tile.dart)
A widget showing issue description, details, and color indicator based on severity (red error, yellow warning, blue info).

#### [NEW] [validation_summary_card.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/widgets/validation_summary_card.dart)
Summary of detected stats (Groups: 12, Winners: 12, Runners-up: 12, Qualified: 32, etc.) using icons.

#### [NEW] [tournament_validation_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/tournament_engine/screens/tournament_validation_screen.dart)
The dashboard UI combining validation results, summary statistics, checks list, and specific issues.

---

### Component: Standings, Knockout & Settings Refactoring

#### [MODIFY] [group_standings_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/standings/services/group_standings_service.dart)
Refactor sorting logic to delegate to the new `StandingSortService`.

#### [MODIFY] [knockout_qualification_service.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/services/knockout_qualification_service.dart)
Refactor sorting logic to delegate to `StandingSortService`.

#### [MODIFY] [best_third_places_section.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/best_third_places_section.dart)
Refactor sorting logic to delegate to `StandingSortService`.

#### [MODIFY] [qualified_teams_section.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/knockout/widgets/qualified_teams_section.dart) (Winners Section UI)
* Update team rows to display: `<position> <flag> <name> <points> pts (<goals difference>)` (e.g. `1° 🇲🇽 México 7 pts (+5)`)
* Render the qualification badge with states `Qualified` / `Clasificado` or `Pending` / `Pendiente` depending on whether the group matches are complete (6 completed matches).

#### [MODIFY] [settings_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/settings/screens/settings_screen.dart)
* Add constructor parameters for `MatchRepository` and `FlagStyleRepository`.
* Add a debug/admin section tile for "Tournament Validation" that navigates to `TournamentValidationScreen`.

#### [MODIFY] [match_list_screen.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/lib/features/matches/screens/match_list_screen.dart)
Pass `matchRepository` and `flagStyleRepository` instances into the `SettingsScreen` constructor.

#### [MODIFY] [app_translations.json](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/assets/data/app_translations.json)
Add translation keys for validation dashboard strings and status indicators in both Spanish and English.

---

### Component: Version & Metadata Updates

#### [MODIFY] [pubspec.yaml](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/pubspec.yaml)
Maintain version `0.8.1` as required.

#### [MODIFY] [README.md](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/README.md)
Document `v0.8.1 - Tournament Engine Validation` features under version history.

---

## Verification Plan

### Automated Tests

#### [NEW] [tournament_validation_service_test.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/test/features/tournament_engine/tournament_validation_service_test.dart)
Unit tests covering the 17 cases specified:
1. `played == wins + draws + losses`.
2. `goalDifference == goalsFor - goalsAgainst`.
3. `points == wins * 3 + draws`.
4. Detects null score in completed match.
5. Detects negative score.
6. Detects incomplete group.
7. Detects complete group with 6 matches.
8. Detects duplicate winners.
9. Detects team qualified & eliminated simultaneously.
10. Validates 12 winners when groups complete.
11. Validates 12 runners-up.
12. Validates 8 best thirds.
13. Validates 4 eliminated thirds.
14. Validates 32 qualified teams.
15. Validates 16 eliminated teams.
16. Validates 16 bracket slots.
17. Validates match numbers 73 to 88.

#### [NEW] [winners_section_test.dart](file:///d:/Users/jezavila80/MisDocumentos/local/antigravity-projects-ai/world_cup_schedule_app/test/features/knockout/winners_section_test.dart)
Widget tests covering:
1. Display of points.
2. Positive GD formatting (`+5`).
3. Zero GD formatting (`+0`).
4. Negative GD formatting (`-2`).
5. `Pending` / `Pendiente` badge for incomplete groups.
6. `Qualified` / `Clasificado` badge for complete groups.

### Running Test Command
```powershell
flutter test
```
