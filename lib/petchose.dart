import 'package:flutter/material.dart';

class Mainarea extends StatelessWidget {
  const Mainarea({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.lightBlue[100],
      child: Center(child: Text('Main Area')),
    );
  }
}

class Subarea extends StatelessWidget {
  const Subarea({super.key});

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
              child: Center(child: Text('Area 2')),
            ),
          ),
          SizedBox(height: 10.0,),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // Handle button press
              },
              child: Center(child: Text('Area 2')),
            ),
          ),
        ],
      );
  }
}

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.lightBlue[100],
              child: Mainarea(),
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.lightGreen[100],
              child: Subarea(),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: 'planner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'setting',
          ),
        ],
      ),
    );
  }
}