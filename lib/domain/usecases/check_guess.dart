import '../entities/player.dart';

/// Use case for checking a guess against a secret number
class CheckGuess {
  /// Checks a guess against the secret number and returns the result
  GuessResult call(String guess, String secretNumber) {
    final List<DigitResult> digitResults = [];
    
    for (int i = 0; i < guess.length; i++) {
      final digit = guess[i];
      final position = i;
      
      DigitStatus status;
      
      if (secretNumber[i] == digit) {
        // Correct digit in correct position
        status = DigitStatus.correct;
      } else if (secretNumber.contains(digit)) {
        // Digit exists but in wrong position
        status = DigitStatus.wrongPlace;
      } else {
        // Digit doesn't exist in secret number
        status = DigitStatus.notFound;
      }
      
      digitResults.add(DigitResult(
        digit: digit,
        position: position,
        status: status,
      ));
    }
    
    return GuessResult(
      guess: guess,
      digitResults: digitResults,
      timestamp: DateTime.now(),
    );
  }
  
  /// Checks if the guess is completely correct
  bool isCorrectGuess(GuessResult result) {
    return result.digitResults.every(
      (digitResult) => digitResult.status == DigitStatus.correct,
    );
  }
}
