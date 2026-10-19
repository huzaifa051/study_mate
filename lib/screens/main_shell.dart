import 'package:flutter/material.dart';
import '../models/study_task.dart';
import '../services/storage_service.dart';
import '../widgets/floating_nav_bar.dart';
import 'add_task_screen.dart';
import 'focus_screen.dart';
import 'home_screen.dart';
import 'insights_screen.dart';
import 'task_details_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final StorageService _storage = StorageService();
  final PageController _pageController = PageController();

  List<StudyTask> _tasks = [];
  bool _isLoading = true;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
    _saveTasks();
  }

  void _deleteTask(StudyTask task) {
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

  Future<void> _openDetails(StudyTask task) async {
    final action = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            TaskDetailsScreen(task: task, onChanged: _saveTasks),
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
