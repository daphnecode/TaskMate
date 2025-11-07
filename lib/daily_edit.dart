import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DBtest/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmate/DBtest/api_service.dart' as api;
import 'package:taskmate/widgets/today_edit_box.dart';

class DailyTaskEditPage extends StatefulWidget {
  final Map<String, List<Task>> dailyTaskMap;
  final DateTime selectedDate; // ← PlannerEditPage가 넘긴 앵커 기준의 시작 날짜
  final void Function(Map<String, List<Task>>) onUpdateDailyTaskMap;

  const DailyTaskEditPage({
    required this.dailyTaskMap,
    required this.selectedDate,
    required this.onUpdateDailyTaskMap,
    super.key,
  });

  @override
  State<DailyTaskEditPage> createState() => _DailyTaskEditPageState();
}

class _DailyTaskEditPageState extends State<DailyTaskEditPage> {
  DateTime _selectedDate = DateTime.now();
  Map<String, List<Task>> _dailyTaskMap = {};
  late final String userId;

  Timer? _saveDailyDebounce;

  // ✅ TodayEditBox commitAll() 호출용 키 (타입 없이)
  final GlobalKey _todayEditKey = GlobalKey();

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _loadTasksForDate(DateTime date) async {
    final key = _dateKey(date);
    try {
      final list = await api.fetchDaily(key); // ✅ 서버에서 읽기
      if (!mounted) return;
      setState(() {
        _dailyTaskMap[key] = list;
      });
      widget.onUpdateDailyTaskMap(_dailyTaskMap);
    } catch (e) {
      
      
      if (!mounted) return;
      setState(() {
        _dailyTaskMap[key] = _dailyTaskMap[key] ?? [];
      });
      widget.onUpdateDailyTaskMap(_dailyTaskMap);
    }
  }

  void _saveDailyDebounced(String key, List<Task> list) {
    _saveDailyDebounce?.cancel();
    _saveDailyDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await api.saveDaily(key, list); // ✅ dailyTasks 저장
      } catch (e) {
        
        
      }
    });
  }

  Future<void> _updateTaskList(List<Task> updatedList) async {
    final key = _dateKey(_selectedDate);
    setState(() {
      _dailyTaskMap[key] = updatedList;
    });
    widget.onUpdateDailyTaskMap(_dailyTaskMap);
    _saveDailyDebounced(key, updatedList); // ✅ 디바운스로 서버 저장
  }

  Map<String, dynamic> _buildResultPayload() {
    return {
      'map': _dailyTaskMap,
      'selectedDate': _dateKey(_selectedDate), // 참고용으로만 보내고, 상위는 앵커 유지
    };
  }

  Future<void> _saveCurrentDateNow() async {
    final key = _dateKey(_selectedDate);
    try {
      await api.saveDaily(key, _dailyTaskMap[key] ?? const <Task>[]);
    } catch (e) {
      
      
    }
  }

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }
    userId = uid;

    _selectedDate = widget.selectedDate;
    _dailyTaskMap = Map<String, List<Task>>.from(widget.dailyTaskMap);

    // ✅ 로컬에 키가 없으면 빈 배열 먼저 넣어두기 (깜빡임/널 방지)
    final k = _dateKey(_selectedDate);
    _dailyTaskMap[k] = _dailyTaskMap[k] ?? [];

    // 첫 로드: 서버에서 해당 날짜 불러오기
    _loadTasksForDate(_selectedDate);
  }

  @override
  void dispose() {
    _saveDailyDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = _dateKey(_selectedDate);
    final list = _dailyTaskMap[key] ?? [];

    return WillPopScope(
      onWillPop: () async {
        // 뒤로가기 시 현재 입력 커밋 + 저장 후 payload 반환
        (_todayEditKey.currentState as dynamic)?.commitAll();
        await _saveCurrentDateNow();
        Navigator.pop(context, _buildResultPayload());
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('일일 리스트 편집'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                (_todayEditKey.currentState as dynamic)?.commitAll(); // ✅ 커밋
                try {
                  await api.saveDaily(
                    key,
                    _dailyTaskMap[key] ?? const <Task>[],
                  );
                } catch (e) {
                  
                  
                }
                if (!mounted) return;
                widget.onUpdateDailyTaskMap(_dailyTaskMap);
                Navigator.pop(context, _buildResultPayload());
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2030, 12, 31),
                focusedDay: _selectedDate,
                selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  // 날짜 변경 전에 현재 날짜 커밋 + 즉시 저장
                  (_todayEditKey.currentState as dynamic)?.commitAll();
                  await _saveCurrentDateNow();

                  setState(() {
                    _selectedDate = selectedDay;
                    final k = _dateKey(selectedDay);
                    _dailyTaskMap[k] = _dailyTaskMap[k] ?? []; // 로컬 임시 보강
                  });
                  await _loadTasksForDate(selectedDay);
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TodayEditBox(
                  key: _todayEditKey, // ✅ 커밋용 키 연결
                  taskList: list,
                  onTaskListUpdated: _updateTaskList, // 변경 → 서버 저장(디바운스)
                  selectedDate: _selectedDate,
                  onExpand: () {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
