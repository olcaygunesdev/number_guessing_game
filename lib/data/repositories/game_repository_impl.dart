// Remove uuid import - we'll use a simple ID generation
import '../../domain/entities/game.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/repositories/game_repository.dart';
import '../datasources/local_game_datasource.dart';
import '../models/game_model.dart';
// Removed unused import

/// Implementation of GameRepository using local data source
class GameRepositoryImpl implements GameRepository {
  final LocalGameDataSource _localDataSource;
  // Simple ID generation

  GameRepositoryImpl(this._localDataSource);

  @override
  Future<Game> createGame({
    required GameMode mode,
    required List<Player> players,
    GameConfig? config,
  }) async {
    final game = Game(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      players: players,
      mode: mode,
      status: GameStatus.waiting,
      currentPlayerIndex: 0,
      maxGuesses: config?.maxGuesses ?? 10,
      createdAt: DateTime.now(),
    );

    final gameModel = GameModel.fromEntity(game);
    await _localDataSource.saveGame(gameModel);
    await _localDataSource.saveCurrentGameId(game.id);

    return game;
  }

  @override
  Future<void> saveGame(Game game) async {
    final gameModel = GameModel.fromEntity(game);
    await _localDataSource.saveGame(gameModel);
  }

  @override
  Future<Game?> loadGame(String gameId) async {
    final gameModel = await _localDataSource.loadGame(gameId);
    return gameModel?.toEntity();
  }

  @override
  Future<Game> updatePlayer(String gameId, Player player) async {
    final game = await loadGame(gameId);
    if (game == null) throw Exception('Game not found');

    final playerIndex = game.players.indexWhere((p) => p.id == player.id);
    if (playerIndex == -1) throw Exception('Player not found');

    final updatedPlayers = List<Player>.from(game.players);
    updatedPlayers[playerIndex] = player;

    final updatedGame = game.copyWith(players: updatedPlayers);
    await saveGame(updatedGame);

    return updatedGame;
  }

  @override
  Future<Game> addGuess(String gameId, String playerId, String guess, GuessResult result) async {
    final game = await loadGame(gameId);
    if (game == null) throw Exception('Game not found');

    final playerIndex = game.players.indexWhere((p) => p.id == playerId);
    if (playerIndex == -1) throw Exception('Player not found');

    final player = game.players[playerIndex];
    final updatedGuesses = List<String>.from(player.guesses)..add(guess);
    final updatedResults = List<GuessResult>.from(player.guessResults)..add(result);

    final updatedPlayer = player.copyWith(
      guesses: updatedGuesses,
      guessResults: updatedResults,
    );

    return updatePlayer(gameId, updatedPlayer);
  }

  @override
  Future<Game> switchPlayer(String gameId) async {
    final game = await loadGame(gameId);
    if (game == null) throw Exception('Game not found');

    final nextPlayerIndex = (game.currentPlayerIndex + 1) % game.players.length;
    final updatedGame = game.copyWith(currentPlayerIndex: nextPlayerIndex);

    await saveGame(updatedGame);
    return updatedGame;
  }

  @override
  Future<Game> endGame(String gameId, Player winner) async {
    final game = await loadGame(gameId);
    if (game == null) throw Exception('Game not found');

    final updatedGame = game.copyWith(
      status: GameStatus.finished,
      winner: winner,
      finishedAt: DateTime.now(),
    );

    await saveGame(updatedGame);
    return updatedGame;
  }

  @override
  Future<Map<String, dynamic>> getGameStats() async {
    final games = await _localDataSource.getAllGames();
    
    final totalGames = games.length;
    final finishedGames = games.where((g) => g.status == GameStatus.finished.index).length;
    final singlePlayerGames = games.where((g) => g.mode == GameMode.singlePlayer.index).length;
    final multiPlayerGames = games.where((g) => g.mode == GameMode.multiPlayer.index).length;

    return {
      'totalGames': totalGames,
      'finishedGames': finishedGames,
      'singlePlayerGames': singlePlayerGames,
      'multiPlayerGames': multiPlayerGames,
    };
  }

  @override
  Future<void> deleteGame(String gameId) async {
    await _localDataSource.deleteGame(gameId);
  }

  @override
  Future<Game?> getCurrentGame() async {
    final gameModel = await _localDataSource.getCurrentGame();
    return gameModel?.toEntity();
  }

  @override
  Future<void> clearCurrentGame() async {
    await _localDataSource.clearCurrentGame();
  }
}
