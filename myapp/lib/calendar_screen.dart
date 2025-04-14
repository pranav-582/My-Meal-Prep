import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  List<Meal> _mealsForSelectedDay = [];
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadMealsForDate(_selectedDay);
  }

  Future<void> _loadMealsForDate(DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final dateString = _dateFormat.format(date);
    final mealKeys = prefs.getKeys().where(
      (key) => key.startsWith('meal_$dateString'),
    );

    final meals = <Meal>[];
    for (final key in mealKeys) {
      final mealJson = prefs.getString(key);
      if (mealJson != null) {
        try {
          meals.add(Meal.fromJson(jsonDecode(mealJson)));
        } catch (error) {
          debugPrint('Error decoding meal: $error for key: $key');
        }
      }
    }

    if (mounted) {
      setState(() {
        _mealsForSelectedDay = meals;
        _selectedDay = date;
      });
    }
  }

  Widget _displayMealDetails(List<Meal> meals) {
    if (meals.isEmpty) {
      return const Center(child: Text('No meals logged for this day.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildNutritionInfo(meal.totalNutrition),
                if (meal.ingredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Ingredients:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  ...meal.ingredients.map(
                    (ingredient) => Text('• $ingredient'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNutritionInfo(NutritionInfo nutrition) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Calories: ${nutrition.calories.toStringAsFixed(1)}'),
        Text('Protein: ${nutrition.protein.toStringAsFixed(1)}g'),
        Text('Carbs: ${nutrition.carbs.toStringAsFixed(1)}g'),
        Text('Fats: ${nutrition.fats.toStringAsFixed(1)}g'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Meal History',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          CalendarDatePicker(
            initialDate: _selectedDay,
            firstDate: DateTime(2023),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (DateTime date) {
              _loadMealsForDate(date);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Meals for ${DateFormat('MMMM d, yyyy').format(_selectedDay)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: _displayMealDetails(_mealsForSelectedDay),
            ),
          ),
        ],
      ),
    );
  }
}

class Meal {
  final String id;
  final String name;
  final DateTime date;
  final List<String> ingredients;
  final NutritionInfo totalNutrition;

  Meal({
    required this.id,
    required this.name,
    required this.date,
    required this.ingredients,
    required this.totalNutrition,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      ingredients: (json['ingredients'] as List<dynamic>).cast<String>(),
      totalNutrition: NutritionInfo(
        calories: (json['totalCalories'] as num).toDouble(),
        protein: (json['totalProtein'] as num).toDouble(),
        carbs: (json['totalCarbs'] as num).toDouble(),
        fats: (json['totalFats'] as num).toDouble(),
      ),
    );
  }
}

class NutritionInfo {
  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  const NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });
}
