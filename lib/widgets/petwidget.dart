import 'dart:math';
import 'package:flutter/material.dart';
import 'package:taskmate/object.dart';

class FloatingPet extends StatefulWidget {
  final Pets? pet;
  final double w;
  final double h;
  const FloatingPet({
    required this.w,
    required this.h,
    required this.pet,
    super.key,
  });

  @override
  State<FloatingPet> createState() => _FloatingPetState();
}

class _FloatingPetState extends State<FloatingPet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Widget petWidget = const SizedBox.shrink();
  Widget styleWidget = const SizedBox.shrink();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // 위아래 반복
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String petAsset = widget.pet!.image;
    final String styleAsset = 'assets/images/${widget.pet!.styleID}.png';

    if (petAsset.isNotEmpty) {
      petWidget = Positioned(
        left: widget.w * 0.2,
        top: widget.h * 0.3,
        child: Image.asset(
          key: ValueKey(widget.pet!.name),
          petAsset,
          fit: BoxFit.cover,
          height: widget.h * 0.3,
          width: widget.w * 0.3,
        ),
      );
    }

    if (styleAsset.isNotEmpty) {
      styleWidget = Positioned(
        left: widget.w * 0.1,
        top: widget.h * 0.2,
        child: Image.asset(
          key: ValueKey(widget.pet!.styleID),
          styleAsset,
          fit: BoxFit.cover,
          height: widget.h * 0.5,
          width: widget.w * 0.5,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offsetY = 10 * (_controller.value - 0.5); // -5 ~ +5 이동
        return Transform.translate(offset: Offset(0, offsetY), child: child);
      },
      child: SizedBox(
        width: widget.w * 0.5,
        height: widget.h * 0.5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [styleWidget, petWidget],
        ),
      ),
    );
  }
}

class MovingPet extends StatefulWidget {
  final Pets? pet;
  final double w;
  final double h;
  const MovingPet({
    required this.pet,
    required this.w,
    required this.h,
    super.key,
  });

  @override
  State<MovingPet> createState() => _MovingPetState();
}

class _MovingPetState extends State<MovingPet> {
  final Random random = Random();
  double x = Random().nextDouble();
  double y = Random().nextDouble();
  double dx = 1; // x축 방향 속도
  double dy = 1; // y축 방향 속도

  void _moveRandomly() {
    final double maxX = widget.w - widget.w * 0.7; // 펫 가로 크기 고려
    final double maxY = widget.h - widget.h * 0.7; // 펫 세로 크기 고려
    setState(() {
      x += dx * 30;

      // 화면 경계에서 반전
      if (x <= 0) {
        x = 0;
        dx = dx.abs();
      }
      if (x >= maxX) {
        x = maxX;
        dx = -dx.abs();
      }
      if (y <= 0) {
        y = 0;
        dy = dy.abs();
      }
      if (y >= maxY) {
        y = maxY;
        dy = -dy.abs();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // 일정 주기로 위치 변경
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 5));
      if (!mounted) return false;
      _moveRandomly();
      
      
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.w,
      height: widget.h,
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(seconds: 5),
            curve: Curves.easeInOut,
            left: x,
            top: y,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(dx <= 0 ? 1.0 : -1.0, 1.0),
              child: FloatingPet(w: widget.w, h: widget.h, pet: widget.pet),
            ),
          ),
        ],
      ),
    );
  }
}
