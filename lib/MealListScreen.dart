import 'package:flutter/material.dart';
import 'package:fyp/MealDetailsScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';

class MealListScreen extends StatefulWidget {
  final String userName;
  final String category;
  final bool isVegan;

  const MealListScreen({
    super.key,
    required this.userName,
    required this.category,
    required this.isVegan,
  });

  @override
  State<MealListScreen> createState() => _MealListScreenState();
}

class _MealListScreenState extends State<MealListScreen> {
  List<dynamic> _meals = [];
  List<dynamic> _filteredMeals = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMeals({String query = ''}) async {
    try {
      final response = await http.get(
        Uri.parse(
        'http://192.168.1.74:4000/meal?'
        'category=${widget.category}&'
        'isVegan=${widget.isVegan}&'
        'search=$query'
        ),
      );

      if (response.statusCode == 200) {
        setState(() {
          _meals = json.decode(response.body);
          _filteredMeals = _meals;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isEmpty) {
        setState(() => _filteredMeals = _meals);
      } else {
        setState(() {
          _filteredMeals = _meals.where((meal) {
            final name = meal['recipe'].toString().toLowerCase();
            return name.contains(query.toLowerCase());
          }).toList();
        });
      }
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
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
                  widget.userName,
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search meals...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _filteredMeals.length,
                    itemBuilder: (context, index) {
                      final meal = _filteredMeals[index];
                      return _buildMealCard(meal);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildMealCard(Map<String, dynamic> meal) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(
                        'http://192.168.1.74:4000/${meal['image']}',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal['recipe'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cooking Time: ${meal['cookingTime']}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Fat: ${meal['fat']}',
                            style: _macroTextStyle(),
                          ),
                          Text(
                            'Protein: ${meal['protein']}',
                            style: _macroTextStyle(),
                          ),
                          Text(
                            'Carbs: ${meal['carbs']}',
                            style: _macroTextStyle(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Calories: ${meal['calories']}',
                  style: _macroTextStyle(),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailsScreen(
                          userName: widget.userName,
                          meal: meal,
                        ),
                      ),
                    );
                  },
                  child: const Text('More'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _macroTextStyle() {
    return const TextStyle(
      fontSize: 14,
      color: Colors.blueGrey,
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.black,
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage(
                  userName: widget.userName,
                  email: '',
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
                MaterialPageRoute(builder: (context) => Details(userName: widget.userName),),
              );
            },
            child: const Text('Exercise'),
          ),
        ],
      ),
    );
  }

}