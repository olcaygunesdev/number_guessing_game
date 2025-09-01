import 'package:hive/hive.dart';
import '../../domain/entities/game.dart';
import 'player_model.dart';

part 'game_model.g.dart';

@HiveType(typeId: 3)
class GameModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<PlayerModel> players;

  @HiveField(2)
  final int mode; // GameMode enum as int

  @HiveField(3)
  final int status; // GameStatus enum as int

  @HiveField(4)
  final int currentPlayerIndex;

  @HiveField(5)
  final int maxGuesses;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime? finishedAt;

  @HiveField(8)
  final PlayerModel? winner;

  GameModel({
    required this.id,
    required this.players,
    required this.mode,
    required this.status,
    required this.currentPlayerIndex,
    required this.maxGuesses,
    required this.createdAt,
    this.finishedAt,
    this.winner,
  });

  factory GameModel.fromEntity(Game game) {
    return GameModel(
      id: game.id,
      players: game.players
          .map((player) => PlayerModel.fromEntity(player))
          .toList(),
      mode: game.mode.index,
      status: game.status.index,
      currentPlayerIndex: game.currentPlayerIndex,
      maxGuesses: game.maxGuesses,
      createdAt: game.createdAt,
      finishedAt: game.finishedAt,
      winner: game.winner != null ? PlayerModel.fromEntity(game.winner!) : null,
    );
  }

  Game toEntity() {
    return Game(
      id: id,
      players: players.map((player) => player.toEntity()).toList(),
      mode: GameMode.values[mode],
      status: GameStatus.values[status],
      currentPlayerIndex: currentPlayerIndex,
      maxGuesses: maxGuesses,
      createdAt: createdAt,
      finishedAt: finishedAt,
      winner: winner?.toEntity(),
    );
  }
}
