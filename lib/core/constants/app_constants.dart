/// Application constants
class AppConstants {
  // App Info
  static const String appName = 'Number Guessing Game';
  static const String appVersion = '1.0.0';
  
  // Game Rules
  static const int defaultNumberLength = 4;
  static const int minNumberLength = 3;
  static const int maxNumberLength = 6;
  static const int defaultMaxGuesses = 10;
  static const int minMaxGuesses = 5;
  static const int maxMaxGuesses = 20;
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double buttonHeight = 48.0;
  static const double cardElevation = 4.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Colors (Material 3 Design)
  static const int primaryColorValue = 0xFF6750A4;
  static const int secondaryColorValue = 0xFF625B71;
  static const int errorColorValue = 0xFFBA1A1A;
  static const int successColorValue = 0xFF00A843;
  static const int warningColorValue = 0xFFFF9800;
  
  // Player IDs
  static const String humanPlayerId = 'human_player';
  static const String computerPlayerId = 'computer_player';
  static const String player1Id = 'player_1';
  static const String player2Id = 'player_2';
  
  // Storage Keys
  static const String currentGameKey = 'current_game';
  static const String playerNameKey = 'player_name';
  static const String gameConfigKey = 'game_config';
  
  // Default Values
  static const String defaultPlayerName = 'Player';
  static const String defaultComputerName = 'Computer';
  
  // Validation Messages
  static const String invalidNumberLengthMessage = 'Number must be exactly %d digits long';
  static const String invalidDigitsMessage = 'Number must contain only digits';
  static const String noLeadingZeroMessage = 'Number cannot start with zero';
  static const String noDuplicateDigitsMessage = 'Number cannot contain duplicate digits';
  static const String emptyPlayerNameMessage = 'Player name cannot be empty';
  
  // Game Messages
  static const String gameWonMessage = 'Congratulations! You won!';
  static const String gameLostMessage = 'Game over! Better luck next time.';
  static const String correctGuessMessage = 'Perfect! You found the number!';
  static const String makeGuessMessage = 'Make your guess';
  static const String waitingForOpponentMessage = 'Waiting for opponent...';
  
  // Sound File Paths (to be added later)
  static const String correctGuessSoundPath = 'sounds/correct_guess.wav';
  static const String wrongGuessSoundPath = 'sounds/wrong_guess.wav';
  static const String gameWonSoundPath = 'sounds/game_won.wav';
  static const String gameLostSoundPath = 'sounds/game_lost.wav';
  static const String buttonClickSoundPath = 'sounds/button_click.wav';
}
