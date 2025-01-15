const express = require('express');
const TaskManager = require('../models/taskManagerSchema');
const router = express.Router();

router.post('/', async (req, res) => {
    try {
        const { task, dueDate } = req.body;

        const newTask = new TaskManager({
            task,
            dueDate,
        });

        const savedTask = await newTask.save();
        res.status(201).json({ message: 'Task created successfully', task: savedTask });
    } catch (error) {
        console.error('Error creating task:', error);
        res.status(500).json({ message: 'Failed to create task', error: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const tasks = await TaskManager.find();
        res.status(200).json(tasks);
    } catch (error) {
        console.error('Error fetching tasks:', error);
        res.status(500).json({ message: 'Failed to fetch tasks', error: error.message });
    }
});

router.put('/:taskId', async (req, res) => {
    try {
        const { taskId } = req.params;
        const updatedTask = await TaskManager.findByIdAndUpdate(taskId, req.body, { new: true });

        if (!updatedTask) {
            return res.status(404).json({ message: 'Task not found' });
        }

        res.status(200).json({ message: 'Task updated successfully', task: updatedTask });
    } catch (error) {
        console.error('Error updating task:', error);
        res.status(500).json({ message: 'Failed to update task', error: error.message });
    }
});

router.delete('/:taskId', async (req, res) => {
    try {
        const { taskId } = req.params;
        const deletedTask = await TaskManager.findByIdAndDelete(taskId);

        if (!deletedTask) {
            return res.status(404).json({ message: 'Task not found' });
        }

        res.status(200).json({ message: 'Task deleted successfully' });
    } catch (error) {
        console.error('Error deleting task:', error);
        res.status(500).json({ message: 'Failed to delete task', error: error.message });
    }
});

module.exports = router;
