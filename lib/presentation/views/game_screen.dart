import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_colors.dart';
import '../../domain/entities/game.dart';
import '../../domain/entities/player.dart';
import '../viewmodels/game_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../widgets/digit_input_field.dart';

class GameScreen extends StatefulWidget {
  final bool isSinglePlayer;
  final String? player1Name;
  final String? player2Name;
  final bool resumeGame;

  const GameScreen({
    super.key,
    required this.isSinglePlayer,
    this.player1Name,
    this.player2Name,
    this.resumeGame = false,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGame();
    });
  }

  void _initializeGame() async {
    final gameViewModel = context.read<GameViewModel>();
    final settingsViewModel = context.read<SettingsViewModel>();
    
    // Update game config from settings
    gameViewModel.updateGameConfig(settingsViewModel.gameConfig);
    
    if (widget.isSinglePlayer) {
      if (widget.resumeGame) {
        // Try to resume saved game
        final resumeSuccess = await gameViewModel.resumeSavedGame();
        if (!resumeSuccess) {
          // Resume failed, start new game instead
          final playerName = settingsViewModel.playerName ?? AppConstants.defaultPlayerName;
          await gameViewModel.startSinglePlayerGame(playerName);
        }
      } else {
        // Start new single player game
        final playerName = settingsViewModel.playerName ?? AppConstants.defaultPlayerName;
        await gameViewModel.startSinglePlayerGame(playerName);
      }
    } else {
      // Two player mode always starts new
      await gameViewModel.startMultiPlayerGame(
        widget.player1Name!,
        widget.player2Name!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isSinglePlayer ? 'Single Player' : 'Two Players',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: _showGameRules,
            icon: const Icon(Icons.help_outline),
          ),
          IconButton(
            onPressed: _endGame,
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: Consumer<GameViewModel>(
        builder: (context, gameViewModel, child) {
          if (gameViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (gameViewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gameViewModel.error!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final game = gameViewModel.currentGame;
          if (game == null) {
            return const Center(
              child: Text('No active game'),
            );
          }

          return Column(
            children: [
              // Game Status Banner
              _buildGameStatusBanner(game),
              
              // Main Game Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: _buildGameContent(context, gameViewModel),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGameContent(BuildContext context, GameViewModel gameViewModel) {
    final game = gameViewModel.currentGame!;
    
    switch (game.status) {
      case GameStatus.settingUp:
        return _buildSecretNumberSetup(context, gameViewModel);
      case GameStatus.playing:
        return _buildGameplay(context, gameViewModel);
      case GameStatus.finished:
        return _buildGameFinished(context, gameViewModel);
      default:
        return const Center(child: Text('Game not ready'));
    }
  }

  Widget _buildSecretNumberSetup(BuildContext context, GameViewModel gameViewModel) {
    final currentPlayer = gameViewModel.currentPlayer!;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${currentPlayer.name}, set your secret number',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.largePadding),
          _buildSecretNumberInput(context, gameViewModel, currentPlayer.id),
        ],
      ),
    );
  }

  Widget _buildGameplay(BuildContext context, GameViewModel gameViewModel) {
    final currentPlayer = gameViewModel.currentPlayer!;
    
    if (widget.isSinglePlayer) {
      // Single player: Show both player and computer boards
      return _buildSinglePlayerGameplay(context, gameViewModel);
    } else {
      // Multiplayer: Show current player
      return Column(
        children: [
          // Current Player Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${currentPlayer.name}\'s Turn',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    'Guesses: ${currentPlayer.guesses.length}/${gameViewModel.gameConfig.maxGuesses}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Game Board
          Expanded(
            child: _buildGameBoard(currentPlayer.guessResults, gameViewModel.gameConfig.maxGuesses),
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Guess Input
          _buildGuessInput(context, gameViewModel),
        ],
      );
    }
  }

  Widget _buildSinglePlayerGameplay(BuildContext context, GameViewModel gameViewModel) {
    final humanPlayer = gameViewModel.currentGame!.players.firstWhere((p) => p.id == 'human_player');
    final computerPlayer = gameViewModel.currentGame!.players.firstWhere((p) => p.id == 'computer_player');
    final currentPlayer = gameViewModel.currentPlayer!;
    
    return Column(
      children: [
        // Current Turn Info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Row(
              children: [
                Icon(
                  currentPlayer.id == 'human_player' ? Icons.person : Icons.computer,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    currentPlayer.id == 'human_player' ? 'Your Turn' : 'Computer\'s Turn',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Game Boards Side by Side
        Expanded(
          child: Row(
            children: [
              // Player Board
              Expanded(
                child: _buildPlayerBoard(humanPlayer, 'Your Guesses', gameViewModel.gameConfig.maxGuesses),
              ),
              const SizedBox(width: AppConstants.defaultPadding),
              // Computer Board
              Expanded(
                child: _buildPlayerBoard(computerPlayer, 'Opponent Guesses', gameViewModel.gameConfig.maxGuesses),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Guess Input (only show for human player's turn)
        if (currentPlayer.id == 'human_player')
          _buildGuessInput(context, gameViewModel)
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                'Computer is thinking...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameFinished(BuildContext context, GameViewModel gameViewModel) {
    final game = gameViewModel.currentGame!;
    final winner = game.winner!;
    final isPlayerWinner = winner.id == 'human_player';
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isPlayerWinner 
            ? [Colors.green.shade50, Colors.green.shade100]
            : [Colors.orange.shade50, Colors.orange.shade100],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Title
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  isPlayerWinner ? 'Congratulations!' : 'Computer Wins!',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isPlayerWinner ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Icon
              Container(
                padding: const EdgeInsets.all(20),
                child: isPlayerWinner
                  ? Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.amber,
                    )
                  : const Text(
                      '🤖',
                      style: TextStyle(fontSize: 80),
                      textAlign: TextAlign.center,
                    ),
              ),
              
              const SizedBox(height: 20),
              
              // Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  _getWinnerSubMessage(isPlayerWinner, game),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton.icon(
                        onPressed: _playAgain,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Play Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.home),
                        label: const Text('Main Menu'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getWinnerMessage(bool isPlayerWinner, bool isComputerWinner) {
    if (isPlayerWinner) {
      return '🎉 You Won! 🎉';
    } else if (isComputerWinner) {
      return 'Computer Wins!';
    } else {
      return 'Game Finished!';
    }
  }

  String _getWinnerSubMessage(bool isPlayerWinner, Game game) {
    final winner = game.winner!;
    final winnerGuessCount = winner.guesses.length;
    
    if (isPlayerWinner) {
      return 'Great job! You outsmarted the AI.\nYou found it in $winnerGuessCount ${winnerGuessCount == 1 ? 'guess' : 'guesses'}!';
    } else {
      return 'The AI found your number first!\nComputer solved it in $winnerGuessCount ${winnerGuessCount == 1 ? 'guess' : 'guesses'}.\nBetter luck next time!';
    }
  }

  void _showGameRules() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Rules'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🎯 Objective:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Guess your opponent\'s secret 4-digit number.\n'),
              
              Text('📝 Rules:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('• Each digit must be different'),
              Text('• Number cannot start with 0'),
              Text('• You have limited guesses\n'),
              
              Text('🎨 Color Guide:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('🟢 Green: Correct digit in correct position'),
              Text('🟡 Yellow: Correct digit in wrong position'),
              Text('🔴 Red: Digit not in the number'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _playAgain() {
    final gameViewModel = context.read<GameViewModel>();
    // Clear saved game and start new
    if (widget.isSinglePlayer) {
      gameViewModel.clearSavedGame();
    }
    _initializeGame();
  }

  void _endGame() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Game'),
        content: const Text('Are you sure you want to end this game?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final gameViewModel = context.read<GameViewModel>();
              // Clear saved game when ending
              if (widget.isSinglePlayer) {
                gameViewModel.clearSavedGame();
              }
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close game screen
            },
            child: Text(
              'End Game',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameStatusBanner(Game game) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getGameStatusIcon(game.status),
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _getGameStatusText(game.status),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getGameStatusIcon(GameStatus status) {
    switch (status) {
      case GameStatus.settingUp:
        return Icons.edit;
      case GameStatus.playing:
        return Icons.play_arrow;
      case GameStatus.finished:
        return Icons.flag;
      default:
        return Icons.info;
    }
  }

  String _getGameStatusText(GameStatus status) {
    switch (status) {
      case GameStatus.settingUp:
        return 'Setting up secret numbers...';
      case GameStatus.playing:
        return 'Game in progress';
      case GameStatus.finished:
        return 'Game finished';
      default:
        return 'Preparing game...';
    }
  }

  Widget _buildSecretNumberInput(BuildContext context, GameViewModel gameViewModel, String playerId) {
    final digitInputKey = GlobalKey<DigitInputFieldState>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.largePadding),
        child: Column(
          children: [
            Text(
              'Enter your 4-digit secret number:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            
            // 4-digit input fields
            DigitInputField(
              key: digitInputKey,
              digitCount: 4,
              onCompleted: (number) {
                // Number is automatically handled
              },
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    'Rules:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Each digit must be different\n• Number cannot start with 0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final enteredNumber = digitInputKey.currentState?.value ?? '';
                  if (enteredNumber.length == 4) {
                    // Additional validation
                    if (_isValidNumber(enteredNumber)) {
                      await gameViewModel.setPlayerSecretNumber(playerId, enteredNumber);
                    } else {
                      _showValidationError(context);
                    }
                  } else {
                    // Show gentle reminder
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter all 4 digits (${enteredNumber.length}/4 entered)'),
                        backgroundColor: AppColors.warning,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: const Text('Set Number'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(List<dynamic> guessResults, int maxGuesses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Guesses:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: guessResults.isEmpty
                  ? const Center(
                      child: Text(
                        'No guesses yet\nStart by making your first guess!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: guessResults.length,
                      itemBuilder: (context, index) {
                        // Show newest first (reverse the list data, not the ListView)
                        final reversedIndex = guessResults.length - 1 - index;
                        final result = guessResults[reversedIndex];
                        return _buildGuessResultRow(result, guessResults.length - index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerBoard(Player player, String title, int maxGuesses) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  player.id == 'human_player' ? Icons.person : Icons.computer,
                  size: 20,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: player.guessResults.isEmpty
                  ? Center(
                      child: Text(
                        'No guesses yet',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: player.guessResults.length,
                      itemBuilder: (context, index) {
                        // Show newest first (reverse the list data, not the ListView)
                        final reversedIndex = player.guessResults.length - 1 - index;
                        final result = player.guessResults[reversedIndex];
                        return _buildCompactGuessResultRow(result, player.guessResults.length - index);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuessResultRow(dynamic result, int guessNumber) {
    // Convert result to GuessResult if it's not already
    final GuessResult guessResult = result is GuessResult ? result : result as GuessResult;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            '$guessNumber.',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          // Show the actual guess
          Text(
            guessResult.guess,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 18,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Show real digit results
                for (final digitResult in guessResult.digitResults)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getDigitStatusColor(digitResult.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        digitResult.digit,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGuessResultRow(dynamic result, int guessNumber) {
    // Convert result to GuessResult if it's not already
    final GuessResult guessResult = result is GuessResult ? result : result as GuessResult;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Show only digit results (no numbers or guess text)
          for (final digitResult in guessResult.digitResults)
            Flexible(
              child: Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: _getDigitStatusColor(digitResult.status),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Center(
                  child: Text(
                    digitResult.digit,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getDigitStatusColor(DigitStatus status) {
    switch (status) {
      case DigitStatus.correct:
        return AppColors.correctDigit;
      case DigitStatus.wrongPlace:
        return AppColors.wrongPlace;
      case DigitStatus.notFound:
        return AppColors.wrongDigit;
    }
  }

  bool _isValidNumber(String number) {
    // Check if starts with 0
    if (number.startsWith('0')) {
      return false;
    }
    
    // Check for duplicate digits
    Set<String> uniqueDigits = number.split('').toSet();
    return uniqueDigits.length == number.length;
  }

  void _showValidationError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Invalid Number'),
          content: const Text(
            'Please make sure your number:\n'
            '• Does not start with 0\n'
            '• Has all different digits',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGuessInput(BuildContext context, GameViewModel gameViewModel) {
    final digitInputKey = GlobalKey<DigitInputFieldState>();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            Text(
              'Make your guess:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            // 4-digit input fields for guess
            DigitInputField(
              key: digitInputKey,
              digitCount: 4,
              onCompleted: (number) {
                // Auto-submit when all 4 digits are entered (if valid)
                if (gameViewModel.canMakeGuess && _isValidNumber(number)) {
                  gameViewModel.makeGuess(number);
                  digitInputKey.currentState?.clear();
                }
              },
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: gameViewModel.canMakeGuess
                    ? () async {
                        final guess = digitInputKey.currentState?.value ?? '';
                        if (guess.length == 4) {
                          if (_isValidNumber(guess)) {
                            await gameViewModel.makeGuess(guess);
                            digitInputKey.currentState?.clear();
                          } else {
                            _showValidationError(context);
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Please enter all 4 digits (${guess.length}/4 entered)'),
                              backgroundColor: AppColors.warning,
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        }
                      }
                    : null,
                child: const Text('Submit Guess'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
