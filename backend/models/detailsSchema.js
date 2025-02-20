const mongoose = require('mongoose');

const detailsSchema = new mongoose.Schema({
  age: {
    type: Number,
    required: true,
  },
  height: {
    type: Number,
    required: true,
  },
  weight: {
    type: Number,
    required: true,
  },
  gender: {
    type: String,
    enum: ['Male', 'Female', 'Other'],
    required: true,
  },
});

const Details = mongoose.model('Details', detailsSchema);

module.exports = Details;
