import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Login.dart';
import 'home.dart';
import 'taskManagerScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Boost Productivity and Health',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/', 
      routes: {
        '/': (context) => const Signup(),
        '/login': (context) => const Login(),
        '/home': (context) => HomePage(),
        '/taskManager': (context) => TaskManagerScreen(),
      },
    );
  }
}
