import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';

class Dino extends SpriteAnimationComponent with CollisionCallbacks{
  final FlameGame game;
  Dino(this.game, {required this.groundY}) : super(size: Vector2(128, 128), priority: 10);

  double travelDistance = 0.0; // 진행 거리 (미터)
  double speed = 25;    // 초당 100미터 속도

  double velocityY = 0.0;
  double gravity = 800; // 중력 (픽셀/초²)
  double jumpForce = -500; // 점프 시 초기 속도 (음수: 위로)

  final double groundY;

  bool isJumping = false;

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
    super.onCollision(intersectionPoints, other);

    if (other is Obstacle) {
      // 충돌 시 게임 오버 처리
      
      game.overlays.add('FailPopup');
      game.pauseEngine(); // 게임 일시 정지
      // 또는 gameRef.overlays.add('GameOver'); 등으로 화면 전환
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // 점프, 중력 등 처리
     y += velocityY * dt;

    // 중력 적용
    velocityY += gravity * dt;

    // 바닥에 도달하면 멈춤
    if (y >= groundY) {
      y = groundY;
      velocityY = 0;
      isJumping = false;
    }
  }

  void run() {
    // 달리기 애니메이션 설정
  }

  void jump() {
    // 달리기 애니메이션 설정
    if (!isJumping) {
      velocityY = jumpForce;
      isJumping = true;
    }
  }

  void idle() {
    // 대기 애니메이션 설정
  }
}