import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector2;

class JoystickWidget extends StatefulWidget {
  final void Function(Vector2) onDirectionChanged;

  const JoystickWidget({super.key, required this.onDirectionChanged});

  @override
  State<JoystickWidget> createState() => _JoystickWidgetState();
}

class _JoystickWidgetState extends State<JoystickWidget> {
  Offset _stickOffset = Offset.zero;

  final double baseRadius = 60;
  final double knobRadius = 25;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        Offset newOffset = _stickOffset + details.delta;

        // 중심 기준 최대 반경 안으로 제한
        if (newOffset.distance > baseRadius - knobRadius) {
          final angle = newOffset.direction;
          newOffset = Offset.fromDirection(angle, baseRadius - knobRadius);
        }

        setState(() {
          _stickOffset = newOffset;
        });

        widget.onDirectionChanged(Vector2(newOffset.dx, newOffset.dy));
      },
      onPanEnd: (_) {
        setState(() {
          _stickOffset = Offset.zero;
        });
        widget.onDirectionChanged(Vector2.zero());
      },
      child: SizedBox(
        width: baseRadius * 2,
        height: baseRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 배경 원
            Container(
              width: baseRadius * 2,
              height: baseRadius * 2,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                shape: BoxShape.circle,
              ),
            ),
            // 움직이는 조이스틱
            Transform.translate(
              offset: _stickOffset,
              child: Container(
                width: knobRadius * 2,
                height: knobRadius * 2,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
