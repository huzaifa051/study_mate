import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/study_task.dart';

class StorageService {
  static const String _key = 'study_task';

  Future<List<StudyTask>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_key);

    if (data == null) {
      return [];
    }

    final List<dynamic> decode = jsonDecode(data);
    return decode.map((item) => StudyTask.fromMap(item)).toList();
  }

  Future<void> saveTasks(List<StudyTask> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(tasks.map((t) => t.toMap()).toList());
    await prefs.setString(_key, encoded);
  }
}