import 'package:flutter/material.dart';

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

class Subarea1 extends StatelessWidget {
  const Subarea1({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
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
              color: Colors.white,
              child: Mainarea1(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: Subarea1(),
              ),
            ),
        ],
      ),
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
                    onNext(3); // Navigate to PlannerMain
                  },
                ),

                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
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