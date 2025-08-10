import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

//반복 리스트 편집
class RepeatEditBox extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final VoidCallback onExpand;

  const RepeatEditBox({
    super.key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onExpand,
  });

  @override
  State<RepeatEditBox> createState() => _RepeatEditBoxState();
}

class _RepeatEditBoxState extends State<RepeatEditBox> {
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
  Widget build(BuildContext context) {
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
                child: Row(
                  children:  [
                    Text('반복해야 할 일',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: TextStyle(fontSize: 16)),
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
          SizedBox(height: 5),
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
                        autofocus: index == _localTaskList.length -1,
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

//반복 리스트 편집 확장
class ReapeatEditFullScreen extends StatefulWidget {
  final List<Task> tasklist;
  final void Function(List<Task>) onTaskAListUpdated;
  final VoidCallback onCollapse;

  const ReapeatEditFullScreen({
    super.key,
    required this.tasklist,
    required this.onTaskAListUpdated,
    required this.onCollapse,
  });

  @override
  State<ReapeatEditFullScreen> createState() => _ReapeatEditFullScreenState();
}

class _ReapeatEditFullScreenState extends State<ReapeatEditFullScreen> {
  late List<Task> _localTaskList;
  @override
  void initState() {
    super.initState();
    _localTaskList = List.from(widget.tasklist);
  }

  void _addTask() {
    setState(() {
      _localTaskList.add(Task(text: '할 일을 추가해보세요', isChecked: false, point: 0));
      widget.onTaskAListUpdated(_localTaskList);
    });
  }

  void _removeTask(int index) {
    setState(() {
      _localTaskList.removeAt(index);
      widget.onTaskAListUpdated(_localTaskList);
    });
  }

  void _updateTaskText(int index, String newText) {
    setState(() {
      _localTaskList[index] = _localTaskList[index].copyWith(text: newText);
      widget.onTaskAListUpdated(_localTaskList);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 제목과 접기 버튼
        TextButton(
          onPressed: widget.onCollapse,
          child: Row(
            children:  [
              Text('반복해야 할 일', style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 28,
                  fontWeight: FontWeight.bold)),
              Icon(Icons.expand_less),
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
              )
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

