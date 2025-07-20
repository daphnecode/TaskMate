import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks {
  final FlameGame game;
  final double speed;
  Obstacle(this.game, {required this.speed})
      : super(size: Vector2(32, 48)); // 선인장 등 크기 설정

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('dragon.png');
    position = Vector2(game.size.x - 128, game.size.y - size.y - 48); // 오른쪽에서 시작
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x -= speed * dt;

    if (position.x < -size.x) {
      removeFromParent(); // 왼쪽 끝 지나면 삭제
    }
  }
}