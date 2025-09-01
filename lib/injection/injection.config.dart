// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:number_guessing_game/data/datasources/local_game_datasource.dart'
    as _i646;
import 'package:number_guessing_game/data/datasources/local_settings_datasource.dart'
    as _i878;
import 'package:number_guessing_game/domain/repositories/game_repository.dart'
    as _i529;
import 'package:number_guessing_game/domain/repositories/settings_repository.dart'
    as _i164;
import 'package:number_guessing_game/domain/usecases/check_guess.dart' as _i17;
import 'package:number_guessing_game/domain/usecases/generate_computer_number.dart'
    as _i374;
import 'package:number_guessing_game/domain/usecases/validate_number.dart'
    as _i439;
import 'package:number_guessing_game/injection/injection_module.dart' as _i764;
import 'package:number_guessing_game/presentation/viewmodels/game_viewmodel.dart'
    as _i1046;
import 'package:number_guessing_game/presentation/viewmodels/settings_viewmodel.dart'
    as _i152;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final injectionModule = _$InjectionModule();
    gh.lazySingleton<_i646.LocalGameDataSource>(
        () => injectionModule.localGameDataSource);
    gh.lazySingleton<_i878.LocalSettingsDataSource>(
        () => injectionModule.localSettingsDataSource);
    gh.lazySingleton<_i439.ValidateNumber>(
        () => injectionModule.validateNumber);
    gh.lazySingleton<_i17.CheckGuess>(() => injectionModule.checkGuess);
    gh.lazySingleton<_i374.GenerateComputerNumber>(
        () => injectionModule.generateComputerNumber);
    gh.lazySingleton<_i529.GameRepository>(
        () => injectionModule.gameRepository(gh<_i646.LocalGameDataSource>()));
    gh.lazySingleton<_i1046.GameViewModel>(() => injectionModule.gameViewModel(
          gh<_i529.GameRepository>(),
          gh<_i439.ValidateNumber>(),
          gh<_i17.CheckGuess>(),
          gh<_i374.GenerateComputerNumber>(),
        ));
    gh.lazySingleton<_i164.SettingsRepository>(() => injectionModule
        .settingsRepository(gh<_i878.LocalSettingsDataSource>()));
    gh.lazySingleton<_i152.SettingsViewModel>(() =>
        injectionModule.settingsViewModel(gh<_i164.SettingsRepository>()));
    return this;
  }
}

class _$InjectionModule extends _i764.InjectionModule {}
