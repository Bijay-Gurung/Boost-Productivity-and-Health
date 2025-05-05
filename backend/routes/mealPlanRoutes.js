const express = require('express');
const router = express.Router();
const MealPlan = require('../models/mealPlan');
const auth = require('../middleware/auth');

router.post('/', auth, async (req, res) => {
  try {
    const { date, meals } = req.body;
    
    // Delete existing plan for the date
    await MealPlan.deleteOne({ user: req.user._id, date });

    // Create new plan
    const mealPlan = new MealPlan({
      user: req.user._id,
      date,
      meals
    });

    await mealPlan.save();
    res.status(201).send(mealPlan);
  } catch (error) {
    res.status(400).send(error.message);
  }
});

// Get weekly plans

// In mealPlanRoutes.js
router.get('/', auth, async (req, res) => {
  try {
    const { start, end } = req.query;
    const plans = await MealPlan.find({
      user: req.user._id,
      date: { $gte: new Date(start), $lte: new Date(end) }
    }).populate('meals.meal');
    res.send(plans);
  } catch (error) {
    res.status(500).send(error.message);
  }
});
module.exports = router;