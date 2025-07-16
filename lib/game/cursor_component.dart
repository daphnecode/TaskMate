import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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

  @override
  void update(double dt) {
    super.update(dt);
    // 필요시 애니메이션 처리 가능
  }
}
