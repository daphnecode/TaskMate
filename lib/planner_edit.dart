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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
      onPressed: () async {
        final newMap = Map<String, List<Task>>.from(dailyTaskMap);
        final key = _dateKey(selectedDate);
        newMap[key] = todayTaskList;

        // 화면 이동 + 결과 기다림
        final result = await Navigator.push<Map<String, List<Task>>>(
          context,
          MaterialPageRoute(
            builder: (context) => DailyTaskEditPage(
              dailyTaskMap: newMap,
              selectedDate: selectedDate,
              onUpdateDailyTaskMap: (updatedMap) {
                //Navigator.pop(context, updatedMap); // ✅ 수정된 map을 반환
              },
            ),
          ),
        );

        // 돌아왔을 때 result가 null 아니면 상태 반영
        if (result != null) {
          setState(() {
            dailyTaskMap = result;
            todayTaskList = result[_dateKey(selectedDate)] ?? [];
          });

          // 부모 위젯에도 전달
          widget.onDailyMapChanged(result);
        }
      }
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

