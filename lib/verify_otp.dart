import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class VerifyOTPScreen extends StatefulWidget {
  final String email;
  VerifyOTPScreen(this.email);

  @override
  _VerifyOTPScreenState createState() => _VerifyOTPScreenState();
}

class _VerifyOTPScreenState extends State<VerifyOTPScreen> {
  TextEditingController otpController = TextEditingController();

  Future<void> verifyOTP() async {
    final response = await http.post(
      Uri.parse("http://192.168.1.74:4000/verify-otp"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": widget.email, "otp": otpController.text}),
    );

    final responseData = jsonDecode(response.body);
    if (response.statusCode == 200) {
      Navigator.pushReplacementNamed(context, "/reset-password", arguments: widget.email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(responseData['message'])));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: otpController, decoration: InputDecoration(labelText: "Enter OTP")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: verifyOTP, child: Text("Verify OTP")),
          ],
        ),
      ),
    );
  }
}
