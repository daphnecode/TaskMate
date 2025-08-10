import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

/// 일일 리스트 편집
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
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initFromTasks(widget.taskList);
  }

  @override
  void didUpdateWidget(covariant TodayEditBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskList != widget.taskList) {
      _initFromTasks(widget.taskList);
    }
  }

  void _initFromTasks(List<Task> tasks) {
    // 이전 컨트롤러/포커스 정리
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _controllers.clear();
    _focusNodes.clear();

    _localTaskList = List.from(tasks);
    for (final t in _localTaskList) {
      _controllers.add(TextEditingController(text: t.text));
      _focusNodes.add(FocusNode());
    }
    setState(() {});
  }

  void _addTask() {
    setState(() {
      final newTask = Task(text: '할 일을 추가해보세요', isChecked: false, point: 0);
      _localTaskList.add(newTask);
      _controllers.add(TextEditingController(text: newTask.text));
      final node = FocusNode();
      _focusNodes.add(node);
      widget.onTaskListUpdated(_localTaskList);
      // 프레임 이후 마지막 항목에 포커스
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });
  }

  void _removeTask(int index) {
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.removeAt(index).dispose();
      _focusNodes.removeAt(index).dispose();
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _updateTaskText(int index, String newText) {
    _localTaskList[index] = _localTaskList[index].copyWith(text: newText);
    widget.onTaskListUpdated(_localTaskList);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.selectedDate;
    final formattedDate = d != null
        ? "${d.year} / ${d.month.toString().padLeft(2, '0')} / ${d.day.toString().padLeft(2, '0')}"
        : "2025 / 00 / 00";

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
                  onPressed: widget.onExpand,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: theme.colorScheme.onSurface,
                  ),
                  child: Text(
                    formattedDate,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 26,
                    ),
                  ),
                ),
                const Spacer(),
                OutlinedButton(
                  onPressed: _addTask,
                  style: OutlinedButton.styleFrom(
                    shape: const CircleBorder(),
                    side: BorderSide(color: Colors.blue, width: 2),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: Icon(Icons.add, color: Colors.blue),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text('Checklist items', style: theme.textTheme.bodySmall),

            const SizedBox(height: 8),
            SizedBox(
              height: 140,
              child: ListView.builder(
                itemCount: _localTaskList.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          onChanged: (v) => _updateTaskText(index, v),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            fillColor: theme.colorScheme.surfaceVariant,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _removeTask(index),
                        tooltip: '삭제',
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 일일 리스트 편집 - 전체 화면(스타일 통일 + 컨트롤러/포커스 유지)
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
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    _initFromTasks(widget.taskList);
  }

  @override
  void didUpdateWidget(covariant TodayEditFullScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskList != widget.taskList) {
      _initFromTasks(widget.taskList);
    }
  }

  void _initFromTasks(List<Task> tasks) {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    _controllers.clear();
    _focusNodes.clear();

    _localTaskList = List.from(tasks);
    for (final t in _localTaskList) {
      _controllers.add(TextEditingController(text: t.text));
      _focusNodes.add(FocusNode());
    }
    setState(() {});
  }

  void _addTask() {
    setState(() {
      final newTask = Task(text: '할 일을 추가해보세요', isChecked: false, point: 0);
      _localTaskList.add(newTask);
      _controllers.add(TextEditingController(text: newTask.text));
      final node = FocusNode();
      _focusNodes.add(node);
      widget.onTaskListUpdated(_localTaskList);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });
  }

  void _removeTask(int index) {
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.removeAt(index).dispose();
      _focusNodes.removeAt(index).dispose();
      widget.onTaskListUpdated(_localTaskList);
    });
  }

  void _updateTaskText(int index, String newText) {
    _localTaskList[index] = _localTaskList[index].copyWith(text: newText);
    widget.onTaskListUpdated(_localTaskList);
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.selectedDate;
    final formattedDate = d != null
        ? "${d.year} / ${d.month.toString().padLeft(2, '0')} / ${d.day.toString().padLeft(2, '0')}"
        : "2025 / 00 / 00";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextButton(
          onPressed: widget.onCollapse,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Row(
            children: [
              Text(
                formattedDate,
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
              OutlinedButton(
                onPressed: _addTask,
                style: OutlinedButton.styleFrom(
                  shape: const CircleBorder(),
                  side: BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.all(8),
                ),
                child: Icon(Icons.add, color: Colors.blue),
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
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        onChanged: (v) => _updateTaskText(index, v),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                          fillColor: theme.colorScheme.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => _removeTask(index),
                      tooltip: '삭제',
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
