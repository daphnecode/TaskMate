import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'object.dart';
import 'petchoose.dart';
import 'petstatus.dart';

//청소게임
import 'clean_game_screen.dart';

Future<void> changeStatusSave(Pets pet) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pet1.json');

  final jsonString = jsonEncode(pet.toJson());

  await file.writeAsString(jsonString);
}

class Mainarea extends StatefulWidget {
  final void Function(int) onNext;
  const Mainarea({required this.onNext, super.key});

  @override
  State<Mainarea> createState() => _MainareaState();
}

class _MainareaState extends State<Mainarea> {
  Users user = Users(
    point: 0,
    image: "",
    name: ""
  );
  Pets pet = Pets(
    image: "",
    name: "",
    hunger:0,
    happy: 0,
    level: 0,
    currentExp: 0,
  );
  
  
  @override
  void initState() {
    super.initState();
    loadItems();
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr = await File('${testDirectory.path}/user1.json').readAsString();    
    final Map<String, dynamic> jsonData = json.decode(jsonStr);
    final Users loadedItems = Users.fromJson(jsonData);

    String jsonStr1 = await File('${testDirectory.path}/pet1.json').readAsString();    
    final Map<String, dynamic> jsonData1 = json.decode(jsonStr1);
    final Pets loadedItems1 = Pets.fromJson(jsonData1);

    setState(() {
      user = loadedItems;
      pet = loadedItems1;
    });
  }

  
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 미리 이미지 로딩
    for (int i = 0; i < 5; i++) {
      precacheImage(AssetImage('assets/icons/icon-heart.png'), context);
      precacheImage(AssetImage('assets/icons/icon-heartW.png'), context);
      precacheImage(AssetImage('assets/icons/icon-chickenalt.png'), context);
      precacheImage(AssetImage('assets/icons/icon-chickenaltW.png'), context);
    }
  }
    

  @override
  Widget build(BuildContext context) {
    if (user.image == "" || pet.image == "") {
      return Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        PetStatArea(pet: pet),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              // Handle long press
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetChoose(onNext: widget.onNext),));
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
                        user.image, 
                        fit: BoxFit.cover, 
                        height: double.infinity, width: double.infinity
                        ),
                      Positioned(
                        left: width * 0.4, top: height * 0.5,
                        child: Image.asset(
                          pet.image, 
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
    );
  }
}

class Petmain extends StatefulWidget {
  final void Function(int) onNext;
  const Petmain({required this.onNext, super.key});

  @override
  State<Petmain> createState() => _PetmainState();
}

class _PetmainState extends State<Petmain> {
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
              child: Mainarea(onNext: widget.onNext),
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
                                  widget.onNext(1); // Navigate to ItemlistPage
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
                                  widget.onNext(5); // Navigate to ItemlistPage
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => CleanGameScreen(
                                        onNext: (int index) {
                                          Navigator.pop(context);
                                          widget.onNext(index);
                                        },
                                      )),
                                    );
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
                    widget.onNext(3); // Navigate to PlannerMain
                  },
                ),

                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {widget.onNext(0);
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