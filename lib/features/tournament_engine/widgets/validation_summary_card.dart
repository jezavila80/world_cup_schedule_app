import 'package:flutter/material.dart';
import '../../../../core/i18n/app_translations.dart';
import '../models/tournament_validation_result.dart';
import '../../standings/models/group_standing.dart';
import '../../knockout/models/knockout_qualification_result.dart';
import '../../knockout/models/knockout_match_slot.dart';

class ValidationSummaryCard extends StatelessWidget {
  final Map<String, List<GroupStanding>> groupStandings;
  final KnockoutQualificationResult qualificationResult;
  final List<KnockoutMatchSlot> bracketSlots;
  final TournamentValidationResult validationResult;
  final String lang;

  const ValidationSummaryCard({
    super.key,
    required this.groupStandings,
    required this.qualificationResult,
    required this.bracketSlots,
    required this.validationResult,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    // Counts
    final groupsCount = groupStandings.keys.length;
    final winnersCount = qualificationResult.groupWinners.length;
    final runnersUpCount = qualificationResult.groupRunnersUp.length;
    
    // Count third places from standings
    int thirdPlacesCount = 0;
    groupStandings.values.forEach((list) {
      if (list.length > 2) thirdPlacesCount++;
    });

    final bestThirdsCount = qualificationResult.bestThirdPlacedTeams.length;
    final qualifiedCount = qualificationResult.allQualifiedTeams.length;
    
    // Calculate total eliminated teams
    // 1. 4th places of complete groups
    int fourthPlacesCount = 0;
    groupStandings.values.forEach((list) {
      if (list.length > 3) fourthPlacesCount++;
    });
    // 2. Eliminated third places
    final eliminatedThirdsCount = qualificationResult.eliminatedThirdPlacedTeams.length;
    final totalEliminated = fourthPlacesCount + eliminatedThirdsCount;

    final bracketCount = bracketSlots.length;

    // Check duplicates: we can search the validation issues for duplicates, or compute directly
    final Set<String> allTeamIds = {};
    int duplicateTeamsCount = 0;
    for (var t in qualificationResult.allQualifiedTeams) {
      if (allTeamIds.contains(t.team.id)) {
        duplicateTeamsCount++;
      }
      allTeamIds.add(t.team.id);
    }

    return Card(
      color: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.translate('tournamentValidation', lang).toUpperCase(),
              style: const TextStyle(
                color: Color(0xFF00FF87),
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              label: AppTranslations.translate('groupsDetected', lang),
              value: '$groupsCount',
              expected: '12',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('groupWinners', lang),
              value: '$winnersCount',
              expected: '12',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('groupRunnersUp', lang),
              value: '$runnersUpCount',
              expected: '12',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('thirdPlaces', lang),
              value: '$thirdPlacesCount',
              expected: '12',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('bestThirds', lang),
              value: '$bestThirdsCount',
              expected: '8',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('qualifiedTeams', lang),
              value: '$qualifiedCount',
              expected: '32',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('eliminatedTeams', lang),
              value: '$totalEliminated',
              expected: '16',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('duplicateTeams', lang),
              value: '$duplicateTeamsCount',
              expected: '0',
            ),
            _buildSummaryRow(
              label: AppTranslations.translate('bracketSlots', lang),
              value: '$bracketCount',
              expected: '16',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
    required String expected,
  }) {
    final bool isCorrect = value == expected;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(
                color: isCorrect ? Colors.white : Colors.redAccent,
                fontSize: 13,
                fontWeight: isCorrect ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
          if (!isCorrect)
            Text(
              lang == 'es' ? 'Esperado $expected, encontrado $value' : 'Expected $expected, found $value',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }
}
