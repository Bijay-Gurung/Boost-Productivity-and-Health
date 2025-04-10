const express = require('express');
const Signup = require('../models/signupSchema');
const bcrypt = require('bcrypt');
const router = express.Router();

router.post('/', async (req, res) => {
    try {
        if (!req.body.password) {
            return res.status(400).json({ message: 'Password is required' });
        }

        const hashedPassword = await bcrypt.hash(req.body.password, 10);

        const signup = new Signup({
            userName: req.body.userName,
            email: req.body.email,
            password: hashedPassword,
        });

        await signup.save();
        console.log('Signup saved:', signup);
        res.status(201).json(signup);
    } catch (error) {
        console.log('Error while signup:', error);
        res.status(400).json({ message: 'Error while signup', error: error.message });
    }
});

router.get('/', async (req, res) => {
    try {
        const signups = await Signup.find();
        res.json(signups);
    } catch (error) {
        console.error('Error retrieving signup data:', error);
        res.status(500).json({ message: 'Error retrieving signup data', error: error.message });
    }
});

router.delete('/:id', async (req, res) => {
    try {
      console.log("Delete request for ID:", req.params.id);
      const user = await Signup.findByIdAndDelete(req.params.id);
      
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }
  
      res.status(200).json({ message: 'User deleted successfully' });
    } catch (error) {
      console.error('Error deleting user:', error);
      res.status(500).json({ message: 'Server error' });
    }
  });

router.put('/:id', async (req, res) => {
    try {
        const updatedUser = await Signup.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(updatedUser);
    } catch (error) {
        res.status(400).json({ message: 'Error updating user', error: error.message });
    }
});

module.exports = router;