import 'package:shared_preferences/shared_preferences.dart';

class FavoritesStorage {
  final SharedPreferences _prefs;
  static const String _key = 'favorite_matches_ids';

  FavoritesStorage(this._prefs);

  /// Retrieves the list of favorite match IDs stored locally.
  List<String> getFavorites() {
    return _prefs.getStringList(_key) ?? [];
  }

  /// Toggles a match's favorite state in the local storage.
  /// Returns true if the state was successfully updated.
  Future<bool> toggleFavorite(String matchId) async {
    final favorites = getFavorites();
    if (favorites.contains(matchId)) {
      favorites.remove(matchId);
    } else {
      favorites.add(matchId);
    }
    return _prefs.setStringList(_key, favorites);
  }

  /// Checks if a match is marked as favorite in the local list.
  bool isFavorite(String matchId) {
    return getFavorites().contains(matchId);
  }
}
