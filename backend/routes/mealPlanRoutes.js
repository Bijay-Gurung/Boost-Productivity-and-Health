const express = require('express');
const router = express.Router();
const MealPlan = require('../models/mealPlan');
const auth = require('../middleware/auth');

router.post('/', auth, async (req, res) => {
  try {
    const { date, meals } = req.body;
    
    // Delete existing plan for the date

    // Create new plan
    const mealPlan = await MealPlan.findOneAndUpdate(
      { 
        user: req.user._id,
        date: new Date(date)
      },
      {
        $set: { meals }
      },
      {
        new: true,
        upsert: true,
        runValidators: true
      }
    ).populate('meals.meal');

    res.status(201).send(mealPlan);
  } catch (error) {
    console.error('Meal plan error:', error);
    res.status(400).send({ message: error.message });
  }
});

router.get('/', auth, async (req, res) => {
  try {
    const { start, end } = req.query;
    const plans = await MealPlan.find({
      user: req.user._id,
      date: { 
        $gte: new Date(start), 
        $lte: new Date(end) 
      }
    }).populate({
      path: 'meals.meal',
      model: 'Recipe'
    });
    
    res.send(plans);
  } catch (error) {
    res.status(500).send({ message: error.message });
  }
});

module.exports = router;