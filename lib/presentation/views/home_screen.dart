import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/game_viewmodel.dart';
import '../widgets/game_mode_card.dart';
import '../widgets/player_name_dialog.dart';
import 'game_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              // App Header
              _buildHeader(context),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Game Mode Selection
              Expanded(
                child: _buildGameModeSelection(context),
              ),
              
              // Settings Button
              _buildSettingsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        // App Title
        Text(
          AppConstants.appName,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: AppConstants.mediumAnimation)
          .slideY(begin: -0.2, end: 0),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        // App Subtitle
        Text(
          'Test your logic and guess the secret number!',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(
          duration: AppConstants.mediumAnimation,
          delay: 200.ms,
        ),
      ],
    );
  }

  Widget _buildGameModeSelection(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Text(
          'Choose Game Mode',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ).animate().fadeIn(
          duration: AppConstants.mediumAnimation,
          delay: 400.ms,
        ),
        
        const SizedBox(height: AppConstants.largePadding),
        
        // Single Player Mode
        GameModeCard(
          title: 'Single Player',
          subtitle: 'Play against the computer',
          icon: Icons.person,
          color: AppColors.primary,
          onTap: () => _startSinglePlayerGame(context),
        ).animate().fadeIn(
          duration: AppConstants.mediumAnimation,
          delay: 600.ms,
        ).slideX(begin: -0.3, end: 0),
        
        const SizedBox(height: AppConstants.defaultPadding),
        
        // Multiplayer Mode
        GameModeCard(
          title: 'Two Players',
          subtitle: 'Play with a friend',
          icon: Icons.people,
          color: AppColors.secondary,
          onTap: () => _startMultiPlayerGame(context),
        ).animate().fadeIn(
          duration: AppConstants.mediumAnimation,
          delay: 800.ms,
        ).slideX(begin: 0.3, end: 0),
      ],
      ),
    );
  }

  Widget _buildSettingsButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _openSettings(context),
        icon: const Icon(Icons.settings),
        label: const Text('Settings'),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: AppConstants.mediumAnimation,
      delay: 1000.ms,
    );
  }

  void _startSinglePlayerGame(BuildContext context) async {
    final settingsViewModel = context.read<SettingsViewModel>();
    final gameViewModel = context.read<GameViewModel>();
    
    bool shouldResume = false;
    
    // Check if there's a saved game
    final hasSavedGame = await gameViewModel.hasSavedSinglePlayerGame();
    
    if (hasSavedGame && context.mounted) {
      // Show dialog to resume or start new
      final userChoice = await _showResumeGameDialog(context);
      if (userChoice == null) return; // User cancelled
      
      shouldResume = userChoice;
      
      if (!shouldResume) {
        // User chose to start new game, clear saved game
        await gameViewModel.clearSavedGame();
      }
    }
    
    // Check if player name is set (only for new games)
    if (!shouldResume && (settingsViewModel.playerName == null || 
        settingsViewModel.playerName!.isEmpty)) {
      final playerName = await _showPlayerNameDialog(context, 'Enter Your Name');
      if (playerName == null) return;
      
      await settingsViewModel.updatePlayerName(playerName);
    }
    
    if (context.mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GameScreen(
            isSinglePlayer: true,
            resumeGame: shouldResume,
          ),
        ),
      );
    }
  }

  void _startMultiPlayerGame(BuildContext context) async {
    final player1Name = await _showPlayerNameDialog(context, 'Enter Player 1 Name');
    if (player1Name == null) return;
    
    if (context.mounted) {
      final player2Name = await _showPlayerNameDialog(context, 'Enter Player 2 Name');
      if (player2Name == null) return;
      
      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GameScreen(
              isSinglePlayer: false,
              player1Name: player1Name,
              player2Name: player2Name,
            ),
          ),
        );
      }
    }
  }

  Future<String?> _showPlayerNameDialog(BuildContext context, String title) {
    return showDialog<String>(
      context: context,
      builder: (context) => PlayerNameDialog(title: title),
    );
  }

  Future<bool?> _showResumeGameDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Continue Game?',
          textAlign: TextAlign.center,
        ),
        content: const Text(
          'You have an unfinished game.\n'
          'Would you like to continue where you left off or start a new game?',
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top row: Start New and Continue buttons
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Start New',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Bottom: Cancel button (centered)
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const SettingsScreen(),
      ),
    );
  }
}
