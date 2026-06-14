import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/i18n/locale_helper.dart';
import '../../../core/i18n/app_translations.dart';
import '../data/match_repository.dart';
import '../data/flag_style_repository.dart';
import '../models/world_cup_match.dart';
import '../models/match_result_status.dart';
import '../widgets/match_card.dart';
import '../widgets/edit_result_dialog.dart';
import '../filters/filter_state.dart';
import '../filters/filter_bottom_sheet.dart';
import '../filters/active_filter_chips.dart';
import 'match_detail_screen.dart';
import 'about_screen.dart';

class MatchListScreen extends StatefulWidget {
  final MatchRepository matchRepository;
  final FlagStyleRepository flagStyleRepository;

  const MatchListScreen({
    super.key,
    required this.matchRepository,
    required this.flagStyleRepository,
  });

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  List<WorldCupMatch> _allMatches = [];
  bool _isLoading = true;
  String _errorMessage = '';
  Timer? _refreshTimer;

  // Bottom Navigation state
  int _currentIndex = 0; // 0 = Partidos, 1 = Mis Favoritos

  // Filter State
  FilterState _filterState = const FilterState();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMatches();
    _startAutoRefresh();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowSubscriptionPopup();
    });
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted) {
        setState(() {
          // Triggers recalculation of match statuses using DateTime.now()
        });
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMatches() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final matches = await widget.matchRepository.getMatches();
      setState(() {
        _allMatches = matches;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(WorldCupMatch match, String lang) async {
    try {
      final newIsFav = await widget.matchRepository.toggleFavorite(match.id);
      if (!mounted) return;
      
      setState(() {
        final index = _allMatches.indexWhere((m) => m.id == match.id);
        if (index != -1) {
          _allMatches[index] = _allMatches[index].copyWith(isFavorite: newIsFav);
        }
      });

      // Feedback snackbar
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newIsFav
                ? AppTranslations.translate('addedToFavorites', lang)
                : AppTranslations.translate('removedFromFavorites', lang),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          duration: const Duration(seconds: 1),
          backgroundColor: newIsFav ? const Color(0xFF00FF87) : Colors.grey[800],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppTranslations.translate('errorUpdatingFavorite', lang)}: $e')),
      );
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filterState = const FilterState();
      _searchController.clear();
    });
  }

  List<WorldCupMatch> get _filteredMatches {
    return _filterState.apply(_allMatches, DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final lang = LocaleHelper.supportedLanguageCode(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF00FF87),
                ),
              )
            : _errorMessage.isNotEmpty
                ? _buildErrorWidget(theme, lang)
                : _currentIndex == 0
                    ? _buildMatchesTab(theme, lang)
                    : _buildFavoritesTab(theme, lang),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_month),
            label: AppTranslations.translate('matches', lang),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: AppTranslations.translate('myFavorites', lang),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesTab(ThemeData theme, String lang) {
    final filtered = _filteredMatches;
    final now = DateTime.now();

    // Grouping matches by status
    final liveMatches = filtered.where((m) => m.getStatus(now) == MatchStatus.live).toList();
    final todayMatches = filtered.where((m) => m.getStatus(now) == MatchStatus.today).toList();
    final upcomingMatches = filtered.where((m) => m.getStatus(now) == MatchStatus.upcoming).toList();
    final finishedMatches = filtered.where((m) => m.getStatus(now) == MatchStatus.finished).toList();

    return Column(
      children: [
        // Custom Compact Header
        _buildHeader(theme, lang),

        // Search Bar & Collapsible Filter Buttons
        _buildSearchAndFilters(theme, lang),

        // World Cup Progress Card
        _buildWorldCupProgressCard(theme, lang),

        // Main Content Area
        Expanded(
          child: filtered.isEmpty
              ? _buildEmptyState(theme, lang)
              : RefreshIndicator(
                  onRefresh: _loadMatches,
                  color: const Color(0xFF00FF87),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      if (liveMatches.isNotEmpty) ...[
                        _buildSectionHeader(theme, '${AppTranslations.translate('live', lang).toUpperCase()} 🔴', const Color(0xFFFF4D4D)),
                        ...liveMatches.map((m) => _buildMatchCardItem(m, lang)),
                      ],
                      if (todayMatches.isNotEmpty) ...[
                        _buildSectionHeader(theme, '${AppTranslations.translate('todayMatches', lang).toUpperCase()} 🟢', const Color(0xFF00FF87)),
                        ...todayMatches.map((m) => _buildMatchCardItem(m, lang)),
                      ],
                      if (upcomingMatches.isNotEmpty) ...[
                        _buildSectionHeader(theme, '${AppTranslations.translate('upcomingMatches', lang).toUpperCase()} 🔵', const Color(0xFF94A3B8)),
                        ...upcomingMatches.map((m) => _buildMatchCardItem(m, lang)),
                      ],
                      if (finishedMatches.isNotEmpty) ...[
                        _buildSectionHeader(theme, '${AppTranslations.translate('finished', lang).toUpperCase()} ⚫', const Color(0xFF475569)),
                        ...finishedMatches.map((m) => _buildMatchCardItem(m, lang)),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0, left: 4.0),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCardItem(WorldCupMatch match, String lang) {
    return MatchCard(
      match: match,
      flagStyleHome: widget.flagStyleRepository.getFlagStyle(match.homeTeam.name.en),
      flagStyleAway: widget.flagStyleRepository.getFlagStyle(match.awayTeam.name.en),
      onTap: () async {
        // Navigate to details and reload favorite state on return
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetailScreen(
              match: match,
              matchRepository: widget.matchRepository,
              flagStyleRepository: widget.flagStyleRepository,
              onFavoriteToggled: _loadMatches,
            ),
          ),
        );
        _loadMatches();
      },
      onFavoriteToggled: () => _toggleFavorite(match, lang),
      onEditResult: () => _openEditResultDialog(match),
    );
  }

  Widget _buildWorldCupProgressCard(ThemeData theme, String lang) {
    if (_allMatches.isEmpty) return const SizedBox.shrink();

    final totalMatches = _allMatches.length;
    final completedMatches = _allMatches
        .where((m) => m.resultStatus == MatchResultStatus.completed)
        .length;
    final progress = totalMatches > 0 ? (completedMatches / totalMatches) : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D30),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppTranslations.translate('tournamentProgress', lang),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text(
                '$completedMatches ${AppTranslations.translate('of', lang)} $totalMatches ${AppTranslations.translate('played', lang)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    color: theme.colorScheme.primary,
                    minHeight: 10,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openEditResultDialog(WorldCupMatch match) async {
    final flagStyleHome = widget.flagStyleRepository.getFlagStyle(match.homeTeam.name.en);
    final flagStyleAway = widget.flagStyleRepository.getFlagStyle(match.awayTeam.name.en);

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) => EditResultDialog(
        match: match,
        matchRepository: widget.matchRepository,
        flagStyleHome: flagStyleHome,
        flagStyleAway: flagStyleAway,
      ),
    );

    if (updated == true) {
      _loadMatches();
    }
  }

  Widget _buildFavoritesTab(ThemeData theme, String lang) {
    final favorites = _allMatches.where((m) => m.isFavorite).toList();

    return Column(
      children: [
        // Custom simple header for Favorites
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF0F172A),
                theme.scaffoldBackgroundColor,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppTranslations.translate('myCompetition', lang),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0,
                  color: theme.colorScheme.secondary,
                ),
              ),
              Text(
                AppTranslations.translate('myFavorites', lang),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: favorites.isEmpty
              ? _buildEmptyFavoritesState(theme, lang)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final match = favorites[index];
                    return _buildMatchCardItem(match, lang);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, String lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A),
            theme.scaffoldBackgroundColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'FIFA WORLD CUP',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E294B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'v0.6.0',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'World Cup 2026',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          // World cup styled badge
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E294B),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.5),
                  width: 1.2,
                ),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: Color(0xFFFFD700),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(ThemeData theme, String lang) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search TextField with Settings/Filters Gear Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _filterState = _filterState.copyWith(searchQuery: val);
                    });
                  },
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: AppTranslations.translate('searchHint', lang),
                    hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54, size: 20),
                    filled: true,
                    fillColor: const Color(0xFF151D30),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 1),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Filter/Gear Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF151D30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _filterState.hasActiveFilters
                        ? theme.colorScheme.primary
                        : const Color(0xFF1E294B).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: IconButton(
                  icon: Icon(
                    _filterState.hasActiveFilters ? Icons.settings : Icons.settings_outlined,
                    color: _filterState.hasActiveFilters
                        ? theme.colorScheme.primary
                        : Colors.white70,
                    size: 20,
                  ),
                  onPressed: () => _openFiltersBottomSheet(context, theme),
                ),
              ),
            ],
          ),

          // Resumen Rápido
          _buildQuickSummary(theme, lang),

          // Active Filter Chips
          ActiveFilterChips(
            filterState: _filterState,
            onFilterChanged: (newState) {
              setState(() {
                _filterState = newState;
                if (_searchController.text != newState.searchQuery) {
                  _searchController.text = newState.searchQuery;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSummary(ThemeData theme, String lang) {
    final now = DateTime.now();
    final liveCount = _allMatches.where((m) => m.getStatus(now) == MatchStatus.live).length;
    final todayCount = _allMatches.where((m) => m.getStatus(now) == MatchStatus.today).length;
    final favCount = _allMatches.where((m) => m.isFavorite).length;

    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSummaryItem('🔴', '$liveCount ${AppTranslations.translate('liveLower', lang)}'),
          const SizedBox(width: 16),
          _buildSummaryItem('⚽', '$todayCount ${AppTranslations.translate('todayLower', lang)}'),
          const SizedBox(width: 16),
          _buildSummaryItem('⭐', '$favCount ${AppTranslations.translate('favoritesLower', lang)}'),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String emoji, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _openFiltersBottomSheet(BuildContext context, ThemeData theme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FilterBottomSheet(
          initialState: _filterState,
          onApply: (newState) {
            setState(() {
              _filterState = newState;
              if (_searchController.text != newState.searchQuery) {
                _searchController.text = newState.searchQuery;
              }
            });
          },
        );
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            AppTranslations.translate('noMatchesFound', lang),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Text(
            AppTranslations.translate('tryChangingFilters', lang),
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white30),
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _clearAllFilters,
            icon: const Icon(Icons.refresh, color: Color(0xFF00FF87)),
            label: Text(
              AppTranslations.translate('resetFilters', lang),
              style: const TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyFavoritesState(ThemeData theme, String lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.white30,
          ),
          const SizedBox(height: 16),
          Text(
            AppTranslations.translate('noFavoritesYet', lang),
            style: theme.textTheme.titleMedium?.copyWith(color: Colors.white54),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              AppTranslations.translate('tapHeartToFavorite', lang),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white30),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(AppTranslations.translate('viewFullSchedule', lang), style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(ThemeData theme, String lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              '${AppTranslations.translate('errorLoadingMatches', lang)}: $_errorMessage',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMatches,
              child: Text(AppTranslations.translate('retry', lang)),
            ),
          ],
        ),
      ),
    );
  }

  void _checkAndShowSubscriptionPopup() {
    final shown = widget.matchRepository.isSubscriptionPopupShown();
    if (!shown) {
      _showSubscriptionPopup();
    }
  }

  void _showSubscriptionPopup() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        final lang = LocaleHelper.supportedLanguageCode(dialogContext);
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            backgroundColor: const Color(0xFF151D30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(
                color: Color(0xFF00FF87),
                width: 2,
              ),
            ),
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Color(0xFFFFD700),
                            size: 48,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang == 'es' ? 'Planes de Suscripción' : 'Subscription Plans',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          lang == 'es'
                              ? 'Disfruta de la mejor experiencia sin límites'
                              : 'Enjoy the ultimate experience without limits',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildSubscriptionPlanCard(
                          title: lang == 'es' ? 'Suscripción Básica' : 'Basic Subscription',
                          price: '\$1,000 MXN',
                          features: lang == 'es'
                              ? ['Acceso a fixture completo', 'Estadísticas del torneo', 'Soporte estándar']
                              : ['Full fixture access', 'Tournament stats', 'Standard support'],
                          color: const Color(0xFF00FF87),
                          lang: lang,
                        ),
                        const SizedBox(height: 16),
                        _buildSubscriptionPlanCard(
                          title: lang == 'es' ? 'Suscripción Premium' : 'Premium Subscription',
                          price: '\$1,500 MXN',
                          features: lang == 'es'
                              ? ['Alineaciones en vivo', 'Estadísticas avanzadas', 'Sin anuncios', 'Soporte prioritario']
                              : ['Live lineups', 'Advanced analytics', 'Ad-free experience', 'Priority support'],
                          color: const Color(0xFFFFD700),
                          lang: lang,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          lang == 'es'
                              ? '* Suscripción meramente demostrativa y sin transacciones reales.'
                              : '* Subscription for demonstration purposes only, no real transactions.',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => _confirmCloseSubscriptionPopup(dialogContext),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubscriptionPlanCard({
    required String title,
    required String price,
    required List<String> features,
    required Color color,
    required String lang,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E294B).withOpacity(0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  price,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...features.map((feature) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline_rounded, color: color, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        feature,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: color.withOpacity(0.15),
                foregroundColor: color,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: color.withOpacity(0.5)),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: Text(
                lang == 'es' ? 'Seleccionar' : 'Select',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCloseSubscriptionPopup(BuildContext parentDialogContext) {
    final lang = LocaleHelper.supportedLanguageCode(parentDialogContext);
    showDialog(
      context: parentDialogContext,
      builder: (BuildContext confirmContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151D30),
          title: Text(
            lang == 'es' ? '¿Confirmar cierre?' : 'Confirm Close?',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            lang == 'es'
                ? '¿Estás seguro de que deseas cerrar esta oferta? No volverá a mostrarse al iniciar la aplicación.'
                : 'Are you sure you want to close this offer? It will not be shown again when starting the application.',
            style: const TextStyle(color: Color(0xFFCBD5E1)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(confirmContext).pop();
              },
              child: Text(
                lang == 'es' ? 'Cancelar' : 'Cancel',
                style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                await widget.matchRepository.setSubscriptionPopupShown();
                if (confirmContext.mounted) {
                  Navigator.of(confirmContext).pop();
                }
                if (parentDialogContext.mounted) {
                  Navigator.of(parentDialogContext).pop();
                }
              },
              child: Text(
                lang == 'es' ? 'Sí, cerrar' : 'Yes, close',
                style: const TextStyle(color: Color(0xFFFF4D4D), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
