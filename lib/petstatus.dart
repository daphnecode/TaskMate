import 'package:flutter/material.dart';
import 'object.dart';
import 'tutorial.dart';

Row hungerStatus(int nowHunger) {
  int check = (nowHunger / 20).truncate() + 1;
  
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: List.generate(5, (index) {
      return Image.asset(
        (index < check) ? 'assets/icons/icon-chickenaltW.png' : 'assets/icons/icon-chickenalt.png',
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
        index < check ? 'assets/icons/icon-heartW.png' : 'assets/icons/icon-heart.png',
        width: 30,
        height: 30,
        );
      },
      )
    );
}

class PetStatArea extends StatefulWidget{
  final Pets pet;
  final int pageType;
  const PetStatArea({required this.pet, required this.pageType, super.key});

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
                  "LV ${widget.pet.level}",),
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
                    onPressed: () => showTutorial(context, widget.pageType),
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
    double progress = pet.currentExp / 157;
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
                    Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 8,
                          backgroundColor: Colors.white,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                      ),
                      SizedBox(width: 4),
                    ],
                  ),
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