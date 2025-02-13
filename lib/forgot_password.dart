import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  TextEditingController emailController = TextEditingController();
  bool otpSent = false;

  Future<void> sendOTP() async {
    final response = await http.post(
      Uri.parse("http://192.168.1.74:4000/forgot-password"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": emailController.text}),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      setState(() => otpSent = true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Forgot Password")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: "Enter your email"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: sendOTP,
              child: Text("Send OTP"),
            ),
            if (otpSent) Text("OTP sent! Check your email."),
          ],
        ),
      ),
    );
  }
}
