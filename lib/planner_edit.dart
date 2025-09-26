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
  final void Function(List<Task> updatedRepeatList, List<Task> updatedTodayList)
  onUpdateTasks;
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
    super.key,
  });

  @override
  _PlannerEditPageState createState() => _PlannerEditPageState();
}

class _PlannerEditPageState extends State<PlannerEditPage> {
  // ✅ 로그인한 사용자 uid로 런타임 초기화
  late final String userId;

  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  late List<Task> repeatTaskList;
  late List<Task> todayTaskList;
  late DateTime selectedDate;
  late Map<String, List<Task>> dailyTaskMap;

  bool showFullRepeat = false;
  bool showFullToday = false;

  Timer? _saveRepeatDebounce;
  Timer? _saveTodayDebounce;

  void _saveRepeatDebounced(List<Task> list) {
    _saveRepeatDebounce?.cancel();
    _saveRepeatDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await api.saveRepeatList(list); // 🔸 POST /repeatList/save/:uid
        
      } catch (e) {
        
      }
    });
  }

  void _saveTodayDebounced() {
    _saveTodayDebounce?.cancel();
    _saveTodayDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final key = _dateKey(selectedDate);
        await api.saveDaily(key, todayTaskList); // ⬅️ dailyTasks에 저장
        
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

    // ✅ 로그인한 사용자 uid 고정
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    userId = uid;

    // 부모 위젯에서 받은 상태 복사
    repeatTaskList = List.from(widget.repeatTaskList);
    todayTaskList = List.from(widget.todayTaskList);
    selectedDate = widget.selectedDate;
    dailyTaskMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
  }

  void updateTasks(int type, List<Task> newTasks) {
    setState(() {
      if (type == 0) {
        // 반복 리스트
        repeatTaskList = newTasks;
        _saveRepeatDebounced(repeatTaskList);
      } else if (type == 1) {
        // 일일(오늘) 리스트
        todayTaskList = newTasks;
        _saveTodayDebounced();
      }
    });
  }

  /// 🔹 (API만) planner + repeat 동시 저장
  Future<void> saveCurrentTasks() async {
    final key = _dateKey(selectedDate);
    try {
      await Future.wait([
        api.saveRepeatList(repeatTaskList),
        api.saveDaily(key, todayTaskList),
      ]);
    } catch (e) {
      debugPrint('[API] saveCurrentTasks (repeat+daily) error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 실패: $e')),
      );
    }
  }

  /// 저장 후 페이지 이동
  void saveAndNavigate(int target) async {
    final key = _dateKey(widget.selectedDate);
    final newMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    newMap[key] = todayTaskList;

    widget.onDailyMapChanged(newMap);
    widget.onUpdateTasks(repeatTaskList, todayTaskList);

    await saveCurrentTasks(); // 공통 저장(API)

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
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            // 🔹 현재 데이터 저장(API)
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.calendar_month),
                  onPressed: () => saveAndNavigate(1), // 플래너 메인으로
                ),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => saveAndNavigate(0), // 펫 메인(홈)으로
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
