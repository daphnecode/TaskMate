import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:taskmate/game/clean_game.dart';
import 'package:taskmate/widgets/joystick_widget.dart';

class CleanGameScreen extends StatefulWidget {
  final void Function(int) onNext;
  const CleanGameScreen({super.key, required this.onNext});

  @override
  State<CleanGameScreen> createState() => _CleanGameScreenState();
}

class _CleanGameScreenState extends State<CleanGameScreen> {
  final CleanGame _game = CleanGame();

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
                  onClose: () {
                    _game.overlays.remove('ClearPopup');
                    Navigator.pop(context);
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
                onPressed: () {},
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [BoxShadow(blurRadius: 10, color: Colors.black26)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("CLEAR!",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
