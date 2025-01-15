const mongoose = require('mongoose');

const taskManagerSchema = new mongoose.Schema({
    task: {
        type: String,
        required: true,
    },
    isCompleted: {
        type: Boolean,
        default: false,
    },
    dueDate: {
        type: Date,
    },
    createdAt: {
        type: Date,
        default: Date.now,
    },
});

module.exports = mongoose.model('TaskManager', taskManagerSchema);
