import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'poop_component.dart';
import 'cursor_component.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'dart:math';

class CleanGame extends FlameGame {
  final Random _random = Random();
  late CursorComponent cursor;
  late JoystickComponent joystick; //


  @override
  Future<void> onLoad() async {
    super.onLoad();

    // 오염물 생성
    final poopCount = 4 + _random.nextInt(4); // 4~7개

    for (int i = 0; i < poopCount; i++) {
      final x = _random.nextDouble() * (size.x - 40);
      final y = _random.nextDouble() * (size.y - 100);
      final poop = PoopComponent(
        position: Vector2(x, y),
        size: Vector2(40, 40),
      );
      add(poop);
    }

    // 조이스틱 구성
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 20, paint: Paint()..color = Colors.blue),
      background: CircleComponent(radius: 50, paint: Paint()..color = Colors.blue.withOpacity(0.3)),
      margin: const EdgeInsets.only(left: 30, bottom: 30),
    );
    add(joystick);

    //커서 생성
    cursor = CursorComponent()
      ..position = Vector2(size.x / 2, size.y / 2)
      ..anchor = Anchor.center;
    add(cursor);

  }

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


  @override
  Color backgroundColor() => const Color(0xFFF2F2F2); // 밝은 배경

  @override
  void render(Canvas canvas) {
    super.render(canvas);
  }

  @override
  void update(double dt) {
    super.update(dt);

    final delta = joystick.delta;
    final speed = 150.0; // 커서 속도

    if (delta != Vector2.zero()) {
      cursor.position += delta.normalized() * speed * dt;
    }
  }

}
