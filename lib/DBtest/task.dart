// 체크리스트 데이터 모델
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
}

/*
// 체크리스트 데이터 모델
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
}

 */