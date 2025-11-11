import 'package:flame/components.dart';
import 'package:flame/collisions.dart';
import 'run_game.dart';
import 'obstacle.dart';

class Dino extends SpriteAnimationComponent with CollisionCallbacks {
  final RunGame game;
  Dino(this.game, {required this.petPath, required this.groundY})
    : super(size: Vector2(128, 128), priority: 10, anchor: Anchor.bottomLeft);

  double travelDistance = 0.0; // 진행 거리 (미터)
  double speed = 25; // 초당 100미터 속도

  double velocityY = 0.0;
  double gravity = 800; // 중력 (픽셀/초²)
  double jumpForce = -500; // 점프 시 초기 속도 (음수: 위로)

  double groundY;
  final String petPath;

  bool isJumping = false;

  @override
  Future<void> onLoad() async {
    String imageName = petPath.split('/').last;
    final image = await game.images.load(imageName);
    animation = SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: 1,
        stepTime: 0.1,
        textureSize: Vector2(128, 128),
      ),
    );

    size = Vector2(128, 128);

    add(RectangleHitbox());
  }

  void resize(Vector2 gameSize) {
    size = Vector2.all(128) * (gameSize.y / 600); // 예: 기본 600px 기준 스케일
    groundY = gameSize.y - size.y + 50;
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollision(intersectionPoints, other);
    if (!game.isGameRunning) return;

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
    // 중력 적용
    velocityY += gravity * dt;
    // 점프, 중력 등 처리
    position.y += velocityY * dt;

    // 바닥에 도달하면 멈춤
    if (position.y >= groundY) {
      position.y = groundY;
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
