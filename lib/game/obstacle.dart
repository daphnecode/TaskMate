import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'run_game.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks {
  final RunGame game;
  final double groundY;
  final double speed;
  late int upDown;
  Obstacle(this.game, {required this.groundY, required this.speed})
      : super(size: Vector2(32, 32)); // 선인장 등 크기 설정

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('dragon.png');
    if (Random().nextInt(9) % 2 == 1) {
      upDown = 200;
    } else {
      upDown = 0;
    }

    position = Vector2(game.size.x, groundY - upDown + 50); // 오른쪽에서 시작

    add(RectangleHitbox());
  }

  void resize(Vector2 gameSize) {
    size = Vector2(gameSize.x * 0.05, gameSize.y * 0.05);
    position.y = groundY - upDown + 50;
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