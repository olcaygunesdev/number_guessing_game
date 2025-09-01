import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

/// A particle effect for digit animations using Flame
class DigitParticle extends PositionComponent {
  final String digit;
  final Color color;
  final double targetScale;
  
  DigitParticle({
    required this.digit,
    required this.color,
    this.targetScale = 1.5,
    required Vector2 position,
  }) : super(position: position);

  @override
  Future<void> onLoad() async {
    // Add text component
    final textComponent = TextComponent(
      text: digit,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
    
    add(textComponent);
    
    // Add scale effect
    add(ScaleEffect.to(
      Vector2.all(targetScale),
      EffectController(
        duration: 0.3,
        curve: Curves.elasticOut,
      ),
    ));
    
    // Add fade out effect
    add(OpacityEffect.to(
      0.0,
      EffectController(
        duration: 1.0,
        curve: Curves.easeOut,
      ),
      onComplete: () => removeFromParent(),
    ));
    
    // Add floating effect
    add(MoveEffect.to(
      position + Vector2(0, -50),
      EffectController(
        duration: 1.0,
        curve: Curves.easeOut,
      ),
    ));
  }
}
