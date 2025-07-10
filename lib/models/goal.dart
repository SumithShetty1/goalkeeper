class Goal {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;

  Goal({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
  });

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
