import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'DBtest/task.dart'; // Task 클래스 정의된 파일 import

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




  // 날짜 키 문자열 (예: 2025-06-27)
  String _dateKey(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  // 수정된 리스트를 저장
  void _updateTaskList(List<Task> updatedList) {
    final key = _dateKey(_selectedDate);
    setState(() {
      _dailyTaskMap[key] = updatedList;
    });
    widget.onUpdateDailyTaskMap(_dailyTaskMap); // 변경 즉시 상위에도 반영
  }


  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
    _dailyTaskMap = Map<String, List<Task>>.from(widget.dailyTaskMap);
  }

  @override
  Widget build(BuildContext context) {
    List<Task> taskList = _dailyTaskMap[_dateKey(_selectedDate)] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('일일 리스트 편집'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () {
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

