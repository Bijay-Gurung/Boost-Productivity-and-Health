const express = require('express');
const router = express.Router();
const Details = require('../models/detailsSchema');

router.post('/', async (req, res) => {
  const { age, height, weight, gender } = req.body;

  if (!age || !height || !weight || !gender) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const newDetails = new Details({
      age,
      height,
      weight,
      gender,
    });

    await newDetails.save();
    res.status(201).json({ message: 'Details saved successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

router.post('/fitness', async (req, res) => {
  const { age, height, weight, gender, bmi, bmr, fitnessGoal } = req.body;

  if (!age || !height || !weight || !gender || !bmi || !bmr || !fitnessGoal) {
    return res.status(400).json({ message: 'All fields are required' });
  }

  try {
    const newFitnessData = new Details({
      age,
      height,
      weight,
      gender,
      bmi,
      bmr,
      fitnessGoal,
    });

    await newFitnessData.save();
    res.status(201).json({ message: 'Fitness data saved successfully' });
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

router.get('/', async (req, res) => {
  try {
    const details = await Details.find();
    res.status(200).json(details);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

router.get('/:id', async (req, res) => {
  try {
    const detail = await Details.findById(req.params.id);
    if (!detail) {
      return res.status(404).json({ message: 'Details not found' });
    }
    res.status(200).json(detail);
  } catch (error) {
    res.status(500).json({ message: 'Server error', error });
  }
});

module.exports = router;