import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:taskmate/game/run_game.dart';

class RunGameScreen extends StatefulWidget {
  final void Function(int) onNext;
  const RunGameScreen({super.key, required this.onNext});

  @override
  State<RunGameScreen> createState() => _RunGameScreenState();
}

class _RunGameScreenState extends State<RunGameScreen> {
  final RunGame _game = RunGame();
  bool _isPlaying = false;

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
                    setState(() {
                      _isPlaying = false; // 다시 거리 버튼 보이도록
                    });
                    Navigator.pop(context);
                  },
                ),
                'FailPopup' : (context, _) => FailPopup(
                  onClose: () {
                    _game.overlays.remove('FailPopup');
                    setState(() {
                      _isPlaying = false; // 다시 거리 버튼 보이도록
                    });
                    Navigator.pop(context);
                  },
                )
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
                  Text("놀이",
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
            child: _isPlaying ?
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _game.jump(); // 점프 처리 함수 예시
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(240, 120),
                  backgroundColor: Colors.green,
                ),
                child: Text("Jump", style: TextStyle(fontSize: 24)),
              ),
            ) : 
            Container(
              color: Colors.grey[200],
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _game.startGame(100);  // 100m 시작
                      setState(() {
                        _isPlaying = true;
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 200),
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("100m"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _game.startGame(300);  // 100m 시작
                      setState(() {
                        _isPlaying = true;
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 200),
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("300m"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _game.startGame(1000);  // 100m 시작
                      setState(() {
                        _isPlaying = true;
                      });
                    }, 
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(100, 200),
                      backgroundColor: Colors.yellow,
                      foregroundColor: Colors.white,
                    ),
                    child: Text("1km"),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // 🔹 하단 네비게이션
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
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
              const Text("행복도 +10 포만도 -10"),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onClose, child: const Text("확인")),
            ],
          ),
        ),
      ),
    );
  }
}

class FailPopup extends StatelessWidget {
  final VoidCallback onClose;
  const FailPopup({required this.onClose, super.key});

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
              const Text("FAIL",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              const Text("다시 도전해요!"),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: onClose, child: const Text("확인")),
            ],
          ),
        ),
      ),
    );
  }
}