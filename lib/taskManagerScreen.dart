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
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

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
            const SizedBox(height: 16),
            ListTile(
              title: Text('Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(Duration(days: 365)),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
            ),
            ListTile(
              title: Text('Due Time: ${selectedTime.format(context)}'),
              trailing: Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  selectedTime = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (taskController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a task name')),
                );
                return;
              }

              final dueDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              _taskManagerService.createTask(taskController.text, dueDate).then((newTask) {
                setState(() {
                  _tasks.add(newTask);
                });
                Navigator.of(context).pop();
              }).catchError((e) {
                print('Error adding task: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding task: $e')),
                );
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
    DateTime selectedDate = task.dueDate;
    TimeOfDay selectedTime = TimeOfDay.fromDateTime(task.dueDate);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: const InputDecoration(labelText: 'Task Name'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text('Due Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) {
                  selectedDate = picked;
                }
              },
            ),
            ListTile(
              title: Text('Due Time: ${selectedTime.format(context)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                final TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (picked != null) {
                  selectedTime = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (taskController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a task name')),
                );
                return;
              }

              final dueDate = DateTime(
                selectedDate.year,
                selectedDate.month,
                selectedDate.day,
                selectedTime.hour,
                selectedTime.minute,
              );

              _taskManagerService.updateTask(task.id, {
                'task': taskController.text,
                'dueDate': dueDate.toIso8601String(),
              }).then((updatedTask) {
                setState(() {
                  final index = _tasks.indexOf(task);
                  _tasks[index] = updatedTask;
                });
                Navigator.of(context).pop();
              }).catchError((e) {
                print('Error updating task: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating task: $e')),
                );
              });
            },
            child: const Text('Save'),
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
