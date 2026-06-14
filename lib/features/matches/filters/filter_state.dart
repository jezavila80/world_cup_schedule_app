import '../models/world_cup_match.dart';
import '../models/match_result_status.dart';

class FilterState {
  final String searchQuery;
  final String hostCountry; // 'All', 'Mexico', 'USA', 'Canada'
  final String stage; // 'All', 'Group Stage', 'Eliminatorias', 'Round of 32', etc.
  final bool showOnlyFavorites;
  final String status; // 'All', 'live', 'today', 'upcoming', 'finished'
  final String resultsFilter; // 'All', 'with_result', 'without_result'

  const FilterState({
    this.searchQuery = '',
    this.hostCountry = 'All',
    this.stage = 'All',
    this.showOnlyFavorites = false,
    this.status = 'All',
    this.resultsFilter = 'All',
  });

  FilterState copyWith({
    String? searchQuery,
    String? hostCountry,
    String? stage,
    bool? showOnlyFavorites,
    String? status,
    String? resultsFilter,
  }) {
    return FilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      hostCountry: hostCountry ?? this.hostCountry,
      stage: stage ?? this.stage,
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      status: status ?? this.status,
      resultsFilter: resultsFilter ?? this.resultsFilter,
    );
  }

  bool get hasActiveFilters {
    return hostCountry != 'All' ||
        stage != 'All' ||
        showOnlyFavorites ||
        status != 'All' ||
        resultsFilter != 'All';
  }

  List<WorldCupMatch> apply(List<WorldCupMatch> matches, DateTime now) {
    return matches.where((match) {
      // Search Query
      if (searchQuery.isNotEmpty) {
        if (!match.matchesSearchQuery(searchQuery)) return false;
      }

      // Host Country
      if (hostCountry != 'All') {
        if (match.country.name.en.toLowerCase() != hostCountry.toLowerCase() &&
            match.country.name.es.toLowerCase() != hostCountry.toLowerCase() &&
            match.country.id != hostCountry.toLowerCase()) {
          return false;
        }
      }

      // Stage
      if (stage != 'All') {
        if (stage == 'Group Stage') {
          if (match.stage.id != 'group_stage') return false;
        } else if (stage == 'Eliminatorias' || stage == 'Knockout Stage') {
          if (match.stage.id == 'group_stage') return false;
        } else {
          // Specific stage comparison
          if (match.stage.name.en.toLowerCase() != stage.toLowerCase() &&
              match.stage.name.es.toLowerCase() != stage.toLowerCase() &&
              match.stage.id != stage.toLowerCase()) {
            return false;
          }
        }
      }

      // Favorites
      if (showOnlyFavorites) {
        if (!match.isFavorite) return false;
      }

      // Status
      if (status != 'All') {
        final matchStatus = match.getStatus(now);
        if (status == 'live' && matchStatus != MatchStatus.live) return false;
        if (status == 'today' && matchStatus != MatchStatus.today) return false;
        if (status == 'tomorrow') {
          final localStart = match.startDateTime.toLocal();
          final localTomorrow = now.toLocal().add(const Duration(days: 1));
          final isTomorrow = localStart.year == localTomorrow.year &&
              localStart.month == localTomorrow.month &&
              localStart.day == localTomorrow.day;
          if (!isTomorrow) return false;
        }
        if (status == 'next3days') {
          final localStart = match.startDateTime.toLocal();
          final localNow = now.toLocal();
          final startDate = DateTime(localStart.year, localStart.month, localStart.day);
          final todayDate = DateTime(localNow.year, localNow.month, localNow.day);
          final diffDays = startDate.difference(todayDate).inDays;
          // Option B: today (0), tomorrow (1), and the day after tomorrow (2)
          if (diffDays < 0 || diffDays > 2) return false;
        }
        if (status == 'upcoming' && matchStatus != MatchStatus.upcoming) return false;
        if (status == 'finished' && matchStatus != MatchStatus.finished) return false;
      }

      // Results Filter
      if (resultsFilter != 'All') {
        if (resultsFilter == 'with_result' && match.resultStatus != MatchResultStatus.completed) {
          return false;
        }
        if (resultsFilter == 'without_result' && match.resultStatus == MatchResultStatus.completed) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
