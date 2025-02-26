const mongoose = require('mongoose');

const detailsSchema = new mongoose.Schema({
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
  bmi: {
    type: Number,
    required: false,
  },
  bmr: {
    type: Number,
    required: false,
  },
  fitnessGoal: {
    type: String,
    enum: ['Muscle Building', 'Weight Loss', 'Maintain Weight'],
    required: false,
  },
});

const Details = mongoose.model('Details', detailsSchema);

module.exports = Details;