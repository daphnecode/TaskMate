import 'package:flutter/material.dart';

class Mainarea extends StatelessWidget {
  final void Function(int) onNext;
  const Mainarea({required this.onNext, super.key});

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
                      Image.asset("assets/icons/icon-heart.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-heart.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-heart.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-heart.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-heart.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
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
                      Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
                      Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
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
              onNext(2); // Navigate to PetChoose
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
                      "assets/images/unicon.png", 
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
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: onNext,),
              // MainArea()로 변경
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.grey[100],
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                  onNext(1); // Navigate to ItemlistPage
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[100],
                                  ),
                                  child: Center(
                                    child: Text("창고", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                Positioned(
                                  left: 0, top: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: 35,
                                    child: Image.asset(
                                      "assets/icons/icon-list-alt.png", 
                                      fit: BoxFit.fill, width: 50, height: 50
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child: Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                  onNext(5); // Navigate to ItemlistPage
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[100],
                                  ),
                                  child: Center(
                                    child: Text("상점", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                Positioned(
                                  left: 0, top: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: 35,
                                    child: Image.asset(
                                      "assets/icons/icon-store.png", 
                                      fit: BoxFit.fill, width: 50, height: 50
                                    ),
                                  ),
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle button press
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[100],
                                  ),
                                  child: Center(
                                    child: Text("청소", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                Positioned(
                                  left: 0, top: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: 35,
                                    child: Image.asset(
                                      "assets/icons/icon-paintbrush.png", 
                                      fit: BoxFit.fill, width: 50, height: 50
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 10.0,),
                          Expanded(
                            child:Stack(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle button press
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[100],
                                  ),
                                  child: Center(
                                    child: Text("놀이", style: TextStyle(fontSize: 16)),
                                  ),
                                ),
                                Positioned(
                                  left: 0, top: 0,
                                  child: CircleAvatar(
                                    backgroundColor: Colors.blueAccent,
                                    radius: 35,
                                    child: Image.asset(
                                      "assets/icons/icon-raceflag.png", 
                                      fit: BoxFit.fill, width: 50, height: 50
                                    ),
                                  ), 
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          // Handle bottom navigation bar tap
          if (index == 0) {
            // Navigate to planner
            onNext(3); // Call onNext to switch to PlannerMain
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