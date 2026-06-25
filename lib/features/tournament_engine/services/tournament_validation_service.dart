import '../../matches/models/world_cup_match.dart';
import '../../matches/models/match_result_status.dart';
import '../../standings/models/group_standing.dart';
import '../../knockout/models/knockout_qualification_result.dart';
import '../../knockout/models/qualified_team.dart';
import '../../knockout/models/knockout_match_slot.dart';
import '../../knockout/models/qualification_type.dart';
import '../../knockout/services/knockout_qualification_service.dart';
import '../models/tournament_validation_result.dart';
import '../models/validation_check.dart';
import '../models/validation_issue.dart';
import '../models/validation_severity.dart';
import '../../../core/i18n/localized_text.dart';
import 'standing_sort_service.dart';

class TournamentValidationService {
  final StandingSortService _sortService = StandingSortService();
  final KnockoutQualificationService _qualificationService = KnockoutQualificationService();

  TournamentValidationResult validate({
    required List<WorldCupMatch> matches,
    required Map<String, List<GroupStanding>> standingsByGroup,
    required KnockoutQualificationResult qualificationResult,
    required List<KnockoutMatchSlot> bracketSlots,
  }) {
    final List<ValidationCheck> checks = [];
    final List<ValidationIssue> issues = [];

    // --- RULE 1: Standings Arithmetic & Integrity ---
    bool standingsPassed = true;
    standingsByGroup.forEach((groupId, standingsList) {
      // Rule 4: Group must have at most 4 teams
      if (standingsList.length > 4) {
        standingsPassed = false;
        issues.add(ValidationIssue(
          id: 'standing_max_teams_$groupId',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Group $groupId has more than 4 teams.',
            es: 'El Grupo $groupId tiene más de 4 equipos.',
          ),
          details: 'Found ${standingsList.length} teams.',
        ));
      }

      // Check if all 4 teams in the group have completed their 3 matches
      final isGroupFinished = standingsList.length == 4 && standingsList.every((s) => s.played == 3);

      // Rule 5: Group must have exactly 4 teams when complete
      if (isGroupFinished && standingsList.length != 4) {
        standingsPassed = false;
        issues.add(ValidationIssue(
          id: 'standing_complete_count_$groupId',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Group $groupId is complete but does not have exactly 4 teams.',
            es: 'El Grupo $groupId está completo pero no tiene exactamente 4 equipos.',
          ),
          details: 'Found ${standingsList.length} teams.',
        ));
      }

      final Set<String> teamIds = {};
      for (var standing in standingsList) {
        final team = standing.team;
        // Rule 6: Duplicate team check
        if (teamIds.contains(team.id)) {
          standingsPassed = false;
          issues.add(ValidationIssue(
            id: 'standing_duplicate_${team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Team ${team.name.en} appears multiple times in group $groupId.',
              es: 'El equipo ${team.name.es} aparece varias veces en el grupo $groupId.',
            ),
          ));
        }
        teamIds.add(team.id);

        // Rule 1: played == wins + draws + losses
        if (standing.played != (standing.wins + standing.draws + standing.losses)) {
          standingsPassed = false;
          issues.add(ValidationIssue(
            id: 'standing_played_${team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Stat inconsistency: ${team.name.en} played matches (${standing.played}) does not equal wins + draws + losses (${standing.wins} + ${standing.draws} + ${standing.losses}).',
              es: 'Inconsistencia: Partidos jugados de ${team.name.es} (${standing.played}) no es igual a victorias + empates + derrotas (${standing.wins} + ${standing.draws} + ${standing.losses}).',
            ),
          ));
        }

        // Rule 2: goalDifference == goalsFor - goalsAgainst
        if (standing.goalDifference != (standing.goalsFor - standing.goalsAgainst)) {
          standingsPassed = false;
          issues.add(ValidationIssue(
            id: 'standing_gd_${team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Stat inconsistency: ${team.name.en} goal difference (${standing.goalDifference}) does not equal GF - GA (${standing.goalsFor} - ${standing.goalsAgainst}).',
              es: 'Inconsistencia: Diferencia de goles de ${team.name.es} (${standing.goalDifference}) no es igual a GF - GC (${standing.goalsFor} - ${standing.goalsAgainst}).',
            ),
          ));
        }

        // Rule 3: points == wins * 3 + draws
        if (standing.points != (standing.wins * 3 + standing.draws)) {
          standingsPassed = false;
          issues.add(ValidationIssue(
            id: 'standing_points_${team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Stat inconsistency: ${team.name.en} points (${standing.points}) does not equal (wins * 3) + draws (${standing.wins * 3 + standing.draws}).',
              es: 'Inconsistencia: Puntos de ${team.name.es} (${standing.points}) no es igual a (wins * 3) + draws (${standing.wins * 3 + standing.draws}).',
            ),
          ));
        }
      }
    });

    checks.add(ValidationCheck(
      id: 'standings_integrity',
      title: LocalizedText(
        en: 'Standings Rules Check',
        es: 'Verificación de Reglas de Posiciones',
      ),
      passed: standingsPassed,
      details: standingsPassed ? 'All team stats and counts are consistent.' : 'One or more team stats are mathematically incorrect.',
    ));

    // --- RULE 2: Match Results Validation (Fase de grupos) ---
    bool matchesPassed = true;
    final groupStageMatches = matches.where((m) => m.stage.id == 'group_stage').toList();
    for (var match in groupStageMatches) {
      if (match.resultStatus == MatchResultStatus.completed) {
        // Must not be null
        if (match.homeScore == null || match.awayScore == null) {
          matchesPassed = false;
          issues.add(ValidationIssue(
            id: 'match_null_score_${match.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Completed match ${match.id} has null score.',
              es: 'El partido completado ${match.id} tiene marcador nulo.',
            ),
          ));
        } else {
          // Must be >= 0
          if (match.homeScore! < 0 || match.awayScore! < 0) {
            matchesPassed = false;
            issues.add(ValidationIssue(
              id: 'match_negative_score_${match.id}',
              severity: ValidationSeverity.error,
              message: LocalizedText(
                en: 'Completed match ${match.id} has negative score.',
                es: 'El partido completado ${match.id} tiene marcador negativo.',
              ),
              details: '${match.homeTeam.name.en} ${match.homeScore} - ${match.awayScore} ${match.awayTeam.name.en}',
            ));
          }
        }
      } else if (match.resultStatus == MatchResultStatus.pending) {
        // Check that pending matches do not have scores affecting standings
        // Note: GroupStandingsService filters on completed, but we can verify if scores are present in pending
        if (match.homeScore != null || match.awayScore != null) {
          issues.add(ValidationIssue(
            id: 'match_pending_with_score_${match.id}',
            severity: ValidationSeverity.info,
            message: LocalizedText(
              en: 'Pending match ${match.id} has scores defined.',
              es: 'El partido pendiente ${match.id} tiene marcadores definidos.',
            ),
          ));
        }
      }
    }

    checks.add(ValidationCheck(
      id: 'match_results_validity',
      title: LocalizedText(
        en: 'Match Results Validity Check',
        es: 'Verificación de Validez de Resultados',
      ),
      passed: matchesPassed,
      details: matchesPassed ? 'All completed group matches have valid non-negative scores.' : 'Some completed matches have null or negative scores.',
    ));

    // --- RULE 3: Groups Completeness ---
    bool groupCompletenessPassed = true;
    standingsByGroup.forEach((groupId, standingsList) {
      final groupMatches = groupStageMatches.where((m) => m.group.id == groupId).toList();
      final completedCount = groupStageMatches.where((m) => m.group.id == groupId && m.resultStatus == MatchResultStatus.completed).length;

      final isComplete = completedCount == 6;

      if (!isComplete) {
        groupCompletenessPassed = false;
        issues.add(ValidationIssue(
          id: 'group_in_progress_$groupId',
          severity: ValidationSeverity.warning,
          message: LocalizedText(
            en: 'Group $groupId is still in progress.',
            es: 'El Grupo $groupId sigue en juego.',
          ),
          details: '$completedCount/6 matches completed.',
        ));
      }

      // If group is complete (6 matches), verify:
      // - 1st is marked as qualified
      // - 2nd is marked as qualified
      // - 4th is marked as eliminated
      // - 3rd is marked as pending/best_third/eliminated
      if (standingsList.isNotEmpty) {
        final firstId = standingsList[0].team.id;
        final firstStatus = _qualificationService.getTeamQualificationStatus(
          teamId: firstId,
          groupId: groupId,
          groupStandings: standingsByGroup,
          qualificationResult: qualificationResult,
        );

        if (isComplete && firstStatus != 'qualified') {
          groupCompletenessPassed = false;
          issues.add(ValidationIssue(
            id: 'group_first_status_$groupId',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Group $groupId winner status is "$firstStatus", expected "qualified".',
              es: 'El estado del ganador del Grupo $groupId es "$firstStatus", se esperaba "qualified".',
            ),
          ));
        }

        if (standingsList.length > 1) {
          final secondId = standingsList[1].team.id;
          final secondStatus = _qualificationService.getTeamQualificationStatus(
            teamId: secondId,
            groupId: groupId,
            groupStandings: standingsByGroup,
            qualificationResult: qualificationResult,
          );

          if (isComplete && secondStatus != 'qualified') {
            groupCompletenessPassed = false;
            issues.add(ValidationIssue(
              id: 'group_second_status_$groupId',
              severity: ValidationSeverity.error,
              message: LocalizedText(
                en: 'Group $groupId runner-up status is "$secondStatus", expected "qualified".',
                es: 'El estado del subcampeón del Grupo $groupId es "$secondStatus", se esperaba "qualified".',
              ),
            ));
          }
        }

        if (standingsList.length > 2) {
          final thirdId = standingsList[2].team.id;
          final thirdStatus = _qualificationService.getTeamQualificationStatus(
            teamId: thirdId,
            groupId: groupId,
            groupStandings: standingsByGroup,
            qualificationResult: qualificationResult,
          );

          // If not all groups finished, 3rd place must be pending
          final allFinished = _qualificationService.areAllGroupsComplete(standingsByGroup);
          if (isComplete && !allFinished && thirdStatus != 'pending') {
            groupCompletenessPassed = false;
            issues.add(ValidationIssue(
              id: 'group_third_status_$groupId',
              severity: ValidationSeverity.error,
              message: LocalizedText(
                en: 'Group $groupId third place status is "$thirdStatus", expected "pending".',
                es: 'El estado del tercer lugar del Grupo $groupId es "$thirdStatus", se esperaba "pending".',
              ),
            ));
          }
        }

        if (standingsList.length > 3) {
          final fourthId = standingsList[3].team.id;
          final fourthStatus = _qualificationService.getTeamQualificationStatus(
            teamId: fourthId,
            groupId: groupId,
            groupStandings: standingsByGroup,
            qualificationResult: qualificationResult,
          );

          if (isComplete && fourthStatus != 'eliminated') {
            groupCompletenessPassed = false;
            issues.add(ValidationIssue(
              id: 'group_fourth_status_$groupId',
              severity: ValidationSeverity.error,
              message: LocalizedText(
                en: 'Group $groupId fourth place status is "$fourthStatus", expected "eliminated".',
                es: 'El estado del cuarto lugar del Grupo $groupId es "$fourthStatus", se esperaba "eliminated".',
              ),
            ));
          }
        }
      }
    });

    checks.add(ValidationCheck(
      id: 'groups_completeness',
      title: LocalizedText(
        en: 'Groups Completeness Check',
        es: 'Verificación de Grupo Completo',
      ),
      passed: groupCompletenessPassed,
      details: groupCompletenessPassed ? 'All 12 groups are complete.' : 'Some groups are still in progress or have incorrect qualification mappings.',
    ));

    // --- RULE 4: Automatic Qualifiers Validation ---
    bool qualifiersPassed = true;
    final allGroupsComplete = _qualificationService.areAllGroupsComplete(standingsByGroup);

    if (allGroupsComplete) {
      final wCount = qualificationResult.groupWinners.length;
      final rCount = qualificationResult.groupRunnersUp.length;
      final tCount = qualificationResult.bestThirdPlacedTeams.length;
      final etCount = qualificationResult.eliminatedThirdPlacedTeams.length;
      final qCount = qualificationResult.allQualifiedTeams.length;

      if (wCount != 12 || rCount != 12 || tCount != 8 || etCount != 4 || qCount != 32) {
        qualifiersPassed = false;
        issues.add(ValidationIssue(
          id: 'qualifiers_counts',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Incorrect qualifiers count. Expected: 12 winners, 12 runners-up, 8 best thirds, 4 eliminated thirds, 32 total. Found: $wCount, $rCount, $tCount, $etCount, $qCount.',
            es: 'Cantidad de clasificados incorrecta. Esperado: 12 primeros, 12 segundos, 8 mejores terceros, 4 terceros eliminados, 32 en total. Encontrado: $wCount, $rCount, $tCount, $etCount, $qCount.',
          ),
        ));
      }

      // Check for duplicate teams in qualified
      final Set<String> qTeamIds = {};
      for (var qt in qualificationResult.allQualifiedTeams) {
        if (qTeamIds.contains(qt.team.id)) {
          qualifiersPassed = false;
          issues.add(ValidationIssue(
            id: 'duplicate_qualified_${qt.team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Team ${qt.team.name.en} is duplicated in the qualified list.',
              es: 'El equipo ${qt.team.name.es} está duplicado en la lista de clasificados.',
            ),
          ));
        }
        qTeamIds.add(qt.team.id);
      }

      // Build eliminated list (4th place of each group + eliminated third places)
      final List<QualifiedTeam> eliminatedList = [];
      standingsByGroup.forEach((groupId, standingsList) {
        if (standingsList.length > 3) {
          eliminatedList.add(QualifiedTeam(
            team: standingsList[3].team,
            groupId: groupId,
            groupName: standingsList[3].groupName,
            groupPosition: 4,
            standing: standingsList[3],
            qualificationType: QualificationType.bestThirdPlace, // placeholder
          ));
        }
      });
      eliminatedList.addAll(qualificationResult.eliminatedThirdPlacedTeams);

      final Set<String> eTeamIds = {};
      for (var et in eliminatedList) {
        if (eTeamIds.contains(et.team.id)) {
          qualifiersPassed = false;
          issues.add(ValidationIssue(
            id: 'duplicate_eliminated_${et.team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Team ${et.team.name.en} is duplicated in the eliminated list.',
              es: 'El equipo ${et.team.name.es} está duplicado en la lista de eliminados.',
            ),
          ));
        }
        eTeamIds.add(et.team.id);

        // Check if team is both qualified and eliminated
        if (qTeamIds.contains(et.team.id)) {
          qualifiersPassed = false;
          issues.add(ValidationIssue(
            id: 'qualified_and_eliminated_${et.team.id}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Team ${et.team.name.en} is marked as both qualified and eliminated.',
              es: 'El equipo ${et.team.name.es} está marcado como clasificado y eliminado simultáneamente.',
            ),
          ));
        }
      }

      final totalEvaluated = qTeamIds.length + eTeamIds.length;
      if (totalEvaluated != 48) {
        qualifiersPassed = false;
        issues.add(ValidationIssue(
          id: 'total_evaluated_teams',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Expected exactly 48 evaluated teams, found $totalEvaluated.',
            es: 'Se esperaban exactamente 48 equipos evaluados, se encontraron $totalEvaluated.',
          ),
        ));
      }

      final totalEliminated = eTeamIds.length;
      if (totalEliminated != 16) {
        qualifiersPassed = false;
        issues.add(ValidationIssue(
          id: 'total_eliminated_teams',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Expected exactly 16 eliminated teams, found $totalEliminated.',
            es: 'Se esperaban exactamente 16 equipos eliminados, se encontraron $totalEliminated.',
          ),
        ));
      }
    } else {
      issues.add(ValidationIssue(
        id: 'groups_incomplete_for_qualifiers',
        severity: ValidationSeverity.info,
        message: LocalizedText(
          en: 'Qualifiers validation is pending group phase completion.',
          es: 'La validación de clasificados está pendiente de completar la fase de grupos.',
        ),
      ));
    }

    checks.add(ValidationCheck(
      id: 'automatic_qualifiers',
      title: LocalizedText(
        en: 'Automatic Qualifiers Check',
        es: 'Verificación de Clasificados Automáticos',
      ),
      passed: qualifiersPassed,
      details: qualifiersPassed 
          ? (allGroupsComplete ? 'Qualifiers counts and sets are valid.' : 'Groups are still in progress.')
          : 'Qualifiers counts or sets have duplicates, overlap, or size errors.',
    ));

    // --- RULE 5: Best Thirds Validation ---
    bool bestThirdsPassed = true;
    final List<GroupStanding> thirds = [];
    standingsByGroup.forEach((groupId, standingsList) {
      if (standingsList.length > 2) {
        thirds.add(standingsList[2]);
      }
    });

    if (allGroupsComplete) {
      if (thirds.length != 12) {
        bestThirdsPassed = false;
        issues.add(ValidationIssue(
          id: 'best_thirds_count',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Expected exactly 12 third-placed teams, found ${thirds.length}.',
            es: 'Se esperaban exactamente 12 equipos en tercer lugar, se encontraron ${thirds.length}.',
          ),
        ));
      }

      // Check sorting
      final sortedThirds = _sortService.sortThirdPlaces(thirds);
      for (int i = 0; i < thirds.length; i++) {
        if (thirds[i].team.id != sortedThirds[i].team.id) {
          bestThirdsPassed = false;
          issues.add(ValidationIssue(
            id: 'best_thirds_sorting',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Third-placed teams list is not sorted correctly.',
              es: 'La lista de terceros lugares no está ordenada correctamente.',
            ),
          ));
          break;
        }
      }

      // Check top 8 and bottom 4
      final expectedBest8Ids = sortedThirds.take(8).map((s) => s.team.id).toSet();
      final expectedEliminated4Ids = sortedThirds.skip(8).map((s) => s.team.id).toSet();

      final actualBest8Ids = qualificationResult.bestThirdPlacedTeams.map((t) => t.team.id).toSet();
      final actualEliminated4Ids = qualificationResult.eliminatedThirdPlacedTeams.map((t) => t.team.id).toSet();

      if (actualBest8Ids.length != 8 || !actualBest8Ids.every((id) => expectedBest8Ids.contains(id))) {
        bestThirdsPassed = false;
        issues.add(ValidationIssue(
          id: 'best_thirds_top8_selection',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Best thirds selection does not match expected top 8 ranking.',
            es: 'La selección de mejores terceros no coincide con los 8 mejores del ranking.',
          ),
        ));
      }

      if (actualEliminated4Ids.length != 4 || !actualEliminated4Ids.every((id) => expectedEliminated4Ids.contains(id))) {
        bestThirdsPassed = false;
        issues.add(ValidationIssue(
          id: 'best_thirds_bottom4_selection',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Eliminated thirds selection does not match expected bottom 4 ranking.',
            es: 'La selección de terceros eliminados no coincide con los 4 últimos del ranking.',
          ),
        ));
      }
    }

    checks.add(ValidationCheck(
      id: 'best_thirds',
      title: LocalizedText(
        en: 'Best Thirds Check',
        es: 'Verificación de Mejores Terceros',
      ),
      passed: bestThirdsPassed,
      details: bestThirdsPassed
          ? (allGroupsComplete ? 'Best thirds are correctly ranked, selected, and sorted.' : 'Groups are still in progress.')
          : 'Ranking sorting, size, or selections of best third-placed teams contain errors.',
    ));

    // --- RULE 6: Bracket Slots Validation ---
    bool bracketPassed = true;

    // Must have exactly 16 matches of Round of 32
    if (bracketSlots.length != 16) {
      bracketPassed = false;
      issues.add(ValidationIssue(
        id: 'bracket_slots_count',
        severity: ValidationSeverity.error,
        message: LocalizedText(
          en: 'Expected exactly 16 bracket slots for Round of 32, found ${bracketSlots.length}.',
          es: 'Se esperaban exactamente 16 ranuras del bracket para Dieciseisavos, se encontraron ${bracketSlots.length}.',
        ),
      ));
    }

    // Match numbers 73 to 88
    final matchNumbers = bracketSlots.map((s) => s.matchNumber).toList()..sort();
    if (matchNumbers.isEmpty || matchNumbers.first != 73 || matchNumbers.last != 88) {
      bracketPassed = false;
      issues.add(ValidationIssue(
        id: 'bracket_match_numbers',
        severity: ValidationSeverity.error,
        message: LocalizedText(
          en: 'Bracket match numbers are not from 73 to 88.',
          es: 'Los números de partido del bracket no son del 73 al 88.',
        ),
      ));
    }

    // Validate correct slot mappings
    for (var slot in bracketSlots) {
      // Validate slot fields
      if (slot.round.isEmpty || slot.slotA.isEmpty || slot.slotB.isEmpty) {
        bracketPassed = false;
        issues.add(ValidationIssue(
          id: 'bracket_slot_fields_${slot.matchNumber}',
          severity: ValidationSeverity.error,
          message: LocalizedText(
            en: 'Match M${slot.matchNumber} has incomplete slot fields.',
            es: 'El partido M${slot.matchNumber} tiene campos de ranura incompletos.',
          ),
        ));
      }

      // Check slotA Winner Group X
      if (slot.slotA.contains('_winners')) {
        final gId = slot.slotA.replaceAll('_winners', '');
        final standings = standingsByGroup[gId];
        final isComplete = standings != null && standings.length == 4 && standings.every((s) => s.played == 3);
        if (isComplete && slot.teamA != null && slot.teamA!.team.id != standings[0].team.id) {
          bracketPassed = false;
          issues.add(ValidationIssue(
            id: 'bracket_slotA_winner_mismatch_${slot.matchNumber}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Match M${slot.matchNumber} slotA (${slot.slotA}) does not match winner of group $gId.',
              es: 'El partido M${slot.matchNumber} slotA (${slot.slotA}) no coincide con el ganador del grupo $gId.',
            ),
          ));
        }
      }

      // Check slotB Winner Group X
      if (slot.slotB.contains('_winners')) {
        final gId = slot.slotB.replaceAll('_winners', '');
        final standings = standingsByGroup[gId];
        final isComplete = standings != null && standings.length == 4 && standings.every((s) => s.played == 3);
        if (isComplete && slot.teamB != null && slot.teamB!.team.id != standings[0].team.id) {
          bracketPassed = false;
          issues.add(ValidationIssue(
            id: 'bracket_slotB_winner_mismatch_${slot.matchNumber}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Match M${slot.matchNumber} slotB (${slot.slotB}) does not match winner of group $gId.',
              es: 'El partido M${slot.matchNumber} slotB (${slot.slotB}) no coincide con el ganador del grupo $gId.',
            ),
          ));
        }
      }

      // Check slotA Runner-up Group X
      if (slot.slotA.contains('_runners-up')) {
        final gId = slot.slotA.replaceAll('_runners-up', '');
        final standings = standingsByGroup[gId];
        final isComplete = standings != null && standings.length == 4 && standings.every((s) => s.played == 3);
        if (isComplete && slot.teamA != null && slot.teamA!.team.id != standings[1].team.id) {
          bracketPassed = false;
          issues.add(ValidationIssue(
            id: 'bracket_slotA_runner_mismatch_${slot.matchNumber}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Match M${slot.matchNumber} slotA (${slot.slotA}) does not match runner-up of group $gId.',
              es: 'El partido M${slot.matchNumber} slotA (${slot.slotA}) no coincide con el subcampeón del grupo $gId.',
            ),
          ));
        }
      }

      // Check slotB Runner-up Group X
      if (slot.slotB.contains('_runners-up')) {
        final gId = slot.slotB.replaceAll('_runners-up', '');
        final standings = standingsByGroup[gId];
        final isComplete = standings != null && standings.length == 4 && standings.every((s) => s.played == 3);
        if (isComplete && slot.teamB != null && slot.teamB!.team.id != standings[1].team.id) {
          bracketPassed = false;
          issues.add(ValidationIssue(
            id: 'bracket_slotB_runner_mismatch_${slot.matchNumber}',
            severity: ValidationSeverity.error,
            message: LocalizedText(
              en: 'Match M${slot.matchNumber} slotB (${slot.slotB}) does not match runner-up of group $gId.',
              es: 'El partido M${slot.matchNumber} slotB (${slot.slotB}) no coincide con el subcampeón del grupo $gId.',
            ),
          ));
        }
      }
    }

    checks.add(ValidationCheck(
      id: 'bracket_slots',
      title: LocalizedText(
        en: 'Bracket Slots Check',
        es: 'Verificación de Slots del Bracket',
      ),
      passed: bracketPassed,
      details: bracketPassed ? 'All 16 bracket slots are correctly configured and resolved.' : 'One or more bracket slots have invalid sizes, IDs, or team resolutions.',
    ));

    // Determine overall validity (if there are no errors)
    final isValid = !issues.any((iss) => iss.severity == ValidationSeverity.error);

    return TournamentValidationResult(
      isValid: isValid,
      checks: checks,
      issues: issues,
    );
  }
}
