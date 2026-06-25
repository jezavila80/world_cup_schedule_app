import 'package:flutter/material.dart';
import '../../standings/models/group_standing.dart';
import '../../matches/widgets/flag_circle_avatar.dart';
import '../../matches/data/flag_style_repository.dart';
import '../models/knockout_qualification_result.dart';
import '../services/knockout_qualification_service.dart';
import 'qualification_badge.dart';

class QualifiedTeamsSection extends StatelessWidget {
  final Map<String, List<GroupStanding>> groupStandings;
  final KnockoutQualificationResult qualificationResult;
  final FlagStyleRepository flagStyleRepository;
  final String lang;

  const QualifiedTeamsSection({
    super.key,
    required this.groupStandings,
    required this.qualificationResult,
    required this.flagStyleRepository,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sortedGroupIds = groupStandings.keys.toList()..sort();
    final qualificationService = KnockoutQualificationService();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedGroupIds.length,
      itemBuilder: (context, index) {
        final groupId = sortedGroupIds[index];
        final standings = groupStandings[groupId] ?? [];
        if (standings.isEmpty) return const SizedBox.shrink();

        final groupName = lang == 'es' ? standings[0].groupName.es : standings[0].groupName.en;
        final isGroupComplete = qualificationService.isGroupComplete(standings);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      groupName.toUpperCase(),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: (isGroupComplete ? const Color(0xFF00FF87) : const Color(0xFF94A3B8)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isGroupComplete
                            ? (lang == 'es' ? 'COMPLETO' : 'COMPLETED')
                            : (lang == 'es' ? 'EN JUEGO' : 'IN PROGRESS'),
                        style: TextStyle(
                          color: isGroupComplete ? const Color(0xFF00FF87) : const Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFF1E294B)),
                const SizedBox(height: 12),
                _buildTeamRow(context, standings[0], 1, isGroupComplete ? 'qualified' : 'pending'),
                if (standings.length > 1) ...[
                  const SizedBox(height: 12),
                  _buildTeamRow(context, standings[1], 2, isGroupComplete ? 'qualified' : 'pending'),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTeamRow(BuildContext context, GroupStanding standing, int position, String status) {
    final theme = Theme.of(context);
    final flagStyle = flagStyleRepository.getFlagStyle(standing.team.name.en);
    final teamName = lang == 'es' ? standing.team.name.es : standing.team.name.en;

    final diffSign = standing.goalDifference >= 0 ? '+' : '';
    final diffText = '($diffSign${standing.goalDifference})';
    final ptsText = '${standing.points} pts';

    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            '$position°',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: position == 1 ? theme.colorScheme.primary : Colors.white70,
            ),
          ),
        ),
        FlagCircleAvatar(
          teamName: standing.team.name.en,
          flagStyle: flagStyle,
          size: 24,
          borderWidth: 0.8,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                teamName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$ptsText $diffText',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        QualificationBadge(status: status, lang: lang),
      ],
    );
  }
}
