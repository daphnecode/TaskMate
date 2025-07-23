import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'package:taskmate/DBtest/task_data.dart';
import 'planner_edit.dart';
import 'statistics.dart';


//위젯
import 'package:taskmate/widgets/date_badge.dart';
import 'package:taskmate/widgets/repeat_task_box.dart';
import 'package:taskmate/widgets/today_task_box.dart';


class PlannerMain extends StatefulWidget {
  final void Function(int) onNext;

  const PlannerMain({required this.onNext,super.key});

  @override
  State<PlannerMain> createState() => _PlannerMainState(onNext: onNext);
}

class _PlannerMainState extends State<PlannerMain> {
  final void Function(int) onNext;
  bool isEditMode = false;
  Map<String, List<Task>> dailyTaskMap = {};
  late DateTime selectedDate;

  _PlannerMainState({required this.onNext});


  bool showFullRepeat = false;
  bool showFullToday = false;
  bool _isSubmitted = false;

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day
        .toString().padLeft(2, '0')}";
  }

  void toggleCheck(List<Task> tasklist, int index) {
    setState(() {
      tasklist[index] = tasklist[index].copyWith(
        isChecked: !tasklist[index].isChecked,
      );
    });
  }

  void toggleEditingMode(List<Task> taskList) {
    final anyEditing = taskList.any((task) => task.isEditing);
    setState(() {
      for (int i = 0; i < taskList.length; i++) {
        taskList[i] = taskList[i].copyWith(isEditing: !anyEditing);
      }
    });
  }

  void updatePoint(List<Task> taskList, int index, int newPoint) {
    setState(() {
      taskList[index] = taskList[index].copyWith(
        point: newPoint,
        isEditing: false,
      );
    });
  }

  //dailyTaskMap이 초기화되어 있지 않거나 해당 날짜 키가 없으면 빈 리스트로 초기화
  void _syncTodayTaskWithMap() {
    final key = _dateKey(selectedDate);
    todayTaskList = dailyTaskMap[key] ?? [];
  }

  void _updateDailyTaskMap() {
    final key = _dateKey(selectedDate);
    dailyTaskMap[key] = todayTaskList;
  }


  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    _syncTodayTaskWithMap(); // 오늘 날짜와 일일 리스트 연동
  }

  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return PlannerEditPage(
        onNext: onNext,
        repeatTaskList: repeatTaskList,
        todayTaskList: todayTaskList,
        onUpdateTasks: (updateRepeatLists, updateTodayList) {
          setState(() {
            repeatTaskList
              ..clear()
              ..addAll(updateRepeatLists);
            todayTaskList
              ..clear()
              ..addAll(updateTodayList);

            final key = _dateKey(selectedDate);
            dailyTaskMap[key] = updateTodayList;

            isEditMode = false;
          });
        },
        onBackToMain: () {
          setState(() {
            isEditMode = false;
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
    }

    // MaterialApp 없애고 Scaffold만 남김
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: Builder(
          builder: (context) =>
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StatisticsPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.pie_chart),
              ),
        ),
        title: const DateBadge(),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    content: const Text('정말 제출하겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          setState(() {
                            _isSubmitted = true;
                          });
                        },
                        child: const Text('예'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('아니요'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Text(
              '제출',
            ),
          ),
        ],
      ),
      body: showFullRepeat
          ? RepeatTaskFullScreen(
        taskList: repeatTaskList,
        onToggleCheck: (index) => toggleCheck(repeatTaskList, index),
        onCollapse: () {
          setState(() {
            showFullRepeat = false;
          });
        },
        onEditPoints: () => toggleEditingMode(repeatTaskList),
        onEditPoint: (index, newPoint) =>
            updatePoint(repeatTaskList, index, newPoint),
        onStartEditing: (index) {
          setState(() {
            repeatTaskList[index] =
                repeatTaskList[index].copyWith(isEditing: true);
          });
        },
      )
          : showFullToday
          ? TodayTaskFullScreen(
        taskList: todayTaskList,
        onToggleCheck: (index) =>
            toggleCheck(todayTaskList, index),
        onCollapse: () {
          setState(() {
            showFullToday = false;
          });
        },
        onEditPoints: () => toggleEditingMode(todayTaskList),
        onEditPoint: (index, newPoint) =>
            updatePoint(todayTaskList, index, newPoint),
        onStartEditing: (index) {
          setState(() {
            todayTaskList[index] =
                todayTaskList[index].copyWith(isEditing: true);
          });
        },
      )
          : Column(
        children: [
          Expanded(
            flex: 2,
            child: RepeatTaskBox(
              taskList: repeatTaskList,
              onToggleCheck: (index) =>
                  toggleCheck(repeatTaskList, index),
              onExpand: () {
                setState(() {
                  showFullRepeat = true;
                });
              },
              onEditPoints: () =>
                  toggleEditingMode(repeatTaskList),
              onEditPoint: (index, newPoint) =>
                  updatePoint(repeatTaskList, index, newPoint),
              onStartEditing: (index) {
                setState(() {
                  repeatTaskList[index] = repeatTaskList[index]
                      .copyWith(isEditing: true);
                });
              },
            ),
          ),
          Expanded(
            flex: 2,
            child: TodayTaskBox(
              taskList: todayTaskList,
              onToggleCheck: (index) =>
                  toggleCheck(todayTaskList, index),
              onExpand: () {
                setState(() {
                  showFullToday = true;
                });
              },
              onEditPoints: () =>
                  toggleEditingMode(todayTaskList),
              onEditPoint: (index, newPoint) =>
                  updatePoint(todayTaskList, index, newPoint),
              onStartEditing: (index) {
                setState(() {
                  todayTaskList[index] = todayTaskList[index]
                      .copyWith(isEditing: true);
                });
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Theme.of(context).bottomAppBarTheme.color,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  setState(() {
                    isEditMode = true;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  onNext(0);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
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
