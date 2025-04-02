const mongoose = require('mongoose');

const adminSignupSchema = new mongoose.Schema({
    adminName: { type: String, required: true },
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true },
    otp: { type: String },
    otpExpires: { type: Date }
});

module.exports = mongoose.model("adminSignup", adminSignupSchema);
