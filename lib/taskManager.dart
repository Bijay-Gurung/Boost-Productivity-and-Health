import 'dart:convert';
import 'package:http/http.dart' as http;

class TaskManager {
  final String task;
  final bool isCompleted;
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

  // Factory constructor to create a TaskManager object from JSON
  factory TaskManager.fromJson(Map<String, dynamic> json) {
    return TaskManager(
      task: json['task'],
      isCompleted: json['isCompleted'] ?? false,
      dueDate: DateTime.parse(json['dueDate']),
      createdAt: DateTime.parse(json['createdAt']),
      id: json['_id'],
    );
  }

  // Convert a TaskManager object to JSON
  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'isCompleted': isCompleted,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}

class TaskManagerService {
  final String baseUrl = 'http://localhost:4000/taskManager';

  // Create a new task
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

  // Fetch all tasks
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

  // Update a task
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

  // Delete a task
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
