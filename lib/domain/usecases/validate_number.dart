import '../entities/game_config.dart';

/// Use case for validating a secret number according to game rules
class ValidateNumber {
  /// Validates if a number meets the game configuration requirements
  ValidationResult call(String number, GameConfig config) {
    // Check if number has correct length
    if (number.length != config.numberLength) {
      return ValidationResult(
        isValid: false,
        error: 'Number must be exactly ${config.numberLength} digits long',
      );
    }

    // Check if all characters are digits
    if (!RegExp(r'^\d+$').hasMatch(number)) {
      return ValidationResult(
        isValid: false,
        error: 'Number must contain only digits',
      );
    }

    // Check leading zero restriction
    if (!config.allowLeadingZero && number.startsWith('0')) {
      return ValidationResult(
        isValid: false,
        error: 'Number cannot start with zero',
      );
    }

    // Check duplicate digits restriction
    if (!config.allowDuplicateDigits) {
      final digits = number.split('');
      final uniqueDigits = digits.toSet();
      if (digits.length != uniqueDigits.length) {
        return ValidationResult(
          isValid: false,
          error: 'Number cannot contain duplicate digits',
        );
      }
    }

    return const ValidationResult(isValid: true);
  }
}

/// Result of number validation
class ValidationResult {
  final bool isValid;
  final String? error;

  const ValidationResult({
    required this.isValid,
    this.error,
  });
}
