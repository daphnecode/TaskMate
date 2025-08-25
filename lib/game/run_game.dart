import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';
import 'dino.dart';
import 'background.dart';

class RunGame extends FlameGame with HasCollisionDetection {
  late Dino _dino;
  bool isGameRunning = false;
  double targetDistance = 0;
  late Timer obstacleTimer;

  late double groundY;

  double _currentSpeed = 150;
  final double _speedIncreaseRate = 20; // 초당 증가량

  double elapsedDistance = 0; // 현재 경과 시간 (초 단위)
  double maxDistance = 0;  // 클리어 기준 시간 (예: 30초)

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    groundY = size.y - 128;
    
    _dino = Dino(this, groundY: groundY)
        ..y = groundY
        ..x = 50;
    add(_dino);
    // add(Ground(this));
    final bgSprite = await loadSprite('beach.png');
    add(Background(this, bgSprite));

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    obstacleTimer.start();
  }

  void spawnObstacle() {
    final obstacle = Obstacle(this, speed: _currentSpeed);
    add(obstacle);
  }

  void startGame(double distance) {
    targetDistance = distance;
    isGameRunning = true;
    elapsedDistance = _dino.travelDistance;
    maxDistance = distance;
    
    // 예: dino 달리기 애니메이션 시작, 장애물 주기적 생성 등
    _dino.run(); 
    // 장애물 타이머 등 추가 가능
  }

  void stopGame() {
    isGameRunning = false;
    _dino.idle(); // 대기 상태로
    // 타이머 취소 등
  }

  void jump() {
    _dino.jump();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameRunning) return;
    // 진행 거리 체크 (예시)
    _dino.travelDistance += _dino.speed * dt;
    if (_dino.travelDistance >= targetDistance) {
      stopGame();
      overlays.add('ClearPopup'); // 클리어 팝업
    }
    elapsedDistance += _dino.speed * dt;
    
    _currentSpeed += _speedIncreaseRate * dt;
    obstacleTimer.update(dt);
  }

  void resetGame() {
    elapsedDistance = 0;
    resumeEngine();
    overlays.remove('ClearPopup');
  }

  double travel() {
    return _dino.travelDistance;
  }
}