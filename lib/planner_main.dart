import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'planner_edit.dart';
import 'statistics.dart';
import 'DBtest/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmate/DBtest/api_service.dart' as api;

import 'package:taskmate/widgets/date_badge.dart';
import 'package:taskmate/widgets/repeat_task_box.dart';
import 'package:taskmate/widgets/today_task_box.dart';

const String kFunctionsRegion = 'asia-northeast3';

class PlannerMain extends StatefulWidget {
  final void Function(int) onNext;
  final String sortingMethod;
  final void Function(int delta)? onPointsAdded;

  const PlannerMain({
    required this.onNext,
    required this.sortingMethod,
    this.onPointsAdded,
    super.key,
  });

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
  bool _submitting = false;

  List<Task> repeatTaskList = [];
  List<Task> todayTaskList = [];

  String? userId;

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DateTime getKstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));

  int _calcEarnedPointsForToday() {
    int sum = 0;
    for (final t in todayTaskList) {
      if (t.isChecked) sum += (t.point ?? 0).toInt();
    }
    for (final t in repeatTaskList) {
      if (t.isChecked) sum += (t.point ?? 0).toInt();
    }
    return sum;
  }

  Future<void> toggleCheck(List<Task> tasklist, int index) async {
    if (_isSubmitted) return; // 안전가드

    final old = tasklist[index];
    final newVal = !old.isChecked;

    setState(() {
      tasklist[index] = old.copyWith(isChecked: newVal);
    });

    final dateKey = _dateKey(selectedDate);

    try {
      if (identical(tasklist, todayTaskList)) {
        await api.checkDailyItem(dateKey, index.toString(), newVal);
      } else if (identical(tasklist, repeatTaskList)) {
        await api.checkRepeatItem(index.toString(), newVal);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        tasklist[index] = old;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('체크 저장 실패: $e')),
      );
    }
  }

  void toggleEditingMode(List<Task> taskList) {
    final anyEditing = taskList.any((task) => task.isEditing);
    setState(() {
      for (int i = 0; i < taskList.length; i++) {
        taskList[i] = taskList[i].copyWith(isEditing: !anyEditing);
      }
    });
  }

  Future<void> updatePoint(List<Task> taskList, int index, int newPoint) async {
    if (_isSubmitted && identical(taskList, todayTaskList)) return; // 제출 후 잠금

    final old = taskList[index];

    setState(() {
      taskList[index] = old.copyWith(point: newPoint, isEditing: false);
    });

    final dateKey = _dateKey(selectedDate);

    try {
      if (identical(taskList, todayTaskList)) {
        await api.updateDailyItem(dateKey, index.toString(), point: newPoint);
      } else if (identical(taskList, repeatTaskList)) {
        await api.saveRepeatList(repeatTaskList);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        taskList[index] = old;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포인트 저장 실패: $e')),
      );
    }
  }

  Future<void> _saveBothLists() async {
    final dateKey = _dateKey(selectedDate);
    try {
      await Future.wait([
        api.saveDaily(dateKey, todayTaskList),
        api.saveRepeatList(repeatTaskList),
      ]);
    } catch (e) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid;

    selectedDate = getKstNow();
    final dateKey = _dateKey(selectedDate);

    if (userId == null) {
      return;
    }

    Future.microtask(() async {
      try {
        await resetStreakIfNeededKST(userId!);
      } catch (e) {
        debugPrint('resetStreakIfNeededKST error: $e');
      }
    });

    // ✅ 오늘 리스트를 submitted 포함해서 로드
    api.readDailyWithMeta(dateKey).then((res) {
      if (!mounted) return;
      setState(() {
        todayTaskList = res.tasks;
        _isSubmitted = res.submitted; // 서버 제출 상태 반영
      });
    }).catchError((e) {
      
    });

    // 방문 로그
    firestore
        .collection('Users')
        .doc(userId!)
        .collection('log')
        .doc(dateKey)
        .set({'visited': true}, SetOptions(merge: true));

    // 반복 리스트 로드
    api.fetchRepeatList().then((rows) {
      if (!mounted) return;
      setState(() {
        repeatTaskList = rows
            .map((e) => Task(
          text: e['text'] ?? '',
          point: (e['point'] ?? 0) is int
              ? (e['point'] ?? 0) as int
              : (e['point'] ?? 0).toInt(),
          isChecked: e['isChecked'] ?? false,
        ))
            .toList();
      });
    }).catchError((e) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    selectedDate = getKstNow();

    if (isEditMode) {
      return PlannerEditPage(
        onNext: widget.onNext,
        repeatTaskList: repeatTaskList,
        todayTaskList: todayTaskList,
        onUpdateTasks: (updateRepeatLists, updateTodayList) async {
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
          await _saveBothLists();
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        leading: Builder(
          builder: (context) => IconButton(
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
              if (_submitting) return;

              final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('로그인이 필요합니다.')),
                );
                return;
              }

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
                          setState(() => _submitting = true);

                          try {
                            await submitTasksToFirestore(
                              uid,
                              dateKey,
                              todayTaskList,
                              repeatTaskList,
                            );

                            final earned = _calcEarnedPointsForToday();
                            final functions = FirebaseFunctions.instanceFor(
                              region: kFunctionsRegion,
                            );
                            final rewardFn =
                            functions.httpsCallable('submitRewardAN3');
                            final expFn =
                            functions.httpsCallable('submitPetExpAN3');

                            if (earned > 0) {
                              widget.onPointsAdded?.call(earned);
                              try {
                                await rewardFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey,
                                });
                                await expFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey,
                                });
                              } catch (e) {
                                widget.onPointsAdded?.call(-earned);
                                rethrow;
                              }
                            }

                            // ✅ daily meta에 제출 기록
                            await api.markDailySubmitted(dateKey);

                            if (!mounted) return;
                            setState(() => _isSubmitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("제출 완료!")),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (_) =>
                                  AlertDialog(content: Text(e.toString())),
                            );
                          } finally {
                            if (mounted) setState(() => _submitting = false);
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
            child: const Text('제출'),
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
              onEditPoints: () => toggleEditingMode(repeatTaskList),
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
              onEditPoints: () => toggleEditingMode(todayTaskList),
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
        color: Theme.of(context).cardColor,
        elevation: 0,
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
