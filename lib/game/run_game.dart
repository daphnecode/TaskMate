import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';
import 'dart:math';
import 'dino.dart';
import 'background.dart';

class RunGame extends FlameGame with HasCollisionDetection {
  late Dino _dino;
  bool isGameRunning = false;
  int targetDistance = 0;
  late Timer obstacleTimer;

  @override
  Future<void> onLoad() async {
    _dino = Dino(this);
    add(_dino);
    add(Ground(this));
    add(Background(this));

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    obstacleTimer.start();
  }

  void spawnObstacle() {
    final randomSpeed = 150 + Random().nextDouble() * 100;
    add(Obstacle(this, speed: randomSpeed));
  }

  void startGame(int distance) {
    targetDistance = distance;
    isGameRunning = true;
    
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
    obstacleTimer.update(dt);
    // 진행 거리 체크 (예시)
    _dino.travelDistance += _dino.speed * dt;
    if (_dino.travelDistance >= targetDistance) {
      stopGame();
      overlays.add('ClearPopup'); // 클리어 팝업
    }
  }
}