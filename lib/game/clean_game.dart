import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'poop_component.dart';
import 'cursor_component.dart';
import 'dart:math';
import 'package:flame/components.dart' as flame;
import 'package:vector_math/vector_math_64.dart' as vmath;
import 'dart:async';

class CleanGame extends FlameGame {
  final Random _random = Random();

  late CursorComponent cursor;

  // ✅ 팝업을 내부에서 띄울 "권한" (기본: 허용 안 함)
  bool _canShowClearOverlay = false;

  // ✅ 중복 팝업 방지
  bool _clearShown = false;

  // 🔵 외부 입력 방향을 저장
  vmath.Vector2 moveDelta = vmath.Vector2.zero();

  // (선택) onLoad 이후 클리어 체크 지연
  bool _readyToCheckClear = false;

  /// 외부(UI)에서 호출: 팝업 표시 권한 on/off
  void allowClearOverlay(bool allow) {
    _canShowClearOverlay = allow;
  }

  /// (선택) 스테이지를 초기화/재시작할 때 호출
  Future<void> resetLevel({int? fixedCount}) async {
    // 기존 오염물 제거
    for (final p in children.whereType<PoopComponent>().toList()) {
      p.removeFromParent();
    }

    // 오염물 재생성
    final int poopCount = fixedCount ?? (4 + _random.nextInt(4));
    for (int i = 0; i < poopCount; i++) {
      final x = _random.nextDouble() * (size.x - 40);
      final y = _random.nextDouble() * (size.y - 100);
      final poop = PoopComponent(
        position: flame.Vector2(x, y),
        size: flame.Vector2(40, 40),
      );
      add(poop);
    }

    // 커서 리셋
    cursor.position = flame.Vector2(size.x / 2, size.y / 2);

    // 상태 리셋
    _clearShown = false;
    _readyToCheckClear = false;

    // 프레임 한 번 기다렸다가 체크 허용
    await Future.delayed(const Duration(milliseconds: 100));
    _readyToCheckClear = true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // 오염물 생성
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

    // 초기에 바로 클리어 판정/팝업이 뜨지 않도록 약간 지연
    await Future.delayed(const Duration(milliseconds: 100));
    _readyToCheckClear = true;

    // ✅ 시작 시에는 절대 팝업 못 띄우도록 게이트 닫기
    _canShowClearOverlay = false;
    _clearShown = false;
  }

  // 💩 치우기 기능: 커서 근처의 오염물 1개 제거
  void tryClean() {
    final poops = children.whereType<PoopComponent>().toList();
    for (final poop in poops) {
      final distance = poop.position.distanceTo(cursor.position);
      if (distance < 40) {
        poop.removeFromParent();
        cursor.animateShrink();
        

        // ✅ 마지막 하나를 지금 제거했을 수 있으니 여기서도 클리어 처리 시도
        _maybeShowClearOverlay();
        break;
      }
    }
  }

  // 외부에서 조이스틱 방향 입력
  void move(vmath.Vector2 delta) {
    moveDelta = delta;
  }

  void handleDirection(vmath.Vector2 newDelta) {
    moveDelta = newDelta;
  }

  bool isClear() {
    return children.whereType<PoopComponent>().isEmpty;
  }

  // ✅ 팝업 표시 시점을 한 곳으로 통제
  void _maybeShowClearOverlay() {
    if (!_readyToCheckClear) return;
    if (_clearShown) return;
    if (!_canShowClearOverlay) return; // ← 게이트가 닫혀 있으면 표시 금지
    if (!isClear()) return;

    _clearShown = true;

    // 약간 늦춰서 띄우면 이펙트 자연스러움
    Future.delayed(const Duration(milliseconds: 100), () {
      // overlays는 FlameGame가 제공 (GameWidget에서 맵핑됨)
      if (!overlays.isActive('ClearPopup')) {
        overlays.add('ClearPopup');
      }
    });
  }

  @override
  void update(double dt) {
    super.update(dt);

    // 커서 이동
    const speed = 100.0;
    // vmath.Vector2.zero()와의 직접 비교 대신 길이 체크가 안전
    if (moveDelta.length2 > 0.000001) {
      final dir = flame.Vector2(moveDelta.x, moveDelta.y);
      if (dir.length2 > 0) {
        dir.normalize();
        cursor.position += dir * speed * dt;

        final px = cursor.position.x.clamp(0, size.x).toDouble();
        final py = cursor.position.y.clamp(0, size.y).toDouble();
        cursor.position.setValues(px, py);

      }
    }

    // 마지막 조각 제거 시 tryClean()에서 _maybeShowClearOverlay()가 호출됨.
    if (_readyToCheckClear && !_clearShown) {
      _maybeShowClearOverlay();
    }
  }

  @override
  Color backgroundColor() => const Color(0xFFF2F2F2);
}
