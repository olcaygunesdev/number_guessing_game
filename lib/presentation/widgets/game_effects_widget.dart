import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import '../game/game_effects.dart';

/// Widget wrapper for Flame game effects
class GameEffectsWidget extends StatefulWidget {
  final Widget child;
  
  const GameEffectsWidget({
    super.key,
    required this.child,
  });

  @override
  State<GameEffectsWidget> createState() => _GameEffectsWidgetState();
}

class _GameEffectsWidgetState extends State<GameEffectsWidget> {
  late GameEffects _gameEffects;
  
  @override
  void initState() {
    super.initState();
    _gameEffects = GameEffects();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        // Overlay Flame game for effects
        Positioned.fill(
          child: IgnorePointer(
            child: GameWidget(game: _gameEffects),
          ),
        ),
      ],
    );
  }

  /// Access to game effects from outside
  GameEffects get gameEffects => _gameEffects;
}
