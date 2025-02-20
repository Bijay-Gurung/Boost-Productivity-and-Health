const express = require('express');
const bcrypt = require('bcrypt');
const Signup = require('../models/signupSchema');
const router = express.Router();
const crypto = require('crypto');
const nodemailer = require('nodemailer');

router.post('/', async (req, res) => {
    try {
        const { email, password } = req.body;
        console.log('Received login request:', { email, password });

        const user = await Signup.findOne({ email });
        if (!user) {
            console.log('User not found for email:', email);
            return res.status(400).json({ message: 'User not found' });
        }

        console.log('User found:', user);

        console.log('Plaintext password:', password);
        console.log('Hashed password from DB:', user.password);

        const isMatch = await bcrypt.compare(password, user.password);
        console.log('Password match result:', isMatch);

        if (!isMatch) {
            return res.status(400).json({ message: 'Invalid credentials' });
        }

        res.status(200).json({ message: 'Login successful', user: {userName: user.userName, email: user.email} });
    } catch (error) {
        console.error('Error during login:', error);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

module.exports = router;
