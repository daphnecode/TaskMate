import 'package:flutter/material.dart';
import 'petchoose.dart';
import 'itemlist.dart';

class Mainarea extends StatefulWidget {
  const Mainarea({super.key});

  @override
  State<Mainarea> createState() => _MainareaState();
}

class _MainareaState extends State<Mainarea> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: Colors.white10,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold), 
                      "LV 13",),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      Icon(Icons.heart_broken,),
                      ],
                    )
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: Icon(Icons.question_mark,),
                        onPressed: () {
                          // Handle back button press
                        },
                        )
                      ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      Icon(Icons.apple,),
                      ],
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              // Handle long press
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PetChoose()),
              );
            },
            child: Container(
              color: Colors.white,
              child: Stack(
                children: [
                  Image.asset(
                    "assets/images/beach.png", 
                    fit: BoxFit.cover, 
                    height: double.infinity, width: double.infinity
                    ),
                  Positioned(
                    left: 150.0, top: 150.0,
                    child: Image.asset(
                      "assets/images/dragon.png", 
                      fit: BoxFit.cover, 
                      height: 180.0, width: 180.0
                    ),
                  ),
                ],
              ),
          ),),
        ),
      ],
    );
  }
}

class Petmain extends StatelessWidget {
  final void Function(int) onNext;
  const Petmain({required this.onNext, super.key});


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Container(
              color: Colors.white,
              child: Mainarea(),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                     onNext(1); // Navigate to ItemlistPage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 2')),
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
                      onNext(1); // Navigate to ItemlistPage
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[100],
                    ),
                    child: Center(child: Text('Area 4')),
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
                    child: Center(child: Text('Area 5')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
              // SubArea()로 변경
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          // Handle bottom navigation bar tap
          if (index == 0) {
            // Navigate to planner
          } else if (index == 1) {
            // Navigate to home
            onNext(0); // Call onNext to switch to ItemlistPage
          } else if (index == 2) {
            // Navigate to settings
          }
        },
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