import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

/// ==============================
/// 일일 리스트 편집 (카드)
/// ==============================
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

  // id 기반 영속 관리
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _syncWith(widget.taskList);
  }

  @override
  void didUpdateWidget(covariant TodayEditBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ 내용이 실제로 달라졌을 때만 동기화
    final oldIds = oldWidget.taskList.map((t) => t.id).toList(growable: false);
    final newIds = widget.taskList.map((t) => t.id).toList(growable: false);
    final shallowEqual = oldIds.length == newIds.length &&
        List.generate(oldIds.length, (i) => oldIds[i] == newIds[i]).every((b) => b);

    if (!shallowEqual) {
      _syncWith(widget.taskList);
    } else {
      // 같은 항목 구성이면, 포커스 안 잡힌 항목 텍스트만 조용히 맞춰줌
      for (final t in widget.taskList) {
        final f = _focusNodes[t.id];
        if (f != null && !f.hasFocus) {
          final c = _controllers[t.id];
          if (c != null && c.text != t.text) {
            c.text = t.text;
          }
        }
      }
    }
  }

  void _syncWith(List<Task> tasks) {
    _localTaskList = List<Task>.from(tasks);

    for (final t in _localTaskList) {
      _controllers.putIfAbsent(t.id, () => TextEditingController(text: t.text));
      _focusNodes.putIfAbsent(t.id, () {
        final f = FocusNode();
        f.addListener(() {
          if (!f.hasFocus) _commitIfChanged(t.id);
        });
        return f;
      });

      // 포커스 중 아닐 때만 외부 변경 반영
      final f = _focusNodes[t.id]!;
      if (!f.hasFocus) {
        final c = _controllers[t.id]!;
        if (c.text != t.text) c.text = t.text;
      }
    }

    // 제거 정리
    final alive = _localTaskList.map((e) => e.id).toSet();
    for (final id in _controllers.keys.toList()) {
      if (!alive.contains(id)) {
        _controllers.remove(id)?.dispose();
        _focusNodes.remove(id)?.dispose();
      }
    }

    setState(() {});
  }

  void _commitIfChanged(String id) {
    final idx = _localTaskList.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final c = _controllers[id]!;
    if (c.value.isComposingRangeValid) return; // 한글 합성 중 커밋 금지

    final cur = _localTaskList[idx];
    if (cur.text != c.text) {
      _localTaskList[idx] = cur.copyWith(text: c.text);
      widget.onTaskListUpdated(List<Task>.from(_localTaskList)); // 커밋 시에만 상위 반영
    }
  }

  void _onChangedLocal(String id, String _) {
    final c = _controllers[id]!;
    if (c.value.isComposingRangeValid) return; // 합성 중
    final i = _localTaskList.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _localTaskList[i] = _localTaskList[i].copyWith(text: c.text);
    }
  }

  void _addTask() {
    final newTask = Task(
      id: generateTaskId(),
      text: '할 일을 추가해보세요',
      isChecked: false,
      point: 0,
    );
    setState(() {
      _localTaskList.add(newTask);
      _controllers[newTask.id] = TextEditingController(text: newTask.text);
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) _commitIfChanged(newTask.id);
      });
      _focusNodes[newTask.id] = node;

      // 구조 변경은 즉시 알림 (내용은 포커스 아웃/엔터에서 커밋)
      widget.onTaskListUpdated(List<Task>.from(_localTaskList));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });
  }

  void _removeTask(int index) {
    final id = _localTaskList[index].id;
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
      widget.onTaskListUpdated(List<Task>.from(_localTaskList));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    for (final f in _focusNodes.values) f.dispose();
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
                    side: const BorderSide(color: Colors.blue, width: 2),
                    padding: const EdgeInsets.all(8),
                  ),
                  child: const Icon(Icons.add, color: Colors.blue),
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
                  final t = _localTaskList[index];
                  final c = _controllers[t.id]!;
                  final f = _focusNodes[t.id]!;
                  return Row(
                    key: ValueKey(t.id), // 안정 키
                    children: [
                      Expanded(
                        child: TextField(
                          controller: c,
                          focusNode: f,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _commitIfChanged(t.id),
                          onChanged: (v) => _onChangedLocal(t.id, v),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10,
                            ),
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

/// =======================================
/// 일일 리스트 편집 - 전체 화면
/// =======================================
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

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _syncWith(widget.taskList);
  }

  @override
  void didUpdateWidget(covariant TodayEditFullScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.taskList, widget.taskList)) {
      _syncWith(widget.taskList);
    }
  }

  void _syncWith(List<Task> tasks) {
    _localTaskList = List<Task>.from(tasks);

    for (final t in _localTaskList) {
      _controllers.putIfAbsent(t.id, () => TextEditingController(text: t.text));
      _focusNodes.putIfAbsent(t.id, () {
        final f = FocusNode();
        f.addListener(() {
          if (!f.hasFocus) _commitIfChanged(t.id);
        });
        return f;
      });

      final f = _focusNodes[t.id]!;
      if (!f.hasFocus) {
        final c = _controllers[t.id]!;
        if (c.text != t.text) c.text = t.text;
      }
    }

    final alive = _localTaskList.map((e) => e.id).toSet();
    for (final id in _controllers.keys.toList()) {
      if (!alive.contains(id)) {
        _controllers.remove(id)?.dispose();
        _focusNodes.remove(id)?.dispose();
      }
    }

    setState(() {});
  }

  void _commitIfChanged(String id) {
    final idx = _localTaskList.indexWhere((t) => t.id == id);
    if (idx < 0) return;
    final c = _controllers[id]!;
    if (c.value.isComposingRangeValid) return;

    final cur = _localTaskList[idx];
    if (cur.text != c.text) {
      _localTaskList[idx] = cur.copyWith(text: c.text);
      widget.onTaskListUpdated(List<Task>.from(_localTaskList));
    }
  }

  void _onChangedLocal(String id, String _) {
    final c = _controllers[id]!;
    if (c.value.isComposingRangeValid) return;
    final i = _localTaskList.indexWhere((t) => t.id == id);
    if (i >= 0) {
      _localTaskList[i] = _localTaskList[i].copyWith(text: c.text);
    }
  }

  void _addTask() {
    final newTask = Task(
      id: generateTaskId(),
      text: '할 일을 추가해보세요',
      isChecked: false,
      point: 0,
    );
    setState(() {
      _localTaskList.add(newTask);
      _controllers[newTask.id] = TextEditingController(text: newTask.text);
      final node = FocusNode();
      node.addListener(() {
        if (!node.hasFocus) _commitIfChanged(newTask.id);
      });
      _focusNodes[newTask.id] = node;

      widget.onTaskListUpdated(List<Task>.from(_localTaskList));

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });
  }

  void _removeTask(int index) {
    final id = _localTaskList[index].id;
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
      widget.onTaskListUpdated(List<Task>.from(_localTaskList));
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) c.dispose();
    for (final f in _focusNodes.values) f.dispose();
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
                  side: const BorderSide(color: Colors.blue, width: 2),
                  padding: const EdgeInsets.all(8),
                ),
                child: const Icon(Icons.add, color: Colors.blue),
              ),
            ],
          ),
        ),

        // 전체 편집 리스트
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView.builder(
              itemCount: _localTaskList.length,
              itemBuilder: (context, index) {
                final t = _localTaskList[index];
                final c = _controllers[t.id]!;
                final f = _focusNodes[t.id]!;
                return Row(
                  key: ValueKey(t.id), // 안정 키
                  children: [
                    Expanded(
                      child: TextField(
                        controller: c,
                        focusNode: f,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _commitIfChanged(t.id),
                        onChanged: (v) => _onChangedLocal(t.id, v),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10,
                          ),
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
