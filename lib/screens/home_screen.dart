import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  final List<StudyTask> tasks;
  final void Function(StudyTask) onOpenDetails;
  final void Function(StudyTask) onToggle;
  final void Function(StudyTask) onFocus;
  final void Function(StudyTask) onDelete;

  const HomeScreen({
    super.key,
    required this.tasks,
    required this.onOpenDetails,
    required this.onToggle,
    required this.onFocus,
    required this.onDelete,
  });

  List<StudyTask> get _pending =>
      tasks.where((t) => !t.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  List<StudyTask> get _completed =>
      tasks.where((t) => t.isCompleted).toList()
        ..sort((a, b) => a.dueDate.compareTo(b.dueDate));

  double get _progress => tasks.isEmpty ? 0 : _completed.length / tasks.length;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _todayText {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final now = DateTime.now();
    return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;
    final completed = _completed;
    final nextTask = pending.isEmpty ? null : pending.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _todayText,
                style: const TextStyle(color: AppColors.muted, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(_greeting, style: AppTheme.serif(30)),
            ],
          ),
        ),

        Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.forest,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Today',
                    style: AppTheme.serif(22, color: AppColors.stone),
                  ),
                  Text(
                    '${completed.length} of ${tasks.length} done',
                    style: const TextStyle(color: AppColors.sage),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              LinearProgressIndicator(
                value: _progress,
                minHeight: 4,
                backgroundColor: const Color(0xFF4D6B5B),
                color: AppColors.sage,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      nextTask != null
                          ? 'Next: ${nextTask.title}'
                          : (tasks.isEmpty
                                ? 'Add a task to get started'
                                : 'All caught up'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFC9D2C4),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  if (nextTask != null) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => onFocus(nextTask),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.clay,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.play_arrow_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Focus',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: tasks.isEmpty
              ? const _EmptyState()
              : ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    const _SectionTitle('Up next'),
                    if (pending.isEmpty)
                      const Padding(
                        padding: EdgeInsets.fromLTRB(20, 4, 20, 12),
                        child: Text(
                          'All tasks completed. Nice work!',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                    ...pending.map(
                      (task) => _TaskRow(
                        task: task,
                        onTap: () => onOpenDetails(task),
                        onToggle: () => onToggle(task),
                        onDelete: () => onDelete(task),
                      ),
                    ),
                    if (completed.isNotEmpty) ...[
                      const _SectionTitle('Completed'),
                      ...completed.map(
                        (task) => _TaskRow(
                          task: task,
                          onTap: () => onOpenDetails(task),
                          onToggle: () => onToggle(task),
                          onDelete: () => onDelete(task),
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final StudyTask task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskRow({
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  String get _hourMinute {
    final hour = task.dueDate.hour % 12 == 0 ? 12 : task.dueDate.hour % 12;
    final minute = task.dueDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get _period => task.dueDate.hour >= 12 ? 'PM' : 'AM';

  String get _shortDate {
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
    return '${task.dueDate.day} ${months[task.dueDate.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final done = task.isCompleted;

    return Dismissible(
      key: ValueKey(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        color: const Color(0xFFF3DDD5),
        child: const Icon(
          Icons.delete_outline,
          color: AppColors.clay,
          size: 26,
        ),
      ),
      confirmDismiss: (direction) async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            backgroundColor: AppColors.stone,
            title: Text('Delete task?', style: AppTheme.serif(22)),
            content: Text('"${task.title}" will be removed.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.muted),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: AppColors.clay),
                ),
              ),
            ],
          ),
        );
        return confirmed ?? false;
      },
      onDismissed: (direction) => onDelete(),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: AppColors.hairline, width: 0.8),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 46,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _hourMinute,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _period,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: done ? AppColors.muted : AppColors.charcoal,
                        decoration: done ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.sand,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            task.subject,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          task.isOverdue ? 'Overdue · $_shortDate' : _shortDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: task.isOverdue
                                ? AppColors.clay
                                : AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.forest : Colors.transparent,
                      border: Border.all(
                        color: done ? AppColors.forest : AppColors.muted,
                        width: 1.5,
                      ),
                    ),
                    child: done
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: AppColors.stone,
                          )
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.spa_outlined, size: 48, color: AppColors.sage),
          const SizedBox(height: 12),
          Text('Nothing planned yet', style: AppTheme.serif(20)),
          const SizedBox(height: 6),
          const Text(
            'Tap + to add your first study task.',
            style: TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
