import 'package:flutter/material.dart';
import 'package:taskmate/DBtest/task.dart';

/// ==============================
/// 반복 리스트 편집 (카드)
/// ==============================
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

  // id 기반 영속 관리
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _syncWith(widget.taskList);
  }

  @override
  void didUpdateWidget(covariant RepeatEditBox oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ 구성(항목 id 시퀀스)이 바뀐 경우에만 전체 동기화
    final oldIds = oldWidget.taskList.map((t) => t.id).toList(growable: false);
    final newIds = widget.taskList.map((t) => t.id).toList(growable: false);
    final sameLength = oldIds.length == newIds.length;
    final sameOrder = sameLength &&
        List<bool>.generate(oldIds.length, (i) => oldIds[i] == newIds[i])
            .every((b) => b);

    if (!sameOrder) {
      _syncWith(widget.taskList);
    } else {
      // 구성 동일 → 포커스 없는 항목만 텍스트 싱크
      for (final t in widget.taskList) {
        final f = _focusNodes[t.id];
        if (f != null && !f.hasFocus) {
          final c = _controllers[t.id];
          if (c != null && c.text != t.text) c.text = t.text;
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

      // 포커스 중이 아닐 때만 외부 텍스트 반영
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
      widget.onTaskListUpdated(List<Task>.from(_localTaskList)); // 복제본
    }
  }

  // onChanged에서는 로컬 상태만 갱신
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

      // 먼저 로컬 UI 렌더 + 포커스
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });

    // 부모 반영은 다음 프레임으로 미룸 (되돌림/깜빡임 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTaskListUpdated(List<Task>.from(_localTaskList));
    });
  }

  void _removeTask(int index) {
    final id = _localTaskList[index].id;
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    });

    // 삭제도 프레임 뒤에 부모 반영(깜빡임 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
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
                    '반복해야 할 일',
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
/// 반복 리스트 편집 - 전체 화면(풀스크린)
/// =======================================
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

  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};

  @override
  void initState() {
    super.initState();
    _syncWith(widget.tasklist);
  }

  @override
  void didUpdateWidget(covariant ReapeatEditFullScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final oldIds = oldWidget.tasklist.map((t) => t.id).toList(growable: false);
    final newIds = widget.tasklist.map((t) => t.id).toList(growable: false);
    final sameLength = oldIds.length == newIds.length;
    final sameOrder = sameLength &&
        List<bool>.generate(oldIds.length, (i) => oldIds[i] == newIds[i])
            .every((b) => b);

    if (!sameOrder) {
      _syncWith(widget.tasklist);
    } else {
      for (final t in widget.tasklist) {
        final f = _focusNodes[t.id];
        if (f != null && !f.hasFocus) {
          final c = _controllers[t.id];
          if (c != null && c.text != t.text) c.text = t.text;
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
      widget.onTaskAListUpdated(List<Task>.from(_localTaskList));
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

      // 로컬 먼저 렌더 + 포커스
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) FocusScope.of(context).requestFocus(node);
      });
    });

    // 부모 반영은 다음 프레임
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTaskAListUpdated(List<Task>.from(_localTaskList));
    });
  }

  void _removeTask(int index) {
    final id = _localTaskList[index].id;
    setState(() {
      _localTaskList.removeAt(index);
      _controllers.remove(id)?.dispose();
      _focusNodes.remove(id)?.dispose();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onTaskAListUpdated(List<Task>.from(_localTaskList));
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
                '반복해야 할 일',
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
