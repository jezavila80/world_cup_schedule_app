import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../matches/data/match_repository.dart';
import '../../matches/models/world_cup_match.dart';
import '../../standings/services/group_standings_service.dart';
import '../../knockout/services/knockout_qualification_service.dart';
import '../../knockout/services/knockout_bracket_service.dart';
import '../services/tournament_validation_service.dart';
import '../models/tournament_validation_result.dart';
import '../widgets/validation_summary_card.dart';
import '../widgets/validation_check_tile.dart';
import '../widgets/validation_issue_tile.dart';
import '../../../../core/i18n/locale_helper.dart';
import '../../../../core/i18n/app_translations.dart';
import '../../../../core/widgets/world_cup_header.dart';
import '../../../../core/app_info/app_info.dart';

class TournamentValidationScreen extends StatefulWidget {
  final MatchRepository matchRepository;

  const TournamentValidationScreen({
    super.key,
    required this.matchRepository,
  });

  @override
  State<TournamentValidationScreen> createState() => _TournamentValidationScreenState();
}

class _TournamentValidationScreenState extends State<TournamentValidationScreen> {
  late Future<List<WorldCupMatch>> _matchesFuture;

  @override
  void initState() {
    super.initState();
    _matchesFuture = widget.matchRepository.getMatches();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            WorldCupHeader(
              title: AppTranslations.translate('tournamentValidation', lang),
              showVersion: true,
            ),
            Expanded(
              child: FutureBuilder<List<WorldCupMatch>>(
                future: _matchesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final matches = snapshot.data ?? [];

                  // Perform all engine calculations
                  final standingsService = GroupStandingsService();
                  final groupStandings = standingsService.calculateStandings(matches);

                  final qualificationService = KnockoutQualificationService();
                  final qualificationResult = qualificationService.calculateQualifiedTeams(groupStandings);

                  final bracketService = KnockoutBracketService();
                  final bracketSlots = bracketService.calculateBracketSlots(matches, groupStandings);

                  final validationService = TournamentValidationService();
                  final validationResult = validationService.validate(
                    matches: matches,
                    standingsByGroup: groupStandings,
                    qualificationResult: qualificationResult,
                    bracketSlots: bracketSlots,
                  );

                  // Developer Info Card details
                  final appInfo = AppInfoScope.of(context);
                  final platformName = defaultTargetPlatform.name;
                  final platformDisplay = platformName.isNotEmpty
                      ? '${platformName[0].toUpperCase()}${platformName.substring(1)}'
                      : 'Unknown';

                  return ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // Overall Status Header
                      _buildOverallStatusHeader(validationResult, lang),
                      const SizedBox(height: 16),

                      // Summary stats card
                      ValidationSummaryCard(
                        groupStandings: groupStandings,
                        qualificationResult: qualificationResult,
                        bracketSlots: bracketSlots,
                        validationResult: validationResult,
                        lang: lang,
                      ),
                      const SizedBox(height: 24),

                      // General Checks section
                      Text(
                        AppTranslations.translate('validationChecks', lang).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...validationResult.checks.map((check) => ValidationCheckTile(check: check, lang: lang)),
                      const SizedBox(height: 24),

                      // Issues & Warnings section
                      Text(
                        AppTranslations.translate('issues', lang).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w800,
                          fontSize: 11,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (validationResult.issues.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 12),
                              Text(
                                AppTranslations.translate('noIssues', lang),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                              ),
                            ],
                          ),
                        )
                      else
                        ...validationResult.issues.map((issue) => ValidationIssueTile(issue: issue, lang: lang)),

                      // Developer Info Card
                      Container(
                        margin: const EdgeInsets.only(top: 24.0, bottom: 16.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translate('developerSectionTitle', lang).toUpperCase() + ' INFO',
                              style: const TextStyle(
                                color: Color(0xFF00FF87),
                                fontWeight: FontWeight.w800,
                                fontSize: 11,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildInfoRow('Application', appInfo.appName),
                            const Divider(color: Colors.white10),
                            _buildInfoRow('Version', appInfo.version),
                            const Divider(color: Colors.white10),
                            _buildInfoRow('Build', appInfo.buildNumber),
                            const Divider(color: Colors.white10),
                            _buildInfoRow('Platform', platformDisplay),
                            const Divider(color: Colors.white10),
                            _buildInfoRow('Locale', Localizations.localeOf(context).toString()),
                            const Divider(color: Colors.white10),
                            _buildInfoRow('Theme', theme.brightness == Brightness.dark ? 'Dark' : 'Light'),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallStatusHeader(TournamentValidationResult validationResult, String lang) {
    final isPassed = validationResult.isValid;
    final statusColor = isPassed ? Colors.green : Colors.red;
    final title = isPassed
        ? AppTranslations.translate('validationPassed', lang)
        : AppTranslations.translate('validationError', lang);
    final detail = isPassed
        ? AppTranslations.translate('validationPassedDetail', lang)
        : AppTranslations.translate('validationFailedDetail', lang);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Icon(
            isPassed ? Icons.verified : Icons.dangerous,
            color: statusColor,
            size: 36,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  detail,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
