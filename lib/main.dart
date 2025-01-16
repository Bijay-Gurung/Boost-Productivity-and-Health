import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boost Productivity and Health',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Signup(),
    );
  }
}
