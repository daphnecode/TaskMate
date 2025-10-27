import 'dart:math';

/// 패키지 없이 안전한 고유 ID (웹/모바일 공통)
String generateTaskId() {
  final r = Random();
  final ts = DateTime.now().microsecondsSinceEpoch.toRadixString(36);

  // ✅ 절대 비트시프트 쓰지 말고, 상수 리터럴 사용 (웹 안전)
  const MAX = 0x7fffffff; // 2,147,483,647 (<= 2^31-1)

  final a = r.nextInt(MAX).toRadixString(36).padLeft(6, '0');
  final b = r.nextInt(MAX).toRadixString(36).padLeft(6, '0');
  return 't_${ts}_$a$b';
}

/// ==========================
/// Task 모델
/// ==========================
class Task {
  final String id;        // ✅ 안정 키
  final String text;
  final bool isChecked;
  final int point;
  final bool isEditing;

  Task({
    required this.id,
    required this.text,
    required this.isChecked,
    required this.point,
    this.isEditing = false,
  });

  Task copyWith({
    String? id,
    String? text,
    bool? isChecked,
    int? point,
    bool? isEditing,
  }) {
    return Task(
      id: id ?? this.id,
      text: text ?? this.text,
      isChecked: isChecked ?? this.isChecked,
      point: point ?? this.point,
      isEditing: isEditing ?? this.isEditing,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,                 // ✅ 저장 시 id 포함
      'text': text,
      'isChecked': isChecked,
      'point': point,
      // isEditing은 UI 상태이므로 보통 저장하지 않음
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    // ✅ 레거시 데이터(id 없음) 대비: 즉시 생성해서 메모리 상 보정
    final rawId = json['id'];
    return Task(
      id: (rawId is String && rawId.isNotEmpty) ? rawId : generateTaskId(),
      text: (json['text'] ?? '') as String,
      isChecked: (json['isChecked'] ?? false) as bool,
      point: (json['point'] ?? 0) as int,
    );
  }
}

/// ==========================
/// 정렬 (원본 불변, 뷰 전용)
/// ==========================
/// - 절대 원본 리스트를 .sort로 바꾸지 말고
///   복사본을 만들어 정렬한 뒤 반환
List<Task> sorting(List<Task> tasks, String sortingMethod) {
  final list = List<Task>.from(tasks); // ✅ 복사본
  switch (sortingMethod) {
    case "사전 순":
      list.sort((a, b) => a.text.compareTo(b.text));
      break;
    case "포인트 순":
      list.sort((a, b) => b.point.compareTo(a.point));
      break;
    default:
      list.sort((a, b) => a.text.compareTo(b.text));
      break;
  }
  return list;
}

/// ==========================
/// 마이그레이션 보조 (옵션)
/// ==========================
/// Firestore에서 id 없이 내려온 과거 Task들을 즉시 보정
List<Task> ensureIds(List<Task> list) {
  return list.map((t) => (t.id.isEmpty) ? t.copyWith(id: generateTaskId()) : t).toList();
}
