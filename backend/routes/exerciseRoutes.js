const express = require('express');
const router = express.Router();
const Exercise = require('../models/exercise');
const ExerciseCategory = require('../models/exerciseCategory');

router.post('/categories', async (req, res) => {
  const { name, parentCategory, type } = req.body;
  const category = new ExerciseCategory({ name, parentCategory, type });
  await category.save();
  res.status(201).send(category);
});

router.post('/exercises', async (req, res) => {
  const { name, category, caloriesPerSet, steps, media } = req.body;
  const exercise = new Exercise({ name, category, caloriesPerSet, steps, media });
  await exercise.save();
  res.status(201).send(exercise);
});

router.get('/categories', async (req, res) => {
  const categories = await ExerciseCategory.find().populate('parentCategory');
  res.send(categories);
});

router.get('/exercises/:categoryId', async (req, res) => {
  const exercises = await Exercise.find({ category: req.params.categoryId });
  res.send(exercises);
});

module.exports = router;