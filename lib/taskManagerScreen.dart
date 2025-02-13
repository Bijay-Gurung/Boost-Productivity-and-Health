import 'package:flutter/material.dart';
import 'taskManager.dart'; 

class TaskManagerScreen extends StatefulWidget {
  @override
  _TaskManagerScreenState createState() => _TaskManagerScreenState();
}

class _TaskManagerScreenState extends State<TaskManagerScreen> {
  final TaskManagerService _taskManagerService = TaskManagerService();
  List<TaskManager> _tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      List<TaskManager> tasks = await _taskManagerService.fetchTasks();
      setState(() {
        _tasks = tasks;
      });
    } catch (e) {
      print('Error fetching tasks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (context, index) {
          final task = _tasks[index];
          return ListTile(
            title: Text(task.task),
            subtitle: Text('Due: ${task.dueDate}'),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _taskManagerService.deleteTask(task.id),
            ),
          );
        },
      ),
    );
  }
}
