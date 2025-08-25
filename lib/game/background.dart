import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'run_game.dart';

class Background extends SpriteComponent {
  final RunGame game;
  Background(this.game, Sprite sprite) : super(
    priority: -10,
    position: Vector2.zero(),
    sprite: sprite,
    ); // 모든 컴포넌트 뒤에 그리기

  @override
  Future<void> onLoad() async {
    size = game.size; // 전체 화면 크기에 맞게
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size; // 화면 크기 변경 시 크기 조정
  }
}

class ProgressBarOverlay extends StatelessWidget {
  final double elapsedTime;
  final double totalTime;

  const ProgressBarOverlay({
    super.key,
    required this.elapsedTime,
    required this.totalTime,
  });

  @override
  Widget build(BuildContext context) {
    double progress = (elapsedTime / totalTime).clamp(0.0, 1.0);

    return LinearProgressIndicator(
        value: progress,
        minHeight: 20,
        backgroundColor: Colors.white,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
  }
}