const mongoose = require("mongoose");

const exerciseSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true
    },
    category: {
        type: String, // e.g., Strength, Cardio, Flexibility
        required: true
    },
    muscleGroup: {
        type: String,
        required: true
    },
    duration: {
        type: Number, // in minutes
        required: true
    },
    caloriesBurned: {
        type: Number,
        required: true
    },
    intensity: {
        type: String, // Low, Medium, High
        required: true
    },
    steps: {
        type: String,
        required: true
    },
    image: {
        type: String // image file path
    },
    recommendedFor: {
        bmiRange: {
            min: Number,
            max: Number
        },
        ageRange: {
            min: Number,
            max: Number
        },
        gender: {
            type: String,
            enum: ['Male', 'Female', 'Other', 'Any'],
            default: 'Any'
        }
    },
    dateAdded: {
        type: Date,
        default: Date.now
    }
});

module.exports = mongoose.model("Exercise", exerciseSchema);
