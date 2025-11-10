import 'package:flutter/material.dart';
import 'DBtest/task.dart';
import 'daily_edit.dart';
import 'dart:async';
import 'package:taskmate/DBtest/api_service.dart' as api;

// 위젯
import 'package:taskmate/widgets/repeat_edit_box.dart';
import 'package:taskmate/widgets/today_edit_box.dart';

import 'package:firebase_auth/firebase_auth.dart';

class PlannerEditPage extends StatefulWidget {
  final VoidCallback onBackToMain;
  final void Function(int) onNext;
  final List<Task> repeatTaskList;
  final List<Task> todayTaskList;
  final void Function(List<Task> updatedRepeatList, List<Task> updatedTodayList) onUpdateTasks;
  final Map<String, List<Task>> dailyTaskMap;
  final DateTime selectedDate; // ← 편집 시작 앵커 날짜
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
    super.key,
  });

  @override
  _PlannerEditPageState createState() => _PlannerEditPageState();
}

class _PlannerEditPageState extends State<PlannerEditPage> {
  // ✅ 로그인한 사용자 uid
  late final String userId;

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  late List<Task> repeatTaskList;
  late List<Task> todayTaskList;
  late DateTime selectedDate; // 내부 상태로 유지하되, 앵커는 widget.selectedDate
  late Map<String, List<Task>> dailyTaskMap;

  bool showFullRepeat = false;
  bool showFullToday = false;

  Timer? _saveRepeatDebounce;
  Timer? _saveTodayDebounce;

  // ✅ commitAll() 호출용 키들 (타입 없이 사용)
  final GlobalKey _repeatEditKey = GlobalKey();
  final GlobalKey _todayEditKey = GlobalKey();

  void _saveRepeatDebounced(List<Task> list) {
    _saveRepeatDebounce?.cancel();
    _saveRepeatDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await api.saveRepeatList(list); // POST /repeatList/save/:uid
        
      } catch (e) {
        
      }
    });
  }

  void _saveTodayDebounced() {
    _saveTodayDebounce?.cancel();
    _saveTodayDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final key = _dateKey(selectedDate);
        await api.saveDaily(key, todayTaskList); // dailyTasks 저장
        
      } catch (e) {
        
      }
    });
  }

  @override
  void dispose() {
    _saveRepeatDebounce?.cancel();
    _saveTodayDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // ✅ 로그인 uid 확보
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    userId = uid;

    // 부모 상태 복사
    repeatTaskList = List<Task>.from(widget.repeatTaskList);
    todayTaskList = List<Task>.from(widget.todayTaskList);
    selectedDate = widget.selectedDate; // 내부 편집 기준일 (앵커는 widget.selectedDate)
    dailyTaskMap = Map<String, List<Task>>.from(widget.dailyTaskMap);

    // 현재 날짜 키 보장
    final key = _dateKey(selectedDate);
    dailyTaskMap[key] = dailyTaskMap[key] ?? List<Task>.from(todayTaskList);
  }

  /// 편집 박스에서 온 변경을 수신
  void updateTasks(int type, List<Task> newTasks) {
    setState(() {
      if (type == 0) {
        // 반복 리스트
        repeatTaskList = newTasks;
        _saveRepeatDebounced(repeatTaskList);
      } else if (type == 1) {
        // 일일(오늘) 리스트
        todayTaskList = newTasks;

        // ✅ 로컬 날짜맵에도 즉시 반영
        final key = _dateKey(selectedDate);
        dailyTaskMap[key] = List<Task>.from(todayTaskList);

        // 부모에게 맵 변경 알림 (실시간 동기화)
        widget.onDailyMapChanged(Map<String, List<Task>>.from(dailyTaskMap));

        _saveTodayDebounced();
      }
    });
  }

  /// planner + repeat 동시 저장 (API)
  Future<void> saveCurrentTasks() async {
    final key = _dateKey(selectedDate);
    try {
      await Future.wait([
        api.saveRepeatList(repeatTaskList),
        api.saveDaily(key, todayTaskList),
      ]);
    } catch (e) {
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  /// 모든 입력을 강제 커밋
  void _commitAllEditors() {
    FocusManager.instance.primaryFocus?.unfocus();
    (_repeatEditKey.currentState as dynamic?)?.commitAll();
    (_todayEditKey.currentState  as dynamic?)?.commitAll();
  }

  /// 부모에 커밋 + 저장 + 이동 처리
  Future<void> saveAndNavigate(int target) async {
    // ✅ 먼저 포커스/로컬 편집 내용 모두 커밋
    _commitAllEditors();

    final key = _dateKey(selectedDate);
    final newMap = Map<String, List<Task>>.from(dailyTaskMap);
    newMap[key] = List<Task>.from(todayTaskList);

    // 부모 콜백들
    widget.onDailyMapChanged(newMap);
    widget.onUpdateTasks(
      List<Task>.from(repeatTaskList),
      List<Task>.from(todayTaskList),
    );

    // 서버 저장
    await saveCurrentTasks();

    // 이동
    if (target == 0) {
      widget.onNext(0); // 홈
    } else if (target == 1) {
      widget.onBackToMain(); // 플래너 메인
    }
  }

  /// DailyTaskEditPage에서 돌아올 때 결과 흡수
  void _absorbCalendarResult(dynamic result) {
    if (result == null) return;

    // 🔒 앵커: 편집 화면에 들어올 때의 날짜를 기준으로 고정
    final anchorKey = _dateKey(widget.selectedDate);

    // A) DailyTaskEditPage가 map만 반환한 경우
    if (result is Map<String, List<Task>>) {
      setState(() {
        dailyTaskMap = result;
        // 돌아와서도 오늘(또는 편집 시작일) 박스만 보여주기
        todayTaskList = List<Task>.from(
          dailyTaskMap[anchorKey] ?? const <Task>[],
        );
        selectedDate = widget.selectedDate; // 내부 selectedDate도 앵커로 복귀
      });
      widget.onDailyMapChanged(Map<String, List<Task>>.from(dailyTaskMap));
      return;
    }

    // B) { map, selectedDate } 형태로 반환해도 날짜는 무시하고 map만 반영 (앵커 유지)
    if (result is Map) {
      final m = result['map'];
      if (m is Map) {
        final casted = <String, List<Task>>{};
        m.forEach((k, v) {
          if (v is List<Task>) {
            casted[k] = List<Task>.from(v);
          } else if (v is List) {
            try {
              casted[k] = v
                  .map((e) {
                if (e is Task) return e;
                if (e is Map<String, dynamic>) return Task.fromJson(e);
                return null;
              })
                  .whereType<Task>()
                  .toList();
            } catch (_) {}
          }
        });
        setState(() {
          dailyTaskMap = casted;
          todayTaskList = List<Task>.from(
            dailyTaskMap[anchorKey] ?? const <Task>[],
          );
          selectedDate = widget.selectedDate; // 내부 selectedDate도 앵커로 복귀
        });
        widget.onDailyMapChanged(Map<String, List<Task>>.from(dailyTaskMap));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () async {
              // ✅ 커밋 후 저장
              _commitAllEditors();
              await saveCurrentTasks();

              // 현재 상태를 보존한 맵으로 전달
              final key = _dateKey(selectedDate);
              final outbound = Map<String, List<Task>>.from(dailyTaskMap);
              outbound[key] = List<Task>.from(todayTaskList);

              if (!mounted) return;

              // DailyTaskEditPage로 이동
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DailyTaskEditPage(
                    dailyTaskMap: outbound,
                    selectedDate: selectedDate,
                    onUpdateDailyTaskMap: (updatedMap) {
                      // 실시간 신호만 받을 수 있으므로 여기서는 저장 X
                    },
                  ),
                ),
              );

              // 돌아오면 결과 흡수 (앵커 유지)
              _absorbCalendarResult(result);
            },
          ),
        ],
      ),
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
                key: _repeatEditKey, // ✅ 커밋용 키 연결
                taskList: repeatTaskList,
                onTaskListUpdated: (updated) => updateTasks(0, updated),
                onExpand: () {
                  setState(() {
                    showFullRepeat = true;
                  });
                },
              ),
              TodayEditBox(
                key: _todayEditKey, // ✅ 커밋용 키 연결
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 플래너 메인으로 (상위 위젯이 isEditMode=false로 전환)
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: () => saveAndNavigate(1),
              ),
              // 홈(펫 메인)으로
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => saveAndNavigate(0),
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
