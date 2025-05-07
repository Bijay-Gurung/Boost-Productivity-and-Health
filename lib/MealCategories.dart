import 'package:flutter/material.dart';
import 'taskManagerScreen.dart';
import 'details.dart';
import 'home.dart';
import 'MealPlanner.dart';
import 'MealListScreen.dart';

class MealCategoriesScreen extends StatelessWidget {
  final String userName;
  final String userId;
  final bool isVegetarian;

  const MealCategoriesScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.isVegetarian,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Categories'),
      ),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          padding: const EdgeInsets.all(16.0),
          mainAxisSpacing: 2.0,
          crossAxisSpacing: 2.0,
          childAspectRatio: 0.8,
          children: [
            _buildMealCard(context, 'Breakfast', 'assets/Breakfast.jpg'),
            _buildMealCard(context, 'Lunch', 'assets/Meal.jpg'),
            _buildMealCard(context, 'Dinner', 'assets/Dinner.jpg'),
          ],
        ),
      ),
    );
  }

  Widget _buildMealCard(BuildContext context, String title, String imagePath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealListScreen(
              userId: userId,
              userName: userName,
              dietaryPreference: isVegetarian ? DietaryPreference.vegetarian : DietaryPreference.nonVegetarian,
              mealCategory: _getMealCategory(title),
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
              child: Image.asset(
                imagePath,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMealList(BuildContext context, String category) {
    Navigator.pushNamed(
      context,
      '/mealList',
      arguments: {
        'userName': userName,
        'userId': userId,
        'dietaryPreference': isVegetarian ? DietaryPreference.vegetarian : DietaryPreference.nonVegetarian,
        'mealCategory': _getMealCategory(category),
      },
    );
  }

  MealCategory _getMealCategory(String category) {
    switch (category) {
      case 'Breakfast':
        return MealCategory.breakfast;
      case 'Lunch':
        return MealCategory.lunch;
      case 'Dinner':
        return MealCategory.dinner;
      default:
        return MealCategory.lunch;
    }
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(
                  userName: userName,
                  email: '',
                  userId: userId,
                )),
              );
            },
            child: const Text('Home'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const TaskManagerScreen()),
              );
            },
            child: const Text('TaskManager'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => Details(userName: userName, userId: userId,)),
              );
            },
            child: const Text('Exercise'),
          ),
        ],
      ),
    );
  }
}