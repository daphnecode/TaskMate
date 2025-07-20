import 'package:flame/components.dart';
import 'package:flame/game.dart';

class Ground extends SpriteComponent {
  final FlameGame game;
  Ground(this.game) : super(size: Vector2(800, 48), priority: 0); // 바닥의 너비와 높이 설정

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('forest.png');
    position = Vector2(0, game.size.y - size.y); // 화면 맨 아래쪽에 배치
  }
}

class Background extends SpriteComponent {
  final FlameGame game;
  Background(this.game) : super(priority: -10); // 모든 컴포넌트 뒤에 그리기

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('beach.png');
    size = game.size; // 전체 화면 크기에 맞게
    position = Vector2.zero(); // (0, 0)
  }
}