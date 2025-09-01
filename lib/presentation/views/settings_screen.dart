import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/app_colors.dart';
import '../viewmodels/settings_viewmodel.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          if (settingsViewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            children: [
              // Player Settings
              _buildSectionHeader(context, 'Player'),
              _buildPlayerNameSetting(context, settingsViewModel),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Audio & Visual Settings
              _buildSectionHeader(context, 'Audio & Visual'),
              _buildSoundSetting(context, settingsViewModel),
              _buildAnimationsSetting(context, settingsViewModel),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Reset Settings
              _buildResetButton(context, settingsViewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPlayerNameSetting(BuildContext context, SettingsViewModel settingsViewModel) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person, color: AppColors.primary),
        title: const Text('Player Name'),
        subtitle: Text(settingsViewModel.playerName ?? 'Not set'),
        trailing: const Icon(Icons.edit),
        onTap: () => _showPlayerNameDialog(context, settingsViewModel),
      ),
    );
  }

  Widget _buildSoundSetting(BuildContext context, SettingsViewModel settingsViewModel) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          settingsViewModel.soundEnabled ? Icons.volume_up : Icons.volume_off,
          color: AppColors.primary,
        ),
        title: const Text('Sound Effects'),
        subtitle: const Text('Play sounds during the game'),
        value: settingsViewModel.soundEnabled,
        onChanged: (value) {
          settingsViewModel.updateSoundEnabled(value);
        },
      ),
    );
  }

  Widget _buildAnimationsSetting(BuildContext context, SettingsViewModel settingsViewModel) {
    return Card(
      child: SwitchListTile(
        secondary: Icon(
          settingsViewModel.animationsEnabled ? Icons.animation : Icons.not_interested,
          color: AppColors.primary,
        ),
        title: const Text('Animations'),
        subtitle: const Text('Enable smooth animations and transitions'),
        value: settingsViewModel.animationsEnabled,
        onChanged: (value) {
          settingsViewModel.updateAnimationsEnabled(value);
        },
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, SettingsViewModel settingsViewModel) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.restore, color: AppColors.error),
        title: Text(
          'Reset to Defaults',
          style: TextStyle(color: AppColors.error),
        ),
        subtitle: const Text('Reset all settings to their default values'),
        onTap: () => _showResetDialog(context, settingsViewModel),
      ),
    );
  }

  void _showPlayerNameDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    final controller = TextEditingController(text: settingsViewModel.playerName ?? '');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Player Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: 'Player Name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                settingsViewModel.updatePlayerName(name);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, SettingsViewModel settingsViewModel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to their default values? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              settingsViewModel.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings reset to defaults'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}