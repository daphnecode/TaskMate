import 'package:flutter/material.dart';
import 'planner_main.dart';
import 'planner_edit.dart';
import 'itemlist.dart';
import 'petmain.dart';
import 'petchoose.dart';
import 'package:taskmate/DBtest/task.dart';
import 'package:taskmate/DBtest/task_data.dart';

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
          currentWidget = Petmain(onNext: goNext);
          break;
        case 1:
          currentWidget = ItemCategory(onNext: goNext);
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
          currentWidget = ShopCategory(onNext: goNext);
          break;
        default:
          currentWidget = Text('기본');
    }
    
    return Scaffold(
      body:currentWidget
    );  
  }
}
