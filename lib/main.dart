import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Login.dart';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';
import 'next.dart';
import 'DietaryPreferences.dart';
void main() {
  runApp(const MyApp());
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
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return HomePage(userName: args['userName']!, email: args['email']!);
        },
        '/taskManager': (context) => TaskManagerScreen(),
        '/details': (context) => Details(),
        '/dietaryPreferences': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return DietaryPreferencesScreen(userName: args['userName']!,);
        },
        '/next': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return NextPage(
            age: args['age'],
            height: args['height'],
            weight: args['weight'],
            gender: args['gender'],
          );
        },
      },
    );
  }
}