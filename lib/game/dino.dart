import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';

class Dino extends SpriteAnimationComponent with CollisionCallbacks{
  final FlameGame game;
  Dino(this.game) : super(size: Vector2(128, 128), priority: 10);

  @override
  Future<void> onLoad() async {
    final image = await game.images.load('unicon.png');
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(128, 128),
      ),
    );
    position = Vector2(50, game.size.y - 128); // 바닥 위
    add(RectangleHitbox());
  }
  
   @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is Obstacle) {
      // 충돌 시 게임 오버 처리
      
      game.pauseEngine(); // 게임 일시 정지
      // 또는 gameRef.overlays.add('GameOver'); 등으로 화면 전환
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 점프, 중력 등 처리
  }
}