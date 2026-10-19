import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/study_task.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _tasks = FirebaseFirestore
      .instance
      .collection('tasks');

  Future<List<StudyTask>> loadTasks() async {
    final snapshot = await _tasks.get().timeout(const Duration(seconds: 8));
    return snapshot.docs.map((doc) => StudyTask.fromMap(doc.data())).toList();
  }

  Future<void> saveTask(StudyTask task) {
    return _tasks.doc(task.id).set(task.toMap());
  }

  Future<void> deleteTask(String id) {
    return _tasks.doc(id).delete();
  }
}
