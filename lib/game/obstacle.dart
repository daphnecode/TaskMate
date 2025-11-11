import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'dart:math';
import 'run_game.dart';

class Obstacle extends SpriteComponent with CollisionCallbacks {
  final RunGame game;
  final Random _random = Random();
  final double groundY;
  final double speed;
  int upDown = 0;
  Obstacle(this.game, {required this.groundY, required this.speed})
    : super(size: Vector2(32, 32)); // 선인장 등 크기 설정

  @override
  Future<void> onLoad() async {
    sprite = await game.loadSprite('icon_brickwall_f.png');
    // 1️⃣ 랜덤으로 위/아래 장애물 구분
    final bool isUpperObstacle = _random.nextBool();

    // 2️⃣ 장애물 종류에 따라 스프라이트 지정
    final spritePath = isUpperObstacle
        ? 'icon_ghost_f.png' // 위 장애물
        : 'icon_brickwall_f.png'; // 아래 장애물

    sprite = await Sprite.load(spritePath);

    // 3️⃣ 위치 지정
    upDown = isUpperObstacle ? 150 : 0;

    position = Vector2(game.size.x, groundY - upDown); // 오른쪽에서 시작

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
