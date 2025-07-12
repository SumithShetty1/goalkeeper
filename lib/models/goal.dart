class Goal {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime? dueDate;
  final DateTime createdAt;
  final Map<String, String> createdBy; // {name: String, email: String}
  final bool isGroupGoal;
  final List<Map<String, String>> participants; // Array of {name, email} maps

  Goal({
    required this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.dueDate,
    DateTime? createdAt,
    required this.createdBy,
    this.isGroupGoal = false,
    this.participants = const [],
  }) : createdAt = createdAt ?? DateTime.now();

  Goal copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? createdAt,
    Map<String, String>? createdBy,
    bool? isGroupGoal,
    List<Map<String, String>>? participants,
  }) {
    return Goal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      isGroupGoal: isGroupGoal ?? this.isGroupGoal,
      participants: participants ?? this.participants,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'dueDate': dueDate?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
      'isGroupGoal': isGroupGoal,
      'participants': participants,
    };
  }

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'],
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      createdBy: Map<String, String>.from(map['createdBy']),
      isGroupGoal: map['isGroupGoal'],
      participants: List<Map<String, String>>.from(
        map['participants'].map((p) => Map<String, String>.from(p)),
      ),
    );
  }
}
