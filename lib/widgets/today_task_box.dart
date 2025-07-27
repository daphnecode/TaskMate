import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';
import 'checklist_item.dart';

//일일 리스트
class TodayTaskBox extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onExpand;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;
  final String sortingMethod;

  const TodayTaskBox({
    required this.taskList,
    required this.onToggleCheck,
    required this.onExpand,
    required this.onEditPoints,
    required this.onEditPoint,
    required this.onStartEditing,
    required this.sortingMethod,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalTasks = taskList.length;
    int completedTasks = taskList.where((task) => task.isChecked).length;
    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    List<Task> tmpList = sorting(taskList, sortingMethod);
    for (int i = 0; i < taskList.length; i++) {
      taskList[i] = tmpList[i].copyWith();
    }

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
                onPressed: onExpand,
                child: Text(
                  '오늘해야 할 일',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 28,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: TextStyle(fontSize: 16)),
              IconButton(
                onPressed: onEditPoints,
                icon: Icon(Icons.sync),
              ),
            ],
          ),
          SizedBox(height: 5),
          SizedBox(
            height: 140,
            child: ListView.builder(
              itemCount: taskList.length > 3 ? 3 : taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return ChecklistItem(
                  index: index,
                  task: task.text,
                  isChecked: task.isChecked,
                  point: task.point,
                  isEditing: task.isEditing,
                  onChanged: (_) => onToggleCheck(index),
                  onStartEditing: (i) => onStartEditing(index),
                  onEditPoint: (newPoint) => onEditPoint(index, newPoint),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
              SizedBox(width: 4),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 16)),
            ],
          ),
        ],
      ),
    );
  }
}

// 일일 리스트 확장
class TodayTaskFullScreen extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onCollapse;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;

  const TodayTaskFullScreen({
    required this.taskList,
    required this.onToggleCheck,
    required this.onCollapse,
    required this.onEditPoints,
    required this.onEditPoint,
    required this.onStartEditing,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int totalTasks = taskList.length;
    int completedTasks = taskList.where((task) => task.isChecked).length;
    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: onCollapse,
          child: Row(
            children: [
              Text('오늘해야 할 일', style: TextStyle(
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
              IconButton(onPressed: onEditPoints, icon: const Icon(Icons.sync)),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return ChecklistItem(
                  index: index,
                  task: task.text,
                  isChecked: task.isChecked,
                  point: task.point,
                  isEditing: task.isEditing,
                  onChanged: (_) => onToggleCheck(index),
                  onStartEditing: (_) => onStartEditing(index),
                  onEditPoint: (newPoint) => onEditPoint(index, newPoint),
                );
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text('${(progress * 100).round()}%'),
                ],
              ),
            ],
          ),
        )
      ],
    );
  }
}