import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'planner_edit.dart';
import 'statistics.dart';
import 'DBtest/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmate/DBtest/api_service.dart' as api;


// 위젯
import 'package:taskmate/widgets/date_badge.dart';
import 'package:taskmate/widgets/repeat_task_box.dart';
import 'package:taskmate/widgets/today_task_box.dart';

/// 🔧 Functions 리전 (배포한 리전에 맞게 수정)
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

  // 로그인 전에도 안전하도록 nullable 처리
  String? userId;

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  void toggleCheck(List<Task> tasklist, int index) {
    setState(() {
      tasklist[index] = tasklist[index].copyWith(
        isChecked: !tasklist[index].isChecked,
      );
    });
    _autoSave();
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
    _autoSave();
  }

  void _autoSave() {
    if (userId == null) return;
    final dateKey = _dateKey(selectedDate);
    updateTasksToFirestore(userId!, dateKey, todayTaskList);

    // (반복 리스트)  API로 저장
    api.saveRepeatList(repeatTaskList).catchError((e) {
      debugPrint('repeatList save error: $e');
    });
  }

  DateTime getKstNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 9));
  }

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

  @override
  void initState() {
    super.initState();

    userId = FirebaseAuth.instance.currentUser?.uid;

    selectedDate = getKstNow();
    final dateKey = _dateKey(selectedDate);

    if (userId == null) {
      // 비로그인 상태면 데이터 로딩만 건너뜀
      return;
    }

    // 🔹 streak 보정 (KST 자정 이후 전날 제출 없으면 streak=0)
    Future.microtask(() async {
      try {
        await resetStreakIfNeededKST(userId!);
      } catch (e) {
        debugPrint('resetStreakIfNeededKST error: $e');
      }
    });

    // dailyTasks → planner 동기화 후 오늘 리스트 로드
    syncDailyToPlanner(userId!, dateKey).then((_) {
      fetchTasks(userId!, dateKey).then((data) {
        if (!mounted) return;
        setState(() {
          todayTaskList = data['todayTasks'];
          _isSubmitted = data['submitted'];
        });
      });
    });

    // 방문 로그 기록
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
        repeatTaskList = rows.map((e) =>
            Task(
              text: e['text'] ?? '',
              point: (e['point'] ?? 0) is int
                  ? (e['point'] ?? 0) as int
                  : (e['point'] ?? 0).toInt(),
              isChecked: e['isChecked'] ?? false,
            )).toList();
      });
      debugPrint('[API] repeat loaded: ${repeatTaskList.length}');
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
          _autoSave();
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

              // 로그인 확인
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
                            // 플래너 저장
                            await submitTasksToFirestore(
                              uid,
                              dateKey,
                              todayTaskList,
                              repeatTaskList,
                            );

                            // 이번에 얻을 포인트 합계
                            final earned = _calcEarnedPointsForToday();

                            // ✅ Functions 리전 명시
                            final functions = FirebaseFunctions.instanceFor(
                              region: kFunctionsRegion,
                            );

                            final rewardFn = functions.httpsCallable('submitRewardAN3'); // 포인트 지급 함수
                            final expFn    = functions.httpsCallable('submitPetExpAN3');// EXP/레벨업 함수

                            if (earned > 0) {
                              // UI 즉시 반영
                              widget.onPointsAdded?.call(earned);

                              try {
                                // 1) 포인트 지급 (기존 그대로)
                                await rewardFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey,
                                });

                                // 2) 펫 EXP/레벨업 (신규 추가)
                                final resp = await expFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey, // logV2 idempotency용
                                });
                                // 웹(Chrome) 테스트면 F12 Console에서 확인 가능
                                
                                print('submitPetExpAN3 resp.data = ${resp.data}');
                              } catch (e) {
                                // 실패 시 UI 롤백
                                widget.onPointsAdded?.call(-earned);
                                rethrow;
                              }
                            }

                            if (!mounted) return;
                            setState(() => _isSubmitted = true);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("제출 완료!")),
                            );
                          } catch (e) {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(content: Text(e.toString())),
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
                  repeatTaskList[index] =
                      repeatTaskList[index].copyWith(isEditing: true);
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
                  todayTaskList[index] =
                      todayTaskList[index].copyWith(isEditing: true);
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
