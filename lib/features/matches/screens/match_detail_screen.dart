import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import '../data/match_repository.dart';
import '../data/flag_style_repository.dart';
import '../models/world_cup_match.dart';
import '../models/match_result_status.dart';
import '../widgets/edit_result_dialog.dart';
import '../widgets/score_display.dart';
import '../widgets/match_result_badge.dart';

class MatchDetailScreen extends StatefulWidget {
  final WorldCupMatch match;
  final MatchRepository matchRepository;
  final FlagStyleRepository flagStyleRepository;
  final VoidCallback onFavoriteToggled;

  const MatchDetailScreen({
    super.key,
    required this.match,
    required this.flagStyleRepository,
    required this.matchRepository,
    required this.onFavoriteToggled,
  });

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  late bool _isFavorite;
  late WorldCupMatch _match;

  @override
  void initState() {
    super.initState();
    _match = widget.match;
    _isFavorite = _match.isFavorite;
  }

  void _handleFavoriteToggle() {
    widget.onFavoriteToggled();
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  /// Calculates the stadium local time in UTC.
  DateTime _getStadiumDateTimeInUtc() {
    final dateParts = widget.match.date.split('-');
    final timeParts = widget.match.timeLocal.split(':');
    
    final year = int.parse(dateParts[0]);
    final month = int.parse(dateParts[1]);
    final day = int.parse(dateParts[2]);
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Apply offset for June/July timezone in host cities
    int utcOffsetHours = 0;
    switch (widget.match.timezone) {
      case 'America/Mexico_City':
        utcOffsetHours = -6;
        break;
      case 'America/Toronto':
      case 'America/New_York':
        utcOffsetHours = -4; // EDT (Eastern Daylight Time)
        break;
      case 'America/Los_Angeles':
      case 'America/Vancouver':
        utcOffsetHours = -7; // PDT (Pacific Daylight Time)
        break;
      case 'America/Chicago':
        utcOffsetHours = -5; // CDT (Central Daylight Time)
        break;
      default:
        utcOffsetHours = -6;
    }

    return DateTime.utc(year, month, day, hour, minute).subtract(Duration(hours: utcOffsetHours));
  }

  /// Get Stadium Stats.
  Map<String, String> _getStadiumStats(String stadiumName, String lang) {
    final capLabel = AppTranslations.translate('capacity', lang);
    final inaugLabel = AppTranslations.translate('inauguration', lang);
    final grassLabel = AppTranslations.translate('grass', lang);

    String capVal = '';
    String inaugVal = '';
    String grassVal = '';

    switch (stadiumName) {
      case 'Estadio Azteca':
      case 'Mexico City Stadium':
        capVal = '87,523';
        inaugVal = '1966';
        grassVal = AppTranslations.translate('naturalHybrid', lang);
        break;
      case 'BMO Field':
      case 'Toronto Stadium':
        capVal = '45,736';
        inaugVal = '2007';
        grassVal = AppTranslations.translate('hybridReinforced', lang);
        break;
      case 'SoFi Stadium':
      case 'Los Angeles Stadium':
        capVal = '70,240';
        inaugVal = '2020';
        grassVal = AppTranslations.translate('syntheticPremium', lang);
        break;
      case 'MetLife Stadium':
      case 'New York New Jersey Stadium':
        capVal = '82,500';
        inaugVal = '2010';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'AT&T Stadium':
      case 'Dallas Stadium':
        capVal = '80,000';
        inaugVal = '2009';
        grassVal = AppTranslations.translate('syntheticMatrix', lang);
        break;
      case 'Estadio BBVA':
      case 'Monterrey Stadium':
        capVal = '53,500';
        inaugVal = '2015';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'BC Place':
      case 'BC Place Vancouver':
        capVal = '54,500';
        inaugVal = '1983';
        grassVal = lang == 'es' ? 'Sintético Polytan' : 'Polytan Synthetic';
        break;
      case 'Lincoln Financial Field':
      case 'Philadelphia Stadium':
        capVal = '67,594';
        inaugVal = '2003';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'San Francisco Bay Area Stadium':
        capVal = '68,500';
        inaugVal = '2014';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'Boston Stadium':
        capVal = '65,878';
        inaugVal = '2002';
        grassVal = lang == 'es' ? 'Sintético FieldTurf' : 'FieldTurf Synthetic';
        break;
      case 'Houston Stadium':
        capVal = '72,220';
        inaugVal = '2002';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'Atlanta Stadium':
        capVal = '71,000';
        inaugVal = '2017';
        grassVal = lang == 'es' ? 'Sintético FieldTurf' : 'FieldTurf Synthetic';
        break;
      case 'Seattle Stadium':
        capVal = '69,000';
        inaugVal = '2002';
        grassVal = lang == 'es' ? 'Sintético FieldTurf' : 'FieldTurf Synthetic';
        break;
      case 'Miami Stadium':
        capVal = '65,326';
        inaugVal = '1987';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'Kansas City Stadium':
        capVal = '76,416';
        inaugVal = '1972';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      case 'Guadalajara Stadium':
        capVal = '48,071';
        inaugVal = '2010';
        grassVal = AppTranslations.translate('naturalGrass', lang);
        break;
      default:
        capVal = '60,000+';
        inaugVal = 'N/A';
        grassVal = AppTranslations.translate('naturalGrass', lang);
    }

    return {
      capLabel: capVal,
      inaugLabel: inaugVal,
      grassLabel: grassVal,
    };
  }

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
        return [const Color(0xFF334155), const Color(0xFF475569)];
    }
  }

  String _getTeamInitials(String teamName) {
    if (teamName.contains('Winner') || teamName.contains('Match') || teamName.contains('runners-up')) {
      return 'TBD';
    }
    if (teamName.length <= 3) return teamName.toUpperCase();
    return teamName.substring(0, 3).toUpperCase();
  }

  String _formatDateString(DateTime dateTime, String lang) {
    final monthsEs = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    final monthsEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final months = lang == 'es' ? monthsEs : monthsEn;
    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }

  String _formatTimeString(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _openEditResultDialog() async {
    final flagStyleHome = widget.flagStyleRepository.getFlagStyle(_match.homeTeam.name.en);
    final flagStyleAway = widget.flagStyleRepository.getFlagStyle(_match.awayTeam.name.en);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditResultDialog(
        match: _match,
        matchRepository: widget.matchRepository,
        flagStyleHome: flagStyleHome,
        flagStyleAway: flagStyleAway,
      ),
    );

    if (updated == true) {
      final updatedMatches = await widget.matchRepository.getMatches();
      final freshMatch = updatedMatches.firstWhere((m) => m.id == _match.id);
      setState(() {
        _match = freshMatch;
      });
      widget.onFavoriteToggled();
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final theme = Theme.of(context);
    final homeColors = _getTeamColors(_match.homeTeam.name.en);
    final awayColors = _getTeamColors(_match.awayTeam.name.en);
    
    // Timezone Conversions
    final utcTime = _getStadiumDateTimeInUtc();
    final userLocalTime = utcTime.toLocal();

    // Stadium Details
    final stadiumStats = _getStadiumStats(_match.stadium.name.en, lang);

    final showPromoImage = (_match.homeTeam.name.en.toLowerCase() == 'argentina' &&
            (_match.awayTeam.name.en.toLowerCase() == 'austria' || _match.awayTeam.name.en.toLowerCase() == 'australia')) ||
        ((_match.homeTeam.name.en.toLowerCase() == 'austria' || _match.homeTeam.name.en.toLowerCase() == 'australia') &&
            _match.awayTeam.name.en.toLowerCase() == 'argentina') ||
        _match.id == 'M041';

    return Scaffold(
      appBar: AppBar(
        title: Text(AppTranslations.translate('matchDetail', lang)),
        actions: [
          IconButton(
            onPressed: _handleFavoriteToggle,
            icon: Icon(
              _isFavorite ? Icons.favorite : Icons.favorite_border,
              color: _isFavorite ? Colors.redAccent : Colors.white,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPromoImage) ...[
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withOpacity(0.8), // Golden border
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset(
                      'assets/icons/match_promo.jpg',
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ],
            // 1. Stage / Category Banner
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E294B),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _match.stage.id == 'group_stage'
                      ? '${AppTranslations.translate('groupStageLabel', lang)} ${_match.group.id.toUpperCase()}'
                      : _match.stage.name.value(lang).toUpperCase(),
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 2. Scoreboard / Matchup Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFF1E294B).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Home Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: homeColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: homeColors.first.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getTeamInitials(_match.homeTeam.name.en),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _match.homeTeam.name.value(lang),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),

                      // VS indicator or Score Display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_match.resultStatus == MatchResultStatus.completed) ...[
                            ScoreDisplay(match: _match, fontSize: 32),
                            const SizedBox(height: 6),
                            Text(
                              AppTranslations.translate('finalResult', lang),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white54,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const MatchResultBadge(),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Color(0xFF1E293B),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                'VS',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),

                      // Away Team
                      Expanded(
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: awayColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: awayColors.first.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _getTeamInitials(_match.awayTeam.name.en),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _match.awayTeam.name.value(lang),
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Timezone conversion and Kickoff Info
            Text(
              AppTranslations.translate('schedulesBroadcast', lang),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E294B).withOpacity(0.5),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stadium, color: Color(0xFF00FF87), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translate('stadiumLocalTime', lang),
                              style: const TextStyle(fontSize: 12, color: Colors.white60),
                            ),
                            Text(
                              '${_formatDateString(userLocalTime, lang)} - ${widget.match.timeLocal} (${widget.match.timezone.split("/").last.replaceAll("_", " ")})',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Divider(color: Colors.white10),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.schedule, color: Color(0xFFFFD700), size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppTranslations.translate('deviceLocalTime', lang),
                              style: const TextStyle(fontSize: 12, color: Colors.white60),
                            ),
                            Text(
                              '${_formatDateString(userLocalTime, lang)} - ${_formatTimeString(userLocalTime)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFFD700),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Stadium Details Card
            Text(
              AppTranslations.translate('venueDetails', lang),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFF1E294B).withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_city, color: Colors.white70),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          widget.match.stadium.name.value(lang),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 34.0),
                    child: Text(
                      '${widget.match.city.name.value(lang)}, ${widget.match.country.name.value(lang)}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.white10),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: stadiumStats.entries.map((entry) {
                      return Column(
                        children: [
                          Text(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF00FF87),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.key,
                            style: const TextStyle(fontSize: 11, color: Colors.white38),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 5. Visual Mock Pitch / Lineup
            Text(
              AppTranslations.translate('lineupsTitle', lang),
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFF064e3b), Color(0xFF065f46)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2,
                ),
              ),
              child: Stack(
                children: [
                  // Pitch Center Circle
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                      ),
                    ),
                  ),
                  // Center Line
                  Center(
                    child: Container(
                      height: 1.5,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
                  // Halfway Line Spot
                  Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.white30,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),

                  // Home Team formation dots (Top half)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Goalkeeper
                        _buildPlayerDot(widget.match.homeTeam.name.en, 'GK'),
                        const SizedBox(height: 16),
                        // Defenders
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayerDot(widget.match.homeTeam.name.en, 'DEF'),
                            _buildPlayerDot(widget.match.homeTeam.name.en, 'DEF'),
                            _buildPlayerDot(widget.match.homeTeam.name.en, 'DEF'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Attackers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayerDot(widget.match.homeTeam.name.en, 'MID'),
                            _buildPlayerDot(widget.match.homeTeam.name.en, 'FWD'),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Away Team formation dots (Bottom half)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        // Attackers
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayerDot(widget.match.awayTeam.name.en, 'FWD'),
                            _buildPlayerDot(widget.match.awayTeam.name.en, 'MID'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Defenders
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildPlayerDot(widget.match.awayTeam.name.en, 'DEF'),
                            _buildPlayerDot(widget.match.awayTeam.name.en, 'DEF'),
                            _buildPlayerDot(widget.match.awayTeam.name.en, 'DEF'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Goalkeeper
                        _buildPlayerDot(widget.match.awayTeam.name.en, 'GK'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_match.canEditResult(DateTime.now())) ...[
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.edit_rounded, size: 20),
                  label: Text(
                    _match.resultStatus == MatchResultStatus.completed
                        ? AppTranslations.translate('editResult', lang)
                        : AppTranslations.translate('enterScore', lang),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  onPressed: _openEditResultDialog,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerDot(String teamName, String position) {
    final colors = _getTeamColors(teamName);
    return Column(
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
          ),
          child: Center(
            child: Text(
              position[0],
              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
