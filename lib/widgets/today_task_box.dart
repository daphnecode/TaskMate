import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';
import 'checklist_item.dart';

// 일일 리스트
class TodayTaskBox extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onExpand;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;
  final String sortingMethod;

  const TodayTaskBox({
    super.key,
    required this.taskList,
    required this.onToggleCheck,
    required this.onExpand,
    required this.onEditPoints,
    required this.onEditPoint,
    required this.onStartEditing,
    required this.sortingMethod,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalTasks = taskList.length;
    final completedTasks = taskList.where((t) => t.isChecked).length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    // ✅ 편집 중엔 정렬 잠깐 OFF (포커스 보호)
    final isEditingAny = taskList.any((t) => t.isEditing);

    // ✅ 원본은 절대 건드리지 말고 뷰 전용 정렬본 사용
    final viewList = isEditingAny ? taskList : sorting(taskList, sortingMethod);

    // ✅ id -> 원본 인덱스 매핑
    final idToIndex = {
      for (int i = 0; i < taskList.length; i++) taskList[i].id: i,
    };

    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              children: [
                TextButton(
                  onPressed: onExpand,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  child: Text(
                    '오늘해야 할 일',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: onEditPoints,
                  icon: const Icon(Icons.sync),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text('Checklist items', style: theme.textTheme.bodySmall),

            const SizedBox(height: 8),
            // 미리보기 리스트(최대 3개)
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: viewList.length > 3 ? 3 : viewList.length,
                itemBuilder: (context, index) {
                  final task = viewList[index];
                  final originalIndex = idToIndex[task.id]!;
                  return KeyedSubtree(
                    key: ValueKey(task.id),
                    child: ChecklistItem(
                      index: originalIndex, // ✅ 원본 인덱스 기준
                      task: task.text,
                      isChecked: task.isChecked,
                      point: task.point,
                      isEditing: task.isEditing,
                      onChanged: (_) => onToggleCheck(originalIndex),
                      onStartEditing: (_) => onStartEditing(originalIndex),
                      onEditPoint: (newPoint) => onEditPoint(originalIndex, newPoint),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // 진행도
            Text(
              'Progress',
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${(progress * 100).round()}%', style: theme.textTheme.bodyMedium),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// 일일 리스트 확장(스타일만 통일)
class TodayTaskFullScreen extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onCollapse;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;

  const TodayTaskFullScreen({
    super.key,
    required this.taskList,
    required this.onToggleCheck,
    required this.onCollapse,
    required this.onEditPoints,
    required this.onEditPoint,
    required this.onStartEditing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalTasks = taskList.length;
    final completedTasks = taskList.where((t) => t.isChecked).length;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: onCollapse,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Row(
            children: [
              Text(
                '오늘해야 할 일',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.expand_less),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: theme.textTheme.bodySmall),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onEditPoints,
                icon: const Icon(Icons.sync),
              ),
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
                return KeyedSubtree(
                  key: ValueKey(task.id),
                  child: ChecklistItem(
                    index: index,
                    task: task.text,
                    isChecked: task.isChecked,
                    point: task.point,
                    isEditing: task.isEditing,
                    onChanged: (_) => onToggleCheck(index),
                    onStartEditing: (_) => onStartEditing(index),
                    onEditPoint: (newPoint) => onEditPoint(index, newPoint),
                  ),
                );
              },
            ),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Progress', style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: theme.colorScheme.surfaceVariant,
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${(progress * 100).round()}%', style: theme.textTheme.bodyMedium),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
