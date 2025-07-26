import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';

class Ground extends SpriteComponent {
  final FlameGame game;
  Ground(this.game) : super(size: Vector2(800, 48), priority: 0); // 바닥의 너비와 높이 설정

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('forest.png');
    position = Vector2(0, game.size.y - size.y); // 화면 맨 아래쪽에 배치
  }
}

class Background extends SpriteComponent {
  final FlameGame game;
  Background(this.game) : super(priority: -10); // 모든 컴포넌트 뒤에 그리기

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('beach.png');
    size = game.size; // 전체 화면 크기에 맞게
    position = Vector2.zero(); // (0, 0)
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

    // return Align(
    //   alignment: Alignment.topCenter,
    //   child: Container(
    //     margin: const EdgeInsets.only(top: 20, left: 20, right: 20),
    //     height: 20,
    //     decoration: BoxDecoration(
    //       color: Colors.grey[300],
    //       borderRadius: BorderRadius.circular(10),
    //     ),
    //     child: FractionallySizedBox(
    //       alignment: Alignment.centerLeft,
    //       widthFactor: progress,
    //       child: Container(
    //         decoration: BoxDecoration(
    //           color: Colors.green,
    //           borderRadius: BorderRadius.circular(10),
    //         ),
    //       ),
    //     ),
    //   ),
    // );
  }
}