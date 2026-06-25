import 'package:flutter/material.dart';
import '../../matches/models/world_cup_match.dart';
import '../../matches/widgets/flag_circle_avatar.dart';
import '../../matches/data/flag_style_repository.dart';
import '../models/knockout_match_slot.dart';
import '../models/qualification_type.dart';

class KnockoutMatchCard extends StatelessWidget {
  final KnockoutMatchSlot slot;
  final WorldCupMatch originalMatch;
  final FlagStyleRepository flagStyleRepository;
  final String lang;

  const KnockoutMatchCard({
    super.key,
    required this.slot,
    required this.originalMatch,
    required this.flagStyleRepository,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String homeDisplayName;
    final Widget homeFlagWidget;
    if (slot.teamA != null) {
      homeDisplayName = lang == 'es' ? slot.teamA!.team.name.es : slot.teamA!.team.name.en;
      final flagStyle = flagStyleRepository.getFlagStyle(slot.teamA!.team.name.en);
      homeFlagWidget = FlagCircleAvatar(
        teamName: slot.teamA!.team.name.en,
        flagStyle: flagStyle,
        size: 28,
        borderWidth: 0.8,
      );
    } else {
      homeDisplayName = lang == 'es' ? originalMatch.homeTeam.name.es : originalMatch.homeTeam.name.en;
      homeFlagWidget = _buildPlaceholderFlag();
    }

    final String awayDisplayName;
    final Widget awayFlagWidget;
    if (slot.teamB != null) {
      awayDisplayName = lang == 'es' ? slot.teamB!.team.name.es : slot.teamB!.team.name.en;
      final flagStyle = flagStyleRepository.getFlagStyle(slot.teamB!.team.name.en);
      awayFlagWidget = FlagCircleAvatar(
        teamName: slot.teamB!.team.name.en,
        flagStyle: flagStyle,
        size: 28,
        borderWidth: 0.8,
      );
    } else {
      awayDisplayName = lang == 'es' ? originalMatch.awayTeam.name.es : originalMatch.awayTeam.name.en;
      awayFlagWidget = _buildPlaceholderFlag();
    }

    final dateStr = originalMatch.date;
    final timeStr = originalMatch.timeLocal;
    final cityStr = lang == 'es' ? originalMatch.city.name.es : originalMatch.city.name.en;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Match Number and Kickoff Details
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${lang == 'es' ? 'PARTIDO' : 'MATCH'} ${slot.matchNumber}',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.secondary,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '$dateStr - $timeStr ($cityStr)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.4),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFF1E294B)),
            const SizedBox(height: 12),

            // Home Team Row
            Row(
              children: [
                homeFlagWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    homeDisplayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: slot.teamA != null ? FontWeight.bold : FontWeight.w600,
                      color: slot.teamA != null ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
                if (slot.teamA != null)
                  _buildPositionTag(theme, slot.teamA!.qualificationType, slot.teamA!.groupId),
              ],
            ),
            const SizedBox(height: 12),

            // Away Team Row
            Row(
              children: [
                awayFlagWidget,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    awayDisplayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: slot.teamB != null ? FontWeight.bold : FontWeight.w600,
                      color: slot.teamB != null ? Colors.white : Colors.white60,
                    ),
                  ),
                ),
                if (slot.teamB != null)
                  _buildPositionTag(theme, slot.teamB!.qualificationType, slot.teamB!.groupId),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderFlag() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFF1E294B).withOpacity(0.6),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.8,
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.help_outline,
          size: 14,
          color: Colors.white30,
        ),
      ),
    );
  }

  Widget _buildPositionTag(ThemeData theme, QualificationType type, String groupId) {
    final groupLetter = groupId.toUpperCase().replaceAll('GROUP_', '');
    String text;
    if (type == QualificationType.groupWinner) {
      text = '1° $groupLetter';
    } else if (type == QualificationType.groupRunnerUp) {
      text = '2° $groupLetter';
    } else {
      text = '3° $groupLetter';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w900,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
