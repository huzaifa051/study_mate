import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../models/study_task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();

  final List<String> _subjects = [
    'Dart',
    'Flutter',
    'Math',
    'English',
    'Other',
  ];
  final List<String> _priorities = ['Low', 'Medium', 'High'];

  String _subject = 'Dart';
  String _priority = 'Medium';
  DateTime _dueDate = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _titleController.dispose();
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
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: _dueDate,
    );
    if (picked != null) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = StudyTask(
        title: _titleController.text.trim(),
        subject: _subject,
        dueDate: _dueDate,
        priority: _priority,
      );
      Navigator.pop(context, task);
    }
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
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: AppColors.hairline),
                              top: BorderSide(color: AppColors.hairline),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 20,
                                color: AppColors.forest,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Due date',
                                style: TextStyle(fontSize: 15),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(_dueDate),
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 15,
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right,
                                color: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
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
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsetsGeometry.fromLTRB(20, 8, 20, 16),
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
