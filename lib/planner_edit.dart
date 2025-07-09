import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'daily_edit.dart';

//위젯
import 'package:taskmate/widgets/repeat_edit_box.dart';
import 'package:taskmate/widgets/today_edit_box.dart';

class PlannerEditPage extends StatefulWidget {

  final VoidCallback onBackToMain;
  final void Function(int) onNext;
  final List<Task> repeatTaskList;
  final List<Task> todayTaskList;
  final void Function(List<Task> updatedRepeatList, List<Task> updatedTodayList) onUpdateTasks;
  final Map<String, List<Task>> dailyTaskMap;
  final DateTime selectedDate;
  final void Function(Map<String, List<Task>>) onDailyMapChanged;


  const PlannerEditPage({
    required this.onNext,
    required this.onBackToMain,
    required this.repeatTaskList,
    required this.todayTaskList,
    required this.onUpdateTasks,
    required this.dailyTaskMap,
    required this.selectedDate,
    required this.onDailyMapChanged,
    super.key});

  @override
  _PlannerEditPageState createState() => _PlannerEditPageState();
}

class _PlannerEditPageState extends State<PlannerEditPage> {

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }


  late List<Task> repeatTaskList;
  late List<Task> todayTaskList;
  late DateTime selectedDate;
  late Map<String, List<Task>> dailyTaskMap;

  /*
  final void Function(int) onNext;
  _PlannerEditPageState({required this.onNext});
*/
  bool showFullRepeat =false;
  bool showFullToday = false;

  @override
  void initState() {
    super.initState(); // 부모 위젯으로부터 전달받은 리스트 복사
    repeatTaskList = List.from(widget.repeatTaskList);
    todayTaskList = List.from(widget.todayTaskList);
    selectedDate =widget.selectedDate;
    dailyTaskMap =  Map<String, List<Task>>.from(widget.dailyTaskMap);
  }

/*
  List<Task> repeatTaskList = [
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
  ];

  List<Task> todayTaskList = [
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
  ];
 */
  void updateTasks(int type, List<Task> newTasks) {
    setState(() {
      if (type == 0) {
        repeatTaskList = newTasks;
  } // type == 0 : 반복 리스트
      else if (type == 1) {
        todayTaskList = newTasks;
  } // type == 1 : 일일 리스트
    });
  }

  /*
  void updateRepeatTasks(List<Task> newTasks) {
    setState(() {
      repeatTaskList = newTasks;
    });
  }

  void updateTodayTasks(List<Task> updatedTasks) {
    setState(() {
      todayTaskList = updatedTasks;
    });
  }
   */
  void saveAndNavigate(int target) {
    final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    final key = _dateKey(widget.selectedDate);
    newMap[key] = todayTaskList;

    widget.onDailyMapChanged(newMap);
    widget.onUpdateTasks(repeatTaskList, todayTaskList);

    if(target == 0) {
      widget.onNext(0); //홈 화면으로 이동
    }
    else if(target ==1) {
      widget.onBackToMain(); //플래너 메인화면으로 이동
    }
  }
  /*
  void saveAndExitToMain() {
    final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    final key = _dateKey(widget.selectedDate);
    newMap[key] = todayTaskList;

    widget.onDailyMapChanged(newMap); // planner_main에 전달
    widget.onUpdateTasks(repeatTaskList, todayTaskList);
    widget.onBackToMain();
  }

  void saveAndGoHome() {
    final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    final key = _dateKey(widget.selectedDate);
    newMap[key] = todayTaskList;

    widget.onDailyMapChanged(newMap);
    widget.onUpdateTasks(repeatTaskList, todayTaskList);
    widget.onNext(0);
  }
   */




  /*
  void saveAndExitToMain() {
    widget.onUpdateTasks(repeatTaskList, todayTaskList);
    widget.onBackToMain();
  } //플래너 메인으로 이동할 때

  void saveAndGoHome() {
    widget.onUpdateTasks(repeatTaskList, todayTaskList);
    widget.onNext(0);
  } // 펫 메인화면으로 이동할 때
*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
            final key = _dateKey(widget.selectedDate);
            newMap[key] = todayTaskList;

            widget.onDailyMapChanged(newMap); // 최신화
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyTaskEditPage(
                    dailyTaskMap: widget.dailyTaskMap,
                    selectedDate: widget.selectedDate,
                    onUpdateDailyTaskMap: widget.onDailyMapChanged,
                  ),
            ),
            );// 일일 리스트 편집 이동
          },
        )
      ]),
      body: showFullRepeat
          ? ReapeatEditFullScreen(
        tasklist: repeatTaskList,
        onTaskAListUpdated: (updated) => updateTasks(0, updated),
        onCollapse: () {
          setState(() {
            showFullRepeat = false;
          });
        },
      )
          : showFullToday
          ? TodayEditFullScreen(
        taskList: todayTaskList,
        onTaskListUpdated: (updated) => updateTasks(1, updated),
        onCollapse: () {
          setState(() {
            showFullToday = false;
          });
        },
        selectedDate: selectedDate,
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RepeatEditBox(
                taskList: repeatTaskList,
                onTaskListUpdated: (updated) => updateTasks(0, updated),
                onExpand: () {
                  setState(() {
                    showFullRepeat = true;
                  });
                },
              ),
              TodayEditBox(
                taskList: todayTaskList,
                onTaskListUpdated: (updated) => updateTasks(1, updated),
                onExpand: () {
                  setState(() {
                    showFullToday = true;
                  });
                },
                selectedDate: selectedDate,
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () => saveAndNavigate(1),// 플래너 메인으로
                ),

              ),
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () => saveAndNavigate(0), // 펫 메인화면(홈)으로
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

