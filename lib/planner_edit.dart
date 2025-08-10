import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'daily_edit.dart';
import 'DBtest/firestore_service.dart';


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
  final String userId = "HiHgtVpIvdyCZVtiFCOc";

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

  /// 🔹 planner + dailyTasks 동시 저장
  Future<void> saveCurrentTasks() async {
    final key = _dateKey(selectedDate);
    await updateTasksToFirestore(userId, key, todayTaskList);
    await saveDailyTasks(userId, key, todayTaskList);
  }

  /// 저장 후 페이지 이동
  void saveAndNavigate(int target) async {
    final key = _dateKey(widget.selectedDate);
    final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    newMap[key] = todayTaskList;

    widget.onDailyMapChanged(newMap);
    widget.onUpdateTasks(repeatTaskList, todayTaskList);

    await saveCurrentTasks(); // 공통 저장

    if (target == 0) {
      widget.onNext(0); // 홈
    } else if (target == 1) {
      widget.onBackToMain(); // 플래너 메인
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            // 🔹 현재 데이터 저장
            await saveCurrentTasks();

            final key = _dateKey(selectedDate);
            final newMap = Map<String, List<Task>>.from(dailyTaskMap);
            newMap[key] = todayTaskList;

            if (!mounted) return;

            // DailyTaskEditPage로 이동
            final result = await Navigator.push<Map<String, List<Task>>>(
              context,
              MaterialPageRoute(
                builder: (context) => DailyTaskEditPage(
                  dailyTaskMap: newMap,
                  selectedDate: selectedDate,
                  onUpdateDailyTaskMap: (updatedMap) {},
                ),
              ),
            );

            // 돌아오면 결과 반영
            if (result != null) {
              setState(() {
                dailyTaskMap = result;
                todayTaskList = result[_dateKey(selectedDate)] ?? [];
              });
              widget.onDailyMapChanged(result);
            }
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
        color: Theme.of(context).cardColor,
        elevation: 0,
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
                onPressed: () {widget.onNext(6);
                  },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

