import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

// 일일 리스트 편집
class TodayEditBox extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final DateTime? selectedDate;
  final VoidCallback onExpand;

  const TodayEditBox({
    super.key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onExpand,
    this.selectedDate,
  });

  @override
  State<TodayEditBox> createState() => _TodayEditBoxState();
}

class _TodayEditBoxState extends State<TodayEditBox> {
  late List<Task> _localTaskList;

  @override
  void initState() {
    super.initState();
    _localTaskList = List.from(widget.taskList); // 복사본 사용
  }

  void _addTask() {
    setState(() {
      _localTaskList.add(Task(text: '할 일을 추가해보세요', isChecked: false, point: 0));
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _removeTask(int index) {
    setState(() {
      _localTaskList.removeAt(index);
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _updateTaskText(int index, String newText) {
    setState(() {
      _localTaskList[index] = _localTaskList[index].copyWith(text: newText);
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  @override
  void didUpdateWidget(covariant TodayEditBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskList != widget.taskList) {
      _localTaskList = List.from(widget.taskList); // 새로운 리스트로 갱신
    }
  }



  @override
  Widget build(BuildContext context) {
    String formattedDate = widget.selectedDate != null
        ? "${widget.selectedDate!.year} / ${widget.selectedDate!.month.toString().padLeft(2, '0')} / ${widget.selectedDate!.day.toString().padLeft(2, '0')}"
        : "2025/00/00";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(border: Border.all(color: Colors.black)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: widget.onExpand,
                child: Text(
                  formattedDate,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Checklist items', style: TextStyle(fontSize: 16)),
              OutlinedButton(
                onPressed: _addTask,
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.all(8),
                ),
                child: const Icon(Icons.add, color: Colors.blue),
              )
            ],
          ),
          const SizedBox(height: 5),
          SizedBox(
            height: 140,
            child: ListView.builder(
              itemCount: _localTaskList.length,
              itemBuilder: (context, index) {
                final task = _localTaskList[index];

                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: task.text),
                        onChanged: (newText) => _updateTaskText(index, newText),
                        decoration: const InputDecoration(border: InputBorder.none),
                        autofocus: index == _localTaskList.length - 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeTask(index),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 일일 리스트 편집 확장
class TodayEditFullScreen extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final VoidCallback onCollapse;
  final DateTime? selectedDate;

  const TodayEditFullScreen({
    super.key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onCollapse,
    this.selectedDate,
  });

  @override
  State<TodayEditFullScreen> createState() => _TodayEditFullScreenState();
}

class _TodayEditFullScreenState extends State<TodayEditFullScreen> {
  late List<Task> _localTaskList;

  @override
  void initState() {
    super.initState();
    _localTaskList = List.from(widget.taskList);
  }

  void _addTask() {
    setState(() {
      _localTaskList.add(Task(text: '할 일을 추가해보세요', isChecked: false, point: 0));
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _removeTask(int index) {
    setState(() {
      _localTaskList.removeAt(index);
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _updateTaskText(int index, String newText) {
    setState(() {
      _localTaskList[index] = _localTaskList[index].copyWith(text: newText);
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  @override
  Widget build(BuildContext context) {
    String formattedDate = widget.selectedDate != null
        ? "${widget.selectedDate!.year} / ${widget.selectedDate!.month.toString().padLeft(2, '0')} / ${widget.selectedDate!.day.toString().padLeft(2, '0')}"
        : "2025/00/00";

    return Column(
      children: [
        TextButton(
          onPressed: widget.onCollapse,
          child: Row(
            children: [
              Text(
                formattedDate,
                style:  TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.expand_less),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Checklist items', style: TextStyle(fontSize: 16)),
              OutlinedButton(
                onPressed: _addTask,
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: const BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.all(8),
                ),
                child: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              itemCount: _localTaskList.length,
              itemBuilder: (context, index) {
                final task = _localTaskList[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: task.text),
                        onChanged: (newText) => _updateTaskText(index, newText),
                        decoration: const InputDecoration(border: InputBorder.none),
                        autofocus: index == _localTaskList.length - 1,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeTask(index),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
