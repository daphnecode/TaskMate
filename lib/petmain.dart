import 'package:flutter/material.dart';
import 'widgets/button.dart';
import 'object.dart';
import 'petchoose.dart';
import 'petstatus.dart';

//청소게임
import 'clean_game_screen.dart';

//장애물달리기게임
import 'run_game_screen.dart';

//화면 상단 구성
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
    
  /*
  웹과 앱에서 실행할 때, 이미지 크기나 위치 조정.

  */
  @override
  Widget build(BuildContext context) {
    if (widget.user.setting['placeID'] == "" || widget.pet.image == "") {
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
                    widget.pet.styleID = newPet.styleID;
                  });
                });
            },
            child: AspectRatio(
              aspectRatio: 1 / 1, // 예: 모바일 화면 비율
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
    
                  return Stack(
                    children: [
                      Image.asset(
                        widget.user.setting['placeID'], 
                        fit: BoxFit.cover, 
                        height: h, width: w
                        ),
                      Positioned(
                        left: w * 0.5, top: h * 0.6,
                        child: Image.asset(
                          widget.pet.image, 
                          fit: BoxFit.cover, 
                          height: h * 0.2, width: w * 0.2,
                        ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
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
  final bool soundEffectsOn;
  const Petmain({required this.onNext, required this.pet, required this.user, required this.pageType, required this.soundEffectsOn, super.key});

  @override
  State<Petmain> createState() => _PetmainState();
}

class _PetmainState extends State<Petmain> { 
  @override
  Widget build(BuildContext context) {
    if (widget.user.setting['placeID'] == "" || widget.pet.image == "") {
      return Center(child: CircularProgressIndicator());
    }
    return Scaffold(
            appBar: AppBar(),
            body: Column(
              children: [
                Expanded(
                  flex: 6,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Mainarea(onNext: widget.onNext, pet: widget.pet, user: widget.user, pageType: widget.pageType,),
                    // MainArea()로 변경
                  ),
                ),
                //화면 하단 구성
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Expanded(
                                  child: mainButton(onNext: widget.onNext, buttonName: "창고", icon: "assets/icons/icon-list-alt.png", pageNumber: 1,),
                                ),
                                SizedBox(width: 10.0,),
                                Expanded(
                                  child: mainButton(onNext: widget.onNext, buttonName: "상점", icon: "assets/icons/icon-store.png", pageNumber: 5,),
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
                                        onPressed: () async {
                                          final changed =await Navigator.push<bool> (
                                            context,
                                            MaterialPageRoute(builder: (_) => CleanGameScreen(
                                              onNext: (int index) {
                                                Navigator.pop(context);
                                                widget.onNext(index);
                                              },
                                              soundEffectsOn: widget.soundEffectsOn,
                                              pet: widget.pet,
                                              uid: 'HiHgtVpIvdyCZVtiFCOc',
                                              petId: widget.user.nowPet,
                                            )),
                                          );
                                          if (changed == true) {
                                            setState(() {
                                            });
                                          }
                                          // Handle button press
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[100],
                                        ),
                                        child: Center(
                                          child: Text("청소", style: TextStyle(fontSize: 16, color: Colors.black)),
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
                                              soundEffectsOn: widget.soundEffectsOn,
                                              pet: widget.pet,
                                            )),
                                          ).then((value) {
                                            setState(() {
                                            });
                                          });
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[100],
                                        ),
                                        child: Center(
                                          child: Text("놀이", style: TextStyle(fontSize: 16, color: Colors.black)),
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
            // 하단 앱바
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
                          widget.onNext(3); // Navigate to PlannerMain
                        },
                      ),
          
                      IconButton(
                        icon: Icon(Icons.home),
                        onPressed: () {}, // 현재 페이지이므로 빈 처리
                      ),
                      IconButton(
                        icon: Icon(Icons.settings),
                        onPressed: () {widget.onNext(6);
                          },
                      ),
                    ],
                  ),
                ),
              ),
          );
      
  }
}