import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'obstacle.dart';
import 'dart:math';
import 'dino.dart';
import 'background.dart';

class RunGame extends FlameGame with HasCollisionDetection {
  late Timer obstacleTimer;

  @override
  Future<void> onLoad() async {
    add(Dino(this));
    add(Ground(this));
    add(Background(this));

    obstacleTimer = Timer(2, onTick: spawnObstacle, repeat: true);
    obstacleTimer.start();
  }

  void spawnObstacle() {
    final randomSpeed = 150 + Random().nextDouble() * 100;
    add(Obstacle(this, speed: randomSpeed));
  }

  @override
  void update(double dt) {
    super.update(dt);
    obstacleTimer.update(dt);
  }
}