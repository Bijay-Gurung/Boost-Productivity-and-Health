import 'package:flutter/material.dart';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';

class MealDetailsScreen extends StatelessWidget {
  final String userName;
  final String userId;
  final Map<String, dynamic> meal;

  const MealDetailsScreen({
    super.key,
    required this.userName,
    required this.userId,
    required this.meal,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  void _navigateToMealPlanner(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/mealPlanner',
      arguments: {
        'userName': userName,
        'meal': meal,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                  ),
                ),
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal Image
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(
                  'http://localhost:4000/${meal['image']}',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Meal Name
          Text(
            meal['recipe'],
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          // Cooking Time and Calories
          Row(
            children: [
              Icon(Icons.timer, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('Cooking Time: ${meal['cookingTime']}'),
              const SizedBox(width: 16),
              Icon(Icons.local_fire_department, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${meal['calories']} Calories'),
            ],
          ),
          const SizedBox(height: 20),
          // Macronutrients
          _buildSectionTitle('Macronutrients'),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNutritionItem('Protein', '${meal['protein']}g'),
              _buildNutritionItem('Carbs', '${meal['carbs']}g'),
              _buildNutritionItem('Fat', '${meal['fat']}g'),
            ],
          ),
          const SizedBox(height: 20),
          // Ingredients
          _buildSectionTitle('Ingredients'),
          const SizedBox(height: 10),
          Column(
            children: (meal['ingredient'] as String)
            .split('\n')
            .where((i) => i.isNotEmpty)
            .map((ingredient) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.fiber_manual_record, size: 12),
                  const SizedBox(width: 8),
                  Text(ingredient.trim()),
                ],
              ),
            ))
            .toList(),
          ),
          Text(meal['ingredient']),
          const SizedBox(height: 20),
          // Procedure
          _buildSectionTitle('Cooking Procedure'),
          const SizedBox(height: 10),
          Text(meal['process']),
        ],
      ),
    ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.teal,
      ),
    );
  }

  Widget _buildNutritionItem(String label, dynamic value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: const TextStyle(
            fontSize: 16,
            color: Colors.blueGrey,
          ),
        ),
      ],
    );
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
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomePage(
                    userName: userName,
                    email: '',
                    userId: userId,
                  ),
                ),
              );
            },
            child: const Text('Home'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const TaskManagerScreen(),
                ),
              );
            },
            child: const Text('TaskManager'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => Details(userName: userName, userId: userId,),
                ),
              );
            },
            child: const Text('Exercise'),
          ),
        ],
      ),
    );
  }
}