import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:reorderables/reorderables.dart';
import 'home.dart';
import 'taskManagerScreen.dart';
import 'details.dart';

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
    final startDate = _focusedDay.subtract(const Duration(days: 7));
    final endDate = _focusedDay.add(const Duration(days: 7));

    final response = await http.get(
      Uri.parse(
        'http://192.168.1.74:4000/mealPlan?userId=${widget.userId}&start=${startDate.toIso8601String()}&end=${endDate.toIso8601String()}',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as List;
      setState(() {
        _meals = {
          for (var entry in data)
            DateTime.parse(entry['date']): [
              for (var meal in entry['meals']) Meal.fromJson(meal)
            ]
        };
      });
    }
  }

  Future<void> _fetchAvailableMeals() async {
    final response = await http.get(Uri.parse('http://192.168.1.74:4000/meal'));
    if (response.statusCode == 200) {
      setState(() {
        _availableMeals = (json.decode(response.body) as List)
            .map((x) => Meal.fromJson(x))
            .toList();
      });
    }
  }

  Future<void> _saveMealPlan(DateTime date, Meal meal) async {
    final existingMeals = _meals[date] ?? [];

    final updatedMeals = [
      ...existingMeals,
      meal,
    ];

    final response = await http.post(
      Uri.parse('http://192.168.1.74:4000/mealPlan'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'userId': widget.userId,
        'date': date.toIso8601String(),
        'meals': [{
          'mealType': 'lunch',
          'mealId': meal.id,
        }]
      }),
    );

    if (response.statusCode == 201) {
      _fetchMealPlan();
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to save meal plan'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('OK'),
            )
          ],
        ),
      );
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
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
      ),
      body: Column(
        children: [
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
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
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
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: Colors.grey)),
    ),
    child: Row( // <-- moved child here
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HomePage(
                  userName: widget.userName,
                  email: '',
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
                builder: (context) => Details(userName: widget.userName),
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
      child: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: 'http://192.168.1.74:4000/${meal.image}',
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
                Text(
                  '${meal.calories} kcal',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Meal {
  final String id;
  final String recipe;
  final String image;
  final int calories;

  Meal({
    required this.id,
    required this.recipe,
    required this.image,
    required this.calories,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['_id'],
      recipe: json['recipe'],
      image: json['image'],
      calories: int.parse(json['calories'].toString()),
    );
  }
}