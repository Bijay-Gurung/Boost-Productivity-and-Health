import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'taskManager.dart';

class TaskManagerScreen extends StatefulWidget {
  const TaskManagerScreen({super.key});

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

  Future<void> _addTask() async {
    final taskController = TextEditingController();
    final dueDateController = TextEditingController();
    final timeController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: dueDateController,
              decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Due Time (HH:MM)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final task = taskController.text;
              final dueDate = DateTime.parse('${dueDateController.text}T${timeController.text}');
              _taskManagerService.createTask(task, dueDate).then((newTask) {
                setState(() {
                  _tasks.add(newTask);
                });
                Navigator.of(context).pop();
              }).catchError((e) {
                print('Error adding task: $e');
              });
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _editTask(TaskManager task) async {
    final taskController = TextEditingController(text: task.task);

    final formattedDueDate = DateFormat('yyyy-MM-dd').format(task.dueDate);
    final formattedDueTime = DateFormat('HH:mm').format(task.dueDate);
    final dueDateController = TextEditingController(text: formattedDueDate);
    final timeController = TextEditingController(text: formattedDueTime);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(labelText: 'Task Name'),
            ),
            TextField(
              controller: dueDateController,
              decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
            ),
            TextField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Due Time (HH:MM)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final updatedTask = taskController.text;
              final updatedDueDate = DateTime.parse('${dueDateController.text}T${timeController.text}');

              _taskManagerService.updateTask(task.id, {
                'task': updatedTask,
                'dueDate': updatedDueDate.toIso8601String(),
              }).then((updatedTask) {
                setState(() {
                  final index = _tasks.indexOf(task);
                  _tasks[index] = updatedTask;
                });
                Navigator.of(context).pop();
              }).catchError((e) {
                print('Error updating task: $e');
              });
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Task Manager')),
      body: Center(
        child: _tasks.isEmpty
            ? CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (value) {
                                  setState(() {
                                    task.isCompleted = value!;
                                  });
                                  _taskManagerService.updateTask(task.id, {'isCompleted': task.isCompleted});
                                },
                              ),
                              title: Text(task.task),
                              subtitle: Text('Due: ${DateFormat('yyyy-MM-dd HH:mm').format(task.dueDate)}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      _editTask(task);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _tasks.removeAt(index);
                                      });
                                      _taskManagerService.deleteTask(task.id);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        backgroundColor: Colors.blue,
        child: Icon(Icons.add),
      ),
    );
  }
}
