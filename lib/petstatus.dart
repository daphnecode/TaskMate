import 'package:flutter/material.dart';
import 'object.dart';
import 'tutorial.dart';
import 'package:taskmate/utils/icon_utis.dart';

Row hungerStatus(BuildContext context, int nowHunger) {
  int check = (nowHunger / 20).truncate() + 1;
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: List.generate(5, (index) {
      return getThemedIcon(
        context,
        index < check
            ? 'assets/icons/icon-chickenalt.png'
            : 'assets/icons/icon-chickenaltW.png',
        width: 30,
        height: 30,
      );
    }),
  );
}

Row happyStatus(BuildContext context, int nowHappy) {
  int check = (nowHappy / 20).truncate() + 1;
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: List.generate(5, (index) {
      return getThemedIcon(
        context,
        index < check
            ? 'assets/icons/icon-heart.png'
            : 'assets/icons/icon-heartW.png',
        width: 30,
        height: 30,
      );
    }),
  );
}

class PetStatArea extends StatefulWidget{
  final Pets? pet;
  final Users user;
  final int pageType;
  const PetStatArea({required this.pet, required this.user, required this.pageType, super.key});

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
              child: PetStatus(pet: widget.pet, user: widget.user,),
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
                  "LV ${widget.pet!.level}",),
              ),
              Expanded(
                child: happyStatus(context, widget.pet!.happy),
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
                child: hungerStatus(context, widget.pet!.hunger),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PetStatus extends StatelessWidget{
  final Pets? pet;
  final Users user;
  const PetStatus({required this.pet, required this.user, super.key});

  /*
  경험치가 증가하거나 감소했을 때, 레벨 업 혹은 레벨 다운.
  */
  @override
  Widget build(BuildContext context) {
    double progress = pet!.currentExp / petLevelTable[pet!.level-1].expToNext;
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
                  "LV ${pet!.level}",
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
                    Text("${pet!.currentExp}/${petLevelTable[pet!.level-1].expToNext}"),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: getThemedIcon(context, "assets/icons/icon-heart.png")),
              Expanded(child: Text("${pet!.happy}/100")),
              Expanded(child: getThemedIcon(context, "assets/icons/icon-chickenalt.png")),
              Expanded(child: Text("${pet!.hunger}/100")),
            ],
          ),
          SizedBox(height: 40,),
          /*
          사용자의 통계 정보로 갱신하기.
          */
          Row(
            children: [
              Expanded(child: Text("총 달린 거리", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text('${user.statistics['distance']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("행복도 증가 횟수", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text('${user.statistics['doCount']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("먹이 준 횟수", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text('${user.statistics['feedCount']}', style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
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
              Expanded(child: Text("${user.gotPoint}pt", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
            ],
          ),
          Row(
            children: [
              Expanded(child: Text("포인트 총 소비량", style: TextStyle(fontSize: 16),)),
              Expanded(child: Text("${user.gotPoint - user.currentPoint}pt", style: TextStyle(fontSize: 16), textAlign: TextAlign.end,)),
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