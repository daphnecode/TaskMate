import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/api_service.dart';

class Mainarea1 extends StatelessWidget {
  const Mainarea1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[100],
      child: const Center(
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            '함께할 펫을 선택해주세요!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class Subarea1 extends StatefulWidget {
  const Subarea1({super.key});

  @override
  State<Subarea1> createState() => _Subarea1State();
}

class _Subarea1State extends State<Subarea1> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await choosePet("dragon");
              Navigator.pop(context); // ✅ Pets로 pop
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red[100]),
            child: Center(
              child: Image.asset(
                "assets/images/dragon.png",
                fit: BoxFit.cover,
                height: 100.0,
                width: 100.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              await choosePet("unicon");
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green[100]),
            child: Center(
              child: Image.asset(
                "assets/images/unicon.png",
                fit: BoxFit.cover,
                height: 100.0,
                width: 100.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10.0),
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              // 필요하면 다른 펫 ID로 교체
              await choosePet("unicon");
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[100]),
            child: Center(
              child: Image.asset(
                "assets/images/unicon.png",
                fit: BoxFit.cover,
                height: 100.0,
                width: 100.0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PetChoose extends StatelessWidget {
  final void Function(int) onNext;
  const PetChoose({required this.onNext, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(20.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Mainarea1(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: const Subarea1(),
            ),
          ),
        ],
      ),
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
                  Navigator.pop(context);
                  onNext(3);
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.pop(context);
                  onNext(0);
                },
              ),
              IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
