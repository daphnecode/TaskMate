import 'package:flutter/material.dart';
import 'task.dart';
import 'daily_edit.dart';


class PlannerEditPage extends StatefulWidget {
<<<<<<< HEAD
  final VoidCallback onBackToMain;

  const PlannerEditPage({Key? key,required this.onBackToMain}) : super(key: key);
=======
  final void Function(int) onNext;
  const PlannerEditPage({required this.onNext, super.key});
  
>>>>>>> 05d37471a85305ad38e565f91e842852908bb4f4

  @override
  _PlannerEditPageState createState() => _PlannerEditPageState(onNext: onNext);
}

class _PlannerEditPageState extends State<PlannerEditPage> {
  final void Function(int) onNext;
  _PlannerEditPageState({required this.onNext});

  bool showFullRepeat =false;
  bool showFullToday = false;

  List<Task> repeatTaskList = [
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
  ];

  List<Task> todayTaskList = [
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일을 추가해보세요', isChecked: false, point: 0),
  ];

  void updateRepeatTasks(List<Task> newTasks) {
    setState(() {
      repeatTaskList = newTasks;
    });
  }

  void updateTodayTasks(List<Task> updatedTasks) {
    setState(() {
      todayTaskList = updatedTasks;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(actions: [
        IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DailyTaskEditPage(),
            ),
            );// 일일 리스트 편집 이동
          },
        )
      ]),
      body: showFullRepeat
          ? ReapeatEditFullScreen(
        tasklist: repeatTaskList,
        onTaskAListUpdated: updateRepeatTasks,
        onCollapse: () {
          setState(() {
            showFullRepeat = false;
          });
        },
      )
          : showFullToday
          ? TodayEditFullScreen(
        taskList: todayTaskList,
        onTaskListUpdated: updateTodayTasks,
        onCollapse: () {
          setState(() {
            showFullToday = false;
          });
        },
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              RepeatEditBox(
                taskList: repeatTaskList,
                onTaskListUpdated: updateRepeatTasks,
                onExpand: () {
                  setState(() {
                    showFullRepeat = true;
                  });
                },
              ),
              TodayEditBox(
                taskList: todayTaskList,
                onTaskListUpdated: updateTodayTasks,
                onExpand: () {
                  setState(() {
                    showFullToday = true;
                  });
                },
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Builder(
                builder: (context) => IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () {
<<<<<<< HEAD
                    widget.onBackToMain();
=======
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlannerEditPage(onNext: onNext,),
                      ),
                    );
>>>>>>> 05d37471a85305ad38e565f91e842852908bb4f4
                  },
                ),

              ),
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  onNext(0); // 홈으로 이동
                },
              ),
              IconButton(
                icon: Icon(Icons.settings),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//반복 리스트 편집
class RepeatEditBox extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final VoidCallback onExpand;

  const RepeatEditBox({
    Key? key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onExpand,
  }) : super(key: key);

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
                  children: const [
                    Text('반복해야 할 일',
                      style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
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
                final taskListLength = _localTaskList.length;

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


/*
class RepeatEditBox extends StatelessWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;

  const RepeatEditBox({
    Key? key,
  required this.taskList,
  required this.onTaskListUpdated,
  }) : super(key: key);

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
                  onPressed: () {

                  },
                  child: Text(
                      '반복해야 할 일',
                    style: TextStyle(color: Colors.black, fontSize: 28,fontWeight: FontWeight.bold),
                  ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: TextStyle(fontSize: 16),),
              OutlinedButton(
                  onPressed: () {

                  },
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
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(text: task.text),
                        onChanged: (newText) {
                          // 실시간으로 수정된 텍스트 반영
                          taskList[index] = task.copyWith(text: newText);
                          onTaskListUpdated(List.from(taskList)); // 부모에게 알려주기
                        },
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        taskList.removeAt(index);
                        onTaskListUpdated(List.from(taskList));
                      },
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
 */


//하나의 작업 항목을 관리할 수 있는 위젯
class ChecklistItemEdit extends StatelessWidget {
  final int index;
  final String taskText;
  final ValueChanged<String> onTextChanged;
  final VoidCallback onDelete;

  const ChecklistItemEdit({
    Key? key,
    required this.index,
    required this.taskText,
    required this.onTextChanged,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: taskText);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // 수정 가능한 텍스트 필드
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onTextChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: '할 일을 입력하세요',
              ),
            ),
          ),
          // 삭제 버튼 (X 아이콘)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}



// 일일 리스트 편집
class TodayEditBox extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final DateTime? selectedDate;
  final VoidCallback onExpand;

  const TodayEditBox({
    Key? key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onExpand,
    this.selectedDate,
  }) : super(key: key);

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
                  style: const TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
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


//반복 리스트 편집 확장
class ReapeatEditFullScreen extends StatefulWidget {
  final List<Task> tasklist;
  final void Function(List<Task>) onTaskAListUpdated;
  final VoidCallback onCollapse;

  const ReapeatEditFullScreen({
    required this.tasklist,
    required this.onTaskAListUpdated,
    required this.onCollapse,
    Key? key,
  }) : super(key: key);

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
            children: const [
              Text('반복해야 할 일', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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

// 일일 리스트 편집 확장
class TodayEditFullScreen extends StatefulWidget {
  final List<Task> taskList;
  final void Function(List<Task>) onTaskListUpdated;
  final VoidCallback onCollapse;
  final DateTime? selectedDate;

  const TodayEditFullScreen({
    Key? key,
    required this.taskList,
    required this.onTaskListUpdated,
    required this.onCollapse,
    this.selectedDate,
  }) : super(key: key);

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
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
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
