import 'package:flutter/material.dart';
import '../../standings/models/group_standing.dart';
import '../../matches/widgets/flag_circle_avatar.dart';
import '../../matches/data/flag_style_repository.dart';
import '../models/knockout_qualification_result.dart';
import '../services/knockout_qualification_service.dart';
import 'qualification_badge.dart';
import '../../../core/i18n/app_translations.dart';
import '../../tournament_engine/services/standing_sort_service.dart';

class BestThirdPlacesSection extends StatelessWidget {
  final Map<String, List<GroupStanding>> groupStandings;
  final KnockoutQualificationResult qualificationResult;
  final FlagStyleRepository flagStyleRepository;
  final String lang;

  const BestThirdPlacesSection({
    super.key,
    required this.groupStandings,
    required this.qualificationResult,
    required this.flagStyleRepository,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qualificationService = KnockoutQualificationService();
    final sortService = StandingSortService();

    // Extract all third places from standings
    final List<GroupStanding> rawThirds = [];
    groupStandings.forEach((groupId, standingsList) {
      if (standingsList.length > 2) {
        rawThirds.add(standingsList[2]);
      }
    });

    final List<GroupStanding> thirds = sortService.sortThirdPlaces(rawThirds);

    final allGroupsComplete = qualificationService.areAllGroupsComplete(groupStandings);

    final headerStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w800,
      color: Colors.white.withOpacity(0.5),
      letterSpacing: 0.5,
    );

    return Column(
      children: [
        // Helper notification banner if incomplete
        if (!allGroupsComplete)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFD700).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFFFD700).withOpacity(0.3),
                width: 0.8,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Color(0xFFFFD700), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    lang == 'es'
                        ? 'El ranking final se resolverá cuando los 12 grupos completen sus partidos.'
                        : 'The final ranking will be resolved once all 12 groups complete their matches.',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Table Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              SizedBox(width: 24, child: Text('#', style: headerStyle)),
              Expanded(child: Text(AppTranslations.translate('team', lang).toUpperCase(), style: headerStyle)),
              SizedBox(width: 32, child: Center(child: Text(AppTranslations.translate('pointsAbbr', lang), style: headerStyle))),
              SizedBox(width: 32, child: Center(child: Text(AppTranslations.translate('goalDiffAbbr', lang), style: headerStyle))),
              SizedBox(width: 32, child: Center(child: Text(AppTranslations.translate('goalsForAbbr', lang), style: headerStyle))),
              const SizedBox(width: 85), // Spacer for badge
            ],
          ),
        ),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: thirds.length,
            itemBuilder: (context, index) {
              final standing = thirds[index];
              final position = index + 1;

              String status;
              if (!allGroupsComplete) {
                status = 'pending';
              } else {
                status = position <= 8 ? 'best_third' : 'eliminated';
              }

              final flagStyle = flagStyleRepository.getFlagStyle(standing.team.name.en);
              final teamName = lang == 'es' ? standing.team.name.es : standing.team.name.en;
              final groupLetter = standing.groupId.toUpperCase().replaceAll('GROUP_', '');

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Color(0xFF1E294B),
                      width: 0.5,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Position
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$position',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: status == 'best_third'
                              ? const Color(0xFF00FF87)
                              : Colors.white70,
                        ),
                      ),
                    ),
                    // Flag and name
                    Expanded(
                      child: Row(
                        children: [
                          FlagCircleAvatar(
                            teamName: standing.team.name.en,
                            flagStyle: flagStyle,
                            size: 20,
                            borderWidth: 0.8,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  teamName,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${AppTranslations.translate('group', lang)} $groupLetter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.white.withOpacity(0.4),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Pts
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '${standing.points}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF00FF87),
                          ),
                        ),
                      ),
                    ),
                    // DG
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          standing.goalDifference >= 0
                              ? '+${standing.goalDifference}'
                              : '${standing.goalDifference}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: standing.goalDifference > 0
                                ? const Color(0xFF00FF87)
                                : standing.goalDifference < 0
                                    ? const Color(0xFFFF4D4D)
                                    : Colors.white54,
                          ),
                        ),
                      ),
                    ),
                    // GF
                    SizedBox(
                      width: 32,
                      child: Center(
                        child: Text(
                          '${standing.goalsFor}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    SizedBox(
                      width: 77,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: QualificationBadge(status: status, lang: lang),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
