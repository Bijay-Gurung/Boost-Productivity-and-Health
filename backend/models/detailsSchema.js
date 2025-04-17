const mongoose = require('mongoose');

const detailsSchema = new mongoose.Schema({
  user: {
    type: String,
    required: true,
    unique: true
  },
  age: {
    type: Number,
    required: true,
  },
  height: {
    type: Number,
    required: true,
  },
  weight: {
    type: Number,
    required: true,
  },
  gender: {
    type: String,
    enum: ['Male', 'Female', 'Other'],
    required: true,
  },
  bmi: Number,
  bmr: Number,
  fitnessGoal: {
    type: String,
    enum: ['Muscle Building', 'Weight Loss', 'Maintain Weight'],
  },
}, { timestamps: true });

module.exports = mongoose.model('Details', detailsSchema);