import 'package:flutter/material.dart';
import 'object.dart';

List<Image> hungerStatus(int nowHunger) {
  List<Image> now = [];

  int check = (nowHunger / 20).truncate();
  
  switch (check) {
    case 0:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
    case 1:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
    case 2:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
    case 3:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenaltW.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
    case 4:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
    default:
      now = [
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
        Image.asset("assets/icons/icon-chickenalt.png", fit: BoxFit.cover, height: 30.0, width: 30.0),
      ];
      return now;
  }
  
}

class Mainarea extends StatefulWidget {
  final void Function(int) onNext;
  const Mainarea({required this.onNext, super.key});

  @override
  State<Mainarea> createState() => _MainareaState();
}

class _MainareaState extends State<Mainarea> {
  Pets pet1 = Pets(
    image: "assets/images/dragon.png",
    name: "드래곤",
    hunger: 40,
    happy: 70,
    level: 33,
    currentExp: 50,
  );
    

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "펫 상태창입니다.",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    Text(
                      "펫의 세부상태와 통계를 확인할 수 있습니다.",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("닫기"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Column(
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return Dialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.arrow_left,),
                                            Image.asset(
                                              "assets/images/petTuto1.png",
                                              height: 600.0,
                                              width: 250.0,
                                            ),
                                            Icon(Icons.arrow_right,),
                                          ],
                                        ),
                                        Text(
                                          "펫 키우기 메인화면 입니다.",
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(height: 10.0),
                                        Text(
                                          "여러 기능을 사용할 수 있습니다.",
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        SizedBox(height: 20.0),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text("닫기"),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          )
                        ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: hungerStatus(pet1.hunger),
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
                widget.onNext(2); // Navigate to PetChoose
              },
              child: Container(
                color: Colors.white,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;
      
                    return Stack(
                      children: [
                        Image.asset(
                          "assets/images/beach.png", 
                          fit: BoxFit.cover, 
                          height: double.infinity, width: double.infinity
                          ),
                        Positioned(
                          left: width * 0.4, top: height * 0.5,
                          child: Image.asset(
                            pet1.image, 
                            fit: BoxFit.cover, 
                            height: 180.0, width: 180.0
                          ),
                        ),
                      ],
                    );
                  }
                ),
            ),),
          ),
        ],
      ),
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
                  onPressed: () {onNext(0);
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