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
  final String sortingMethod;
  const PlannerMain(
      {
        required this.onNext,
        required this.sortingMethod,
        super.key
      }
    );

  @override
  State<PlannerMain> createState() => _PlannerMainState();
}

class _PlannerMainState extends State<PlannerMain> {
  bool isEditMode = false;
  Map<String, List<Task>> dailyTaskMap = {};
  late DateTime selectedDate;


  bool showFullRepeat = false;
  bool showFullToday = false;
  bool _isSubmitted = false;

  String userId = "HiHgtVpIvdyCZVtiFCOc";

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
    _autoSave(); // Firestore에 바로 저장
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
    _autoSave(); // Firestore에 바로 저장
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

  // Firestore 저장 함수
  void _autoSave() {
    final dateKey = _dateKey(selectedDate);
    updateTasksToFirestore(userId, dateKey, todayTaskList); // 일일 리스트 저장
    updateRepeatTasks(userId, repeatTaskList); // 반복 리스트 저장
  }



  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
    final dateKey = _dateKey(selectedDate);

    // 오늘 문서 없으면 생성 + visited 기록
    initializeTasksIfNotExist(userId, dateKey, todayTaskList);

    // 반복 리스트 불러오기
    fetchRepeatTasks(userId).then((repeatTasks) {
      setState(() {
        repeatTaskList = repeatTasks;
      });
    });

    // 일일 리스트 불러오기
    fetchTasks(userId, dateKey).then((data) {
      setState(() {
        todayTaskList = data['todayTasks'];
        _isSubmitted = data['submitted'];
      });
    });
  }

    //  Firestore 제출 함수
  void _submit() async {
    final dateKey = _dateKey(selectedDate);
    try {
      await submitTasksToFirestore(userId, dateKey, todayTaskList, repeatTaskList);
      setState(() {
        _isSubmitted = true;
      });

      // 팝업으로 알림
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: const Text("제출 완료!"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("확인"),
            ),
          ],
        ),
      );
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("닫기"),
            ),
          ],
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    if (isEditMode) {
      return PlannerEditPage(
        onNext: widget.onNext,
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
          _autoSave(); // 편집 후 Firestore 바로 저장
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
                        onPressed: () async {
                          Navigator.of(context).pop();
                          final dateKey = _dateKey(selectedDate);
                          try {
                            await submitTasksToFirestore(userId, dateKey, todayTaskList, repeatTaskList);
                            setState(() => _isSubmitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("제출 완료!")),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(content: Text(e.toString())),
                            );
                          }
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
        onToggleCheck: (index) {
          if (!_isSubmitted) {
            toggleCheck(repeatTaskList, index);
          }
        },
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
        onToggleCheck: (index) {
          if (!_isSubmitted) {
            toggleCheck(todayTaskList, index);
          }
        },
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
              onToggleCheck: (index) {
                if (!_isSubmitted) {
                  toggleCheck(repeatTaskList, index);
                }
              },
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
              sortingMethod: widget.sortingMethod,
            ),
          ),
          Expanded(
            flex: 2,
            child: TodayTaskBox(
              taskList: todayTaskList,
              onToggleCheck: (index) {
                if (!_isSubmitted) {
                  toggleCheck(todayTaskList, index);
                }
              },
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
              sortingMethod: widget.sortingMethod,
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
                  widget.onNext(0);
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  widget.onNext(6);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
