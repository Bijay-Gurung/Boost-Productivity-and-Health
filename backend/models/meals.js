const mongoose = require('mongoose');

const recipe_Schema = new mongoose.Schema({
    recipe: {
        type: String,
        required: true,
    },
    author: {
        type: String,
        required: true,
    },
    date: {
        type: Date,
        required: true,
    },
    cookingTime: {
        type: String,
        required: true,
    },
    calories: {
        type: String,
        required: true,
    },
    carbs: {
        type: String,
        required: true,
    },
    protein: {
        type: String,
        required: true,
    },
    fat: {
        type: String,
        required: true,
    },
    nutInfo: {
        type: String,
        required: true,
    },
    ingredient: {
        type: String,
        required: true,
    },
    process: {
        type: String,
        required: true,
    },
    image: {
        type: String,
        required: true,
    },
    details: {
        type: String,
        required: true,
    },
    category: {
        type: String,
        required: true,
    },
    isVegan: {
        type: Boolean,
        required: true,
    }

});

module.exports = mongoose.model("Recipe", recipe_Schema);