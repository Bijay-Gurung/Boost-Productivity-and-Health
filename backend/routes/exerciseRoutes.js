const express = require("express");
const router = express.Router();
const Exercise = require('../models/exercise');
const multer = require("multer");
const path = require("path");
const storage = multer.diskStorage({
    destination: function (req, file, cb) {
        cb(null, "uploads/");
    },
    filename: function (req, file, cb) {
        const uniqueSuffix = Date.now() + "-" + file.originalname;
        cb(null, uniqueSuffix);
    }
});

const upload = multer({ storage: storage });

router.post("/", upload.single("image"), async (req, res) => {
    try {
        const {
            name,
            category,
            muscleGroup,
            duration,
            caloriesBurned,
            intensity,
            steps,
            recommendedFor
        } = req.body;

        const image = req.file ? req.file.path : "";

        const exercise = new Exercise({
            name,
            category,
            muscleGroup,
            duration,
            caloriesBurned,
            intensity,
            steps,
            image,
            recommendedFor: recommendedFor ? JSON.parse(recommendedFor) : undefined
        });

        await exercise.save();
        res.status(201).json({ message: "Exercise created successfully", exercise });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: "Failed to create exercise" });
    }
});

router.get("/", async (req, res) => {
    try {
        const exercises = await Exercise.find();
        res.status(200).json(exercises);
    } catch (err) {
        res.status(500).json({ error: "Failed to fetch exercises" });
    }
});

router.get("/:id", async (req, res) => {
    try {
        const exercise = await Exercise.findById(req.params.id);
        if (!exercise) return res.status(404).json({ error: "Exercise not found" });

        res.status(200).json(exercise);
    } catch (err) {
        res.status(500).json({ error: "Error fetching exercise" });
    }
});

router.put("/:id", upload.single("image"), async (req, res) => {
    try {
        const image = req.file ? req.file.path : undefined;
        const updatedData = {
            ...req.body,
            ...(image && { image }),
            ...(req.body.recommendedFor && { recommendedFor: JSON.parse(req.body.recommendedFor) })
        };

        const updatedExercise = await Exercise.findByIdAndUpdate(req.params.id, updatedData, { new: true });
        if (!updatedExercise) return res.status(404).json({ error: "Exercise not found" });

        res.status(200).json({ message: "Exercise updated", exercise: updatedExercise });
    } catch (err) {
        res.status(500).json({ error: "Error updating exercise" });
    }
});

router.delete("/:id", async (req, res) => {
    try {
        const deleted = await Exercise.findByIdAndDelete(req.params.id);
        if (!deleted) return res.status(404).json({ error: "Exercise not found" });

        res.status(200).json({ message: "Exercise deleted" });
    } catch (err) {
        res.status(500).json({ error: "Error deleting exercise" });
    }
});

module.exports = router;
