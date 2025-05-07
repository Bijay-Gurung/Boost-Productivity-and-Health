const multer = require('multer');
const Recipe = require('../models/meals');
const express = require('express');
const router = express.Router();
const path = require('path');
const auth = require('../middleware/auth');

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
        const { recipe, author, date, cookingTime, calories, carbs, protein, fat, nutInfo, ingredient, process, details, category, isVegetarian} = req.body;
        const imagePath = req.file ? req.file.path : '';

        const newRecipe = new Recipe({
            recipe,
            author,
            date,
            cookingTime,
            calories: parseFloat(calories),
            carbs: parseFloat(carbs),
            protein: parseFloat(protein),
            fat: parseFloat(fat),
            nutInfo,
            ingredient,
            process,
            image: imagePath,
            category,
            details,
            isVegetarian,
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
      const { category, search, dietaryPreference } = req.query;
      const query = {};
  
      if (category) query.category = { $regex: new RegExp(category, 'i') };
      if (search) query.recipe = { $regex: search, $options: 'i' };
      if (dietaryPreference !== undefined) {
        const isVegetarian = dietaryPreference.toLowerCase() === 'true';
        console.log('Received dietaryPreference:', dietaryPreference);
        console.log('Converted isVegetarian:', isVegetarian);
        query.isVegetarian = isVegetarian;
      }
  
      console.log('Final query:', JSON.stringify(query));
      const recipes = await Recipe.find(query);
      console.log('Found recipes:', recipes.length);
      console.log('Sample recipe:', recipes.length > 0 ? {
        recipe: recipes[0].recipe,
        isVegetarian: recipes[0].isVegetarian
      } : 'No recipes found');
      
      res.json(recipes);
    } catch (error) {
      console.error('Error in GET /:', error);
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

        if (typeof updates.isVegetarian === 'string') {
            updates.isVegetarian = updates.isVegetarian === 'true';
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