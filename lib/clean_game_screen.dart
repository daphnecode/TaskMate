import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:taskmate/game/clean_game.dart';
import 'package:taskmate/widgets/joystick_widget.dart';
import 'package:taskmate/utils/bgm_manager.dart';
import 'main.dart';
import 'object.dart';
import 'package:taskmate/DBtest/api_service.dart';

class CleanGameScreen extends StatefulWidget {
  final void Function(int) onNext;
  final bool soundEffectsOn;
  final Pets? pet;
  final String uid;
  final String petId;

  const CleanGameScreen({
    super.key,
    required this.onNext,
    required this.soundEffectsOn,
    required this.pet,
    required this.uid,
    required this.petId,
  });

  @override
  State<CleanGameScreen> createState() => _CleanGameScreenState();
}

class _CleanGameScreenState extends State<CleanGameScreen> {
  final CleanGame _game = CleanGame();

  // ── 보상/트리거 가드 ──────────────────────────────────────────────
  bool _rewardApplied = false; // 이미 보상 실행?
  bool _playedOnce = false;    // 유저가 실제 버튼 눌렀나?
  bool _completed = false;     // 보상 절대 1회만

  @override
  void initState() {
    super.initState();

    // 사운드
    final rootState = context.findAncestorStateOfType<RootState>();
    if (rootState != null && rootState.user.setting['sound']) {
      BgmManager.playBgm('bgm2.wav');
    }

    // 가드 초기화
    _rewardApplied = false;
    _playedOnce = false;
    _completed = false;

    // 🔒 시작 시에는 게임이 스스로 팝업 못 띄우게 게이트 닫기
    _game.allowClearOverlay(false);

    // 🔧 혹시 CleanGame이 onLoad 직후 팝업을 띄워버리면(레벨이 이미 클리어 상태 등)
    //    첫 프레임에 유저 조작 전이면 팝업을 제거하는 안전망
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_playedOnce && _game.overlays.isActive('ClearPopup')) {
        _game.overlays.remove('ClearPopup');
      }
    });
  }

  @override
  void dispose() {
    BgmManager.stopBgm();
    super.dispose();
  }

  // ── 보상은 이 함수 "단 한 곳"에서만 실행 ────────────────────────
  Future<void> _applyRewardOnce() async {
    if (_completed || _rewardApplied) return; // 재진입/중복 클릭 방지
    _completed = true;
    _rewardApplied = true;

    // 로컬 즉시 반영 (null 안전)
    if (widget.pet != null) {
      setState(() {
        widget.pet!.happy = (widget.pet!.happy + 10).clamp(0, 9999);
      });
    }

    // 서버 반영 (실패해도 UX 흐름은 유지)
    try {
      await gameCleanReward();
      // 필요 시: await petSaveDB(widget.uid, widget.petId, widget.pet);
    } catch (_) {
      // TODO: 스낵바/토스트 등 안내 원하면 여기
    }

    // 팝업 닫고, 부모에 변경됨(true) 전달
    _game.overlays.remove('ClearPopup');
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 빌드 타이밍에도 혹시 떠 있으면 제거(한 번 더 안전망)
    if (!_playedOnce && _game.overlays.isActive('ClearPopup')) {
      _game.overlays.remove('ClearPopup');
    }

    return Scaffold(
      body: Column(
        children: [
          // 🔹 게임 영역
          Expanded(
            flex: 5,
            child: GameWidget(
              game: _game,
              overlayBuilderMap: {
                'ClearPopup': (context, _) => ClearPopup(
                  onClose: () async {
                    // ✅ 보상은 오직 여기서만
                    await _applyRewardOnce();
                  },
                ),
              },
              initialActiveOverlays: const [],
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.centerLeft,
              child: const Row(
                children: [
                  Icon(Icons.home, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "청소",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 🎮 조이스틱
                  JoystickWidget(onDirectionChanged: _game.handleDirection),

                  const SizedBox(width: 48),

                  // 🧹 정사각형 치우기 버튼 (아이콘 + 텍스트)
                  SizedBox(
                    width: 100, // ✅ 정사각형 크기 지정
                    height: 100,
                    child: ElevatedButton(
                      onPressed: () {
                        _playedOnce = true;
                        _game.allowClearOverlay(true);
                        _game.tryClean();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.cleaning_services_rounded, size: 36),
                          SizedBox(height: 6),
                          Text(
                            "치우기",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 하단 네비게이션
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => widget.onNext(3),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => widget.onNext(0),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => widget.onNext(6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClearPopup extends StatelessWidget {
  final VoidCallback onClose;
  const ClearPopup({required this.onClose, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "CLEAR!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text("행복도 +10"),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onClose, child: const Text("확인")),
            ],
          ),
        ),
      ),
    );
  }
}
