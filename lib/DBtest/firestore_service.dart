import 'package:cloud_firestore/cloud_firestore.dart';
import 'task.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

/// ==========================
/// 반복 리스트 전용 (repeatTasks)
/// ==========================
Future<List<Task>> fetchRepeatTasks(String userId) async {
  final repeatRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('repeatTasks')
      .doc('default');

  final metaRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('repeatTasks')
      .doc('meta'); // 날짜 기록용

  final doc = await repeatRef.get();
  if (!doc.exists) return [];

  // 마지막 업데이트 날짜 확인
  final metaDoc = await metaRef.get();
  DateTime lastUpdated = metaDoc.exists
      ? DateTime.tryParse(metaDoc['lastUpdated'] ?? '') ?? DateTime.now()
      : DateTime.now();

  DateTime today = DateTime.now();

  List<Task> tasks = (doc.data()?['tasks'] as List)
      .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
      .toList();

  // 날짜가 바뀌었으면 체크 해제
  if (lastUpdated.year != today.year ||
      lastUpdated.month != today.month ||
      lastUpdated.day != today.day) {
    tasks = tasks.map((t) => t.copyWith(isChecked: false)).toList();

    // Firestore에 반영
    await repeatRef.set({
      'tasks': tasks.map((t) => t.toJson()).toList(),
    }, SetOptions(merge: true));

    // meta 날짜 갱신
    await metaRef.set({'lastUpdated': today.toIso8601String()});
  }

  return tasks;
}

Future<void> updateRepeatTasks(String userId, List<Task> tasks) async {
  final docRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('repeatTasks')
      .doc('default');

  final metaRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('repeatTasks')
      .doc('meta');

  await docRef.set({
    'tasks': tasks.map((t) => t.toJson()).toList(),
  }, SetOptions(merge: true));

  // 저장할 때도 마지막 업데이트 날짜 갱신
  await metaRef.set({'lastUpdated': DateTime.now().toIso8601String()});
}

/// ==========================
/// 일일 리스트 (planner)
/// ==========================
Future<Map<String, dynamic>> fetchTasks(String userId, String dateKey) async {
  final doc = await firestore
      .collection('Users')
      .doc(userId)
      .collection('planner')
      .doc(dateKey)
      .get();

  if (!doc.exists) return {'todayTasks': [], 'submitted': false};

  final data = doc.data()!;
  return {
    'todayTasks': (data['todayTasks'] as List)
        .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
        .toList(),
    'submitted': data['submitted'] ?? false
  };
}

/// Firestore에 문서가 없으면 로컬 기본값으로 생성
Future<void> initializeTasksIfNotExist(
    String userId, String dateKey, List<Task> defaultToday) async {
  final plannerRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('planner')
      .doc(dateKey);

  final logRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('log')
      .doc(dateKey);

  final docSnap = await plannerRef.get();

  if (!docSnap.exists) {
    await plannerRef.set({
      'todayTasks': defaultToday.map((t) => t.toJson()).toList(),
      'submitted': false,
    });
  }

  // 접속 로그 기록
  await logRef.set({
    'visited': true,
  }, SetOptions(merge: true));
}

/// Firestore에 현재 체크리스트 저장
Future<void> updateTasksToFirestore(
    String userId, String dateKey, List<Task> todayTasks) async {
  final docRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('planner')
      .doc(dateKey);

  await docRef.set({
    'todayTasks': todayTasks.map((t) => t.toJson()).toList(),
  }, SetOptions(merge: true));
}

/// 제출 처리 (체크, 포인트, submitted 업데이트 + log 기록)
Future<void> submitTasksToFirestore(
    String userId, String dateKey, List<Task> todayTasks, List<Task> repeatTasks) async {
  final plannerRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('planner')
      .doc(dateKey);

  final logRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('log')
      .doc(dateKey);

  final docSnap = await plannerRef.get();
  if (docSnap.exists && (docSnap.data()?['submitted'] ?? false)) {
    throw Exception("이미 제출했습니다.");
  }

  // 완료 개수 & 전체 개수 계산
  final completedCount = [
    ...todayTasks,
    ...repeatTasks,
  ].where((t) => t.isChecked).length;
  final totalTasks = todayTasks.length + repeatTasks.length;

  // 플래너 제출
  await plannerRef.set({
    'todayTasks': todayTasks.map((t) => t.toJson()).toList(),
    'submitted': true,
  }, SetOptions(merge: true));

  // 로그 기록
  await logRef.set({
    'submitted': true,
    'submittedAt': FieldValue.serverTimestamp(),
    'completedCount': completedCount,
    'totalTasks': totalTasks,
    'visited': true,
  }, SetOptions(merge: true));
}

/// ==========================
/// 일일 리스트 날짜별 저장 (dailyTasks)
/// ==========================
Future<List<Task>> fetchDailyTasks(String userId, String dateKey) async {
  final doc = await firestore
      .collection('Users')
      .doc(userId)
      .collection('dailyTasks')
      .doc(dateKey)
      .get();

  if (!doc.exists) return [];
  final data = doc.data();
  if (data == null || data['tasks'] == null) return [];

  return (data['tasks'] as List)
      .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
      .toList();
}

Future<void> saveDailyTasks(String userId, String dateKey, List<Task> tasks) async {
  await firestore
      .collection('Users')
      .doc(userId)
      .collection('dailyTasks')
      .doc(dateKey)
      .set({
    'tasks': tasks.map((t) => t.toJson()).toList(),
  }, SetOptions(merge: true));
}

/// ==========================
/// dailyTasks → planner 동기화
/// ==========================
Future<void> syncDailyToPlanner(String userId, String dateKey) async {
  final plannerRef = firestore
      .collection('Users')
      .doc(userId)
      .collection('planner')
      .doc(dateKey);

  final plannerSnap = await plannerRef.get();
  if (plannerSnap.exists) return; // 이미 있으면 아무 것도 안 함

  // dailyTasks에서 가져오기
  final dailyDoc = await firestore
      .collection('Users')
      .doc(userId)
      .collection('dailyTasks')
      .doc(dateKey)
      .get();

  List<Task> tasks = [];
  if (dailyDoc.exists && dailyDoc.data()?['tasks'] != null) {
    tasks = (dailyDoc.data()!['tasks'] as List)
        .map((t) => Task.fromJson(Map<String, dynamic>.from(t)))
        .toList();
  }

  // planner에 생성 (없으면 빈 리스트)
  await plannerRef.set({
    'todayTasks': tasks.map((t) => t.toJson()).toList(),
    'submitted': false,
  }, SetOptions(merge: true));
}

