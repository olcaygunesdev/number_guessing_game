import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../../core/utils/app_colors.dart';
import '../../domain/entities/player.dart';
import 'digit_particle.dart';

/// Flame game for visual effects and animations
class GameEffects extends FlameGame {
  @override
  Color backgroundColor() => Colors.transparent;

  /// Show particle effect for guess result
  void showGuessResult(GuessResult result, Offset position) {
    for (int i = 0; i < result.digitResults.length; i++) {
      final digitResult = result.digitResults[i];
      final color = _getColorForStatus(digitResult.status);
      
      final particle = DigitParticle(
        digit: digitResult.digit,
        color: color,
        position: Vector2(
          position.dx + (i * 50.0),
          position.dy,
        ),
      );
      
      add(particle);
    }
  }

  /// Show celebration effect when player wins
  void showCelebration(Offset center) {
    for (int i = 0; i < 10; i++) {
      final angle = (i / 10) * 2 * math.pi;
      final radius = 100.0;
      
      final particle = DigitParticle(
        digit: '🎉',
        color: AppColors.success,
        targetScale: 2.0,
        position: Vector2(
          center.dx + radius * math.cos(angle),
          center.dy + radius * math.sin(angle),
        ),
      );
      
      add(particle);
    }
  }

  /// Show feedback effect for correct/incorrect guess
  void showFeedbackEffect(bool isCorrect, Offset position) {
    final color = isCorrect ? AppColors.success : AppColors.error;
    final icon = isCorrect ? '✓' : '✗';
    
    final particle = DigitParticle(
      digit: icon,
      color: color,
      targetScale: 3.0,
      position: Vector2(position.dx, position.dy),
    );
    
    add(particle);
  }

  Color _getColorForStatus(DigitStatus status) {
    switch (status) {
      case DigitStatus.correct:
        return AppColors.correctDigit;
      case DigitStatus.wrongPlace:
        return AppColors.wrongPlaceDigit;
      case DigitStatus.notFound:
        return AppColors.notFoundDigit;
    }
  }
}
