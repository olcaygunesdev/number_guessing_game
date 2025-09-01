import 'package:hive/hive.dart';
import '../../domain/entities/player.dart';

part 'player_model.g.dart';

@HiveType(typeId: 0)
class PlayerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final String? secretNumber;

  @HiveField(4)
  final List<String> guesses;

  @HiveField(5)
  final List<GuessResultModel> guessResults;

  @HiveField(6)
  final bool isCurrentPlayer;

  @HiveField(7)
  final bool hasWon;

  PlayerModel({
    required this.id,
    required this.name,
    required this.score,
    this.secretNumber,
    required this.guesses,
    required this.guessResults,
    required this.isCurrentPlayer,
    required this.hasWon,
  });

  factory PlayerModel.fromEntity(Player player) {
    return PlayerModel(
      id: player.id,
      name: player.name,
      score: player.score,
      secretNumber: player.secretNumber,
      guesses: player.guesses,
      guessResults: player.guessResults
          .map((result) => GuessResultModel.fromEntity(result))
          .toList(),
      isCurrentPlayer: player.isCurrentPlayer,
      hasWon: player.hasWon,
    );
  }

  Player toEntity() {
    return Player(
      id: id,
      name: name,
      score: score,
      secretNumber: secretNumber,
      guesses: guesses,
      guessResults: guessResults.map((result) => result.toEntity()).toList(),
      isCurrentPlayer: isCurrentPlayer,
      hasWon: hasWon,
    );
  }
}

@HiveType(typeId: 1)
class GuessResultModel extends HiveObject {
  @HiveField(0)
  final String guess;

  @HiveField(1)
  final List<DigitResultModel> digitResults;

  @HiveField(2)
  final DateTime timestamp;

  GuessResultModel({
    required this.guess,
    required this.digitResults,
    required this.timestamp,
  });

  factory GuessResultModel.fromEntity(GuessResult result) {
    return GuessResultModel(
      guess: result.guess,
      digitResults: result.digitResults
          .map((digit) => DigitResultModel.fromEntity(digit))
          .toList(),
      timestamp: result.timestamp,
    );
  }

  GuessResult toEntity() {
    return GuessResult(
      guess: guess,
      digitResults: digitResults.map((digit) => digit.toEntity()).toList(),
      timestamp: timestamp,
    );
  }
}

@HiveType(typeId: 2)
class DigitResultModel extends HiveObject {
  @HiveField(0)
  final String digit;

  @HiveField(1)
  final int position;

  @HiveField(2)
  final int status; // DigitStatus enum as int

  DigitResultModel({
    required this.digit,
    required this.position,
    required this.status,
  });

  factory DigitResultModel.fromEntity(DigitResult result) {
    return DigitResultModel(
      digit: result.digit,
      position: result.position,
      status: result.status.index,
    );
  }

  DigitResult toEntity() {
    return DigitResult(
      digit: digit,
      position: position,
      status: DigitStatus.values[status],
    );
  }
}
