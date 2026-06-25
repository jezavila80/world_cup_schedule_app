import 'package:flutter/material.dart';
import '../../matches/models/world_cup_match.dart';
import '../../matches/models/match_result_status.dart';
import '../../matches/data/flag_style_repository.dart';
import '../../standings/services/group_standings_service.dart';
import '../services/knockout_qualification_service.dart';
import '../services/knockout_bracket_service.dart';
import '../widgets/qualified_teams_section.dart';
import '../widgets/best_third_places_section.dart';
import '../widgets/knockout_bracket_view.dart';
import '../../../core/i18n/app_translations.dart';
import '../../../core/widgets/world_cup_header.dart';

class KnockoutDashboardScreen extends StatelessWidget {
  final List<WorldCupMatch> matches;
  final FlagStyleRepository flagStyleRepository;
  final String lang;
  final Future<void> Function() onRefresh;

  const KnockoutDashboardScreen({
    super.key,
    required this.matches,
    required this.flagStyleRepository,
    required this.lang,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Calculate standings and knockout results
    final standingsService = GroupStandingsService();
    final groupStandings = standingsService.calculateStandings(matches);

    final qualificationService = KnockoutQualificationService();
    final qualificationResult = qualificationService.calculateQualifiedTeams(groupStandings);

    final bracketService = KnockoutBracketService();
    final bracketSlots = bracketService.calculateBracketSlots(matches, groupStandings);

    // Check if there are any completed group stage matches
    final hasCompletedMatches = matches.any((m) =>
        m.stage.id == 'group_stage' &&
        m.resultStatus == MatchResultStatus.completed);

    return Column(
      children: [
        // Screen Header
        _buildHeader(theme),

        // Tabs or Empty State
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            color: const Color(0xFF00FF87),
            child: !hasCompletedMatches
                ? _buildEmptyState(context, theme)
                : DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: const Color(0xFF00FF87),
                          labelColor: const Color(0xFF00FF87),
                          unselectedLabelColor: const Color(0xFF64748B),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerColor: const Color(0xFF1E294B),
                          labelStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                          tabs: [
                            Tab(text: AppTranslations.translate('q_winners', lang).toUpperCase()),
                            Tab(text: AppTranslations.translate('q_best_thirds', lang).toUpperCase()),
                            Tab(text: AppTranslations.translate('bracket', lang).toUpperCase()),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              QualifiedTeamsSection(
                                groupStandings: groupStandings,
                                qualificationResult: qualificationResult,
                                flagStyleRepository: flagStyleRepository,
                                lang: lang,
                              ),
                              BestThirdPlacesSection(
                                groupStandings: groupStandings,
                                qualificationResult: qualificationResult,
                                flagStyleRepository: flagStyleRepository,
                                lang: lang,
                              ),
                              KnockoutBracketView(
                                slots: bracketSlots,
                                allMatches: matches,
                                flagStyleRepository: flagStyleRepository,
                                lang: lang,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return WorldCupHeader(
      title: AppTranslations.translate('knockoutTitle', lang),
      showVersion: true,
      showBackButton: false,
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
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
                    Icons.emoji_events_rounded,
                    size: 64,
                    color: theme.colorScheme.secondary.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  AppTranslations.translate('notEnoughResults', lang),
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
