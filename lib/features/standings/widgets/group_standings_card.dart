import 'package:flutter/material.dart';
import '../models/group_standing.dart';
import 'standings_table.dart';
import '../../matches/data/flag_style_repository.dart';
import '../../knockout/models/knockout_qualification_result.dart';

class GroupStandingsCard extends StatelessWidget {
  final String groupId;
  final List<GroupStanding> standings;
  final String lang;
  final FlagStyleRepository flagStyleRepository;
  final Map<String, List<GroupStanding>> groupStandings;
  final KnockoutQualificationResult qualificationResult;

  const GroupStandingsCard({
    super.key,
    required this.groupId,
    required this.standings,
    required this.lang,
    required this.flagStyleRepository,
    required this.groupStandings,
    required this.qualificationResult,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Resolve group name: e.g. "Group A" / "Grupo A"
    final groupLabel = lang == 'es' ? 'Grupo' : 'Group';
    final groupLetter = groupId.toUpperCase().replaceAll('GROUP_', '');
    final fullGroupTitle = '$groupLabel $groupLetter';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Header Section
            Padding(
              padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 16,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary, // green accent line
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fullGroupTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
            // Standings Table
            StandingsTable(
              standings: standings,
              lang: lang,
              flagStyleRepository: flagStyleRepository,
              groupStandings: groupStandings,
              qualificationResult: qualificationResult,
            ),
          ],
        ),
      ),
    );
  }
}

