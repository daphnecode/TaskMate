import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

// 하나의 작업 항목을 관리할 수 있는 위젯
class ChecklistItem extends StatelessWidget {
  final int index;
  final String task;
  final bool isChecked;
  final int point;
  final bool isEditing;
  final ValueChanged<bool?> onChanged;
  final ValueChanged<int> onStartEditing;
  final ValueChanged<int> onEditPoint;

  const ChecklistItem({
    super.key,
    required this.index,
    required this.task,
    required this.isChecked,
    required this.point,
    required this.isEditing,
    required this.onChanged,
    required this.onStartEditing,
    required this.onEditPoint,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
        ),
        Expanded(
          child: Text(
            task,
            style: TextStyle(
              fontSize: 16,
              decoration: isChecked ? TextDecoration.lineThrough : null,
              color: isChecked
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.6)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        isEditing
            ? SizedBox(
          width: 50,
          child: TextField(
            autofocus: true,
            keyboardType: TextInputType.number,
            onSubmitted: (value) {
              final newPoint = int.tryParse(value) ?? point;
              onEditPoint(newPoint);
            },
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            ),
          ),
        )
            : GestureDetector(
          onTap: () => onStartEditing(index),
          child: Text(
            '$point pt',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
// 작업 리스트를 보여주는 공간
class TaskListWidget extends StatelessWidget {
  final List<Task> tasks;
  final ValueChanged<int> onToggleCheck;
  final void Function(int) onStartEditing;
  final void Function(int index, int newPoint) onEditPoint;

  const TaskListWidget({
    super.key,
    required this.tasks,
    required this.onToggleCheck,
    required this.onStartEditing,
    required this.onEditPoint,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: ChecklistItem(
              index: index,
              task: task.text,
              isChecked: task.isChecked,
              point: task.point,
              isEditing: task.isEditing,
              onChanged: (_) => onToggleCheck(index),
              onStartEditing: (int _) => onStartEditing(index),
              onEditPoint: (newPoint) => onEditPoint(index, newPoint),
            ),
          );
        },
      ),
    );
  }
}
