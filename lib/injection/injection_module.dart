import 'package:injectable/injectable.dart';

// Data Sources
import '../data/datasources/local_game_datasource.dart';
import '../data/datasources/local_settings_datasource.dart';

// Repositories
import '../domain/repositories/game_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../data/repositories/game_repository_impl.dart';
import '../data/repositories/settings_repository_impl.dart';

// Use Cases
import '../domain/usecases/validate_number.dart';
import '../domain/usecases/check_guess.dart';
import '../domain/usecases/generate_computer_number.dart';

// ViewModels
import '../presentation/viewmodels/game_viewmodel.dart';
import '../presentation/viewmodels/settings_viewmodel.dart';

@module
abstract class InjectionModule {
  // Data Sources
  @lazySingleton
  LocalGameDataSource get localGameDataSource => LocalGameDataSource();

  @lazySingleton
  LocalSettingsDataSource get localSettingsDataSource => LocalSettingsDataSource();

  // Repositories
  @LazySingleton(as: GameRepository)
  GameRepositoryImpl gameRepository(LocalGameDataSource dataSource) =>
      GameRepositoryImpl(dataSource);

  @LazySingleton(as: SettingsRepository)
  SettingsRepositoryImpl settingsRepository(LocalSettingsDataSource dataSource) =>
      SettingsRepositoryImpl(dataSource);

  // Use Cases
  @lazySingleton
  ValidateNumber get validateNumber => ValidateNumber();

  @lazySingleton
  CheckGuess get checkGuess => CheckGuess();

  @lazySingleton
  GenerateComputerNumber get generateComputerNumber => GenerateComputerNumber();

  // ViewModels
  @lazySingleton
  GameViewModel gameViewModel(
    GameRepository gameRepository,
    ValidateNumber validateNumber,
    CheckGuess checkGuess,
    GenerateComputerNumber generateComputerNumber,
  ) =>
      GameViewModel(
        gameRepository,
        validateNumber,
        checkGuess,
        generateComputerNumber,
      );

  @lazySingleton
  SettingsViewModel settingsViewModel(SettingsRepository settingsRepository) =>
      SettingsViewModel(settingsRepository);
}
