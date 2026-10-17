class StudyTask {
  String id;
  String title;
  String subject;
  DateTime dueDate;
  String priority;
  bool isCompleted;

  StudyTask({
    String? id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
  }) : id = id ?? DateTime.now().microsecondsSinceEpoch.toString();

  void toggleStatus() {
    isCompleted = !isCompleted;
  }

  bool get isOverdue {
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return !isCompleted && dueDay.isBefore(todayDay);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    return StudyTask(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'],
      isCompleted: map['isCompleted'],
    );
  }
}
