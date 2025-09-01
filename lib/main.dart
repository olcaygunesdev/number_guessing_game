import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Core
import 'core/constants/app_constants.dart';
import 'core/utils/app_colors.dart';

// Data Models (for Hive registration)
import 'data/models/player_model.dart';
import 'data/models/game_model.dart';

// Dependency Injection
import 'injection/injection.dart';

// Data Sources
import 'data/datasources/local_game_datasource.dart';
import 'data/datasources/local_settings_datasource.dart';

// ViewModels
import 'presentation/viewmodels/game_viewmodel.dart';
import 'presentation/viewmodels/settings_viewmodel.dart';

// Views
import 'presentation/views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(PlayerModelAdapter());
  Hive.registerAdapter(GuessResultModelAdapter());
  Hive.registerAdapter(DigitResultModelAdapter());
  Hive.registerAdapter(GameModelAdapter());
  
  // Configure dependencies
  await configureDependencies();
  
  // Initialize data sources
  await getIt<LocalGameDataSource>().init();
  await getIt<LocalSettingsDataSource>().init();
  
  // Initialize ViewModels
  await getIt<SettingsViewModel>().initialize();
  
  runApp(const NumberGuessingGameApp());
}

class NumberGuessingGameApp extends StatelessWidget {
  const NumberGuessingGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GameViewModel>.value(
          value: getIt<GameViewModel>(),
        ),
        ChangeNotifierProvider<SettingsViewModel>.value(
          value: getIt<SettingsViewModel>(),
        ),
      ],
      child: Consumer<SettingsViewModel>(
        builder: (context, settingsViewModel, child) {
          return MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: AppColors.getColorScheme(),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: AppConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: AppColors.getDarkColorScheme(),
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              cardTheme: CardThemeData(
                elevation: AppConstants.cardElevation,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}