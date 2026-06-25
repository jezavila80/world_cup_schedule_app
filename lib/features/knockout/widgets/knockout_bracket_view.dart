import 'package:flutter/material.dart';
import '../../matches/models/world_cup_match.dart';
import '../../matches/data/flag_style_repository.dart';
import '../models/knockout_match_slot.dart';
import 'knockout_match_card.dart';

class KnockoutBracketView extends StatelessWidget {
  final List<KnockoutMatchSlot> slots;
  final List<WorldCupMatch> allMatches;
  final FlagStyleRepository flagStyleRepository;
  final String lang;

  const KnockoutBracketView({
    super.key,
    required this.slots,
    required this.allMatches,
    required this.flagStyleRepository,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: slots.length,
      itemBuilder: (context, index) {
        final slot = slots[index];
        
        // Find corresponding match by matching id (e.g. M073, M074, etc.)
        final matchId = 'M${slot.matchNumber.toString().padLeft(3, '0')}';
        final originalMatch = allMatches.firstWhere(
          (m) => m.id == matchId,
          orElse: () => allMatches.firstWhere(
            (m) => m.id == 'M073',
          ),
        );

        return KnockoutMatchCard(
          slot: slot,
          originalMatch: originalMatch,
          flagStyleRepository: flagStyleRepository,
          lang: lang,
        );
      },
    );
  }
}
