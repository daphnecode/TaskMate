import 'dart:async';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DBtest/task.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskmate/DBtest/api_service.dart' as api;
import 'package:taskmate/widgets/today_edit_box.dart';

class DailyTaskEditPage extends StatefulWidget {
  final Map<String, List<Task>> dailyTaskMap;
  final DateTime selectedDate;
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

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  DateTime getKstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));

  Future<void> _loadTasksForDate(DateTime date) async {
    final key = _dateKey(date);
    try {
      final list = await api.fetchDaily(key); // ✅ 서버에서 읽기
      if (!mounted) return;
      setState(() {
        _dailyTaskMap[key] = list;
      });
    } catch (e) {
      
      
      if (!mounted) return;
      setState(() {
        _dailyTaskMap[key] = _dailyTaskMap[key] ?? [];
      });
    }
  }

  void _saveDailyDebounced(String key, List<Task> list) {
    _saveDailyDebounce?.cancel();
    _saveDailyDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await api.saveDaily(key, list);     // ✅ dailyTasks 저장
        await api.savePlanner(key, list);   // ✅ planner에도 동기화(원하지 않으면 제거)
      } catch (e) {
        
        
      }
    });
  }

  Future<void> _updateTaskList(List<Task> updatedList) async {
    final key = _dateKey(_selectedDate);
    setState(() {
      _dailyTaskMap[key] = updatedList;
    });
    _saveDailyDebounced(key, updatedList); // ✅ 디바운스로 서버 저장
    widget.onUpdateDailyTaskMap(_dailyTaskMap);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 리스트 편집'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              try {
                await api.saveDaily(key, list);
                await api.savePlanner(key, list); // 동기화 원치 않으면 제거 가능
              } catch (e) {
                
                
              }
              if (!mounted) return;
              widget.onUpdateDailyTaskMap(_dailyTaskMap);
              Navigator.pop(context, _dailyTaskMap);
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
                setState(() {
                  _selectedDate = selectedDay;
                });
                await _loadTasksForDate(selectedDay);
              },
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TodayEditBox(
                taskList: list,
                onTaskListUpdated: _updateTaskList, // ✅ 변경 → 서버 저장
                selectedDate: _selectedDate,
                onExpand: () {},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
