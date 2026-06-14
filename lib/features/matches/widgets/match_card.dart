import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import '../models/world_cup_match.dart';
import '../models/flag_style.dart';
import '../models/match_result_status.dart';
import 'flag_circle_avatar.dart';
import 'score_display.dart';
import 'match_result_badge.dart';

class MatchCard extends StatelessWidget {
  final WorldCupMatch match;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggled;
  final VoidCallback? onEditResult;
  final FlagStyle? flagStyleHome;
  final FlagStyle? flagStyleAway;

  const MatchCard({
    super.key,
    required this.match,
    required this.onTap,
    required this.onFavoriteToggled,
    this.onEditResult,
    this.flagStyleHome,
    this.flagStyleAway,
  });

  /// Generates gradient colors for national teams.
  List<Color> _getTeamColors(String teamName) {
    switch (teamName.toLowerCase()) {
      case 'mexico':
        return [const Color(0xFF006847), const Color(0xFFCE1126)];
      case 'usa':
        return [const Color(0xFF0A3161), const Color(0xFFB31942)];
      case 'canada':
        return [const Color(0xFFD80621), Colors.white];
      case 'argentina':
        return [const Color(0xFF74ACDF), Colors.white];
      case 'netherlands':
        return [const Color(0xFFFF4F00), Colors.white];
      case 'brazil':
        return [const Color(0xFFFEDF00), const Color(0xFF009B3A)];
      case 'spain':
        return [const Color(0xFFCE1126), const Color(0xFFFBE122)];
      case 'portugal':
        return [const Color(0xFF046A38), const Color(0xFFDA291C)];
      case 'france':
        return [const Color(0xFF002395), const Color(0xFFED2939)];
      case 'japan':
        return [Colors.white, const Color(0xFFBC002D)];
      case 'germany':
        return [Colors.black, const Color(0xFFDD0000), const Color(0xFFFFCE00)];
      case 'morocco':
        return [const Color(0xFFC1272D), const Color(0xFF006233)];
      case 'south africa':
        return [const Color(0xFF007A4D), const Color(0xFFDE3831)];
      case 'sweden':
        return [const Color(0xFF006AA7), const Color(0xFFFECC00)];
      case 'australia':
        return [const Color(0xFF002F6C), const Color(0xFFFFCD00)];
      default:
        return [const Color(0xFF334155), const Color(0xFF475569)]; // Default placeholders
    }
  }

  /// Helper to get team initials.
  String _getTeamInitials(String teamName) {
    if (teamName.contains('Winner') || teamName.contains('Match') || teamName.contains('runners-up')) {
      return 'TBD';
    }
    if (teamName.length <= 3) return teamName.toUpperCase();
    return teamName.substring(0, 3).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final homeColors = _getTeamColors(match.homeTeam.name.en);
    final awayColors = _getTeamColors(match.awayTeam.name.en);
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: match.isFavorite 
              ? theme.colorScheme.primary.withOpacity(0.3)
              : const Color(0xFF1E294B).withOpacity(0.5),
          width: match.isFavorite ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          if (match.isFavorite)
            BoxShadow(
              color: theme.colorScheme.primary.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            splashColor: theme.colorScheme.primary.withOpacity(0.05),
            highlightColor: theme.colorScheme.primary.withOpacity(0.02),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Upper row: Stage, Status Chip and Favorite Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E294B),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              match.stage.id == 'group_stage' 
                                  ? match.group.name.value(lang)
                                  : match.stage.name.value(lang),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          _buildStatusChip(match.getStatus(DateTime.now()), lang),
                        ],
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (match.canEditResult(DateTime.now()) && onEditResult != null) ...[
                            IconButton(
                              onPressed: onEditResult,
                              icon: const Icon(
                                Icons.edit_note_rounded,
                                color: Colors.white70,
                                size: 22,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: AppTranslations.translate('editResult', lang),
                            ),
                            const SizedBox(width: 12),
                          ],
                          IconButton(
                            onPressed: onFavoriteToggled,
                            icon: Icon(
                              match.isFavorite ? Icons.favorite : Icons.favorite_border,
                              color: match.isFavorite ? Colors.redAccent : Colors.grey[400],
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Middle Row: Teams and Score/VS
                  Row(
                    children: [
                      // Home Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: homeColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: homeColors.first.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getTeamInitials(match.homeTeam.name.en),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 3,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlagCircleAvatar(
                                  teamName: match.homeTeam.name.en,
                                  size: 12,
                                  flagStyle: flagStyleHome,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    match.homeTeam.name.value(lang),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // VS & Time or Score Display
                      Column(
                        children: [
                          if (match.resultStatus == MatchResultStatus.completed) ...[
                            ScoreDisplay(match: match, fontSize: 20),
                            const SizedBox(height: 2),
                            Text(
                              AppTranslations.translate('finalResult', lang),
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const MatchResultBadge(),
                          ] else ...[
                            Text(
                              'MX: ${_getMexicoTime(match.date, match.timeLocal, match.timezone)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                            Text(
                              'Local: ${match.timeLocal}',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white60,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            match.date,
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),

                      // Away Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: awayColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: awayColors.first.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getTeamInitials(match.awayTeam.name.en),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black45,
                                        blurRadius: 3,
                                        offset: Offset(1, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FlagCircleAvatar(
                                  teamName: match.awayTeam.name.en,
                                  size: 12,
                                  flagStyle: flagStyleAway,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    match.awayTeam.name.value(lang),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.white,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Divider
                  Divider(
                    color: const Color(0xFF1E294B).withOpacity(0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 6),

                  // Lower row: Stadium & City
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${match.stadium.name.value(lang)}, ${match.city.name.value(lang)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                             color: const Color(0xFF94A3B8),
                            fontSize: 10,
                          ),
                        ),
                      ),
                      Text(
                        match.country.name.value(lang).toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: match.country.id == 'mexico'
                              ? const Color(0xFF006847)
                              : match.country.id == 'usa'
                                  ? const Color(0xFF0088CC)
                                  : const Color(0xFFCE1126),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Converts the match time to Mexico City timezone (UTC-6)
  String _getMexicoTime(String dateStr, String timeStr, String timezone) {
    try {
      final dateParts = dateStr.split('-');
      final timeParts = timeStr.split(':');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Get UTC offset of stadium in June/July (DST is active in USA/Canada)
      int utcOffsetHours = 0;
      switch (timezone) {
        case 'America/Mexico_City':
          utcOffsetHours = -6; // Mexico City standard time (no DST)
          break;
        case 'America/Toronto':
        case 'America/New_York':
          utcOffsetHours = -4; // EDT is UTC-4
          break;
        case 'America/Los_Angeles':
        case 'America/Vancouver':
          utcOffsetHours = -7; // PDT is UTC-7
          break;
        case 'America/Chicago':
          utcOffsetHours = -5; // CDT is UTC-5
          break;
        default:
          utcOffsetHours = -6;
      }

      // Convert stadium time to UTC
      final matchUtc = DateTime.utc(year, month, day, hour, minute)
          .subtract(Duration(hours: utcOffsetHours));

      // Convert UTC to Mexico City time (UTC-6)
      final mexicoTime = matchUtc.add(const Duration(hours: -6));

      final hourFormatted = mexicoTime.hour.toString().padLeft(2, '0');
      final minuteFormatted = mexicoTime.minute.toString().padLeft(2, '0');
      return '$hourFormatted:$minuteFormatted';
    } catch (e) {
      return timeStr; // Fallback
    }
  }

  Widget _buildStatusChip(MatchStatus status, String lang) {
    Color bgColor;
    Color textColor;
    String label;
    IconData? icon;

    switch (status) {
      case MatchStatus.live:
        bgColor = const Color(0xFFFF4D4D).withOpacity(0.15);
        textColor = const Color(0xFFFF4D4D);
        label = AppTranslations.translate('live', lang).toUpperCase();
        icon = Icons.radio_button_checked;
        break;
      case MatchStatus.today:
        bgColor = const Color(0xFF00FF87).withOpacity(0.15);
        textColor = const Color(0xFF00FF87);
        label = AppTranslations.translate('todayLower', lang).toUpperCase();
        icon = Icons.star;
        break;
      case MatchStatus.upcoming:
        bgColor = const Color(0xFF1E294B);
        textColor = const Color(0xFF94A3B8);
        label = AppTranslations.translate('upcoming', lang).toUpperCase();
        break;
      case MatchStatus.finished:
        bgColor = const Color(0xFF0F172A);
        textColor = const Color(0xFF475569);
        label = AppTranslations.translate('finished', lang).toUpperCase();
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: textColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 8, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 8,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
