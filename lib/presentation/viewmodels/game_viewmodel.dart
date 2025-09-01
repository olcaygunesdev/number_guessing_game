import 'package:flutter/foundation.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/player.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/repositories/game_repository.dart';
import '../../domain/usecases/validate_number.dart';
import '../../domain/usecases/check_guess.dart';
import '../../domain/usecases/generate_computer_number.dart';

/// ViewModel for managing game state and operations
class GameViewModel extends ChangeNotifier {
  final GameRepository _gameRepository;
  final ValidateNumber _validateNumber;
  final CheckGuess _checkGuess;
  final GenerateComputerNumber _generateComputerNumber;

  GameViewModel(
    this._gameRepository,
    this._validateNumber,
    this._checkGuess,
    this._generateComputerNumber,
  );

  Game? _currentGame;
  GameConfig _gameConfig = GameConfig.defaultConfig;
  bool _isLoading = false;
  String? _error;

  // Getters
  Game? get currentGame => _currentGame;
  GameConfig get gameConfig => _gameConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Player? get currentPlayer => _currentGame?.currentPlayer;
  Player? get opponent => _currentGame?.opponent;
  bool get isGameFinished => _currentGame?.status == GameStatus.finished;
  bool get canMakeGuess => _currentGame?.status == GameStatus.playing && !isGameFinished;

  /// Start a new single player game
  Future<void> startSinglePlayerGame(String playerName) async {
    try {
      _setLoading(true);
      _clearError();

      // Create human player
      final humanPlayer = Player(
        id: 'human_player',
        name: playerName,
      );

      // Create computer player with generated number
      final computerNumber = _generateComputerNumber(_gameConfig);
      final computerPlayer = Player(
        id: 'computer_player',
        name: 'Computer',
        secretNumber: computerNumber,
      );

      // Create game
      _currentGame = await _gameRepository.createGame(
        mode: GameMode.singlePlayer,
        players: [humanPlayer, computerPlayer],
        config: _gameConfig,
      );

      // Set initial status
      _currentGame = _currentGame!.copyWith(status: GameStatus.settingUp);
      await _gameRepository.saveGame(_currentGame!);

      notifyListeners();
    } catch (e) {
      _setError('Failed to start game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Start a new multiplayer game
  Future<void> startMultiPlayerGame(String player1Name, String player2Name) async {
    try {
      _setLoading(true);
      _clearError();

      final player1 = Player(
        id: 'player_1',
        name: player1Name,
        isCurrentPlayer: true,
      );

      final player2 = Player(
        id: 'player_2',
        name: player2Name,
      );

      _currentGame = await _gameRepository.createGame(
        mode: GameMode.multiPlayer,
        players: [player1, player2],
        config: _gameConfig,
      );

      _currentGame = _currentGame!.copyWith(status: GameStatus.settingUp);
      await _gameRepository.saveGame(_currentGame!);

      notifyListeners();
    } catch (e) {
      _setError('Failed to start multiplayer game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Set player's secret number
  Future<bool> setPlayerSecretNumber(String playerId, String number) async {
    try {
      _clearError();

      // Validate number
      final validation = _validateNumber(number, _gameConfig);
      if (!validation.isValid) {
        _setError(validation.error!);
        return false;
      }

      if (_currentGame == null) {
        _setError('No active game');
        return false;
      }

      // Find and update player
      final playerIndex = _currentGame!.players.indexWhere((p) => p.id == playerId);
      if (playerIndex == -1) {
        _setError('Player not found');
        return false;
      }

      final updatedPlayer = _currentGame!.players[playerIndex].copyWith(
        secretNumber: number,
      );

      _currentGame = await _gameRepository.updatePlayer(_currentGame!.id, updatedPlayer);

      // Check if all players are ready
      if (_currentGame!.allPlayersReady) {
        _currentGame = _currentGame!.copyWith(status: GameStatus.playing);
        await _gameRepository.saveGame(_currentGame!);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to set secret number: $e');
      return false;
    }
  }

  /// Make a guess
  Future<bool> makeGuess(String guess) async {
    try {
      _clearError();

      if (_currentGame == null || currentPlayer == null) {
        _setError('No active game or player');
        return false;
      }

      if (!canMakeGuess) {
        _setError('Cannot make guess at this time');
        return false;
      }

      // Validate guess
      final validation = _validateNumber(guess, _gameConfig);
      if (!validation.isValid) {
        _setError(validation.error!);
        return false;
      }

      // Get opponent's secret number
      final opponentSecret = opponent?.secretNumber;
      if (opponentSecret == null) {
        _setError('Opponent secret number not found');
        return false;
      }

      // Check guess
      final guessResult = _checkGuess(guess, opponentSecret);
      final isCorrect = _checkGuess.isCorrectGuess(guessResult);

      // Add guess to current player
      _currentGame = await _gameRepository.addGuess(
        _currentGame!.id,
        currentPlayer!.id,
        guess,
        guessResult,
      );

      // Check if player won
      if (isCorrect) {
        final winner = currentPlayer!.copyWith(hasWon: true);
        _currentGame = await _gameRepository.endGame(_currentGame!.id, winner);
      } else {
        // Switch to next player
        if (_currentGame!.mode == GameMode.multiPlayer) {
          _currentGame = await _gameRepository.switchPlayer(_currentGame!.id);
        } else if (_currentGame!.mode == GameMode.singlePlayer) {
          // In single player, switch to computer
          _currentGame = await _gameRepository.switchPlayer(_currentGame!.id);
          
          // After switching, if it's computer's turn, make computer guess
          if (currentPlayer?.id == 'computer_player') {
            // Delay for better UX (computer thinking)
            Future.delayed(const Duration(seconds: 2), () {
              _makeComputerGuess();
            });
          }
        }
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Failed to make guess: $e');
      return false;
    }
  }

  /// Load an existing game
  Future<void> loadGame(String gameId) async {
    try {
      _setLoading(true);
      _clearError();

      _currentGame = await _gameRepository.loadGame(gameId);
      if (_currentGame == null) {
        _setError('Game not found');
      }

      notifyListeners();
    } catch (e) {
      _setError('Failed to load game: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// End current game
  Future<void> endGame() async {
    try {
      if (_currentGame != null) {
        await _gameRepository.deleteGame(_currentGame!.id);
        _currentGame = null;
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to end game: $e');
    }
  }

  /// Update game configuration
  void updateGameConfig(GameConfig config) {
    _gameConfig = config;
    notifyListeners();
  }

  /// Check if there's a saved single player game
  Future<bool> hasSavedSinglePlayerGame() async {
    try {
      final savedGame = await _gameRepository.getCurrentGame();
      print('DEBUG: HasSaved - savedGame: $savedGame');
      final result = savedGame != null && 
             savedGame.mode == GameMode.singlePlayer && 
             savedGame.status != GameStatus.finished;
      print('DEBUG: HasSaved - result: $result');
      return result;
    } catch (e) {
      print('DEBUG: HasSaved - Exception: $e');
      return false;
    }
  }

  /// Resume saved single player game
  Future<bool> resumeSavedGame() async {
    try {
      _setLoading(true);
      _clearError();

      final savedGame = await _gameRepository.getCurrentGame();
      print('DEBUG: Resume - savedGame: $savedGame');
      
      if (savedGame != null && 
          savedGame.mode == GameMode.singlePlayer && 
          savedGame.status != GameStatus.finished) {
        print('DEBUG: Resume - Setting current game: ${savedGame.id}');
        _currentGame = savedGame;
        notifyListeners();
        return true;
      } else {
        print('DEBUG: Resume - Failed. savedGame: $savedGame, mode: ${savedGame?.mode}, status: ${savedGame?.status}');
        _setError('No saved game found');
        return false;
      }
    } catch (e) {
      print('DEBUG: Resume - Exception: $e');
      _setError('Failed to resume game: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Clear saved game (called when game ends or user chooses to start new)
  Future<void> clearSavedGame() async {
    try {
      await _gameRepository.clearCurrentGame();
      _currentGame = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear saved game: ${e.toString()}');
    }
  }

  /// Make computer guess (AI logic)
  Future<void> _makeComputerGuess() async {
    try {
      if (_currentGame == null || currentPlayer?.id != 'computer_player') {
        return;
      }

      // Get human player's secret number
      final humanPlayer = _currentGame!.players.firstWhere((p) => p.id == 'human_player');
      final humanSecret = humanPlayer.secretNumber;
      
      if (humanSecret == null) {
        _setError('Human secret number not found');
        return;
      }

      // Generate computer guess
      final computerGuess = _generateComputerGuess();
      print('DEBUG: Computer guessing: $computerGuess against human secret: $humanSecret');
      
      // Check computer's guess
      final guessResult = _checkGuess(computerGuess, humanSecret);
      final isCorrect = _checkGuess.isCorrectGuess(guessResult);

      // Add computer's guess
      _currentGame = await _gameRepository.addGuess(
        _currentGame!.id,
        'computer_player',
        computerGuess,
        guessResult,
      );

      // Check if computer won
      if (isCorrect) {
        final winner = currentPlayer!.copyWith(hasWon: true);
        _currentGame = await _gameRepository.endGame(_currentGame!.id, winner);
      } else {
        // Switch back to human player
        _currentGame = await _gameRepository.switchPlayer(_currentGame!.id);
      }

      notifyListeners();
    } catch (e) {
      print('DEBUG: Computer guess failed: $e');
      _setError('Computer guess failed: ${e.toString()}');
    }
  }

  /// Generate computer guess using smart AI
  String _generateComputerGuess() {
    final computerPlayer = currentPlayer!;
    
    // If no previous guesses, generate random valid number
    if (computerPlayer.guesses.isEmpty) {
      return _generateComputerNumber(_gameConfig);
    }
    
    // Smart AI: Analyze previous guesses and results
    return _generateSmartGuess(computerPlayer);
  }

  /// Generate smart guess based on previous results
  String _generateSmartGuess(Player computerPlayer) {
    final numberLength = _gameConfig.numberLength;
    final previousGuesses = computerPlayer.guessResults;
    
    // Track what we know about each position
    List<String?> knownCorrectDigits = List.filled(numberLength, null);
    Set<String> eliminatedDigits = {};
    Set<String> confirmedDigits = {};
    
    // Analyze all previous guesses
    for (final guessResult in previousGuesses) {
      for (int i = 0; i < guessResult.digitResults.length; i++) {
        final digitResult = guessResult.digitResults[i];
        
        switch (digitResult.status) {
          case DigitStatus.correct:
            // This digit is correct in this position
            knownCorrectDigits[i] = digitResult.digit;
            confirmedDigits.add(digitResult.digit);
            break;
            
          case DigitStatus.wrongPlace:
            // This digit exists but not in this position
            confirmedDigits.add(digitResult.digit);
            break;
            
          case DigitStatus.notFound:
            // This digit doesn't exist in the secret number
            eliminatedDigits.add(digitResult.digit);
            break;
        }
      }
    }
    
    print('DEBUG: AI Analysis - Known correct: $knownCorrectDigits');
    print('DEBUG: AI Analysis - Confirmed digits: $confirmedDigits'); 
    print('DEBUG: AI Analysis - Eliminated digits: $eliminatedDigits');
    
    // Generate new guess using the knowledge
    return _buildSmartGuess(knownCorrectDigits, confirmedDigits, eliminatedDigits, numberLength);
  }

  /// Build a smart guess using accumulated knowledge
  String _buildSmartGuess(List<String?> knownCorrectDigits, Set<String> confirmedDigits, 
                         Set<String> eliminatedDigits, int numberLength) {
    List<String> result = [];
    Set<String> usedDigits = {};
    
    // Track which positions are forbidden for which digits (from wrong place results)
    Map<String, Set<int>> forbiddenPositions = {};
    
    // Analyze wrong place constraints
    final computerPlayer = currentPlayer!;
    for (final guessResult in computerPlayer.guessResults) {
      for (int i = 0; i < guessResult.digitResults.length; i++) {
        final digitResult = guessResult.digitResults[i];
        if (digitResult.status == DigitStatus.wrongPlace) {
          // This digit exists but NOT in position i
          forbiddenPositions.putIfAbsent(digitResult.digit, () => {}).add(i);
        }
      }
    }
    
    print('DEBUG: AI Forbidden positions: $forbiddenPositions');
    
    // First pass: Place known correct digits
    for (int i = 0; i < numberLength; i++) {
      if (knownCorrectDigits[i] != null) {
        result.add(knownCorrectDigits[i]!);
        usedDigits.add(knownCorrectDigits[i]!);
      } else {
        result.add('?'); // Placeholder
      }
    }
    
    // Available digits (excluding eliminated ones and avoiding duplicates)
    List<String> availableDigits = [];
    for (int digit = 0; digit <= 9; digit++) {
      String digitStr = digit.toString();
      if (!eliminatedDigits.contains(digitStr) && 
          !usedDigits.contains(digitStr)) {
        availableDigits.add(digitStr);
      }
    }
    
    // Shuffle available digits for variety
    availableDigits.shuffle();
    
    // Prioritize confirmed digits that haven't been placed yet
    List<String> priorityDigits = confirmedDigits
        .where((digit) => !usedDigits.contains(digit) && !eliminatedDigits.contains(digit))
        .toList()
        ..shuffle(); // Add randomness
    
    // Second pass: Fill remaining positions intelligently
    for (int i = 0; i < numberLength; i++) {
      if (result[i] == '?') {
        String chosenDigit = '1'; // Default fallback
        
        // Try to place confirmed digits first, but respect forbidden positions
        if (priorityDigits.isNotEmpty) {
          for (int j = 0; j < priorityDigits.length; j++) {
            String candidate = priorityDigits[j];
            Set<int> forbidden = forbiddenPositions[candidate] ?? {};
            
            if (!forbidden.contains(i)) {
              chosenDigit = candidate;
              priorityDigits.removeAt(j);
              break;
            }
          }
        } else if (availableDigits.isNotEmpty) {
          // If no priority digit fits, use any available digit
          for (int j = 0; j < availableDigits.length; j++) {
            String candidate = availableDigits[j];
            Set<int> forbidden = forbiddenPositions[candidate] ?? {};
            
            if (!forbidden.contains(i)) {
              chosenDigit = candidate;
              availableDigits.removeAt(j);
              break;
            }
          }
        } else {
          // Ultimate fallback: find any unused digit
          chosenDigit = _findUnusedDigit(usedDigits);
        }
        
        // Ensure first digit is not 0 (if config doesn't allow leading zeros)
        if (i == 0 && chosenDigit == '0' && !_gameConfig.allowLeadingZero) {
          // Find alternative non-zero digit
          if (availableDigits.isNotEmpty) {
            for (String alt in List.from(availableDigits)) {
              if (alt != '0') {
                availableDigits.remove(alt);
                availableDigits.add(chosenDigit);
                chosenDigit = alt;
                break;
              }
            }
          }
          if (chosenDigit == '0') chosenDigit = '1'; // Ultimate fallback
        }
        
        result[i] = chosenDigit;
        usedDigits.add(chosenDigit);
        
        // Remove from all lists to prevent reuse
        while (availableDigits.remove(chosenDigit)) {}
        while (priorityDigits.remove(chosenDigit)) {}
      }
    }
    
    final smartGuess = result.join();
    
    // Validate the guess - check for duplicates
    Set<String> uniqueDigits = smartGuess.split('').toSet();
    if (uniqueDigits.length != smartGuess.length) {
      print('DEBUG: AI generated duplicate digits: $smartGuess, falling back to random');
      // Fallback to random valid number if we somehow generated duplicates
      return _generateComputerNumber(_gameConfig);
    }
    
    print('DEBUG: AI Smart guess: $smartGuess');
    return smartGuess;
  }

  /// Find any unused digit as fallback
  String _findUnusedDigit(Set<String> usedDigits) {
    // Try digits 1-9 first (avoid 0 for first position)
    for (int i = 1; i <= 9; i++) {
      if (!usedDigits.contains(i.toString())) {
        return i.toString();
      }
    }
    // If all 1-9 are used, try 0
    if (!usedDigits.contains('0')) {
      return '0';
    }
    // If somehow all digits are used (shouldn't happen), return 1
    return '1';
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}
