import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskManager {
  final String task;
  bool isCompleted;
  final DateTime dueDate;
  final DateTime createdAt;
  final String id;

  TaskManager({
    required this.task,
    required this.isCompleted,
    required this.dueDate,
    required this.createdAt,
    required this.id,
  });

  factory TaskManager.fromJson(Map<String, dynamic> json) {
    return TaskManager(
      task: json['task'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      id: json['_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

class TaskManagerService {
  final String baseUrl = 'http://192.168.1.74:4000/taskManager';

  Future<TaskManager> createTask(String task, DateTime dueDate) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'task': task,
          'dueDate': dueDate.toIso8601String(),
        }),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TaskManager.fromJson(responseData['task']);
      } else {
        throw Exception('Failed to create task');
      }
    } catch (error) {
      throw Exception('Failed to create task: $error');
    }
  }

  Future<List<TaskManager>> fetchTasks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((task) => TaskManager.fromJson(task)).toList();
      } else {
        throw Exception('Failed to fetch tasks');
      }
    } catch (error) {
      throw Exception('Failed to fetch tasks: $error');
    }
  }

  Future<TaskManager> updateTask(String taskId, Map<String, dynamic> updatedData) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$taskId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return TaskManager.fromJson(responseData['task']);
      } else {
        throw Exception('Failed to update task');
      }
    } catch (error) {
      throw Exception('Failed to update task: $error');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$taskId'));

      if (response.statusCode != 200) {
        throw Exception('Failed to delete task');
      }
    } catch (error) {
      throw Exception('Failed to delete task: $error');
    }
  }
}
