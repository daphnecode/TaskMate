import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flame/effects.dart';

class CursorComponent extends PositionComponent {
  double radius = 30;
  final Paint _paint = Paint()
    ..color = Colors.red
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawCircle(Offset.zero, radius, _paint);
  }

  void animateShrink() async {
    add(
      ScaleEffect.to(
        Vector2.all(0.6), // 작아질 비율
        EffectController(
          duration: 0.1,
          reverseDuration: 0.1,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
