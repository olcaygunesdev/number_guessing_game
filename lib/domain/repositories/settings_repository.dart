import '../entities/game_config.dart';

/// Repository interface for settings and configuration
abstract class SettingsRepository {
  /// Saves game configuration
  Future<void> saveGameConfig(GameConfig config);

  /// Loads game configuration
  Future<GameConfig> loadGameConfig();

  /// Saves player name
  Future<void> savePlayerName(String name);

  /// Loads player name
  Future<String?> loadPlayerName();

  /// Saves sound settings
  Future<void> saveSoundEnabled(bool enabled);

  /// Loads sound settings
  Future<bool> loadSoundEnabled();

  /// Saves animation settings
  Future<void> saveAnimationsEnabled(bool enabled);

  /// Loads animation settings
  Future<bool> loadAnimationsEnabled();

  /// Resets all settings to default
  Future<void> resetToDefaults();
}
