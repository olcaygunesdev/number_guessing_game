import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';

/// Local data source for game operations using Hive
class LocalGameDataSource {
  static const String _gameBoxName = 'games';
  static const String _currentGameKey = 'current_game_id';

  Box<GameModel>? _gameBox;

  /// Initialize the data source
  Future<void> init() async {
    _gameBox = await Hive.openBox<GameModel>(_gameBoxName);
  }

  /// Save a game
  Future<void> saveGame(GameModel game) async {
    await _gameBox?.put(game.id, game);
  }

  /// Load a game by ID
  Future<GameModel?> loadGame(String gameId) async {
    return _gameBox?.get(gameId);
  }

  /// Save current game ID
  Future<void> saveCurrentGameId(String gameId) async {
    print('DEBUG: LocalGameDataSource.saveCurrentGameId - saving gameId: $gameId');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currentGameKey, gameId);
  }

  /// Load current game ID
  Future<String?> loadCurrentGameId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_currentGameKey);
  }

  /// Delete a game
  Future<void> deleteGame(String gameId) async {
    await _gameBox?.delete(gameId);
  }

  /// Get all games
  Future<List<GameModel>> getAllGames() async {
    return _gameBox?.values.toList() ?? [];
  }

  /// Clear all games
  Future<void> clearAllGames() async {
    await _gameBox?.clear();
  }

  /// Get current game for resume functionality
  Future<GameModel?> getCurrentGame() async {
    final currentGameId = await loadCurrentGameId();
    print('DEBUG: LocalGameDataSource.getCurrentGame - currentGameId: $currentGameId');
    if (currentGameId != null) {
      final game = await loadGame(currentGameId);
      print('DEBUG: LocalGameDataSource.getCurrentGame - loaded game: ${game?.id}, status: ${game?.status}');
      return game;
    }
    return null;
  }

  /// Clear current game (remove saved state)
  Future<void> clearCurrentGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentGameKey);
  }
}
