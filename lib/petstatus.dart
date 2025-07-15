import 'package:flutter/material.dart';
import 'object.dart';

class PetStatus extends StatelessWidget{
  final Pets pet1;
  const PetStatus({required this.pet1, super.key});

  
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
                  "LV 13",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    Text("------------------------"),
                    Text("111/157"),
                  ],
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(child: Image.asset("assets/icons/icon-heart.png")),
              Expanded(child: Text("${pet1.happy}/100")),
              Expanded(child: Image.asset("assets/icons/icon-chickenalt.png")),
              Expanded(child: Text("${pet1.hunger}/100")),
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