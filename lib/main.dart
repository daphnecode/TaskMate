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
import 'SettingsPage.dart';

void main() {
  runApp(const Root());
}
class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  bool isDarkMode = false;
  bool soundEffectsOn = false;

  void toggleDarkMode(bool value) {
    setState(() => isDarkMode = value);
  }

  void toggleSoundEffects(bool value) {
    setState(() => soundEffectsOn = value);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskMate',
      theme: ThemeData.light().copyWith(
        bottomAppBarTheme: const BottomAppBarTheme(color: Colors.white), // 라이트모드 하단바
      ),
      darkTheme: ThemeData.dark().copyWith(
        iconTheme: const IconThemeData(color: Colors.white),
        bottomAppBarTheme: BottomAppBarTheme(color: Colors.grey[900]), // 다크모드 하단바
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: MyHomePage(
        title: 'Virtual Pet',
        isDarkMode: isDarkMode,
        soundEffectsOn: soundEffectsOn,
        onDarkModeChanged: toggleDarkMode,
        onSoundEffectsChanged: toggleSoundEffects,
      ),
    );
  }
}
/*
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
*/

class MyHomePage extends StatefulWidget {
  final bool isDarkMode;
  final bool soundEffectsOn;
  final Function(bool) onDarkModeChanged;
  final Function(bool) onSoundEffectsChanged;

  const MyHomePage({super.key,
    required this.title,
    required this.isDarkMode,
    required this.soundEffectsOn,
    required this.onDarkModeChanged,
    required this.onSoundEffectsChanged,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  Users user = Users(
    point: 0,
    image: "",
    name: ""
  );
  Pets pet = Pets(
    image: "",
    name: "",
    hunger:0,
    happy: 0,
    level: 0,
    currentExp: 0,
  );

  bool isDarkMode = false;
  bool soundEffectsOn = false;

  @override
  void initState() {
    super.initState();
    initAsync();
  }

  Future<void> initAsync() async {
    await initJsonIfNotExists();
    await loadItems();
  }

  Future<void> initJsonIfNotExists() async {
    final dir = await getApplicationDocumentsDirectory();
    final file1 = File('${dir.path}/pet1.json');
    final file2 = File('${dir.path}/items1.json');
    final file3 = File('${dir.path}/items2.json');
    final file4 = File('${dir.path}/items3.json');
    final file5 = File('${dir.path}/items4.json');
    final file6 = File('${dir.path}/user1.json');
    final file7 = File('${dir.path}/pet2.json');
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
    assetJson = await rootBundle.loadString('lib/DBtest/user1.json');
    await file6.writeAsString(assetJson);
    assetJson = await rootBundle.loadString('lib/DBtest/pet2.json');
    await file7.writeAsString(assetJson);
  }

  Future<void> loadItems() async {
    final testDirectory = await getApplicationDocumentsDirectory();
    String jsonStr1 = await File('${testDirectory.path}/user1.json').readAsString();    
    final Map<String, dynamic> jsonData1 = json.decode(jsonStr1);
    final Users loadedItems1 = Users.fromJson(jsonData1);

    String jsonStr2 = await File('${testDirectory.path}/pet1.json').readAsString();    
    final Map<String, dynamic> jsonData2 = json.decode(jsonStr2);
    final Pets loadedItems2 = Pets.fromJson(jsonData2);

    setState(() {
      user = loadedItems1;
      pet = loadedItems2;
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
        currentWidget = Petmain(onNext: goNext, pet: pet, user: user, pageType: 0,);
        break;
      case 1:
        currentWidget = ItemCategory(onNext: goNext, pet: pet, user: user, pageType: 1,);
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
        currentWidget = ShopCategory(onNext: goNext, pet: pet, user: user,  pageType: 1,);
        break;

      case 6:
        currentWidget = SettingsPage(
          onNext: goNext,
          isDarkMode: widget.isDarkMode,
          soundEffectsEnabled: soundEffectsOn,
          notificationsEnabled: false,
          sortingMethod: '기본값',
          onDarkModeChanged: widget.onDarkModeChanged,
        );
        break;

      default:
        currentWidget = Text('기본');
    }

    return Scaffold(
        body:currentWidget
    );
  }
}