import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:taskmate/game/clean_game.dart';
import 'package:taskmate/widgets/joystick_widget.dart';
import 'package:taskmate/utils/bgm_manager.dart';
import 'main.dart';
import 'object.dart';
import 'package:taskmate/DBtest/firestore_service.dart';

class CleanGameScreen extends StatefulWidget {
  final void Function(int) onNext;
  final bool soundEffectsOn;
  final Pets? pet;
  final String uid;
  final String petId;

  const CleanGameScreen({super.key,
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

  //중복 보상 방지
  bool _rewardApplied = false;

  @override
  void initState() {
    super.initState();
    // Root에서 현재 사운드 설정 읽기
    final rootState = context.findAncestorStateOfType<RootState>();
    if (rootState != null && rootState.user.setting['sound']) {
      BgmManager.playBgm('bgm2.wav');
    }
  }

  @override
  void dispose() {
    BgmManager.stopBgm();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                    if (_rewardApplied) return;
                    _rewardApplied = true;

                    // 로컬 즉시 반영
                    setState(() {
                      widget.pet!.happy = (widget.pet!.happy + 10).clamp(0, 9999);
                    });

                    //  DB 반영
                    try {
                      await petSaveDB(widget.uid, widget.petId, widget.pet);
                    } catch (e) {

                    }
                    // 부모에게 "변경됨" 신호 보내서 돌아간 화면이 setState 하도록
                    _game.overlays.remove('ClearPopup');
                    Navigator.pop(context, true);
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
                  Text("청소",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
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
                  JoystickWidget(onDirectionChanged: _game.handleDirection),
                  ElevatedButton(
                    onPressed: () {
                      _game.tryClean();
                      if (_game.isClear()) {
                        _game.overlays.add('ClearPopup');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("치우기"),
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
                onPressed: () {
                  widget.onNext(3);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => widget.onNext(0),
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {widget.onNext(6);
                  },
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
              const Text("CLEAR!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, )),
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
