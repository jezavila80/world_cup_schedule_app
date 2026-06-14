import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import 'filter_state.dart';

class ActiveFilterChips extends StatelessWidget {
  final FilterState filterState;
  final ValueChanged<FilterState> onFilterChanged;

  const ActiveFilterChips({
    super.key,
    required this.filterState,
    required this.onFilterChanged,
  });

  String _getStageLabel(String stage, String lang) {
    switch (stage) {
      case 'Group Stage':
        return AppTranslations.translate('groupStage', lang);
      case 'Eliminatorias':
        return AppTranslations.translate('knockoutStage', lang);
      case 'Round of 32':
        return lang == 'es' ? 'Dieciseisavos' : 'Round of 32';
      case 'Round of 16':
        return lang == 'es' ? 'Octavos' : 'Round of 16';
      case 'Quarter-finals':
        return lang == 'es' ? 'Cuartos' : 'Quarter-finals';
      case 'Semi-finals':
        return lang == 'es' ? 'Semifinales' : 'Semi-finals';
      case 'Play-off for third place':
        return lang == 'es' ? '3er Lugar' : 'Third Place';
      case 'Final':
        return AppTranslations.translate('grandFinal', lang);
      default:
        return stage;
    }
  }

  String _getStatusLabel(String status, String lang) {
    switch (status) {
      case 'live':
        return '${AppTranslations.translate('live', lang)} 🔴';
      case 'today':
        return '${lang == 'es' ? 'Hoy' : 'Today'} 🟢';
      case 'tomorrow':
        return '${AppTranslations.translate('tomorrow', lang)} 🟡';
      case 'next3days':
        return '${AppTranslations.translate('next3Days', lang)} 📅';
      case 'upcoming':
        return '${AppTranslations.translate('upcoming', lang)} 🔵';
      case 'finished':
        return '${AppTranslations.translate('finished', lang)} ⚫';
      default:
        return status;
    }
  }

  String _getResultsLabel(String resultsFilter, String lang) {
    switch (resultsFilter) {
      case 'with_result':
        return '${AppTranslations.translate('withScore', lang)} 🏆';
      case 'without_result':
        return '${AppTranslations.translate('withoutScore', lang)} ⏳';
      default:
        return resultsFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!filterState.hasActiveFilters) {
      return const SizedBox.shrink();
    }

    final lang = LocaleHelper.supportedLanguageCode(context);
    final chips = <Widget>[];

    if (filterState.hostCountry != 'All') {
      final label = filterState.hostCountry == 'Mexico'
          ? (lang == 'es' ? 'México' : 'Mexico')
          : filterState.hostCountry == 'Canada'
              ? (lang == 'es' ? 'Canadá' : 'Canada')
              : filterState.hostCountry;
      chips.add(
        _buildChip(
          context,
          label,
          () => onFilterChanged(filterState.copyWith(hostCountry: 'All')),
        ),
      );
    }

    if (filterState.stage != 'All') {
      chips.add(
        _buildChip(
          context,
          _getStageLabel(filterState.stage, lang),
          () => onFilterChanged(filterState.copyWith(stage: 'All')),
        ),
      );
    }

    if (filterState.showOnlyFavorites) {
      chips.add(
        _buildChip(
          context,
          AppTranslations.translate('favorites', lang),
          () => onFilterChanged(filterState.copyWith(showOnlyFavorites: false)),
        ),
      );
    }

    if (filterState.status != 'All') {
      chips.add(
        _buildChip(
          context,
          _getStatusLabel(filterState.status, lang),
          () => onFilterChanged(filterState.copyWith(status: 'All')),
        ),
      );
    }

    if (filterState.resultsFilter != 'All') {
      chips.add(
        _buildChip(
          context,
          _getResultsLabel(filterState.resultsFilter, lang),
          () => onFilterChanged(filterState.copyWith(resultsFilter: 'All')),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: chips,
        ),
      ),
    );
  }

  Widget _buildChip(BuildContext context, String label, VoidCallback onDelete) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        deleteIcon: Icon(
          Icons.cancel,
          size: 16,
          color: theme.colorScheme.primary.withOpacity(0.8),
        ),
        onDeleted: onDelete,
        backgroundColor: const Color(0xFF151D30),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.15),
          ),
        ),
      ),
    );
  }
}
