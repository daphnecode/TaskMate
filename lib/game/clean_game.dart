import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'poop_component.dart';
import 'cursor_component.dart';
import 'dart:math';
import 'package:flame/components.dart' as flame;
import 'package:vector_math/vector_math_64.dart' as vmath;

class CleanGame extends FlameGame {
  final Random _random = Random();
  late CursorComponent cursor;

  // 🔵 외부 입력 방향을 저장할 변수
  vmath.Vector2 moveDelta = vmath.Vector2.zero();

  @override
  Future<void> onLoad() async {
    super.onLoad();

    final poopCount = 4 + _random.nextInt(4);
    for (int i = 0; i < poopCount; i++) {
      final x = _random.nextDouble() * (size.x - 40);
      final y = _random.nextDouble() * (size.y - 100);
      final poop = PoopComponent(
        position: flame.Vector2(x, y),
        size: flame.Vector2(40, 40),
      );
      add(poop);
    }

    // 커서 생성
    cursor = CursorComponent()
      ..position = flame.Vector2(size.x / 2, size.y / 2)
      ..anchor = flame.Anchor.center;
    add(cursor);
  }

  // 💩 치우기 기능
  void tryClean() {
    final poops = children.whereType<PoopComponent>().toList();
    for (final poop in poops) {
      final distance = poop.position.distanceTo(cursor.position);
      if (distance < 40) {
        poop.removeFromParent();
        print("💩 제거됨!");
        break;
      }
    }
  }

  // 🟦 외부에서 조이스틱 방향을 입력받는 함수
  void move(vmath.Vector2 delta) {
    moveDelta = delta;
  }

  void handleDirection(vmath.Vector2 newDelta) {
    moveDelta = newDelta;
  }

  bool isClear() {
    return children.whereType<PoopComponent>().isEmpty;
  }

  bool _clearShown = false; // ✅ 이미 클리어 팝업을 띄운 적 있는지 체크

  @override
  void update(double dt) {
    super.update(dt);

    const speed = 150.0;

    if (moveDelta != vmath.Vector2.zero()) {
      // 🔁 Flutter vector → Flame vector로 변환
      cursor.position += flame.Vector2(moveDelta.x, moveDelta.y).normalized() * speed * dt;
    }

    //클리어 상태 체크
    if (isClear() && !_clearShown) {
      overlays.add('ClearPopup');
      _clearShown = true;
    }

  }

  @override
  Color backgroundColor() => const Color(0xFFF2F2F2);
}
