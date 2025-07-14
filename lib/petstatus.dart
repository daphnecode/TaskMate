import 'package:flutter/material.dart';

class PetStatus extends StatelessWidget{
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
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
    );
  }
}