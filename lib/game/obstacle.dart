import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'run_game.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks {
  final RunGame game;
  final double speed;
  Obstacle(this.game, {required this.speed})
      : super(size: Vector2(32, 48)); // 선인장 등 크기 설정

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('dragon.png');
    final int upDown;
    if (Random().nextInt(9) % 2 == 1) {
      upDown = 200;
    } else {
      upDown = 0;
    }

    position = Vector2(game.size.x, game.size.y - size.y - upDown); // 오른쪽에서 시작

    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!game.isGameRunning) return;
    
    position.x -= speed * dt;

    if (position.x < -size.x) {
      removeFromParent(); // 왼쪽 끝 지나면 삭제
    }
  }
}