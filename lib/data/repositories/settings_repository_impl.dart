import '../../domain/entities/game_config.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/local_settings_datasource.dart';

/// Implementation of SettingsRepository using local data source
class SettingsRepositoryImpl implements SettingsRepository {
  final LocalSettingsDataSource _localDataSource;

  SettingsRepositoryImpl(this._localDataSource);

  @override
  Future<void> saveGameConfig(GameConfig config) async {
    await _localDataSource.saveGameConfig(config);
  }

  @override
  Future<GameConfig> loadGameConfig() async {
    return await _localDataSource.loadGameConfig();
  }

  @override
  Future<void> savePlayerName(String name) async {
    await _localDataSource.savePlayerName(name);
  }

  @override
  Future<String?> loadPlayerName() async {
    return await _localDataSource.loadPlayerName();
  }

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    await _localDataSource.saveSoundEnabled(enabled);
  }

  @override
  Future<bool> loadSoundEnabled() async {
    return await _localDataSource.loadSoundEnabled();
  }

  @override
  Future<void> saveAnimationsEnabled(bool enabled) async {
    await _localDataSource.saveAnimationsEnabled(enabled);
  }

  @override
  Future<bool> loadAnimationsEnabled() async {
    return await _localDataSource.loadAnimationsEnabled();
  }

  @override
  Future<void> resetToDefaults() async {
    await _localDataSource.resetToDefaults();
  }
}
