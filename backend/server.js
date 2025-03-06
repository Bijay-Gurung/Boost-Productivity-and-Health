require('dotenv').config();
const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const path = require('path');

const signupRouter = require('./routes/signupRoutes.js');
const loginRouter = require('./routes/loginRoutes.js');
const taskManagerRouter = require('./routes/taskManagerRoutes.js');
const PasswordResetRouter = require('./routes/passwordResetRoutes.js');
const detailsRoutes = require('./routes/detailsRoutes.js');
const exerciseRoutes = require('./routes/exerciseRoutes.js');

const app = express();
const PORT = 4000;

const uploadsDir = path.join(__dirname, 'uploads');

app.use(bodyParser.json());
app.use('/uploads', express.static(uploadsDir));

app.use('/signup', signupRouter);
app.use('/login', loginRouter);
app.use('/taskManager', taskManagerRouter);
app.use('/forgot-password', PasswordResetRouter);
app.use('/details', detailsRoutes);
app.use('/exercises', exerciseRoutes);

mongoose.connect('mongodb://localhost:27017/BoostProductivityAndHealth')
  .then(() => console.log('Connected to MongoDB'))
  .catch(err => console.error('Could not Connect to MongoDB', err));

app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
});