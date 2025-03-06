const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const Exercise = require('../models/exercise');
const ExerciseCategory = require('../models/exerciseCategory');

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  }
});

const upload = multer({ storage });

router.post('/categories', async (req, res) => {
  try {
    const { name, parentCategory, type } = req.body;
    const category = new ExerciseCategory({ name, parentCategory, type });
    await category.save();
    res.status(201).json({ message: "Category added successfully", category });
  } catch (error) {
    res.status(500).json({ message: "Error adding category", error });
  }
});

router.post('/exercises', upload.single('media'), async (req, res) => {
  try {
    const { name, category, caloriesPerSet, steps } = req.body;
    const media = req.file ? req.file.path : null;

    const exercise = new Exercise({ name, category, caloriesPerSet, steps, media });
    await exercise.save();
    
    res.status(201).json({ message: "Exercise added successfully", exercise });
  } catch (error) {
    res.status(500).json({ message: "Error adding exercise", error });
  }
});

router.get('/exercises', async (req, res) => {
    try {
      const exercises = await Exercise.find().populate('category');
      res.json(exercises);
    } catch (error) {
      res.status(500).json({ message: "Error fetching exercises", error });
    }
  });
  

router.get('/categories', async (req, res) => {
  try {
    const categories = await ExerciseCategory.find().populate('parentCategory');
    res.json(categories);
  } catch (error) {
    res.status(500).json({ message: "Error fetching categories", error });
  }
});

router.get('/exercises/:categoryId', async (req, res) => {
  try {
    const exercises = await Exercise.find({ category: req.params.categoryId });
    res.json(exercises);
  } catch (error) {
    res.status(500).json({ message: "Error fetching exercises", error });
  }
});

module.exports = router;
