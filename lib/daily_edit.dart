import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'task.dart'; // Task 클래스 정의된 파일 import
import 'planner_edit.dart'; // TodayEditBox 위젯 정의

class DailyTaskEditPage extends StatefulWidget {
  const DailyTaskEditPage({Key? key}) : super(key: key);

  @override
  State<DailyTaskEditPage> createState() => _DailyTaskEditPageState();
}

class _DailyTaskEditPageState extends State<DailyTaskEditPage> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<Task>> _dailyTaskMap = {};

  // 날짜 키 문자열 (예: 2025-06-27)
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 할 일 업데이트
  void _updateTaskList(List<Task> tasks) {
    setState(() {
      _dailyTaskMap[_dateKey(_selectedDate)] = tasks;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Task> taskList = _dailyTaskMap[_dateKey(_selectedDate)] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 리스트 편집'),
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
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
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
                taskList: taskList,
                onTaskListUpdated: _updateTaskList,
                selectedDate: _selectedDate,
                onExpand: () {}, // ✅ 이거 추가! 확장 기능 필요 없으면 빈 함수로
              ),
            ),

          ],
        ),
      ),
    );
  }
}

