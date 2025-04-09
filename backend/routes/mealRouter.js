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
    try{
        const recipes = await Recipe.find();
        res.json(recipes);
    }catch (error){
        console.error('Error retrieving recipes:', error);
        res.status(500).json({message: 'Error retrieving recipes', error: error.message});
    }
});

module.exports = router;