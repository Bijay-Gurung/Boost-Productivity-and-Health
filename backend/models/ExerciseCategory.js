const mongoose = require('mongoose');

const ExerciseCategorySchema = new mongoose.Schema({
  name: { type: String, required: true },
  parentCategory: { type: mongoose.Schema.Types.ObjectId, ref: 'ExerciseCategory' },
  type: { type: String, enum: ['Cardio', 'Strength'] }
});

module.exports = mongoose.model('ExerciseCategory', ExerciseCategorySchema);