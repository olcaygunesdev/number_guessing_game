import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/game_config.dart';

/// Local data source for settings using SharedPreferences
class LocalSettingsDataSource {
  static const String _playerNameKey = 'player_name';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _animationsEnabledKey = 'animations_enabled';
  static const String _numberLengthKey = 'number_length';
  static const String _allowDuplicatesKey = 'allow_duplicates';
  static const String _allowLeadingZeroKey = 'allow_leading_zero';
  static const String _maxGuessesKey = 'max_guesses';

  SharedPreferences? _prefs;

  /// Initialize the data source
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save game configuration
  Future<void> saveGameConfig(GameConfig config) async {
    await _prefs?.setInt(_numberLengthKey, config.numberLength);
    await _prefs?.setBool(_allowDuplicatesKey, config.allowDuplicateDigits);
    await _prefs?.setBool(_allowLeadingZeroKey, config.allowLeadingZero);
    await _prefs?.setInt(_maxGuessesKey, config.maxGuesses);
    await _prefs?.setBool(_soundEnabledKey, config.soundEnabled);
    await _prefs?.setBool(_animationsEnabledKey, config.animationsEnabled);
  }

  /// Load game configuration
  Future<GameConfig> loadGameConfig() async {
    return GameConfig(
      numberLength: _prefs?.getInt(_numberLengthKey) ?? 4,
      allowDuplicateDigits: _prefs?.getBool(_allowDuplicatesKey) ?? false,
      allowLeadingZero: _prefs?.getBool(_allowLeadingZeroKey) ?? false,
      maxGuesses: _prefs?.getInt(_maxGuessesKey) ?? 10,
      soundEnabled: _prefs?.getBool(_soundEnabledKey) ?? true,
      animationsEnabled: _prefs?.getBool(_animationsEnabledKey) ?? true,
    );
  }

  /// Save player name
  Future<void> savePlayerName(String name) async {
    await _prefs?.setString(_playerNameKey, name);
  }

  /// Load player name
  Future<String?> loadPlayerName() async {
    return _prefs?.getString(_playerNameKey);
  }

  /// Save sound settings
  Future<void> saveSoundEnabled(bool enabled) async {
    await _prefs?.setBool(_soundEnabledKey, enabled);
  }

  /// Load sound settings
  Future<bool> loadSoundEnabled() async {
    return _prefs?.getBool(_soundEnabledKey) ?? true;
  }

  /// Save animation settings
  Future<void> saveAnimationsEnabled(bool enabled) async {
    await _prefs?.setBool(_animationsEnabledKey, enabled);
  }

  /// Load animation settings
  Future<bool> loadAnimationsEnabled() async {
    return _prefs?.getBool(_animationsEnabledKey) ?? true;
  }

  /// Reset all settings to default
  Future<void> resetToDefaults() async {
    await _prefs?.remove(_numberLengthKey);
    await _prefs?.remove(_allowDuplicatesKey);
    await _prefs?.remove(_allowLeadingZeroKey);
    await _prefs?.remove(_maxGuessesKey);
    await _prefs?.remove(_soundEnabledKey);
    await _prefs?.remove(_animationsEnabledKey);
    await _prefs?.remove(_playerNameKey);
  }
}
