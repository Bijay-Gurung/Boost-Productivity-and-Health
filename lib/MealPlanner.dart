import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';
import 'mealListScreen.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

enum DietaryPreference { vegetarian, nonVegetarian }
enum MealCategory { breakfast, lunch, dinner }

class MealPlannerScreen extends StatefulWidget {
  final String userName;
  final String userId;

  const MealPlannerScreen({
    super.key,
    required this.userName,
    required this.userId,
  });

  @override
  _MealPlannerScreenState createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;
  final CalendarFormat _calendarFormat = CalendarFormat.week;
  Map<DateTime, List<Meal>> _meals = {};
  List<Meal> _availableMeals = [];
  bool _isLoading = false;
  String? _error;
  
  // New state variables for filters
  DietaryPreference _selectedDietaryPreference = DietaryPreference.vegetarian;
  MealCategory _selectedMealCategory = MealCategory.breakfast;
  bool _showFilters = false;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _fetchMealPlan();
    _fetchAvailableMeals();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    if (hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  Future<void> _fetchMealPlan() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await storage.read(key: 'jwtToken');

      final response = await http.get(
        Uri.parse(
          'http://localhost:4000/mealPlan'
        ),
        headers: {
          'Authorization': 'Bearer $token'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        if (!mounted) return;
        setState(() {
          _meals = {
            for (var entry in data)
              DateTime.parse(entry['date']): [
                for (var meal in entry['meals']) Meal.fromJson(meal)
              ]
          };
        });
      } else {
        throw Exception('Failed to load meal plan');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchAvailableMeals() async {
    if (!mounted) return;
    try {
      final isVegetarian = _selectedDietaryPreference == DietaryPreference.vegetarian;
      print('Selected Dietary Preference: ${_selectedDietaryPreference}');
      print('Is Vegetarian: $isVegetarian');
      
      final response = await http.get(
        Uri.parse(
          'http://localhost:4000/meal?dietaryPreference=${isVegetarian.toString()}&category=${_selectedMealCategory.toString().split('.').last}',
        ),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        if (!mounted) return;
        setState(() {
          _availableMeals = (json.decode(response.body) as List)
              .map((x) => Meal.fromJson(x))
              .toList();
        });
        print('Available meals: ${_availableMeals.length}');
        print('First meal dietary preference: ${_availableMeals.first.dietaryPreference}');
      } else {
        throw Exception('Failed to load available meals');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
      });
      print('Error fetching meals: $e');
    }
  }

  Future<void> _saveMealPlan(DateTime date, Meal meal) async {
    // if (!mounted) return;
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/mealPlan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': widget.userId,
          'date': _selectedDay!.toIso8601String(),
          'meals': [{
            'mealType': _selectedMealCategory.toString().split('.').last,
            'mealId': meal.id,
          }]
        }),
      );

      if (response.statusCode == 201) {
        await _fetchMealPlan();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal plan saved successfully')),
        );
      } else {
        throw Exception('Failed to save meal plan');
      }
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error'),
          content: Text('Failed to save meal plan: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            )
          ],
        ),
      );
    }
  }

  String _getMealType(DateTime time) {
    final hour = time.hour;
    if (hour < 11) return 'breakfast';
    if (hour < 15) return 'lunch';
    if (hour < 19) return 'dinner';
    return 'snack';
  }

  Widget _buildFilterSection() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dietary Preference',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<DietaryPreference>(
                    title: const Text('Vegetarian'),
                    value: DietaryPreference.vegetarian,
                    groupValue: _selectedDietaryPreference,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedDietaryPreference = value!;
                      });
                      _navigateToMealList();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<DietaryPreference>(
                    title: const Text('Non-Vegetarian'),
                    value: DietaryPreference.nonVegetarian,
                    groupValue: _selectedDietaryPreference,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedDietaryPreference = value!;
                      });
                      _navigateToMealList();
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Meal Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<MealCategory>(
                    title: const Text('Breakfast'),
                    value: MealCategory.breakfast,
                    groupValue: _selectedMealCategory,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedMealCategory = value!;
                      });
                      _navigateToMealList();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MealCategory>(
                    title: const Text('Lunch'),
                    value: MealCategory.lunch,
                    groupValue: _selectedMealCategory,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedMealCategory = value!;
                      });
                      _navigateToMealList();
                    },
                  ),
                ),
                Expanded(
                  child: RadioListTile<MealCategory>(
                    title: const Text('Dinner'),
                    value: MealCategory.dinner,
                    groupValue: _selectedMealCategory,
                    onChanged: (value) {
                      if (!mounted) return;
                      setState(() {
                        _selectedMealCategory = value!;
                      });
                      _navigateToMealList();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToMealList() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MealListScreen(
          userId: widget.userId,
          userName: widget.userName,
          dietaryPreference: _selectedDietaryPreference,
          mealCategory: _selectedMealCategory,
        ),
      ),
    );

    if (result == true) {
      // Refresh meal plan if a meal was successfully planned
      _fetchMealPlan();
    }
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
              icon: Icon(_showFilters ? Icons.filter_list_off : Icons.filter_list),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _showFilters = !_showFilters;
                });
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: $_error',
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _fetchMealPlan();
                          _fetchAvailableMeals();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (_showFilters) _buildFilterSection(),
                    _buildCalendar(),
                    const SizedBox(height: 16),
                    _buildMealList(),
                  ],
                ),
      bottomNavigationBar: _buildFooter(context),
    );
  }

  Widget _buildCalendar() {
    return Card(
      margin: const EdgeInsets.all(8),
      child: TableCalendar(
        firstDay: DateTime.utc(2020),
        lastDay: DateTime.utc(2030),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        eventLoader: (day) => _meals[day] ?? [],
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          if (!mounted) return;
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          if (!mounted) return;
          _focusedDay = focusedDay;
          _fetchMealPlan();
        },
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            if (events.isNotEmpty) {
              return Positioned(
                right: 1,
                bottom: 1,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${events.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildMealList() {
    return Expanded(
      child: ReorderableWrap(
        spacing: 8.0,
        runSpacing: 8.0,
        padding: const EdgeInsets.all(8),
        children: _availableMeals
            .map((meal) => _buildDraggableMealCard(meal))
            .toList(),
        onReorder: (oldIndex, newIndex) {},
      ),
    );
  }

  Widget _buildDraggableMealCard(Meal meal) {
    return LongPressDraggable<Meal>(
      key: ValueKey(meal.id),
      data: meal,
      feedback: Material(
        child: MealCard(meal: meal, isDragging: true),
      ),
      childWhenDragging: MealCard(meal: meal, isDragging: true),
      child: DragTarget<Meal>(
        onAcceptWithDetails: (details) => _saveMealPlan(_selectedDay!, details.data),
        builder: (context, candidateData, rejectedData) {
          return MealCard(meal: meal);
        },
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1, // Meal Planner is the second tab
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.restaurant_menu),
          label: 'Meal Planner',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.task),
          label: 'Tasks',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'Exercise',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userName: widget.userName,
                  userId: widget.userId,
                  email: '',
                ),
              ),
            );
            break;
          case 1:
            // Already on Meal Planner
            break;
          case 2:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const TaskManagerScreen(),
              ),
            );
            break;
          case 3:
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Details(userName: widget.userName, userId: widget.userId,),
              ),
            );
            break;
        }
      },
    );
  }
}

class MealCard extends StatelessWidget {
  final Meal meal;
  final bool isDragging;

  const MealCard({super.key, required this.meal, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      color: isDragging ? Colors.grey[300] : null,
      elevation: isDragging ? 8 : 2,
      child: InkWell(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => MealDetailsSheet(meal: meal),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: 'http://localhost:4000/${meal.image}',
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.recipe,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${meal.calories} kcal',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: meal.dietaryPreference == DietaryPreference.vegetarian
                              ? Colors.green[100]
                              : Colors.red[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          meal.dietaryPreference == DietaryPreference.vegetarian
                              ? 'Veg'
                              : 'Non-Veg',
                          style: TextStyle(
                            color: meal.dietaryPreference == DietaryPreference.vegetarian
                                ? Colors.green[800]
                                : Colors.red[800],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MealDetailsSheet extends StatelessWidget {
  final Meal meal;

  const MealDetailsSheet({super.key, required this.meal});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: 'http://localhost:4000/${meal.image}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: meal.dietaryPreference == DietaryPreference.vegetarian
                            ? Colors.green[100]
                            : Colors.red[100],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        meal.dietaryPreference == DietaryPreference.vegetarian
                            ? 'Vegetarian'
                            : 'Non-Vegetarian',
                        style: TextStyle(
                          color: meal.dietaryPreference == DietaryPreference.vegetarian
                              ? Colors.green[800]
                              : Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.recipe,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          meal.cookingTime,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.local_fire_department, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${meal.calories} calories',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Nutritional Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildNutritionItem('Protein', '${meal.protein}g'),
                        _buildNutritionItem('Carbs', '${meal.carbs}g'),
                        _buildNutritionItem('Fat', '${meal.fat}g'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(meal.details),
                    const SizedBox(height: 16),
                    const Text(
                      'Ingredients',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...meal.ingredient.where((i) => i.isNotEmpty).map((ingredient) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 8),
                          const SizedBox(width: 8),
                          Text(ingredient),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),
                    const Text(
                      'Procedure',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(meal.process),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class Meal {
  final String id;
  final String recipe;
  final String image;
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
  final DietaryPreference dietaryPreference;
  final MealCategory category;
  final String details;
  final List<String> ingredient;
  final String cookingTime;
  final String process;

  Meal({
    required this.id,
    required this.recipe,
    required this.image,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.dietaryPreference,
    required this.category,
    required this.details,
    required this.ingredient,
    required this.cookingTime,
    required this.process,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['_id'],
      recipe: json['recipe'],
      image: json['image'] ?? '',
      calories: int.tryParse(json['calories']?.toString().replaceAll('g', '') ?? '0') ?? 0,
      protein: int.tryParse(json['protein']?.toString().replaceAll('g', '') ?? '0') ?? 0,
      carbs: int.tryParse(json['carbs']?.toString().replaceAll('g', '') ?? '0') ?? 0,
      fat: int.tryParse(json['fat']?.toString().replaceAll('g', '') ?? '0') ?? 0,
      dietaryPreference: json['isVegetarian'] == true ? DietaryPreference.vegetarian : DietaryPreference.nonVegetarian,
      category: MealCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => MealCategory.lunch,
      ),
      details: json['details'] ?? '',
      ingredient: (json['ingredient'] as String).split('\n'),
      cookingTime: json['cookingTime'] ?? '30 mins',
      process: json['process'] ?? '',
    );
  }
}