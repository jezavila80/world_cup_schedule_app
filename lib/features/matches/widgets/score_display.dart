import 'package:flutter/material.dart';
import '../models/world_cup_match.dart';
import '../models/match_result_status.dart';

class ScoreDisplay extends StatelessWidget {
  final WorldCupMatch match;
  final double fontSize;
  final Color? color;

  const ScoreDisplay({
    super.key,
    required this.match,
    this.fontSize = 20,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCompleted = match.resultStatus == MatchResultStatus.completed;

    if (!isCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text(
          'VS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.white60,
          ),
        ),
      );
    }

    final displayColor = color ?? theme.colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '${match.homeScore}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: displayColor,
            fontFamily: 'monospace',
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: fontSize * 0.8,
              fontWeight: FontWeight.bold,
              color: Colors.white54,
            ),
          ),
        ),
        Text(
          '${match.awayScore}',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            color: displayColor,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
