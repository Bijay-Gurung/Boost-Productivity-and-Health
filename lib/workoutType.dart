import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Exercise {
  final String id;
  final String name;
  final String category;
  final String muscleGroup;
  final int duration;
  final int caloriesBurned;
  final String intensity;
  final String steps;
  final String image;
  final RecommendedFor recommendedFor;

  Exercise({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroup,
    required this.duration,
    required this.caloriesBurned,
    required this.intensity,
    required this.steps,
    required this.image,
    required this.recommendedFor,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['_id'],
      name: json['name'],
      category: json['category'],
      muscleGroup: json['muscleGroup'],
      duration: json['duration'],
      caloriesBurned: json['caloriesBurned'],
      intensity: json['intensity'],
      steps: json['steps'],
      image: json['image'],
      recommendedFor: RecommendedFor.fromJson(json['recommendedFor']),
    );
  }
}

class RecommendedFor {
  final BMI bmiRange;
  final Age ageRange;
  final String gender;

  RecommendedFor({
    required this.bmiRange,
    required this.ageRange,
    required this.gender,
  });

  factory RecommendedFor.fromJson(Map<String, dynamic> json) {
    return RecommendedFor(
      bmiRange: BMI.fromJson(json['bmiRange']),
      ageRange: Age.fromJson(json['ageRange']),
      gender: json['gender'],
    );
  }
}

class BMI {
  final double min;
  final double max;

  BMI({required this.min, required this.max});

  factory BMI.fromJson(Map<String, dynamic> json) {
    return BMI(
      min: json['min'].toDouble(),
      max: json['max'].toDouble(),
    );
  }
}

class Age {
  final int min;
  final int max;

  Age({required this.min, required this.max});

  factory Age.fromJson(Map<String, dynamic> json) {
    return Age(
      min: json['min'],
      max: json['max'],
    );
  }
}

class WorkoutTypeScreen extends StatelessWidget {
  const WorkoutTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fitness App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Workout Type',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  onPressed: () => _navigateToExercises(context, 'Cardio'),
                  child: const Text('Cardio'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  ),
                  onPressed: () => _navigateToExercises(context, 'Strength'),
                  child: const Text('Strength'),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _navigateToExercises(BuildContext context, String category) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExerciseListScreen(category: category),
      ),
    );
  }
}

class ExerciseListScreen extends StatefulWidget {
  final String category;

  const ExerciseListScreen({super.key, required this.category});

  @override
  State<ExerciseListScreen> createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  List<Exercise> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  Future<void> _fetchExercises() async {
    try {
      final response = await http.get(Uri.parse('http://192.168.1.74:4000/exercise'));
      if (!mounted) return;
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        setState(() {
          exercises = data
              .map((json) => Exercise.fromJson(json))
              .where((exercise) => exercise.category == widget.category)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading exercises: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} Exercises'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : exercises.isEmpty
              ? const Center(child: Text('No exercises found'))
              : ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ListTile(
                        leading: exercise.image.isNotEmpty
                            ? Image.network(
                                'http://192.168.1.74:4000/${exercise.image}',
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.fitness_center),
                        title: Text(exercise.name),
                        subtitle: Text(
                            'Duration: ${exercise.duration} mins\nCalories: ${exercise.caloriesBurned} kcal'),
                        trailing: Text(exercise.intensity),
                        onTap: () {/* Add navigation */},
                      ),
                    );
                  },
                ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Workouts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}