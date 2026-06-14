import '../../../core/storage/favorites_storage.dart';
import '../models/world_cup_match.dart';
import '../services/match_result_service.dart';
import 'match_local_data_source.dart';

class MatchRepository {
  final MatchLocalDataSource _localDataSource;
  final FavoritesStorage _favoritesStorage;
  final MatchResultService _resultService;

  MatchRepository({
    required MatchLocalDataSource localDataSource,
    required FavoritesStorage favoritesStorage,
    required MatchResultService resultService,
  })  : _localDataSource = localDataSource,
        _favoritesStorage = favoritesStorage,
        _resultService = resultService;

  /// Retrieves all matches, with their correct isFavorite status and score results resolved.
  Future<List<WorldCupMatch>> getMatches() async {
    final matches = await _localDataSource.getMatches();
    final favoriteIds = _favoritesStorage.getFavorites();
    final scoresMap = _resultService.getScores();

    return matches.map((match) {
      final isFav = favoriteIds.contains(match.id);
      final scoreData = scoresMap[match.id];
      if (scoreData != null) {
        return match.copyWith(
          isFavorite: isFav,
          homeScore: scoreData.homeScore,
          awayScore: scoreData.awayScore,
          resultStatus: scoreData.resultStatus,
        );
      }
      return match.copyWith(isFavorite: isFav);
    }).toList();
  }

  /// Saves the score result of a match offline.
  Future<bool> saveMatchResult(String matchId, int homeScore, int awayScore) async {
    return _resultService.saveScore(matchId, homeScore, awayScore);
  }

  /// Toggles the favorite status of a match and returns the new value.
  Future<bool> toggleFavorite(String matchId) async {
    await _favoritesStorage.toggleFavorite(matchId);
    return _favoritesStorage.isFavorite(matchId);
  }

  /// Checks if a match is favorited.
  bool isFavorite(String matchId) {
    return _favoritesStorage.isFavorite(matchId);
  }

  /// Checks if the subscription popup has been shown.
  bool isSubscriptionPopupShown() {
    return _resultService.isSubscriptionPopupShown();
  }

  /// Sets the subscription popup as shown.
  Future<bool> setSubscriptionPopupShown() {
    return _resultService.setSubscriptionPopupShown();
  }
}
