import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'object.dart';

class Mainarea1 extends StatelessWidget {
  const Mainarea1({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.purple[100],
      child: Center(
        child: Container(
          padding: EdgeInsets.all(8.0),
          child: Text(
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            '함께할 펫을 선택해주세요!',))),
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
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr2 = await File('${testDirectory.path}/$currentPet.json').readAsString();    
    final Map<String, dynamic> jsonData2 = json.decode(jsonStr2);
    final Pets loadedItems2 = Pets.fromJson(jsonData2);

    return loadedItems2;
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
                Navigator.pop(context, loadPet("pet1"));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[100],
              ),
              child: Center(
                child: Image.asset("assets/images/dragon.png", fit: BoxFit.cover, height: 100.0, width: 100.0)),
            ),
          ),
          SizedBox(height: 10.0,),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
                Navigator.pop(context, loadPet("pet2"));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[100],
              ),
              child: Center(child: Image.asset("assets/images/unicon.png", fit: BoxFit.cover, height: 100.0, width: 100.0)),
            ),
          ),
          SizedBox(height: 10.0,),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
                Navigator.pop(context, loadPet("pet2"));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
              ),
              child: Center(child: Image.asset("assets/images/unicon.png", fit: BoxFit.cover, height: 100.0, width: 100.0)),
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
              padding: EdgeInsets.all(20.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Mainarea1(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
              child: Subarea1(),
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
                    onNext(3); // Navigate to PlannerMain
                  },
                ),

                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.pop(context);
                    onNext(0);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
    );
  }
}