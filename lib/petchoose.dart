import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'object.dart';

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
  Future<Pets> loadPet(String currentPet) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception("로그인 필요");
    }

    final userRef = FirebaseFirestore.instance.collection('Users').doc(uid);

    // 선택한 펫 문서 읽기
    final petDoc = await userRef.collection('pets').doc(currentPet).get();
    final Pets loaded = petDoc.exists
        ? Pets.fromMap(petDoc.data() as Map<String, dynamic>)
        : Pets(
            image: "",
            name: "",
            hunger: 0,
            happy: 0,
            level: 0,
            currentExp: 0,
            styleID: "",
          );

    // 현재 선택 펫 저장
    await userRef.update({'nowPet': currentPet});

    return loaded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, "dragon"); // ✅ Pets로 pop
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
              Navigator.pop(context, "unicon");
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

              Navigator.pop(context, "unicon");
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
  final void Function(String) updatePet;
  final void Function(int) onNext;
  const PetChoose({required this.updatePet, required this.onNext, super.key});

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
