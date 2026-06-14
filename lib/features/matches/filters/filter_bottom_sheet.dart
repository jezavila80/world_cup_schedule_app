import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import 'filter_state.dart';

class FilterBottomSheet extends StatefulWidget {
  final FilterState initialState;
  final ValueChanged<FilterState> onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialState,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String _hostCountry;
  late String _stage;
  late bool _showOnlyFavorites;
  late String _status;
  late String _resultsFilter;

  @override
  void initState() {
    super.initState();
    _hostCountry = widget.initialState.hostCountry;
    _stage = widget.initialState.stage;
    _showOnlyFavorites = widget.initialState.showOnlyFavorites;
    _status = widget.initialState.status;
    _resultsFilter = widget.initialState.resultsFilter;
  }

  void _clearFilters() {
    setState(() {
      _hostCountry = 'All';
      _stage = 'All';
      _showOnlyFavorites = false;
      _status = 'All';
      _resultsFilter = 'All';
    });
  }

  void _applyFilters() {
    final state = FilterState(
      searchQuery: widget.initialState.searchQuery,
      hostCountry: _hostCountry,
      stage: _stage,
      showOnlyFavorites: _showOnlyFavorites,
      status: _status,
      resultsFilter: _resultsFilter,
    );
    widget.onApply(state);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppTranslations.translate('matchFilters', lang),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Colors.white10),
              const SizedBox(height: 16),

              // Host Country Section
              _buildSectionTitle(AppTranslations.translate('hostCountry', lang)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildChoiceChip(AppTranslations.translate('all', lang), _hostCountry == 'All', () => setState(() => _hostCountry = 'All')),
                  _buildChoiceChip(lang == 'es' ? 'México 🇲🇽' : 'Mexico 🇲🇽', _hostCountry == 'Mexico', () => setState(() => _hostCountry = 'Mexico')),
                  _buildChoiceChip('USA 🇺🇸', _hostCountry == 'USA', () => setState(() => _hostCountry = 'USA')),
                  _buildChoiceChip(lang == 'es' ? 'Canadá 🇨🇦' : 'Canada 🇨🇦', _hostCountry == 'Canada', () => setState(() => _hostCountry = 'Canada')),
                ],
              ),
              const SizedBox(height: 20),

              // Stage Section
              _buildSectionTitle(AppTranslations.translate('tournamentStage', lang)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _stage,
                dropdownColor: const Color(0xFF151D30),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF151D30),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: [
                  DropdownMenuItem(value: 'All', child: Text(AppTranslations.translate('allStages', lang))),
                  DropdownMenuItem(value: 'Group Stage', child: Text(AppTranslations.translate('groupStage', lang))),
                  DropdownMenuItem(value: 'Eliminatorias', child: Text(AppTranslations.translate('knockoutStage', lang))),
                  DropdownMenuItem(value: 'Round of 32', child: Text(AppTranslations.translate('roundOf32', lang))),
                  DropdownMenuItem(value: 'Round of 16', child: Text(AppTranslations.translate('roundOf16', lang))),
                  DropdownMenuItem(value: 'Quarter-finals', child: Text(AppTranslations.translate('quarterFinals', lang))),
                  DropdownMenuItem(value: 'Semi-finals', child: Text(AppTranslations.translate('semiFinals', lang))),
                  DropdownMenuItem(value: 'Play-off for third place', child: Text(AppTranslations.translate('thirdPlace', lang))),
                  DropdownMenuItem(value: 'Final', child: Text(AppTranslations.translate('grandFinal', lang))),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _stage = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Favorites Section
              _buildSectionTitle(AppTranslations.translate('favorites', lang)),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(AppTranslations.translate('showFavoritesOnly', lang), style: const TextStyle(color: Colors.white70)),
                secondary: Icon(
                  _showOnlyFavorites ? Icons.favorite : Icons.favorite_border,
                  color: _showOnlyFavorites ? Colors.redAccent : Colors.white54,
                ),
                value: _showOnlyFavorites,
                activeColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _showOnlyFavorites = val);
                },
              ),
              const SizedBox(height: 12),

              // Status Section
              _buildSectionTitle(AppTranslations.translate('matchStatus', lang)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildChoiceChip(AppTranslations.translate('all', lang), _status == 'All', () => setState(() => _status = 'All')),
                  _buildChoiceChip('${AppTranslations.translate('live', lang)} 🔴', _status == 'live', () => setState(() => _status = 'live')),
                  _buildChoiceChip('${lang == 'es' ? 'Hoy' : 'Today'} 🟢', _status == 'today', () => setState(() => _status = 'today')),
                  _buildChoiceChip('${AppTranslations.translate('tomorrow', lang)} 🟡', _status == 'tomorrow', () => setState(() => _status = 'tomorrow')),
                  _buildChoiceChip('${AppTranslations.translate('next3Days', lang)} 📅', _status == 'next3days', () => setState(() => _status = 'next3days')),
                  _buildChoiceChip('${AppTranslations.translate('upcoming', lang)} 🔵', _status == 'upcoming', () => setState(() => _status = 'upcoming')),
                  _buildChoiceChip('${AppTranslations.translate('finished', lang)} ⚫', _status == 'finished', () => setState(() => _status = 'finished')),
                ],
              ),
              const SizedBox(height: 20),

              // Results Filter Section
              _buildSectionTitle(AppTranslations.translate('matchResults', lang)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  _buildChoiceChip(AppTranslations.translate('all', lang), _resultsFilter == 'All', () => setState(() => _resultsFilter = 'All')),
                  _buildChoiceChip('${AppTranslations.translate('withScore', lang)} 🏆', _resultsFilter == 'with_result', () => setState(() => _resultsFilter = 'with_result')),
                  _buildChoiceChip('${AppTranslations.translate('withoutScore', lang)} ⏳', _resultsFilter == 'without_result', () => setState(() => _resultsFilter = 'without_result')),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _clearFilters,
                      child: Text(AppTranslations.translate('clearFilters', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _applyFilters,
                      child: Text(AppTranslations.translate('applyFilters', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.white54,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildChoiceChip(String label, bool isSelected, VoidCallback onSelected) {
    final theme = Theme.of(context);
    return ChoiceChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onSelected(),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      backgroundColor: const Color(0xFF151D30),
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.5) : Colors.transparent,
        ),
      ),
    );
  }
}
