import 'dart:math';
import '../entities/game_config.dart';

/// Use case for generating a computer's secret number
class GenerateComputerNumber {
  final Random _random = Random();

  /// Generates a valid secret number for the computer player
  String call(GameConfig config) {
    if (config.allowDuplicateDigits) {
      return _generateWithDuplicates(config);
    } else {
      return _generateWithoutDuplicates(config);
    }
  }

  String _generateWithDuplicates(GameConfig config) {
    String number = '';
    
    // First digit (cannot be 0 if leading zero not allowed)
    if (config.allowLeadingZero) {
      number += _random.nextInt(10).toString();
    } else {
      number += (_random.nextInt(9) + 1).toString();
    }
    
    // Remaining digits
    for (int i = 1; i < config.numberLength; i++) {
      number += _random.nextInt(10).toString();
    }
    
    return number;
  }

  String _generateWithoutDuplicates(GameConfig config) {
    final List<int> availableDigits = List.generate(10, (index) => index);
    final List<int> selectedDigits = [];
    
    // First digit (cannot be 0 if leading zero not allowed)
    if (config.allowLeadingZero) {
      final firstDigit = availableDigits[_random.nextInt(availableDigits.length)];
      selectedDigits.add(firstDigit);
      availableDigits.remove(firstDigit);
    } else {
      availableDigits.remove(0); // Remove 0 from available digits
      final firstDigit = availableDigits[_random.nextInt(availableDigits.length)];
      selectedDigits.add(firstDigit);
      availableDigits.remove(firstDigit);
      availableDigits.add(0); // Add 0 back for remaining positions
    }
    
    // Remaining digits
    for (int i = 1; i < config.numberLength; i++) {
      final digit = availableDigits[_random.nextInt(availableDigits.length)];
      selectedDigits.add(digit);
      availableDigits.remove(digit);
    }
    
    return selectedDigits.join();
  }
}
