import 'package:flutter/material.dart';
import 'object.dart';

Row hungerStatus(int nowHunger) {
  int check = (nowHunger / 20).truncate() + 1;
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: List.generate(5, (index) {
      return Image.asset(
        (index < check) ? 'assets/icons/icon-chickenalt.png' : 'assets/icons/icon-chickenaltW.png',
        width: 30,
        height: 30,
        );
      },
      )
    );
}

Row happyStatus(int nowHappy) {
  int check = (nowHappy / 20).truncate() + 1;
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: List.generate(5, (index) {
      return Image.asset(
        index < check ? 'assets/icons/icon-heart.png' : 'assets/icons/icon-heartW.png',
        width: 30,
        height: 30,
        );
      },
      )
    );
}

class PetStatArea extends StatefulWidget{
  final Pets pet;
  const PetStatArea({required this.pet, super.key});

  @override
  State<PetStatArea> createState() => _PetStatAreaState();
}

class _PetStatAreaState extends State<PetStatArea> {
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
              child: PetStatus(pet: widget.pet),
            );
          },
        );
      },
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
                child: happyStatus(widget.pet.happy),
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
                child: hungerStatus(widget.pet.hunger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PetStatus extends StatelessWidget{
  final Pets pet;
  const PetStatus({required this.pet, super.key});

  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "LV ${pet.level}",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("------------------------"),
                    Text("${pet.currentExp}/157"),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: Image.asset("assets/icons/icon-heart.png")),
              Expanded(child: Text("${pet.happy}/100")),
              Expanded(child: Image.asset("assets/icons/icon-chickenalt.png")),
              Expanded(child: Text("${pet.hunger}/100")),
            ],
          ),
          SizedBox(height: 40,),
          Row(
            children: [
              Expanded(child: Text("총 달린 거리", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("15km", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("행복도 증가 횟수", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("124번", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("먹이 준 횟수", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("56번", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("가장 많이 준 먹이", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("딸기", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("경험치 총 획득량", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("1130pt", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("포인트 총 소비량", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("830pt", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
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
    );
  }
}