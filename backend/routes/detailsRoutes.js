const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Details = require('../models/detailsSchema');

router.post('/', auth, async (req, res) => {
  const { age, height, weight, gender } = req.body;
  
  if (!age || !height || !weight || !gender) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const details = await Details.findOneAndUpdate(
      { user: req.user.userId },
      {
        user: req.user.userId,
        age,
        height,
        weight,
        gender
      },
      { new: true, upsert: true }
    );

    res.status(200).json({ message: 'Details saved', details });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

router.post('/fitness', auth, async (req, res) => {
  const { bmi, bmr, fitnessGoal } = req.body;

  try {
    const details = await Details.findOneAndUpdate(
      { user: req.user.userId },
      { 
        bmi,
        bmr,
        fitnessGoal,
        $setOnInsert: {
          user: req.user.userId,
          age: 0,
          height: 0,
          weight: 0,
          gender: 'Unknown'
        }
      },
      { new: true, upsert: true }
    );

    res.status(200).json({ message: 'Fitness data saved', details });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Get current user's details
router.get('/', auth, async (req, res) => {
  try {
    const details = await Details.findOne({ user: req.user.username });
    if (!details) return res.status(404).json({ message: 'Details not found' });
    
    res.status(200).json(details);
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

module.exports = router;