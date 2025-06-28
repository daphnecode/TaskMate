import 'package:flutter/material.dart';
import 'package:planner/task.dart';
import 'planner_edit.dart';
import 'package:planner/statistics.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Task> repeatTaskList = [
    Task(text: '할 일 추가해보세요', isChecked: true, point: 0),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 0),

  ];

  List<Task> todayTaskList = [
    Task(text: '할 일 추가해보세요', isChecked: true, point: 0),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 0),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 0),
  ];

  bool showFullRepeat = false;
  bool showFullToday = false;
  bool _isSubmitted = false;

  void toggleRepeatCheck(int index) {
    setState(() {
      repeatTaskList[index] = repeatTaskList[index].copyWith(
        isChecked: !repeatTaskList[index].isChecked,
      );
    });
  }

  void toggleTodayCheck(int index) {
    setState(() {
      todayTaskList[index] = todayTaskList[index].copyWith(
        isChecked: !todayTaskList[index].isChecked,
      );
    });
  }

  void editRepeatPoints() {
    final anyEditing = repeatTaskList.any((task) => task.isEditing);
    setState(() {
      repeatTaskList = repeatTaskList
          .map((task) => task.copyWith(isEditing: !anyEditing))
          .toList();
    });
  }


  void editTodayPoints() {
    final anyEditing = todayTaskList.any((task) => task.isEditing);
    setState(() {
      todayTaskList = todayTaskList
          .map((task) => task.copyWith(isEditing: !anyEditing))
          .toList();
    });
  }


  void updateRepeatPoint(int index, int newPoint) {
    setState(() {
      repeatTaskList[index] = repeatTaskList[index].copyWith(
        point: newPoint,
        isEditing: false,
      );
    });
  }

  void updateTodayPoint(int index, int newPoint) {
    setState(() {
      todayTaskList[index] = todayTaskList[index].copyWith(
        point: newPoint,
        isEditing: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: Builder(
          builder: (context) => IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder:(context) => const StatisticsPage(),
                  ),
              );
            },
            icon: Icon(Icons.pie_chart),
          ),
          ),
          title: DateBadge(),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _isSubmitted = true;
                });
              },
              child: Text(
                '제출',
                style: TextStyle(color: Colors.black),
              ),
            )
          ],
        ),
        body: showFullRepeat
            ? RepeatTaskFullScreen(
          taskList: repeatTaskList,
          onToggleCheck: toggleRepeatCheck,
          onCollapse: () {
            setState(() {
              showFullRepeat = false;
            });
          },
          onEditPoints: editRepeatPoints,
          onEditPoint: (index, newPoint) {
            setState(() {
              repeatTaskList[index] =
                  repeatTaskList[index].copyWith(point: newPoint, isEditing: false);
            });
          },
          onStartEditing: (index) {
            setState(() {
              repeatTaskList[index] =
                  repeatTaskList[index].copyWith(isEditing: true);
            });
          },
        )
            : showFullToday
            ? TodayTaskFullScreen(
          taskList: todayTaskList,
          onToggleCheck: toggleTodayCheck,
          onCollapse: () {
            setState(() {
              showFullToday = false;
            });
          },
          onEditPoints: editTodayPoints,
          onEditPoint: (index, newPoint) {
            setState(() {
              todayTaskList[index] =
                  todayTaskList[index].copyWith(point: newPoint, isEditing: false);
            });
          },
          onStartEditing: (index) {
            setState(() {
              todayTaskList[index] =
                  todayTaskList[index].copyWith(isEditing: true);
            });
          },
        )
            : Column(
          children: [
            Expanded(
              flex: 2,
              child: RepeatTaskBox(
                taskList: repeatTaskList,
                onToggleCheck: toggleRepeatCheck,
                onExpand: () {
                  setState(() {
                    showFullRepeat = true;
                  });
                },
                onEditPoints: editRepeatPoints,
                onEditPoint: (index, newPoint) {
                  setState(() {
                    repeatTaskList[index] =
                        repeatTaskList[index].copyWith(point: newPoint, isEditing: false);
                  });
                },
                onStartEditing: (index) {
                  setState(() {
                    repeatTaskList[index] =
                        repeatTaskList[index].copyWith(isEditing: true);
                  });
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: TodayTaskBox(
                taskList: todayTaskList,
                onToggleCheck: toggleTodayCheck,
                onExpand: () {
                  setState(() {
                    showFullToday = true;
                  });
                },
                onEditPoints: editTodayPoints,
                onEditPoint: (index, newPoint) {
                  setState(() {
                    todayTaskList[index] =
                        todayTaskList[index].copyWith(point: newPoint, isEditing: false);
                  });
                },
                onStartEditing: (index) {
                  setState(() {
                    todayTaskList[index] =
                        todayTaskList[index].copyWith(isEditing: true);
                  });
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Builder( // ✅ context 재정의!
                  builder: (context) => IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PlannerEditPage(),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),

      ),
    );
  }
}

// 날짜 위젯
class DateBadge extends StatelessWidget {
  const DateBadge({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final String formatted = '${now.year}년 ${now.month}월 ${now.day}일';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26),
      ),
      child: Text(
        formatted,
        style: const TextStyle(color: Colors.blue, fontSize: 16),
      ),
    );
  }
}


//반복 리스트
class RepeatTaskBox extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onExpand;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;

  const RepeatTaskBox({
    required this.taskList,
    required this.onToggleCheck,
    required this.onExpand,
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
                  '반복해야 할 일',
                  style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
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

/*
class RepeatTaskBox extends StatefulWidget {

  RepeatTaskBox({Key? key}) : super(key: key);

  @override
  State<RepeatTaskBox> createState() => _RepeatTaskBoxState();
}


class _RepeatTaskBoxState extends State<RepeatTaskBox> {
  List<Task> taskList = [
    Task(text: '과제하기', isChecked: true, point: 50),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 25),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 25),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 25),

  ];

  @override
  Widget build(BuildContext context) {
    int totalTasks = taskList.length;
    int completedTasks = taskList.where((task) => task.isChecked).length;
    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // 풀리스트 확장
                },
                child: Text(
                  '반복해야 할 일',
                  style: TextStyle(color: Colors.black, fontSize: 28,fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: TextStyle(fontSize: 16),),
              IconButton(
                  onPressed: () {
                    setState(() {
                      // 포인트 수정 기능
                    });
                  },
                  icon: Icon(Icons.sync))
            ],
          ),
          SizedBox(height: 5,),
          // 체크리스트 경계선
          SizedBox(
            height: 140, // 한 3~4개 기준
            child: ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return ChecklistItem(
                  task: task.text,
                  isChecked: task.isChecked,
                  point: task.point,
                  onChanged: (_) {
                    setState(() {
                      taskList[index] =
                          task.copyWith(isChecked: !task.isChecked);
                    });
                  },
                );
              },
            ),
          ),
          // 체크리스트 경계선
          SizedBox(height: 10,),
          Text(
            'Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ,
          ),
          SizedBox(height: 4,),
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
              SizedBox(width: 4,),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 16)),
            ],
          )

        ],
      ),
    );
  }
}

 */

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
    Key? key,
    required this.index,
    required this.task,
    required this.isChecked,
    required this.point,
    required this.isEditing,
    required this.onChanged,
    required this.onStartEditing,
    required this.onEditPoint,
  }) : super(key: key);

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
              color: isChecked ? Colors.grey : Colors.black,
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
    Key? key,
    required this.tasks,
    required this.onToggleCheck,
    required this.onStartEditing,
    required this.onEditPoint,
  }) : super(key: key);

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
//일일 리스트
class TodayTaskBox extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onExpand;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;

  const TodayTaskBox({
    required this.taskList,
    required this.onToggleCheck,
    required this.onExpand,
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
                  style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold),
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

/*
class TodayTaskBox extends StatefulWidget {

  const TodayTaskBox({Key? key,}) : super(key: key);

  @override
  State<TodayTaskBox> createState() => _TodayTaskBoxState();
}


class _TodayTaskBoxState extends State<TodayTaskBox> {
  List<Task> taskList = [
    Task(text: '축구하기', isChecked: true, point: 50),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 25),
    Task(text: '할 일 추가해보세요', isChecked: false, point: 25),
  ];

  @override
  Widget build(BuildContext context) {
    int totalTasks = taskList.length;
    int completedTasks = taskList.where((task) => task.isChecked).length;
    double progress = totalTasks > 0 ? completedTasks / totalTasks : 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  // 풀리스트 확장
                },
                child: Text(
                  '오늘해야 할 일',
                  style: TextStyle(color: Colors.black, fontSize: 28,fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          SizedBox(height: 5,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Checklist items', style: TextStyle(fontSize: 16),),
              IconButton(
                  onPressed: () {
                    setState(() {
                      // 포인트 수정 기능
                    });
                  },
                  icon: Icon(Icons.sync))
            ],
          ),
          SizedBox(height: 5,),

          SizedBox(
            height: 140, // 한 3~4개 기준
            child: ListView.builder(
              itemCount: taskList.length,
              itemBuilder: (context, index) {
                final task = taskList[index];
                return ChecklistItem(
                  task: task.text,
                  isChecked: task.isChecked,
                  point: task.point,
                  onChanged: (_) {
                    setState(() {
                      taskList[index] =
                          task.copyWith(isChecked: !task.isChecked);
                    });
                  },
                );
              },
            ),
          ),
          SizedBox(height: 8,),
          Text(
            'Progress',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ,
          ),
          SizedBox(height: 4,),
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
              SizedBox(width: 4,),
              Text('${(progress * 100).round()}%', style: TextStyle(fontSize: 16)),
            ],
          )

        ],
      ),
    );
  }
}

 */
// 반복 리스트 확장
class RepeatTaskFullScreen extends StatelessWidget {
  final List<Task> taskList;
  final void Function(int) onToggleCheck;
  final VoidCallback onCollapse;
  final VoidCallback onEditPoints;
  final void Function(int index, int newPoint) onEditPoint;
  final void Function(int index) onStartEditing;

  const RepeatTaskFullScreen({
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
            children: const [
              Text('오늘해야 할 일', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
