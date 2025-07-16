import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'planner_main.dart';
import 'planner_edit.dart';
import 'itemlist.dart';
import 'petmain.dart';
import 'petchoose.dart';
import 'package:taskmate/DBtest/task.dart';
import 'package:taskmate/DBtest/task_data.dart';
import 'object.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Virtual Pet'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  String nowBack = "assets/images/prairie.png";
  Pets pet1 = Pets(
    image: "assets/images/dragon.png",
    name: "",
    hunger:0,
    happy: 0,
    level: 0,
    currentExp: 0,
  );
  Pets pet2 = Pets(
    image: "assets/images/unicon.png",
    name: "",
    hunger:0,
    happy: 0,
    level: 0,
    currentExp: 0,
  );

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists(); // 먼저 파일 복사
    await loadItems();           // 복사 완료 후 파일 읽기s
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file1 = File('${dir.path}/pet1.json');
    final file2 = File('${dir.path}/items1.json');
    final file3 = File('${dir.path}/items2.json');
    final file4 = File('${dir.path}/items3.json');
    final file5 = File('${dir.path}/items4.json');
    String assetJson;

    assetJson = await rootBundle.loadString('lib/DBtest/pet1.json');
    await file1.writeAsString(assetJson);
    assetJson = await rootBundle.loadString('lib/DBtest/items1.json');
    await file2.writeAsString(assetJson);
    assetJson = await rootBundle.loadString('lib/DBtest/items2.json');
    await file3.writeAsString(assetJson);
    assetJson = await rootBundle.loadString('lib/DBtest/items3.json');
    await file4.writeAsString(assetJson);
    assetJson = await rootBundle.loadString('lib/DBtest/items4.json');
    await file5.writeAsString(assetJson);
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr1 = await File('${testDirectory.path}/pet1.json').readAsString();    
    final Map<String, dynamic> jsonData1 = json.decode(jsonStr1);
    final Pets loadedItems1 = Pets.fromJson(jsonData1);

    setState(() {
      pet1 = loadedItems1;
    });
  }

  Map<String, List<Task>> dailyTaskMap = {};
  DateTime selectedDate = DateTime.now();
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void goNext(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget currentWidget;

    switch (_currentIndex) {
      case 0:
        currentWidget = Petmain(onNext: goNext, pet: pet1);
        break;
      case 1:
        currentWidget = ItemCategory(onNext: goNext, pet: pet1);
        break;
      case 2:
        currentWidget = PetChoose(onNext: goNext);
        break;
      case 3:
        currentWidget = PlannerMain(onNext: goNext);
        break;
      case 4:
        currentWidget = PlannerEditPage(
          onNext: goNext,
          onBackToMain: () {
            setState(() {
              _currentIndex = 3; //플래너 메인으로 돌아가기
            });
          },

          repeatTaskList: repeatTaskList,
          todayTaskList: todayTaskList,

          onUpdateTasks: (updatedRepeat, updatedToday) {
            setState(() {
              repeatTaskList
                ..clear()
                ..addAll(updatedRepeat);
              todayTaskList
                ..clear()
                ..addAll(updatedToday);

              final key = _dateKey(selectedDate);
              dailyTaskMap[key] = updatedToday;
            });
          },

          dailyTaskMap: dailyTaskMap,
          selectedDate: selectedDate,
          onDailyMapChanged: (newMap) {
            setState(() {
              dailyTaskMap = newMap;
            });
          },
        );
        break;
      case 5:
        currentWidget = ShopCategory(onNext: goNext, pet: pet1);
        break;
      default:
        currentWidget = Text('기본');
    }

    return Scaffold(
        body:currentWidget
    );
  }
}