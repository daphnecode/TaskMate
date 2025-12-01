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

// ✅ 포인트 합계 상한
const int kRepeatPointCap = 150;
const int kTodayPointCap = 50;

// ✅ 합계 유틸
int _sumPoints(List<Task> list) => list.fold(0, (a, t) => a + (t.point));

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

  // NOTE: 서버와 동일 포맷을 사용 (YYYY-MM-DD)
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

  // ✅ 상한 초과 안내 헬퍼
  void _showCapExceededSnackBar({required bool isRepeat, required int remain}) {
    final cap = isRepeat ? kRepeatPointCap : kTodayPointCap;
    final title =
    isRepeat ? '반복 리스트 포인트 합은 최대 $cap 입니다.' : '일일 리스트 포인트 합은 최대 $cap 입니다.';
    final tail = ' (설정 가능한 최대치: ${remain.clamp(0, cap)})';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title$tail')),
    );
  }

  // ✅ 편집(여러 항목 변경) 결과에 대한 일괄 검증
  bool _validateCapsForLists(List<Task> nextRepeat, List<Task> nextToday) {
    final rSum = _sumPoints(nextRepeat);
    final tSum = _sumPoints(nextToday);
    if (rSum > kRepeatPointCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반복 리스트 포인트 합이 150을 초과했습니다. 값을 조정해 주세요.')),
      );
      return false;
    }
    if (tSum > kTodayPointCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일일 리스트 포인트 합이 50을 초과했습니다. 값을 조정해 주세요.')),
      );
      return false;
    }
    return true;
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('체크 저장 실패: $e')));
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

  // ✅ 포인트 수정 시 상한 체크
  Future<void> updatePoint(List<Task> taskList, int index, int newPoint) async {
    if (_isSubmitted && identical(taskList, todayTaskList)) return; // 제출 후 잠금

    if (newPoint < 0) newPoint = 0; // 음수 방지

    final old = taskList[index];

    // ▶️ 상한 계산
    final currentSum = _sumPoints(taskList);
    final proposedSum = currentSum - old.point + newPoint;
    final isRepeat = identical(taskList, repeatTaskList);
    final cap = isRepeat ? kRepeatPointCap : kTodayPointCap;

    if (proposedSum > cap) {
      final remain = cap - (currentSum - old.point); // 이번 항목에 넣을 수 있는 최대치
      _showCapExceededSnackBar(isRepeat: isRepeat, remain: remain);
      return; // ⛔️ 초과 → 수정 중단
    }

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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('포인트 저장 실패: $e')));
    }
  }

  // ✅ 일괄 저장 시도 전에도 가드
  Future<void> _saveBothLists() async {
    // ▶️ 상한 확인
    final repeatSum = _sumPoints(repeatTaskList);
    final todaySum = _sumPoints(todayTaskList);

    if (repeatSum > kRepeatPointCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('반복 리스트 포인트 합이 150을 초과했습니다. 값을 조정해 주세요.')),
      );
      return;
    }
    if (todaySum > kTodayPointCap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('일일 리스트 포인트 합이 50을 초과했습니다. 값을 조정해 주세요.')),
      );
      return;
    }

    final dateKey = _dateKey(selectedDate);
    try {
      await Future.wait([
        api.saveDaily(dateKey, todayTaskList),
        api.saveRepeatList(repeatTaskList),
      ]);
    } catch (e) {
      
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('저장 실패: $e')));
    }
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_submitting) return;

    final uid = userId ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('로그인이 필요합니다.')));
      return;
    }

    if (_isSubmitted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
      return;
    }

    // ✅ 제출 전 상한 재확인(사용자 경험 보호)
    if (!_validateCapsForLists(repeatTaskList, todayTaskList)) {
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
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
        final functions = FirebaseFunctions.instanceFor(region: kFunctionsRegion);
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
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("제출 완료!")));
    } catch (e) {
      final msg = e.toString();
      if (msg.contains("이미 제출했습니다")) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("이미 제출하였습니다.")));
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
    api.readDailyWithMeta(dateKey).then((res) {
      if (!mounted) return;
      setState(() {
        todayTaskList = res.tasks;
        _isSubmitted = res.submitted;
      });
    }).catchError((e) {
      
    });

    // 방문 로그
    FirebaseFirestore.instance
        .collection('Users')
        .doc(userId!)
        .collection('log')
        .doc(dateKey)
        .set({'visited': true}, SetOptions(merge: true));

    // 반복 리스트 로드
    api.fetchRepeatListEnsured().then((rows) {
      if (!mounted) return;
      setState(() {
        repeatTaskList = rows
            .map((e) => Task(
          id: (e['id'] as String?) ?? generateTaskId(), // ✅ 보정
          text: e['text'] ?? '',
          point: (e['point'] ?? 0) is int
              ? (e['point'] ?? 0) as int
              : (e['point'] ?? 0).toInt(),
          isChecked: e['isChecked'] ?? false,
        ))
            .toList(); // ✅ List<Task>
      });
    }).catchError((e) {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    // NOTE: 메인 화면에서는 오늘 날짜 기준으로만 사용
    selectedDate = getKstNow();

    if (isEditMode) {
      return PlannerEditPage(
        onNext: widget.onNext,
        repeatTaskList: repeatTaskList,
        todayTaskList: todayTaskList,
        // ✅ 편집 결과 반영 시 상한 검증 추가
        onUpdateTasks: (updateRepeatLists, updateTodayList) async {
          // 상한 체크
          if (!_validateCapsForLists(updateRepeatLists, updateTodayList)) {
            // 편집 모드 유지, 저장 취소
            return;
          }

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

      // ✅ 작은 화면에서도 잘리지 않도록 SafeArea + LayoutBuilder 로 반응형 처리
      body: SafeArea(
        child: showFullRepeat
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
            : LayoutBuilder(
          builder: (context, constraints) {
            // 🔎 세로 높이가 작은 기기(모바일/노트북)에서는 스크롤 구조로 전환
            final isSmallHeight = constraints.maxHeight < 650;

            if (isSmallHeight) {
              // ✅ 작은 화면: 위/아래 박스를 자연스럽게 세로 스크롤
              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
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
                            updatePoint(
                                repeatTaskList, index, newPoint),
                        onStartEditing: (index) {
                          setState(() {
                            repeatTaskList[index] =
                                repeatTaskList[index]
                                    .copyWith(isEditing: true);
                          });
                        },
                        sortingMethod: widget.sortingMethod,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 8.0),
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
                            updatePoint(
                                todayTaskList, index, newPoint),
                        onStartEditing: (index) {
                          setState(() {
                            todayTaskList[index] =
                                todayTaskList[index]
                                    .copyWith(isEditing: true);
                          });
                        },
                        sortingMethod: widget.sortingMethod,
                      ),
                    ),
                  ],
                ),
              );
            }

            // ✅ 충분히 큰 화면: 기존처럼 위/아래를 1:1로 분할
            return Column(
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
                        repeatTaskList[index] =
                            repeatTaskList[index]
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
                        todayTaskList[index] =
                            todayTaskList[index]
                                .copyWith(isEditing: true);
                      });
                    },
                    sortingMethod: widget.sortingMethod,
                  ),
                ),
              ],
            );
          },
        ),
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
