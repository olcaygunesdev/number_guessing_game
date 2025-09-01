import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Application color palette
class AppColors {
  // Primary Colors
  static const Color primary = Color(AppConstants.primaryColorValue);
  static const Color secondary = Color(AppConstants.secondaryColorValue);
  
  // Status Colors
  static const Color error = Color(AppConstants.errorColorValue);
  static const Color success = Color(AppConstants.successColorValue);
  static const Color warning = Color(AppConstants.warningColorValue);
  
  // Digit Result Colors
  static const Color correctDigit = Colors.green; // Correct position
  static const Color wrongPlaceDigit = Colors.orange; // Wrong position
  static const Color notFoundDigit = Colors.red; // Not in number
  
  // Background Colors
  static const Color background = Colors.white;
  static const Color surface = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1C1B1F);
  static const Color textSecondary = Color(0xFF49454F);
  static const Color textDisabled = Color(0xFF79747E);
  
  // Game Board Colors
  static const Color gameBoardBackground = Color(0xFFF8F9FA);
  static const Color digitInputBackground = Color(0xFFE7E0EC);
  static const Color digitInputBorder = Color(0xFF79747E);
  
  // Button Colors
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = secondary;
  static const Color buttonDisabled = Color(0xFFE8DEF8);
  
  // Flame Game Colors
  static const Color gameBackground = Color(0xFF1A1A2E);
  static const Color gameAccent = Color(0xFF16213E);
  static const Color gameHighlight = Color(0xFF0F3460);
  
  // Aliases for game screen
  static Color get wrongPlace => wrongPlaceDigit;
  static Color get wrongDigit => notFoundDigit;
  
  // Transparency Levels
  static const double lowOpacity = 0.1;
  static const double mediumOpacity = 0.5;
  static const double highOpacity = 0.8;
  
  /// Get color for digit status
  static Color getDigitStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'correct':
        return correctDigit;
      case 'wrongplace':
        return wrongPlaceDigit;
      case 'notfound':
        return notFoundDigit;
      default:
        return textSecondary;
    }
  }
  
  /// Get color scheme for Material 3
  static ColorScheme getColorScheme() {
    return const ColorScheme.light(
      primary: primary,
      secondary: secondary,
      error: error,
      surface: surface,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
      onSurface: textPrimary,
    );
  }
  
  /// Get dark color scheme for Material 3
  static ColorScheme getDarkColorScheme() {
    return const ColorScheme.dark(
      primary: Color(0xFFD0BCFF),
      secondary: Color(0xFFCCC2DC),
      error: Color(0xFFFFB4AB),
      surface: Color(0xFF1C1B1F),
      onPrimary: Color(0xFF381E72),
      onSecondary: Color(0xFF332D41),
      onError: Color(0xFF690005),
      onSurface: Color(0xFFE6E1E5),
    );
  }
}
