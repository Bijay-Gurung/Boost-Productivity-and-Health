const mongoose = require('mongoose');

const mealPlanSchema = new mongoose.Schema({
  user: { 
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  date: {
    type: Date,
    required: true
  },
  meals: [{
    mealType: {
      type: String,
      enum: ['breakfast', 'lunch', 'dinner', 'snack'],
      required: true
    },
    meal: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Recipe',
      required: true
    }
  }]
});

module.exports = mongoose.model('MealPlan', mealPlanSchema);