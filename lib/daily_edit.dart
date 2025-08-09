import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DBtest/task.dart'; // Task 클래스 정의된 파일
import 'DBtest/firestore_service.dart';


//위젯
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
  final String userId = "HiHgtVpIvdyCZVtiFCOc";

// Firestore에서 해당 날짜 할 일 불러오기
  Future<void> _loadTasksForDate(DateTime date) async {
    final key = _dateKey(date);
    final tasks = await fetchDailyTasks(userId, key);  // 🔹 Firestore에서 불러오기
    setState(() {
      _dailyTaskMap[key] = tasks;
    });
  }

  Future<void> _updateTaskList(List<Task> updatedList) async {
    final key = _dateKey(_selectedDate);
    setState(() {
      _dailyTaskMap[key] = updatedList;
    });
    await saveDailyTasks(userId, key, updatedList); // Firestore 저장
    await updateTasksToFirestore(userId, key, _dailyTaskMap[key] ?? []); // planner컬렉션에 반영
    widget.onUpdateDailyTaskMap(_dailyTaskMap);
  }

  DateTime getKstNow() {
    return DateTime.now().toUtc().add(const Duration(hours: 9)); // 한국 시간 변환
  }



  // 날짜 키 문자열 (예: 2025-06-27)
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = getKstNow();
    _dailyTaskMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
    _loadTasksForDate(_selectedDate); // 앱 첫 로드시 Firestore 데이터 불러오기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 리스트 편집'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () async {
              final key = _dateKey(_selectedDate);
              final tasks = _dailyTaskMap[key] ?? [];

              // dailyTasks에 저장
              await saveDailyTasks(userId, key, tasks);
              // planner에도 저장
              await updateTasksToFirestore(userId, key, tasks);

              widget.onUpdateDailyTaskMap(_dailyTaskMap);
              Navigator.pop(context, _dailyTaskMap);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 📅 달력
            TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) async {
                setState(() {
                  _selectedDate = selectedDay;
                });
                await _loadTasksForDate(selectedDay); // 날짜 변경 시 Firestore 데이터 로드
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            const SizedBox(height: 16),


            const SizedBox(height: 16),


            // 일일 리스트 편집 박스
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TodayEditBox(
                taskList: _dailyTaskMap[_dateKey(_selectedDate)] ?? [],
                onTaskListUpdated: _updateTaskList,
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

