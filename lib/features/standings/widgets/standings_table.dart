import 'package:flutter/material.dart';
import '../models/group_standing.dart';
import '../../matches/widgets/flag_circle_avatar.dart';
import '../../matches/data/flag_style_repository.dart';
import '../../../core/i18n/app_translations.dart';
import '../../knockout/models/knockout_qualification_result.dart';
import '../../knockout/widgets/qualification_badge.dart';
import '../../knockout/services/knockout_qualification_service.dart';

class StandingsTable extends StatelessWidget {
  final List<GroupStanding> standings;
  final String lang;
  final FlagStyleRepository flagStyleRepository;
  final Map<String, List<GroupStanding>> groupStandings;
  final KnockoutQualificationResult qualificationResult;

  const StandingsTable({
    super.key,
    required this.standings,
    required this.lang,
    required this.flagStyleRepository,
    required this.groupStandings,
    required this.qualificationResult,
  });

  @override
  Widget build(BuildContext context) {
    const double headerHeight = 36.0;
    const double rowHeight = 48.0;
    const double teamColumnWidth = 150.0;

    final headerStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Colors.white.withOpacity(0.6),
      letterSpacing: 0.5,
    );

    final cellStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    );

    final pointsStyle = const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w900,
      color: Color(0xFF00FF87), // Highlight points in bright green
    );

    return Column(
      children: [
        // Table Header Row
        Container(
          height: headerHeight,
          decoration: BoxDecoration(
            color: const Color(0xFF1E294B).withOpacity(0.3),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFF1E294B).withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Fixed Team Column Header
              Container(
                width: teamColumnWidth,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    AppTranslations.translate('team', lang).toUpperCase(),
                    style: headerStyle,
                  ),
                ),
              ),
              // Scrollable Stats Column Headers
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildHeaderCell(AppTranslations.translate('pointsAbbr', lang), 42, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('goalsForAbbr', lang), 32, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('goalsAgainstAbbr', lang), 32, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('goalDiffAbbr', lang), 38, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('playedAbbr', lang), 32, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('wonAbbr', lang), 32, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('drawnAbbr', lang), 32, headerStyle),
                      _buildHeaderCell(AppTranslations.translate('lostAbbr', lang), 32, headerStyle),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Standings Rows
        ...standings.asMap().entries.map((entry) {
          final index = entry.key;
          final standing = entry.value;
          final position = index + 1;
          final isQualified = position <= 2;

          final flagStyle = flagStyleRepository.getFlagStyle(standing.team.name.en);
          final teamName = lang == 'es' ? standing.team.name.es : standing.team.name.en;

          final qualificationService = KnockoutQualificationService();
          final status = qualificationService.getTeamQualificationStatus(
            teamId: standing.team.id,
            groupId: standing.groupId,
            groupStandings: groupStandings,
            qualificationResult: qualificationResult,
          );

          return Container(
            height: rowHeight,
            decoration: BoxDecoration(
              color: isQualified
                  ? const Color(0xFF00FF87).withOpacity(0.02)
                  : Colors.transparent,
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFF1E294B).withOpacity(0.4),
                  width: 0.8,
                ),
              ),
            ),
            child: Row(
              children: [
                // Fixed Team Column Cell
                Container(
                  width: teamColumnWidth,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      // Position Indicator
                      SizedBox(
                        width: 18,
                        child: Text(
                          '$position',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: isQualified
                                ? const Color(0xFF00FF87)
                                : Colors.white60,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Flag Avatar
                      FlagCircleAvatar(
                        teamName: standing.team.name.en,
                        flagStyle: flagStyle,
                        size: 20,
                        borderWidth: 0.8,
                      ),
                      const SizedBox(width: 8),
                      // Team Name & Qualified Badge
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              teamName,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isQualified ? FontWeight.w800 : FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            QualificationBadge(status: status, lang: lang),
                          ],
                        ),
                      ),

                    ],
                  ),
                ),
                // Scrollable Stats Column Cells
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildDataCell('${standing.points}', 42, pointsStyle),
                        _buildDataCell('${standing.goalsFor}', 32, cellStyle),
                        _buildDataCell('${standing.goalsAgainst}', 32, cellStyle),
                        _buildDataCell(
                          standing.goalDifference >= 0
                              ? '+${standing.goalDifference}'
                              : '${standing.goalDifference}',
                          38,
                          TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: standing.goalDifference > 0
                                ? const Color(0xFF00FF87)
                                : standing.goalDifference < 0
                                    ? const Color(0xFFFF4D4D)
                                    : Colors.white60,
                          ),
                        ),
                        _buildDataCell('${standing.played}', 32, cellStyle),
                        _buildDataCell('${standing.wins}', 32, cellStyle),
                        _buildDataCell('${standing.draws}', 32, cellStyle),
                        _buildDataCell('${standing.losses}', 32, cellStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildHeaderCell(String text, double width, TextStyle style) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(text, style: style),
      ),
    );
  }

  Widget _buildDataCell(String text, double width, TextStyle style) {
    return SizedBox(
      width: width,
      child: Center(
        child: Text(text, style: style),
      ),
    );
  }
}
