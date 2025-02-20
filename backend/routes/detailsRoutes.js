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

module.exports = router;
