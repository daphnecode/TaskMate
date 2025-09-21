import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'planner_edit.dart';
import 'statistics.dart';
import 'DBtest/firestore_service.dart'; // resetStreakIfNeededKST, submitTasksToFirestore 등 사용
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

  ///  체크 토글개별 API 호출(실패 시 롤백)
  Future<void> toggleCheck(List<Task> tasklist, int index) async {
    final old = tasklist[index];
    final newVal = !old.isChecked;

    // 1) UI 먼저 토글
    setState(() {
      tasklist[index] = old.copyWith(isChecked: newVal);
    });

    final dateKey = _dateKey(selectedDate);

    try {
      if (identical(tasklist, todayTaskList)) {
        // 오늘 리스트 체크
        await api.checkPlannerItem(dateKey, index.toString(), newVal);
      } else if (identical(tasklist, repeatTaskList)) {
        // 반복 리스트 체크 (api_service.dart에 checkRepeatItem 필요)
        await api.checkRepeatItem(index.toString(), newVal);
      }
    } catch (e) {
      // 실패 시 롤백
      if (!mounted) return;
      setState(() {
        tasklist[index] = old;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('체크 저장 실패: $e')),
      );
    }
  }

  /// 편집모드 토글 (로컬 UI 전용)
  void toggleEditingMode(List<Task> taskList) {
    final anyEditing = taskList.any((task) => task.isEditing);
    setState(() {
      for (int i = 0; i < taskList.length; i++) {
        taskList[i] = taskList[i].copyWith(isEditing: !anyEditing);
      }
    });
  }

  /// ✅ 포인트 수정: 낙관적 업데이트 + API 저장(실패 시 롤백)
  Future<void> updatePoint(List<Task> taskList, int index, int newPoint) async {
    final old = taskList[index];

    setState(() {
      taskList[index] = old.copyWith(point: newPoint, isEditing: false);
    });

    final dateKey = _dateKey(selectedDate);

    try {
      if (identical(taskList, todayTaskList)) {
        // 오늘 리스트 항목 포인트 변경 → 개별 PATCH
        await api.updatePlannerItem(dateKey, index.toString(), point: newPoint);
      } else if (identical(taskList, repeatTaskList)) {
        // 반복 리스트 포인트 변경 → 간단히 전체 저장 (필요시 update API로 분리 가능)
        await api.saveRepeatList(repeatTaskList);
      }
    } catch (e) {
      if (!mounted) return;
      // 실패 시 롤백
      setState(() {
        taskList[index] = old;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('포인트 저장 실패: $e')),
      );
    }
  }

  /// 편집화면에서 돌아올 때 두 리스트를 API로 동시 저장 (중복 저장 줄임)
  Future<void> _saveBothLists() async {
    final dateKey = _dateKey(selectedDate);
    try {
      await Future.wait([
        api.savePlanner(dateKey, todayTaskList),
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

    // (선택) dailyTasks → planner 1회 동기화 유지
    syncDailyToPlanner(userId!, dateKey).then((_) async {
      // 오늘 리스트 API로 로드
      try {
        final res = await api.readPlanner(dateKey);
        if (!mounted) return;
        setState(() {
          todayTaskList = (res['tasks'] as List<Task>);
          _isSubmitted = (res['submitted'] as bool?) ?? false;
        });
      } catch (e) {
        debugPrint('[API] planner read error: $e');
      }
    });

    // 방문 로그 기록 (직접 Firestore)
    firestore
        .collection('Users')
        .doc(userId!)
        .collection('log')
        .doc(dateKey)
        .set({'visited': true}, SetOptions(merge: true));

    // 반복 리스트 로드 (API)
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
      debugPrint('[API] repeat loaded: ${repeatTaskList.length}');
    }).catchError((e) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    // 실시간 KST 날짜(자정 지나면 dateKey도 바뀌게)
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
          // 편집 후에는 API로 한 번만 저장 (중복 저장 줄이기)
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
                            // 플래너 제출 (log/stat 갱신은 기존 트리거/함수 로직 사용)
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

                            final rewardFn = functions.httpsCallable('submitRewardAN3'); // 포인트 지급
                            final expFn = functions.httpsCallable('submitPetExpAN3'); // EXP/레벨업

                            if (earned > 0) {
                              // UI 즉시 반영
                              widget.onPointsAdded?.call(earned);

                              try {
                                await rewardFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey,
                                });

                                final resp = await expFn.call({
                                  'uid': uid,
                                  'earned': earned,
                                  'dateKey': dateKey,
                                });
                                
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
