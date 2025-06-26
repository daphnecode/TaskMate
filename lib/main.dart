import 'package:flutter/material.dart';
import 'petchose.dart';
import 'itemlist.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Virtual Pet'),
    );
  }
}

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

class SubArea extends StatelessWidget {
  const SubArea({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TutorialPage()),
                      );
                    },
                    child: Center(child: Text('Area 2')),
                  ),
                ),
                SizedBox(height: 10.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ItemlistPage()),
                      );
                    },
                    child: Center(child: Text('Area 3')),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.0,),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    child: Center(child: Text('Area 4')),
                  ),
                ),
                SizedBox(height: 10.0,),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle button press
                    },
                    child: Center(child: Text('Area 5')),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // 화면 내용은 여기에 따라 달라질 수 있음
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.lightBlue[100],
              child: Mainarea(),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.lightGreen[100],
              child: SubArea(),
              // SubArea()로 변경
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
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
