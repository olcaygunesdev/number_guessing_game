import '../entities/game.dart';
import '../entities/player.dart';
import '../entities/game_config.dart';

/// Repository interface for game-related operations
abstract class GameRepository {
  /// Creates a new game
  Future<Game> createGame({
    required GameMode mode,
    required List<Player> players,
    GameConfig? config,
  });

  /// Saves the current game state
  Future<void> saveGame(Game game);

  /// Loads a game by ID
  Future<Game?> loadGame(String gameId);

  /// Updates a player in the game
  Future<Game> updatePlayer(String gameId, Player player);

  /// Adds a guess for a player
  Future<Game> addGuess(String gameId, String playerId, String guess, GuessResult result);

  /// Switches to the next player
  Future<Game> switchPlayer(String gameId);

  /// Ends the game
  Future<Game> endGame(String gameId, Player winner);

  /// Gets game statistics
  Future<Map<String, dynamic>> getGameStats();

  /// Deletes a game
  Future<void> deleteGame(String gameId);

  /// Gets current game (for resume functionality)
  Future<Game?> getCurrentGame();

  /// Clears current game (removes saved state)
  Future<void> clearCurrentGame();
}
