import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';
import 'dino.dart';
import 'background.dart';
import '../DBtest/api_service.dart';

class RunGame extends FlameGame with HasCollisionDetection {
  Dino? _dino;
  Background? background;
  final List<Obstacle> obstacles = [];
  final String imagePath;
  bool isGameRunning = false;
  double targetDistance = 0;
  late Timer obstacleTimer;

  late double groundY;

  double _currentSpeed = 150;
  final double _speedIncreaseRate = 20; // 초당 증가량

  double elapsedDistance = 0; // 현재 경과 시간 (초 단위)
  double maxDistance = 0; // 클리어 기준 시간 (예: 30초)

  RunGame({required this.imagePath});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    groundY = size.y - 128;

    _dino = Dino(this, groundY: groundY)
      ..y = 0
      ..x = 50;
    await add(_dino!);
    // add(Ground(this));
    background = Background(imagePath: imagePath);
    await add(background!);

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    obstacleTimer.start();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (background != null) background!.resize(size);
    if (_dino != null) _dino!.resize(size);

    for (final obstacle in obstacles) {
      // 예: width와 height를 화면 크기에 비례
      obstacle.resize(size);
    }
  }

  void spawnObstacle() {
    final obstacle = Obstacle(this, groundY: groundY, speed: _currentSpeed);
    obstacles.add(obstacle);
    add(obstacle);
  }

  void startGame(double distance) {
    targetDistance = distance;
    isGameRunning = true;
    elapsedDistance = _dino!.travelDistance;
    maxDistance = distance;

    // 예: dino 달리기 애니메이션 시작, 장애물 주기적 생성 등
    _dino!.run();
    // 장애물 타이머 등 추가 가능
  }

  void stopGame() {
    isGameRunning = false;
    _dino!.idle(); // 대기 상태로
    // 타이머 취소 등
  }

  void jump() {
    _dino!.jump();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isGameRunning) return;
    // 진행 거리 체크 (예시)
    _dino!.travelDistance += _dino!.speed * dt;
    if (_dino!.travelDistance >= targetDistance) {
      stopGame();
      overlays.add('ClearPopup'); // 클리어 팝업
      gameRunReward(targetDistance);
    }
    elapsedDistance += _dino!.speed * dt;

    _currentSpeed += _speedIncreaseRate * dt;
    obstacleTimer.update(dt);
  }

  void resetGame() {
    elapsedDistance = 0;
    resumeEngine();
    overlays.remove('ClearPopup');
  }

  double travel() {
    return _dino!.travelDistance;
  }
}
