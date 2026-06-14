import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import '../models/world_cup_match.dart';
import '../data/match_repository.dart';
import '../models/flag_style.dart';
import '../models/team_info.dart';
import 'flag_circle_avatar.dart';

class EditResultDialog extends StatefulWidget {
  final WorldCupMatch match;
  final MatchRepository matchRepository;
  final FlagStyle? flagStyleHome;
  final FlagStyle? flagStyleAway;

  const EditResultDialog({
    super.key,
    required this.match,
    required this.matchRepository,
    this.flagStyleHome,
    this.flagStyleAway,
  });

  @override
  State<EditResultDialog> createState() => _EditResultDialogState();
}

class _EditResultDialogState extends State<EditResultDialog> {
  late int _homeScore;
  late int _awayScore;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _homeScore = widget.match.homeScore ?? 0;
    _awayScore = widget.match.awayScore ?? 0;
  }

  void _incrementHome(String lang) {
    if (_homeScore < 20) {
      setState(() {
        _homeScore++;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = AppTranslations.translate('suggestedMaxGols', lang);
      });
    }
  }

  void _decrementHome() {
    if (_homeScore > 0) {
      setState(() {
        _homeScore--;
        _errorMessage = null;
      });
    }
  }

  void _incrementAway(String lang) {
    if (_awayScore < 20) {
      setState(() {
        _awayScore++;
        _errorMessage = null;
      });
    } else {
      setState(() {
        _errorMessage = AppTranslations.translate('suggestedMaxGols', lang);
      });
    }
  }

  void _decrementAway() {
    if (_awayScore > 0) {
      setState(() {
        _awayScore--;
        _errorMessage = null;
      });
    }
  }

  Future<void> _saveResult(String lang) async {
    if (_homeScore < 0 || _awayScore < 0) {
      setState(() {
        _errorMessage = AppTranslations.translate('negativeGolsError', lang);
      });
      return;
    }
    if (_homeScore > 20 || _awayScore > 20) {
      setState(() {
        _errorMessage = AppTranslations.translate('maxGolsError', lang);
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final success = await widget.matchRepository.saveMatchResult(
        widget.match.id,
        _homeScore,
        _awayScore,
      );

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
        } else {
          setState(() {
            _isSaving = false;
            _errorMessage = AppTranslations.translate('saveError', lang);
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = AppTranslations.translate('unexpectedError', lang);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: const Color(0xFF0F172A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  color: theme.colorScheme.secondary,
                  size: 24,
                ),
                const SizedBox(width: 10),
                Text(
                  AppTranslations.translate('enterScore', lang),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.match.stage.name.value(lang)} • ${lang == 'es' ? 'Partido' : 'Match'} ${widget.match.id}',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(color: Colors.white10, height: 24),

            // Home Team score editor row
            _buildScoreRow(
              context: context,
              team: widget.match.homeTeam,
              flagStyle: widget.flagStyleHome,
              currentScore: _homeScore,
              onDecrement: _decrementHome,
              onIncrement: () => _incrementHome(lang),
              lang: lang,
            ),

            const SizedBox(height: 16),

            // Away Team score editor row
            _buildScoreRow(
              context: context,
              team: widget.match.awayTeam,
              flagStyle: widget.flagStyleAway,
              currentScore: _awayScore,
              onDecrement: _decrementAway,
              onIncrement: () => _incrementAway(lang),
              lang: lang,
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: theme.colorScheme.error.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _errorMessage!,
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSaving ? null : () => Navigator.of(context).pop(false),
                    child: Text(AppTranslations.translate('cancel', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: _isSaving ? null : () => _saveResult(lang),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.black,
                            ),
                          )
                        : Text(AppTranslations.translate('save', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreRow({
    required BuildContext context,
    required TeamInfo team,
    required FlagStyle? flagStyle,
    required int currentScore,
    required VoidCallback onDecrement,
    required VoidCallback onIncrement,
    required String lang,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          // Flag Avatar
          FlagCircleAvatar(
            teamName: team.name.en,
            size: 32,
            flagStyle: flagStyle,
          ),
          const SizedBox(width: 12),

          // Team Name
          Expanded(
            child: Text(
              team.name.value(lang),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Counter Controls
          Row(
            children: [
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
                icon: const Icon(Icons.remove, color: Colors.white70, size: 16),
                onPressed: currentScore > 0 ? onDecrement : null,
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 32,
                child: Text(
                  '$currentScore',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.primary,
                    fontFamily: 'monospace',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.all(4),
                  minimumSize: const Size(32, 32),
                ),
                icon: const Icon(Icons.add, color: Colors.white70, size: 16),
                onPressed: currentScore < 20 ? onIncrement : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
