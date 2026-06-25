import 'package:flutter/material.dart';
import '../services/group_standings_service.dart';
import '../widgets/group_standings_card.dart';
import '../../matches/models/world_cup_match.dart';
import '../../matches/models/match_result_status.dart';
import '../../matches/data/flag_style_repository.dart';
import '../../../core/i18n/app_translations.dart';
import '../../knockout/services/knockout_qualification_service.dart';
import '../../../core/widgets/world_cup_header.dart';

class GroupStandingsDashboardScreen extends StatelessWidget {
  final List<WorldCupMatch> matches;
  final FlagStyleRepository flagStyleRepository;
  final String lang;
  final Future<void> Function() onRefresh;

  const GroupStandingsDashboardScreen({
    super.key,
    required this.matches,
    required this.flagStyleRepository,
    required this.lang,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final standingsService = GroupStandingsService();
    final standingsMap = standingsService.calculateStandings(matches);

    final qualificationService = KnockoutQualificationService();
    final qualificationResult = qualificationService.calculateQualifiedTeams(standingsMap);

    // Check if there are any completed group stage matches to calculate standings.
    final hasCompletedMatches = matches.any((m) =>
        m.stage.id == 'group_stage' &&
        m.resultStatus == MatchResultStatus.completed);

    return Column(
      children: [
        // Compact Screen Header
        _buildHeader(theme),

        // Standings Content
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: const Color(0xFF00FF87),
            child: !hasCompletedMatches
                ? _buildEmptyStateWithContext(context, theme)
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: standingsMap.keys.length,
                    itemBuilder: (context, index) {
                      final sortedGroupIds = standingsMap.keys.toList()..sort();
                      final groupId = sortedGroupIds[index];
                      final groupStandings = standingsMap[groupId] ?? [];

                      return GroupStandingsCard(
                        groupId: groupId,
                        standings: groupStandings,
                        lang: lang,
                        flagStyleRepository: flagStyleRepository,
                        groupStandings: standingsMap,
                        qualificationResult: qualificationResult,
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }


  Widget _buildHeader(ThemeData theme) {
    return WorldCupHeader(
      title: AppTranslations.translate('groupStandings', lang),
      showVersion: true,
      showBackButton: false,
    );
  }

  // Helper to obtain build context width/height in stateless widget without context parameter.
  // Actually, we can just use layout builders or pass context, but since this is inside a build method,
  // we can use a Builder or pass context to the helper, which is much cleaner!
  // Let's refactor _buildEmptyState to accept BuildContext!
  Widget _buildEmptyStateWithContext(BuildContext context, ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF151D30),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF1E294B).withOpacity(0.8),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.leaderboard_rounded,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.7),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppTranslations.translate('noStandingsResults', lang),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// Since we have a build context in the build method, we can just call:
// `_buildEmptyStateWithContext(context, theme)` inside `build`! Let's update `build` to use that.
