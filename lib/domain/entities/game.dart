import 'package:equatable/equatable.dart';
import 'player.dart';

/// Game entity representing the main game state
class Game extends Equatable {
  final String id;
  final List<Player> players;
  final GameMode mode;
  final GameStatus status;
  final int currentPlayerIndex;
  final int maxGuesses;
  final DateTime createdAt;
  final DateTime? finishedAt;
  final Player? winner;

  const Game({
    required this.id,
    required this.players,
    required this.mode,
    this.status = GameStatus.waiting,
    this.currentPlayerIndex = 0,
    this.maxGuesses = 10,
    required this.createdAt,
    this.finishedAt,
    this.winner,
  });

  Game copyWith({
    String? id,
    List<Player>? players,
    GameMode? mode,
    GameStatus? status,
    int? currentPlayerIndex,
    int? maxGuesses,
    DateTime? createdAt,
    DateTime? finishedAt,
    Player? winner,
  }) {
    return Game(
      id: id ?? this.id,
      players: players ?? this.players,
      mode: mode ?? this.mode,
      status: status ?? this.status,
      currentPlayerIndex: currentPlayerIndex ?? this.currentPlayerIndex,
      maxGuesses: maxGuesses ?? this.maxGuesses,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
      winner: winner ?? this.winner,
    );
  }

  /// Get the current player
  Player get currentPlayer => players[currentPlayerIndex];

  /// Check if all players have set their secret numbers
  bool get allPlayersReady => players.every((player) => player.secretNumber != null);

  /// Get the opponent player (for 2-player mode)
  Player? get opponent {
    if (players.length != 2) return null;
    return players.firstWhere((player) => player.id != currentPlayer.id);
  }

  @override
  List<Object?> get props => [
        id,
        players,
        mode,
        status,
        currentPlayerIndex,
        maxGuesses,
        createdAt,
        finishedAt,
        winner,
      ];
}

/// Game modes
enum GameMode {
  singlePlayer, // Against computer
  multiPlayer,  // Two players against each other
}

/// Game status
enum GameStatus {
  waiting,      // Waiting for players to join/set numbers
  settingUp,    // Players are setting their secret numbers
  playing,      // Game in progress
  finished,     // Game finished
  paused,       // Game paused
}
