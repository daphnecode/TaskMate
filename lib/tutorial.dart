import 'package:flutter/material.dart';

List<Widget> getTutorialPagesFor(int pageType) {
    switch (pageType) {
      case 0:
        return [
          TutorialPage1(),
          TutorialPage2(),
          TutorialPage3(),
          TutorialPage4(),
        ];
      case 1:
        return [
          TutorialPage5(),
          TutorialPage6(),
          TutorialPage7(),
        ];
      case 2:
        return [
          TutorialPage8(),
          TutorialPage9(),
        ];
      case 3:
        return [
          TutorialPage10(),
          TutorialPage11(),
        ];
      default:
        return [
          TutorialPage1(),
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
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.arrow_left,),
                Image.asset(
                  "assets/images/petTuto1.png",
                  height: 500.0,
                  width: 250.0,
                ),
                Icon(Icons.arrow_right,),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 번호 (고정 너비)
                SizedBox(
                  width: 24,
                  child: Text(
                    "1.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 제목 + 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "상태창",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "펫의 포만도, 행복도, 레벨을 확인한다.\n클릭하면 상세하게 보여준다.",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10,),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 번호 (고정 너비)
                SizedBox(
                  width: 24,
                  child: Text(
                    "2.",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // 제목 + 설명
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "게임 기능",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "미니게임을 진행한다.\n아이템을 사용하거나 구매한다.",
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "3.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "창고",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "사용자가 보유한 아이템을 보여준다.\n아이템을 사용할 수 있다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "4.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "상점",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "구매 가능한 아이템을 보여준다.\n아이템을 구매할 수 있다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage3 extends StatelessWidget {
  const TutorialPage3({super.key});
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
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "5.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "청소",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "오염물을 치우는 미니게임이다.\n펫의 행복도가 증가한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "6.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "놀이",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "장애물을 피해 달리는 미니게임이다.\n펫의 포만도가 감소하고 행복도가 증가한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage4 extends StatelessWidget {
  const TutorialPage4({super.key});
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
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "7.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "캘린더",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "플래너 페이지로 이동한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "8.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "홈",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "펫 키우기 메인 페이지로 이동한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.0),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "9.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "설정",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "시스템 설정으로 이동한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage5 extends StatelessWidget {
  const TutorialPage5({super.key});
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
                "assets/images/petTuto3.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "1.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "카테고리",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "음식, 장난감, 배경, 스타일로 분류한다.\n아이템 목록으로 이동한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "2.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "포인트",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "상점 페이지에서 포인트를 보여준다.\n아이템 구매에 사용한다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage6 extends StatelessWidget {
  const TutorialPage6({super.key});
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
                "assets/images/petTuto2.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "3.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "음식",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "음식 아이템을 확인한다.\n펫의 행복도와 포만도에 영향을 준다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "4.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "장난감",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "장난감 아이템을 확인한다.\n펫의 행복도에 영향을 준다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage7 extends StatelessWidget {
  const TutorialPage7({super.key});
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
                "assets/images/petTuto2.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "5.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "배경",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "배경 아이템을 확인한다.\n펫의 방을 바꿀 수 있다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "6.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "스타일",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "스타일 아이템을 확인한다.\n펫의 외형에 변화를 준다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage8 extends StatelessWidget {
  const TutorialPage8({super.key});
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
                "assets/images/petTuto4.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "1.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "아이템 목록",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "선택된 카테고리의 아이템이다.\n클릭하면 사용 팝업이 나온다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "2.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "소비형 아이템",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "음식과 장난감 아이템이다.\n펫 상태에 영향을 주고 소모된다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage9 extends StatelessWidget {
  const TutorialPage9({super.key});
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
                "assets/images/petTuto5.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "3.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "배치형 아이템",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "배경과 스타일 아이템이다.\n배치하면 펫 배경과 외형이 바뀐다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "4.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "사용 중",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "현재 배치한 아이템을 확인한다.\n배치형 아이템만 나타난다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage10 extends StatelessWidget {
  const TutorialPage10({super.key});
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
                "assets/images/petTuto6.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "1.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "아이템 목록",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "선택된 카테고리의 아이템이다.\n클릭하면 구매 팝업이 나온다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "2.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "소비형 아이템",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "음식과 장난감 아이템이다.\n구매 개수에 제한이 없다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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

class TutorialPage11 extends StatelessWidget {
  const TutorialPage11({super.key});
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
                "assets/images/petTuto7.png",
                height: 500.0,
                width: 250.0,
              ),
              Icon(Icons.arrow_right,),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "3.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "배치형 아이템",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "배경과 스타일 아이템이다.\n구매 개수에 제한이 있다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10,),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 번호 (고정 너비)
              SizedBox(
                width: 24,
                child: Text(
                  "4.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // 제목 + 설명
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "구매 불가",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "더 이상 구매할 수 없는 아이템이다.\n배치형 아이템만 구매 제한이 있다.",
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
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