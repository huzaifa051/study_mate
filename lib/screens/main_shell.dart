import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../services/firestore_service.dart';
import '../services/settings_service.dart';
import '../services/storage_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_nav_bar.dart';
import 'add_task_screen.dart';
import 'focus_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'task_details_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';

class MainShell extends StatefulWidget {
  final String userName;

  const MainShell({super.key, required this.userName});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final StorageService _storage = StorageService();
  final FirestoreService _cloud = FirestoreService();
  final SettingsService _settings = SettingsService();
  final PageController _pageController = PageController();

  List<StudyTask> _tasks = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  late String _userName;

  @override
  void initState() {
    super.initState();
    _userName = widget.userName;
    _loadTasks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showMessage(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _friendlyError(Object e) {
    if (e is TimeoutException) return 'No internet connection.';
    if (e is FirebaseException) {
      switch (e.code) {
        case 'unavailable':
        case 'deadline-exceeded':
          return 'No internet connection.';
        case 'permission-denied':
          return 'Cloud access was denied.';
      }
    }
    return 'Something went wrong.';
  }

  Future<void> _loadTasks() async {
    final localTasks = await _storage.loadTasks();
    List<StudyTask> tasks;
    bool cloudFailed = false;

    try {
      tasks = await _cloud.loadTasks();

      if (tasks.isEmpty && localTasks.isNotEmpty) {
        for (final task in localTasks) {
          _cloud.saveTask(task).catchError((Object e) {});
        }
        tasks = localTasks;
      } else {
        await _storage.saveTasks(tasks);
      }
    } catch (e) {
      debugPrint('Firestore load error: $e');
      tasks = localTasks;
      cloudFailed = true;
    }

    if (!mounted) return;
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });

    if (cloudFailed) {
      _showMessage(
        'Could not reach the cloud. Showing tasks saved on this phone.',
      );
    }
  }

  Future<void> _saveLocal() async {
    await _storage.saveTasks(_tasks);
  }

  void _syncTask(StudyTask task, {bool showSuccess = false}) {
    _saveLocal();
    _cloud
        .saveTask(task)
        .timeout(const Duration(seconds: 6))
        .then((_) {
      if (showSuccess) _showMessage('Task saved to the cloud');
    }).catchError((Object e) {
      debugPrint('Firestore save error: $e');
      if (e is TimeoutException) {
        _showMessage(
            'You seem to be offline. Saved on this phone and will sync later.');
      } else {
        _showMessage('Could not sync to the cloud. ${_friendlyError(e)}');
      }
    });
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  void _toggleTask(StudyTask task) {
    setState(() {
      task.toggleStatus();
    });
    _syncTask(task);
  }

  void _deleteTask(StudyTask task) {
    setState(() {
      _tasks.remove(task);
    });
    _saveLocal();
    _cloud.deleteTask(task.id).catchError((Object e) {
      debugPrint('Firestore delete error: $e');
      _showMessage('Could not delete from the cloud. ${_friendlyError(e)}');
    });
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
    _syncTask(newTask, showSuccess: true);
  }

  Future<void> _openDetails(StudyTask task) async {
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailsScreen(task: task, onChanged: () => _syncTask(task)),
      ),
    );

    if (!mounted) return;

    if (action == 'toggle') {
      _toggleTask(task);
    } else if (action == 'delete') {
      _deleteTask(task);
    } else {
      setState(() {});
    }
  }

  void _openFocus(StudyTask task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FocusScreen(taskTitle: task.title),
      ),
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _userName);

    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.stone,
        title: Text('Your name', style: AppTheme.serif(22)),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Enter your name'),
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
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text(
              'Save',
              style: TextStyle(color: AppColors.forest),
            ),
          ),
        ],
      ),
    );

    if (newName == null || !mounted) return;

    if (newName.isEmpty) {
      _showMessage('Name cannot be empty');
      return;
    }

    setState(() => _userName = newName);
    await _settings.saveUserName(newName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                children: [
                  HomeScreen(
                    tasks: _tasks,
                    userName: _userName,
                    onEditName: _editName,
                    onOpenDetails: _openDetails,
                    onToggle: _toggleTask,
                    onFocus: _openFocus,
                    onDelete: _deleteTask,
                  ),
                  InsightsScreen(tasks: _tasks),
                ],
              ),
      ),
      bottomNavigationBar: FloatingNavBar(
        currentIndex: _currentIndex,
        onHome: () => _goToPage(0),
        onInsights: () => _goToPage(1),
        onAdd: _openAddTask,
      ),
    );
  }
}
