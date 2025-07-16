import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class PoopComponent extends SpriteComponent {
  PoopComponent({
    required Vector2 position,
    required Vector2 size,
  }) : super(
    position: position,
    size: size,
  );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('shit.png'); // 반드시 assets 등록 필요

    
  }
}
