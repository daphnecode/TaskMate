import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'planner_edit.dart';
import 'statistics.dart';
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

  // NOTE: 서버와 동일 포맷을 사용하세요. (현재 YYYY-MM-DD)
  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  DateTime getKstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));

  int _calcEarnedPointsForToday() {
    int sum = 0;
    for (final t in todayTaskList) {
      if (t.isChecked) sum += (t.point).toInt();
    }
    for (final t in repeatTaskList) {
      if (t.isChecked) sum += (t.point).toInt();
    }
    return sum;
  }

  Future<void> toggleCheck(List<Task> tasklist, int index) async {
    if (_isSubmitted) return; // 제출 후 잠금

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('체크 저장 실패: $e')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('포인트 저장 실패: $e')));
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
      
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_submitting) return;

    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    if (_isSubmitted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Text('정말 제출하겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('예'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('아니요'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final dateKey = _dateKey(selectedDate);
    setState(() => _submitting = true);

    try {
      // ✅ 서버 기준 중복 제출 검사
      final latest = await api.readDailyWithMeta(dateKey);
      if (latest.submitted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
        setState(() => _isSubmitted = true);
        return;
      }

      // 1) 오늘/반복 리스트 저장
      await Future.wait([
        api.saveDaily(dateKey, todayTaskList),
        api.saveRepeatList(repeatTaskList),
      ]);

      // 2) 포인트 계산
      final earned = _calcEarnedPointsForToday();

      // 3) EXP → 포인트 순서 (데이터 불일치 방지)
      if (earned > 0) {
        final functions = FirebaseFunctions.instanceFor(
          region: kFunctionsRegion,
        );
        final expFn = functions.httpsCallable('submitPetExpAN3');
        final rewardFn = functions.httpsCallable('submitRewardAN3');

        // EXP 먼저
        final expResp = await expFn.call({
          'uid': uid,
          'earned': earned,
          'dateKey': dateKey,
        });

        // 🔎 서버 steps 로깅(콘솔)
        try {
          final steps = (expResp.data as Map?)?['steps'];
          
          
        } catch (_) {}

        // 포인트 다음
        await rewardFn.call({'uid': uid, 'earned': earned, 'dateKey': dateKey});

        // UI 포인트 반영 (성공 후)
        widget.onPointsAdded?.call(earned);
      }

      // 4) 제출 플래그
      await api.markDailySubmitted(dateKey);

      if (!mounted) return;
      setState(() => _isSubmitted = true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("제출 완료!")));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains("이미 제출했습니다")) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
        setState(() => _isSubmitted = true);
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(content: Text(msg)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
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

    // 오늘 리스트 + 제출 여부
    api
        .readDailyWithMeta(dateKey)
        .then((res) {
          if (!mounted) return;
          setState(() {
            todayTaskList = res.tasks;
            _isSubmitted = res.submitted;
          });
        })
        .catchError((e) {
          
        });

    // 방문 로그
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId!)
        .collection('log')
        .doc(dateKey)
        .set({'visited': true}, SetOptions(merge: true));

    // 반복 리스트 로드
    api
        .fetchRepeatListEnsured()
        .then((rows) {
          if (!mounted) return;
          setState(() {
            repeatTaskList = rows
                .map(
                  (e) => Task(
                    text: e['text'] ?? '',
                    point: (e['point'] ?? 0) is int
                        ? (e['point'] ?? 0) as int
                        : (e['point'] ?? 0).toInt(),
                    isChecked: e['isChecked'] ?? false,
                  ),
                )
                .toList();
          });
        })
        .catchError((e) {
          
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
                MaterialPageRoute(builder: (context) => const StatisticsPage()),
              );
            },
            icon: const Icon(Icons.pie_chart),
          ),
        ),
        title: const DateBadge(),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => _handleSubmit(context),
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
                  repeatTaskList[index] = repeatTaskList[index].copyWith(
                    isEditing: true,
                  );
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
                  todayTaskList[index] = todayTaskList[index].copyWith(
                    isEditing: true,
                  );
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
                        repeatTaskList[index] = repeatTaskList[index].copyWith(
                          isEditing: true,
                        );
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
                        todayTaskList[index] = todayTaskList[index].copyWith(
                          isEditing: true,
                        );
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
