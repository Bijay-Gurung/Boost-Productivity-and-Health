const express = require('express');
const bcrypt = require('bcrypt');
const adminSignup = require('../models/adminSignupSchema');
const router = express.Router();

router.post('/', async (req, res) => {
    try {
        const { email, password } = req.body;

        const admin = await adminSignup.findOne({ email });
        if (!admin) {
            return res.status(400).json({ message: 'admin not found' });
        }

        const isMatch = await bcrypt.compare(password, admin.password);
        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        res.status(200).json({ message: 'Login successful', admin });
    } catch (error) {
        console.error('Error during login:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

module.exports = router;