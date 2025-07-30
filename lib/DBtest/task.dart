import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

/// Firestore에서 체크리스트 읽기
Future<Map<String, dynamic>> fetchTasks(String dateKey) async {
  final doc = await firestore.collection('planner').doc(dateKey).get();
  if (!doc.exists) return {'todayTasks': [], 'repeatTasks': [], 'submitted': false};

  final data = doc.data()!;
  return {
    'todayTasks': (data['todayTasks'] as List)
        .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
        .toList(),
    'repeatTasks': (data['repeatTasks'] as List)
        .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
        .toList(),
    'submitted': data['submitted'] ?? false
  };
}

/// Firestore에 문서가 없으면 로컬 기본값으로 생성
Future<void> initializeTasksIfNotExist(
    String dateKey, List<Task> defaultRepeat, List<Task> defaultToday) async {
  final docRef = firestore.collection('planner').doc(dateKey);
  final docSnap = await docRef.get();

  if (!docSnap.exists) {
    await docRef.set({
      'repeatTasks': defaultRepeat.map((t) => t.toJson()).toList(),
      'todayTasks': defaultToday.map((t) => t.toJson()).toList(),
      'submitted': false,
    });
    print("Firestore에 초기값 업로드 완료");
  }
}
// Firestore에 현재 체크리스트 저장
Future<void> updateTasksToFirestore(
    String dateKey, List<Task> todayTasks, List<Task> repeatTasks) async {
  final docRef = firestore.collection('planner').doc(dateKey);
  await docRef.set({
    'repeatTasks': repeatTasks.map((t) => t.toJson()).toList(),
    'todayTasks': todayTasks.map((t) => t.toJson()).toList(),
  }, SetOptions(merge: true));
}

/// 제출 처리 (체크, 포인트, submitted 업데이트)
Future<void> submitTasksToFirestore(
    String dateKey, List<Task> todayTasks, List<Task> repeatTasks) async {
  final docRef = firestore.collection('planner').doc(dateKey);
  final docSnap = await docRef.get();

  // 이미 제출했으면 예외 발생
  if (docSnap.exists && (docSnap.data()?['submitted'] ?? false)) {
    throw Exception("이미 제출했습니다.");
  }

  // 제출
  await docRef.set({
    'repeatTasks': repeatTasks.map((t) => t.toJson()).toList(),
    'todayTasks': todayTasks.map((t) => t.toJson()).toList(),
    'submitted': true,
  }, SetOptions(merge: true));
}


class Task {
  final String text;
  final bool isChecked;
  final int point;
  final bool isEditing;

  Task({
    required this.text,
    required this.isChecked,
    required this.point,
    this.isEditing = false,
  });

  Task copyWith({String? text, bool? isChecked, int? point, bool? isEditing}) {
    return Task(
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      point: point ?? this.point,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'isChecked': isChecked,
      'point': point,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      text: json['text'] ?? '',
      isChecked: json['isChecked'] ?? false,
      point: json['point'] ?? 0,
    );
  }
}


List<Task> sorting(List<Task> tasks, String sortingMethod) {
  switch (sortingMethod) {
    case "사전 순":
      tasks.sort((a, b) => a.text.compareTo(b.text));   
      break;
    case "포인트 순":
      tasks.sort((a, b) => b.point.compareTo(a.point));
      break;
    default:
      tasks.sort((a, b) => a.text.compareTo(b.text));
      break;
  }
  return tasks;
}

