import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _subtaskController = TextEditingController();

  final List<String> _subjects = [
    'Dart',
    'Flutter',
    'Math',
    'English',
    'Other',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];
  final List<String> _subtaskTitles = [];

  String _subject = 'Dart';
  String _priority = 'Medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _dueTime = const TimeOfDay(hour: 16, minute: 0);

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtaskController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime,
    );
    if (picked != null) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  void _addSubtask() {
    final text = _subtaskController.text.trim();
    if (text.isEmpty) {
      _showMessage('Type a subtask first, then tap +');
      return;
    }
    setState(() {
      _subtaskTitles.add(text);
      _subtaskController.clear();
    });
  }

  void _saveTask() {

    if (!_formKey.currentState!.validate()) return;
    if (_subtaskController.text.trim().isNotEmpty) {
      _subtaskTitles.add(_subtaskController.text.trim());
      _subtaskController.clear();
    }

    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    if (dueDateTime.isBefore(DateTime.now())) {
      _showMessage('That due time has already passed. Please pick a later time.');
      return;
    }

    final task = StudyTask(
      title: _titleController.text.trim(),
      subject: _subject,
      dueDate: dueDateTime,
      priority: _priority,
      subtasks: _subtaskTitles.map((t) => Subtask(title: t)).toList(),
    );
    Navigator.pop(context, task);
  }

  Widget _pickerRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showTopBorder = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            top: showTopBorder
                ? const BorderSide(color: AppColors.hairline)
                : BorderSide.none,
            bottom: const BorderSide(color: AppColors.hairline),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.forest),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontSize: 15)),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(color: AppColors.muted, fontSize: 15),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('New task', style: AppTheme.serif(32)),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _titleController,
                        textCapitalization: TextCapitalization.sentences,
                        style: const TextStyle(fontSize: 17),
                        decoration: const InputDecoration(
                          labelText: 'What are you studying?',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a task title';
                          }
                          if (value.trim().length < 3) {
                            return 'Title must be at least 3 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Subject',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _subjects.map((s) {
                          final selected = s == _subject;
                          return GestureDetector(
                            onTap: () => setState(() => _subject = s),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.forest
                                    : AppColors.sand,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                s,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.stone
                                      : AppColors.charcoal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 28),

                      _pickerRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Due date',
                        value: _formatDate(_dueDate),
                        onTap: _pickDate,
                        showTopBorder: true,
                      ),
                      _pickerRow(
                        icon: Icons.schedule,
                        label: 'Time',
                        value: _dueTime.format(context),
                        onTap: _pickTime,
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Priority',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.sand,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: _priorities.map((p) {
                            final selected = p == _priority;
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => setState(() => _priority = p),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    p,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text(
                        'Subtasks (optional)',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _subtaskController,
                              textCapitalization: TextCapitalization.sentences,
                              onSubmitted: (_) => _addSubtask(),
                              decoration: const InputDecoration(
                                hintText: 'e.g. Read chapter 3',
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: _addSubtask,
                            icon: const Icon(
                              Icons.add_circle_outline,
                              color: AppColors.forest,
                            ),
                          ),
                        ],
                      ),
                      ..._subtaskTitles.asMap().entries.map((entry) {
                        return Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
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
                              const Icon(
                                Icons.circle_outlined,
                                size: 18,
                                color: AppColors.muted,
                              ),
                              const SizedBox(width: 10),
                              Expanded(child: Text(entry.value)),
                              GestureDetector(
                                onTap: () => setState(
                                  () => _subtaskTitles.removeAt(entry.key),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  size: 18,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveTask,
                  child: const Text(
                    'Save task',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
