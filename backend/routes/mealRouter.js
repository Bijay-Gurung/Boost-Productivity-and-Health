const multer = require('multer');
const Recipe = require('../models/meals');
const express = require('express');
const router = express.Router();
const path = require('path');

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, 'uploads');
    },
    filename: (req, file, cb) => {
        cb(null, `${Date.now()}-${file.originalname}`);
    }
});

const upload = multer({ storage: storage });

router.post('/', upload.single('image'), async (req, res) => {
    try {
        const { recipe, author, date, cookingTime, calories, carbs, protein, fat, nutInfo, ingredient, process, details, category, isVegan} = req.body;
        const imagePath = req.file ? req.file.path : '';

        const newRecipe = new Recipe({
            recipe,
            author,
            date,
            cookingTime,
            calories,
            carbs,
            protein,
            fat,
            nutInfo,
            ingredient,
            process,
            image: imagePath,
            category,
            details,
            isVegan
        });

        await newRecipe.save();
        console.log('Recipe saved:', newRecipe);
        res.status(201).json(newRecipe);
    } catch (error) {
        console.error('Error saving recipe:', error);
        res.status(400).json({ message: 'Error saving recipe', error: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
      const { category, search, isVegan } = req.query;
      const query = {};
  
      if (category) query.category = category;
      if (search) query.recipe = { $regex: search, $options: 'i' };
      if (isVegan !== undefined) query.isVegan = isVegan === 'true';
  
      const recipes = await Recipe.find(query);
      res.json(recipes);
    } catch (error) {
      res.status(500).json({ message: 'Server error', error: error.message });
    }
  });

router.put('/:id', upload.single('image'), async (req, res) => {
    try {
        const updates = {
            ...req.body,
            ...(req.file && { image: req.file.path }),
            date: new Date(req.body.date)
        };

        // Convert string boolean to actual boolean
        if (typeof updates.isVegan === 'string') {
            updates.isVegan = updates.isVegan === 'true';
        }

        const updatedMeal = await Recipe.findByIdAndUpdate(
            req.params.id,
            updates,
            { new: true, runValidators: true }
        );

        if (!updatedMeal) {
            return res.status(404).json({ message: 'Meal not found' });
        }
        res.json(updatedMeal);
    } catch (error) {
        console.error('Error updating recipe:', error);
        res.status(400).json({ message: 'Error updating recipe', error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
        const deletedMeal = await Recipe.findByIdAndDelete(req.params.id);
        if (!deletedMeal) {
            return res.status(404).json({ message: 'Meal not found' });
        }
        res.json({ message: 'Meal deleted successfully' });
    } catch (error) {
        console.error('Error deleting recipe:', error);
        res.status(500).json({ message: 'Error deleting recipe', error: error.message });
    }
});

module.exports = router;