import 'package:flutter/material.dart';
import 'Signup.dart';
import 'Login.dart';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';
import 'next.dart';
import 'DietaryPreferences.dart';
import 'MealCategories.dart';
import 'MealListScreen.dart';
import 'MealDetailsScreen.dart';
import 'MealPlanner.dart';

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
        '/details': (context){
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, String>;
          return Details(userName: args['userName']!,);
        },

        '/dietaryPreferences': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DietaryPreferencesScreen(userName: args['userName']!);
        },
        
        '/mealCategories': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MealCategoriesScreen(
            userName: args['userName']!,
            isVegan: args['isVegan'] as bool,
          );
        },

        '/mealList': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MealListScreen(
            userName: args['userName']!,
            category: args['category']!,
            isVegan: args['isVegan'] as bool,
          );
        },

        '/mealDetail': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MealDetailsScreen(
            userName: args['userName']!,
            meal: args['meal']!,
          );
        },

        '/next': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return NextPage(
            age: args['age'] as int,
            height: args['height'] as int,
            weight: args['weight'] as int,
            gender: args['gender'] as String,
            userName: args['userName'] as String,
          );
        },

        '/mealPlanner': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return MealPlannerScreen(
            userName: args['userName']!,
            userId: args['userId']!,
          );
        },
      },
    );
  }
}