import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'focus_screen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final StudyTask task;
  final VoidCallback onChanged;

  const TaskDetailsScreen({
    super.key,
    required this.task,
    required this.onChanged,
  });

  @override
  State<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  final _subtaskController = TextEditingController();

  StudyTask get task => widget.task;

  @override
  void dispose() {
    _subtaskController.dispose();
    super.dispose();
  }

  String get _progressTitle {
    if (task.subtasks.isEmpty) {
      return task.isCompleted ? 'Task completed' : 'Task pending';
    }
    return '${task.completedSubtasks} of ${task.subtasks.length} subtasks';
  }

  String get _progressMessage {
    if (task.isCompleted) return 'All done';
    if (task.subtasks.isEmpty) return 'No subtasks yet';
    if (task.progress == 1) return 'Ready to mark complete';
    if (task.progress >= 0.5) return 'Almost there';
    if (task.progress > 0) return 'Keep going';
    return 'Let\'s get started';
  }

  void _toggleSubtask(Subtask subtask) {
    setState(() {
      subtask.isDone = !subtask.isDone;
    });
    widget.onChanged();
  }

  Future<void> _addSubtask() async {
    _subtaskController.clear();

    final text = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: Text('New subtask', style: AppTheme.serif(22)),
        content: TextField(
          controller: _subtaskController,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(hintText: 'e.g. Read chapter 3'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.muted),
            ),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _subtaskController.text.trim()),
            child: const Text('Add', style: TextStyle(color: AppColors.forest)),
          ),
        ],
      ),
    );

    if (text == null || !mounted) return;

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subtask cannot be empty')),
      );
      return;
    }

    setState(() {
      task.subtasks.add(Subtask(title: text));
    });
    widget.onChanged();
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: Text('Delete task?', style: AppTheme.serif(22)),
        content: const Text('This cannot be undone.'),
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

    if (confirmed == true && mounted) {
      Navigator.pop(context, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_horiz),
            color: AppColors.stone,
            onSelected: (value) {
              if (value == 'delete') _confirmDelete();
            },
            itemBuilder: (context) => const [
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Delete task'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.forest,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        task.subject,
                        style: const TextStyle(color: AppColors.stone),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    task.title,
                    style: AppTheme.serif(32).copyWith(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: task.isOverdue
                            ? AppColors.clay
                            : AppColors.muted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        task.dueDateText,
                        style: TextStyle(
                          color: task.isOverdue
                              ? AppColors.clay
                              : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.sand,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 54,
                                height: 54,
                                child: CircularProgressIndicator(
                                  value: task.progress,
                                  strokeWidth: 5,
                                  strokeCap: StrokeCap.round,
                                  backgroundColor: const Color(0xFFCFC6B4),
                                  color: AppColors.forest,
                                ),
                              ),
                              Text(
                                '${(task.progress * 100).round()}%',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _progressTitle,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _progressMessage,
                                style: const TextStyle(color: AppColors.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  ...task.subtasks.map((subtask) {
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => _toggleSubtask(subtask),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: AppColors.hairline,
                              width: 0.8,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: subtask.isDone
                                    ? AppColors.forest
                                    : Colors.transparent,
                                border: Border.all(
                                  color: subtask.isDone
                                      ? AppColors.forest
                                      : AppColors.muted,
                                  width: 1.5,
                                ),
                              ),
                              child: subtask.isDone
                                  ? const Icon(
                                      Icons.check,
                                      size: 15,
                                      color: AppColors.stone,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                subtask.title,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: subtask.isDone
                                      ? AppColors.muted
                                      : AppColors.charcoal,
                                  decoration: subtask.isDone
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  InkWell(
                    onTap: _addSubtask,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        children: [
                          Icon(Icons.add, size: 22, color: AppColors.forest),
                          SizedBox(width: 12),
                          Text(
                            'Add subtask',
                            style: TextStyle(color: AppColors.forest),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    flex: 10,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.forest,
                        side: const BorderSide(color: AppColors.forest),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                FocusScreen(taskTitle: task.title),
                          ),
                        );
                      },
                      child: const Text(
                        'Focus',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 14,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, 'toggle'),
                      child: Text(
                        task.isCompleted ? 'Mark pending' : 'Mark complete',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
