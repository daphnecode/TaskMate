/// ==========================
/// Task 모델
/// ==========================
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

