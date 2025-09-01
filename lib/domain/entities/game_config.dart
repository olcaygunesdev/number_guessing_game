import 'package:equatable/equatable.dart';

/// Configuration for the number guessing game
class GameConfig extends Equatable {
  final int numberLength;
  final bool allowDuplicateDigits;
  final bool allowLeadingZero;
  final int maxGuesses;
  final int timeoutDuration; // in seconds
  final bool soundEnabled;
  final bool animationsEnabled;

  const GameConfig({
    this.numberLength = 4,
    this.allowDuplicateDigits = false,
    this.allowLeadingZero = false,
    this.maxGuesses = 10,
    this.timeoutDuration = 30,
    this.soundEnabled = true,
    this.animationsEnabled = true,
  });

  GameConfig copyWith({
    int? numberLength,
    bool? allowDuplicateDigits,
    bool? allowLeadingZero,
    int? maxGuesses,
    int? timeoutDuration,
    bool? soundEnabled,
    bool? animationsEnabled,
  }) {
    return GameConfig(
      numberLength: numberLength ?? this.numberLength,
      allowDuplicateDigits: allowDuplicateDigits ?? this.allowDuplicateDigits,
      allowLeadingZero: allowLeadingZero ?? this.allowLeadingZero,
      maxGuesses: maxGuesses ?? this.maxGuesses,
      timeoutDuration: timeoutDuration ?? this.timeoutDuration,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      animationsEnabled: animationsEnabled ?? this.animationsEnabled,
    );
  }

  /// Default game configuration
  static const GameConfig defaultConfig = GameConfig();

  @override
  List<Object> get props => [
        numberLength,
        allowDuplicateDigits,
        allowLeadingZero,
        maxGuesses,
        timeoutDuration,
        soundEnabled,
        animationsEnabled,
      ];
}
