const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const User = require('../models/userSchema');
const sendEmail = require('../utils/sendEmail');
const crypto = require('crypto');

const generateOTP = () => Math.floor(1000 + Math.random() * 9000).toString();

router.post("/forgot-password", async (req, res) => {
  const { email } = req.body;
  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ message: "User not found" });

  const otp = generateOTP();
  const otpExpires = new Date(Date.now() + 7 * 60 * 1000);

  user.otp = otp;
  user.otpExpires = otpExpires;
  await user.save();

  const emailSent = await sendEmail(email, "Password Reset OTP", `Your OTP: ${otp}`);
  if (emailSent) return res.json({ message: "OTP sent successfully" });

  res.status(500).json({ message: "Failed to send OTP" });
});

router.post("/verify-otp", async (req, res) => {
  const { email, otp } = req.body;
  const user = await User.findOne({ email, otp, otpExpires: { $gt: Date.now() } });

  if (!user) return res.status(400).json({ message: "Invalid or expired OTP" });

  user.otp = null; 
  user.otpExpires = null;
  await user.save();
  
  res.json({ message: "OTP verified successfully" });
});

router.post("/reset-password", async (req, res) => {
  const { email, newPassword, confirmPassword } = req.body;
  
  if (newPassword !== confirmPassword) {
    return res.status(400).json({ message: "Passwords do not match" });
  }

  const user = await User.findOne({ email });
  if (!user) return res.status(400).json({ message: "User not found" });

  const hashedPassword = await bcrypt.hash(newPassword, 10); // Hash password
  user.password = hashedPassword;
  await user.save();

  res.json({ message: "Password reset successfully" });
});


module.exports = router;