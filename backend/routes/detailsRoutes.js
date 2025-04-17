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
      { user: req.user.username },
      {
        user: req.user.username,
        age,
        height,
        weight,
        gender
      },
      { new: true, upsert: true }
    );

    res.status(200).json({
      message: 'Details saved successfully',
      details
    });
  } catch (error) {
    console.error(error);
    res.status(500).json({ message: 'Server error', error: error.message });
  }
});

// Save fitness data
router.post('/fitness', auth, async (req, res) => {
  const { bmi, bmr, fitnessGoal } = req.body;

  if (!bmi || !bmr || !fitnessGoal) {
    return res.status(400).json({ message: 'All fitness fields are required' });
  }

  try {
    const details = await Details.findOneAndUpdate(
      { user: req.user.username },
      {
        bmi,
        bmr,
        fitnessGoal
      },
      { new: true }
    );

    if (!details) {
      return res.status(404).json({ message: 'User details not found' });
    }

    res.status(200).json({
      message: 'Fitness data saved successfully',
      details
    });
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