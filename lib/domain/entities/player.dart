import 'package:equatable/equatable.dart';

/// Player entity representing a game participant
class Player extends Equatable {
  final String id;
  final String name;
  final int score;
  final String? secretNumber;
  final List<String> guesses;
  final List<GuessResult> guessResults;
  final bool isCurrentPlayer;
  final bool hasWon;

  const Player({
    required this.id,
    required this.name,
    this.score = 0,
    this.secretNumber,
    this.guesses = const [],
    this.guessResults = const [],
    this.isCurrentPlayer = false,
    this.hasWon = false,
  });

  Player copyWith({
    String? id,
    String? name,
    int? score,
    String? secretNumber,
    List<String>? guesses,
    List<GuessResult>? guessResults,
    bool? isCurrentPlayer,
    bool? hasWon,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      score: score ?? this.score,
      secretNumber: secretNumber ?? this.secretNumber,
      guesses: guesses ?? this.guesses,
      guessResults: guessResults ?? this.guessResults,
      isCurrentPlayer: isCurrentPlayer ?? this.isCurrentPlayer,
      hasWon: hasWon ?? this.hasWon,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        score,
        secretNumber,
        guesses,
        guessResults,
        isCurrentPlayer,
        hasWon,
      ];
}

/// Represents the result of a guess
class GuessResult extends Equatable {
  final String guess;
  final List<DigitResult> digitResults;
  final DateTime timestamp;

  const GuessResult({
    required this.guess,
    required this.digitResults,
    required this.timestamp,
  });

  @override
  List<Object> get props => [guess, digitResults, timestamp];
}

/// Represents the result of a single digit in a guess
class DigitResult extends Equatable {
  final String digit;
  final int position;
  final DigitStatus status;

  const DigitResult({
    required this.digit,
    required this.position,
    required this.status,
  });

  @override
  List<Object> get props => [digit, position, status];
}

/// Status of a digit in a guess
enum DigitStatus {
  correct,    // Digit is correct and in the right position (Green)
  wrongPlace, // Digit exists but in wrong position (Yellow)
  notFound,   // Digit doesn't exist in the secret number (Red)
}
