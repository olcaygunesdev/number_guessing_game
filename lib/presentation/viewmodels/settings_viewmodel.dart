import 'package:flutter/foundation.dart';
import '../../domain/entities/game_config.dart';
import '../../domain/repositories/settings_repository.dart';

/// ViewModel for managing settings and configuration
class SettingsViewModel extends ChangeNotifier {
  final SettingsRepository _settingsRepository;

  SettingsViewModel(this._settingsRepository);

  GameConfig _gameConfig = GameConfig.defaultConfig;
  String? _playerName;
  bool _soundEnabled = true;
  bool _animationsEnabled = true;
  bool _isLoading = false;
  String? _error;

  // Getters
  GameConfig get gameConfig => _gameConfig;
  String? get playerName => _playerName;
  bool get soundEnabled => _soundEnabled;
  bool get animationsEnabled => _animationsEnabled;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Initialize settings by loading from repository
  Future<void> initialize() async {
    try {
      _setLoading(true);
      _clearError();

      _gameConfig = await _settingsRepository.loadGameConfig();
      _playerName = await _settingsRepository.loadPlayerName();
      _soundEnabled = await _settingsRepository.loadSoundEnabled();
      _animationsEnabled = await _settingsRepository.loadAnimationsEnabled();

      notifyListeners();
    } catch (e) {
      _setError('Failed to load settings: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Update game configuration
  Future<void> updateGameConfig(GameConfig config) async {
    try {
      _clearError();

      await _settingsRepository.saveGameConfig(config);
      _gameConfig = config;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save game config: $e');
    }
  }

  /// Update number length
  Future<void> updateNumberLength(int length) async {
    if (length < 3 || length > 6) {
      _setError('Number length must be between 3 and 6');
      return;
    }

    final updatedConfig = _gameConfig.copyWith(numberLength: length);
    await updateGameConfig(updatedConfig);
  }

  /// Update duplicate digits setting
  Future<void> updateAllowDuplicateDigits(bool allow) async {
    final updatedConfig = _gameConfig.copyWith(allowDuplicateDigits: allow);
    await updateGameConfig(updatedConfig);
  }

  /// Update leading zero setting
  Future<void> updateAllowLeadingZero(bool allow) async {
    final updatedConfig = _gameConfig.copyWith(allowLeadingZero: allow);
    await updateGameConfig(updatedConfig);
  }

  /// Update max guesses
  Future<void> updateMaxGuesses(int maxGuesses) async {
    if (maxGuesses < 5 || maxGuesses > 20) {
      _setError('Max guesses must be between 5 and 20');
      return;
    }

    final updatedConfig = _gameConfig.copyWith(maxGuesses: maxGuesses);
    await updateGameConfig(updatedConfig);
  }

  /// Update player name
  Future<void> updatePlayerName(String name) async {
    try {
      _clearError();

      if (name.trim().isEmpty) {
        _setError('Player name cannot be empty');
        return;
      }

      await _settingsRepository.savePlayerName(name.trim());
      _playerName = name.trim();
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save player name: $e');
    }
  }

  /// Update sound setting
  Future<void> updateSoundEnabled(bool enabled) async {
    try {
      _clearError();

      await _settingsRepository.saveSoundEnabled(enabled);
      _soundEnabled = enabled;
      
      // Also update game config
      final updatedConfig = _gameConfig.copyWith(soundEnabled: enabled);
      _gameConfig = updatedConfig;
      await _settingsRepository.saveGameConfig(updatedConfig);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save sound setting: $e');
    }
  }

  /// Update animations setting
  Future<void> updateAnimationsEnabled(bool enabled) async {
    try {
      _clearError();

      await _settingsRepository.saveAnimationsEnabled(enabled);
      _animationsEnabled = enabled;
      
      // Also update game config
      final updatedConfig = _gameConfig.copyWith(animationsEnabled: enabled);
      _gameConfig = updatedConfig;
      await _settingsRepository.saveGameConfig(updatedConfig);
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to save animations setting: $e');
    }
  }

  /// Reset all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      _setLoading(true);
      _clearError();

      await _settingsRepository.resetToDefaults();
      
      _gameConfig = GameConfig.defaultConfig;
      _playerName = null;
      _soundEnabled = true;
      _animationsEnabled = true;
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to reset settings: $e');
    } finally {
      _setLoading(false);
    }
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
