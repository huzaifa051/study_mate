class Subtask {
  String title;
  bool isDone;

  Subtask({required this.title, this.isDone = false});

  Map<String, dynamic> toMap() {
    return {'title': title, 'isDone': isDone};
  }

  factory Subtask.fromMap(Map<String, dynamic> map) {
    return Subtask(title: map['title'], isDone: map['isDone'] ?? false);
  }
}

class StudyTask {
  String id;
  String title;
  String subject;
  DateTime dueDate;
  String priority;
  bool isCompleted;
  List<Subtask> subtasks;
  DateTime? completedAt;

  StudyTask({
    String? id,
    required this.title,
    required this.subject,
    required this.dueDate,
    this.priority = 'Medium',
    this.isCompleted = false,
    List<Subtask>? subtasks,
    this.completedAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
       subtasks = subtasks ?? [];

  void toggleStatus() {
    isCompleted = !isCompleted;
    completedAt = isCompleted ? DateTime.now() : null;
  }

  bool get isOverdue {
    final today = DateTime.now();
    final dueDay = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final todayDay = DateTime(today.year, today.month, today.day);
    return !isCompleted && dueDay.isBefore(todayDay);
  }

  int get completedSubtasks => subtasks.where((s) => s.isDone).length;

  double get progress {
    if (subtasks.isEmpty) {
      return isCompleted ? 1.0 : 0.0;
    }
    return completedSubtasks / subtasks.length;
  }

  String get dueDateText {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = dueDate.hour % 12 == 0 ? 12 : dueDate.hour % 12;
    final minute = dueDate.minute.toString().padLeft(2, '0');
    final period = dueDate.hour >= 12 ? 'PM' : 'AM';
    return '${days[dueDate.weekday - 1]}, ${dueDate.day} '
        '${months[dueDate.month - 1]} · $hour:$minute $period';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'isCompleted': isCompleted,
      'subtasks': subtasks.map((s) => s.toMap()).toList(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory StudyTask.fromMap(Map<String, dynamic> map) {
    final List<dynamic> rawSubtasks = map['subtasks'] ?? [];
    return StudyTask(
      id: map['id'],
      title: map['title'],
      subject: map['subject'],
      dueDate: DateTime.parse(map['dueDate']),
      priority: map['priority'],
      isCompleted: map['isCompleted'],
      subtasks: rawSubtasks.map((s) => Subtask.fromMap(s)).toList(),
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
    );
  }
}
