import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NextPage extends StatefulWidget {
  final int age;
  final int height;
  final int weight;
  final String gender;

  const NextPage({
    Key? key,
    required this.age,
    required this.height,
    required this.weight,
    required this.gender,
  }) : super(key: key);

  @override
  _NextPageState createState() => _NextPageState();
}

class _NextPageState extends State<NextPage> {
  double? bmi;
  double? bmr;
  String? fitnessGoal;
  String? bmiCategory;

  @override
  void initState() {
    super.initState();
    calculateBMI();
    calculateBMR();
  }

  void calculateBMI() {
    double heightInMeters = widget.height / 100;
    bmi = widget.weight / (heightInMeters * heightInMeters);
    setState(() {
      if (bmi! < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi! >= 18.5 && bmi! <= 24.9) {
        bmiCategory = 'Normal';
      } else if (bmi! >= 25 && bmi! <= 29.9) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    });
  }

  void calculateBMR() {
    if (widget.gender == 'Male') {
      bmr = 10 * widget.weight + 6.25 * widget.height - 5 * widget.age + 5;
    } else {
      bmr = 10 * widget.weight + 6.25 * widget.height - 5 * widget.age - 161;
    }
  }

  Future<void> saveFitnessData() async {
    if (fitnessGoal == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Please select a fitness goal.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.74:4000/details/fitness'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'age': widget.age,
          'height': widget.height,
          'weight': widget.weight,
          'gender': widget.gender,
          'bmi': bmi,
          'bmr': bmr,
          'fitnessGoal': fitnessGoal,
        }),
      );

      if (response.statusCode == 201) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Fitness data saved successfully!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to save fitness data. Please try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Something went wrong. Please try again later.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 60),
            Text(
              'BMI: ${bmi?.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Text(
              'Category: $bmiCategory',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            Text(
              'BMR: ${bmr?.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Select your fitness goal',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Fitness Goal',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 15,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'Muscle Building', child: Text('Muscle Building')),
                DropdownMenuItem(value: 'Weight Loss', child: Text('Weight Loss')),
                DropdownMenuItem(value: 'Maintain Weight', child: Text('Maintain Weight')),
              ],
              onChanged: (value) {
                setState(() {
                  fitnessGoal = value;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: saveFitnessData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}