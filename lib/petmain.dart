import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'object.dart';
import 'petchoose.dart';
import 'petstatus.dart';

//청소게임
import 'clean_game_screen.dart';

//장애물달리기게임
import 'run_game_screen.dart';

Future<void> changeStatusSave(Pets pet) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/pet1.json');

  final jsonString = jsonEncode(pet.toJson());

  await file.writeAsString(jsonString);
}

class Mainarea extends StatefulWidget {
  final void Function(int) onNext;
  final Pets pet;
  final Users user;
  final int pageType;
  const Mainarea({required this.onNext, required this.pet, required this.user, required this.pageType, super.key});

  @override
  State<Mainarea> createState() => _MainareaState();
}

class _MainareaState extends State<Mainarea> {
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
    if (widget.user.image == "" || widget.pet.image == "") {
      return Center(child: CircularProgressIndicator());
    }
    
    return Column(
      children: [
        PetStatArea(pet: widget.pet, pageType: widget.pageType,),
        Expanded(
          child: GestureDetector(
            onLongPress: () {
              // Handle long press
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetChoose(onNext: widget.onNext),
                  )
                ).then((newPet) {
                  setState(() {
                    widget.pet.image = newPet.image;
                    widget.pet.name = newPet.name;
                    widget.pet.hunger = newPet.hunger;
                    widget.pet.happy = newPet.happy;
                    widget.pet.level = newPet.level;
                    widget.pet.currentExp = newPet.currentExp;
                  });
                });
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
                        widget.user.image, 
                        fit: BoxFit.cover, 
                        height: double.infinity, width: double.infinity
                        ),
                      Positioned(
                        left: width * 0.4, top: height * 0.5,
                        child: Image.asset(
                          widget.pet.image, 
                          fit: BoxFit.cover, 
                          height: height * 0.5, width: width * 0.4
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
  final Pets pet;
  final Users user;
  final int pageType;
  const Petmain({required this.onNext, required this.pet, required this.user, required this.pageType, super.key});

  @override
  State<Petmain> createState() => _PetmainState();
}

class _PetmainState extends State<Petmain> { 
  @override
  Widget build(BuildContext context) {
    if (widget.user.image == "" || widget.pet.image == "") {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Container(
              color: Colors.white,
              child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
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
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => RunGameScreen(
                                        onNext: (int index) {
                                          Navigator.pop(context);
                                          widget.onNext(index);
                                        },
                                      )),
                                    );
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