import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../theme/app_theme.dart';
import '../theme/app_colors.dart';
import '../services/storage_service.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<StudyTask> _tasks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await _storage.loadTasks();
    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _saveTasks() async {
    await _storage.saveTasks(_tasks);
  }

  void _toggleTask(StudyTask task) {
    setState(() {
      task.toggleStatus();
    });
    _saveTasks();
  }

  void _deleteTasks(StudyTask task) {
    setState(() {
      _tasks.remove(task);
    });
    _saveTasks();
  }

  Future<void> _openAddTask() async {
    final newTask = await Navigator.push<StudyTask>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (newTask == null || !mounted) return;

    setState(() {
      _tasks.add(newTask);
    });
    _saveTasks();
  }

  int get _completedCount => _tasks.where((t) => t.isCompleted).length;

  double get _progress => _tasks.isEmpty ? 0 : _completedCount / _tasks.length;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good Evening';
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
    return '${days[now.weekday - 1]}, ${now.day}, ${months[now.month - 1]}';
  }

  String _formatDue(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final sortedTasks = [..._tasks]
      ..sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
    return Scaffold(
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _todayText,
                          style: const TextStyle(
                            color: AppColors.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text('$_greeting, Huzaifa', style: AppTheme.serif(26)),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.forest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today',
                              style: AppTheme.serif(20, color: AppColors.stone),
                            ),
                            Text(
                              '$_completedCount of ${_tasks.length} done',
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
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 22, 20, 6),
                    child: Text(
                      'Your tasks',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: sortedTasks.isEmpty
                        ? const _EmptyState()
                        : ListView.builder(
                            padding: EdgeInsets.only(bottom: 90),
                            itemCount: sortedTasks.length,
                            itemBuilder: (context, index) {
                              final task = sortedTasks[index];
                              return _TaskRow(
                                task: task,
                                dueText: _formatDue(task.dueDate),
                                onToggle: () => _toggleTask(task),
                                onDelete: () => _deleteTasks(task),
                              );
                            },
                          ),
                  ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTask,
        backgroundColor: AppColors.clay,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final StudyTask task;
  final String dueText;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const _TaskRow({
    required this.task,
    required this.dueText,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.hairline, width: 0.8),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggle,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.isCompleted ? AppColors.forest : Colors.transparent,
                border: Border.all(
                  color: task.isCompleted ? AppColors.forest : AppColors.muted,
                  width: 1.5,
                ),
              ),
              child: task.isCompleted
                  ? const Icon(Icons.check, size: 15, color: AppColors.stone)
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: task.isCompleted
                        ? AppColors.muted
                        : AppColors.charcoal,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.sand,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.subject,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      task.isOverdue ? 'Overdue . $dueText' : 'Due $dueText',
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
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: AppColors.muted),
          ),
        ],
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
