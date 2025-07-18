import 'package:flutter/material.dart';

List<Widget> getTutorialPagesFor(int pageType) {
    switch (pageType) {
      case 0:
        return [
          TutorialPage1(),
          TutorialPage2(),
        ];
      case 1:
        return [
          TutorialPage1(),
        ];
      case 2:
        return [
          TutorialPage2(),
        ];
      default:
        return [
          TutorialPage2(),
        ];
    }
}


void showTutorial(BuildContext context, int pageType) {
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: PageView(
          children: getTutorialPagesFor(pageType),
        ),
      );
    },
  );
}

class TutorialPage1 extends StatelessWidget {
  const TutorialPage1({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
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
              Navigator.pop(context);
            },
            child: Text("닫기"),
          ),
        ],
      ),
    );
  }
}

class TutorialPage2 extends StatelessWidget {
  const TutorialPage2({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
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
            "메인 화면은 아닙니다.",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.0),
          SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text("닫기"),
          ),
        ],
      ),
    );
  }
}