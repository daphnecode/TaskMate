import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class Background extends SpriteComponent {
  final String imagePath;
  Background({required this.imagePath}) : super(anchor: Anchor.topLeft);

  @override
  Future<void> onLoad() async {
    String imageName = imagePath.split('/').last;
    sprite = await Sprite.load(imageName);
  }

  void resize(Vector2 gameSize) {
    size = gameSize;       // 화면 전체를 덮도록 크기 조정
    position = Vector2.zero();
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
