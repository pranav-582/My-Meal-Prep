import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

// Add these missing class definitions at the top of your file
class Meal {
  final String id;
  final String name;
  final DateTime date;
  final List<Map<String, dynamic>> ingredients;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  Meal({
    required this.id,
    required this.date,
    required this.name,
    required this.ingredients,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      date: DateTime.parse(json['date'] as String),
      ingredients:
          (json['ingredients'] as List<dynamic>)
              .map((e) => e as Map<String, dynamic>)
              .toList(),
      totalCalories: (json['totalCalories'] as num).toDouble(),
      totalProtein: (json['totalProtein'] as num).toDouble(),
      totalCarbs: (json['totalCarbs'] as num).toDouble(),
      totalFats: (json['totalFats'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'ingredients': ingredients,
      'totalCalories': totalCalories,
      'totalProtein': totalProtein,
      'totalCarbs': totalCarbs,
      'totalFats': totalFats,
    };
  }
}

class Ingredient {
  String name;
  double quantity;
  double calories;
  double protein;
  double carbs;
  double fats;

  Ingredient({
    this.name = '',
    this.quantity = 0.0,
    this.calories = 0.0,
    this.protein = 0.0,
    this.carbs = 0.0,
    this.fats = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    };
  }
}

class IngredientForm extends StatelessWidget {
  final Ingredient ingredient;
  final VoidCallback onRemove;

  const IngredientForm({
    super.key,
    required this.ingredient,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Ingredient Name'),
              onChanged: (value) => ingredient.name = value,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter name' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Quantity'),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      ingredient.quantity = double.tryParse(value) ?? 0.0,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter quantity' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) =>
                      ingredient.calories = double.tryParse(value) ?? 0.0,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter calories' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Protein (g)'),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) => ingredient.protein = double.tryParse(value) ?? 0.0,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter protein' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Carbs (g)'),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) => ingredient.carbs = double.tryParse(value) ?? 0.0,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter carbs' : null,
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Fats (g)'),
              keyboardType: TextInputType.number,
              onChanged:
                  (value) => ingredient.fats = double.tryParse(value) ?? 0.0,
              validator:
                  (value) =>
                      value == null || value.isEmpty ? 'Enter fats' : null,
            ),
            ElevatedButton(onPressed: onRemove, child: const Text('Remove')),
          ],
        ),
      ),
    );
  }
}

class MealNutritionSummary extends StatelessWidget {
  final List<Ingredient> ingredients;

  const MealNutritionSummary({super.key, required this.ingredients});

  @override
  Widget build(BuildContext context) {
    final totalNutrition = ingredients.fold<Map<String, double>>(
      {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0},
      (previousValue, element) => {
        'calories': previousValue['calories']! + element.calories,
        'protein': previousValue['protein']! + element.protein,
        'carbs': previousValue['carbs']! + element.carbs,
        'fats': previousValue['fats']! + element.fats,
      },
    );

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        children: [
          const Text(
            'Total Nutritional Information:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Calories: ${totalNutrition['calories']!.toStringAsFixed(1)}'),
          Text('Protein: ${totalNutrition['protein']!.toStringAsFixed(1)}g'),
          Text('Carbs: ${totalNutrition['carbs']!.toStringAsFixed(1)}g'),
          Text('Fats: ${totalNutrition['fats']!.toStringAsFixed(1)}g'),
        ],
      ),
    );
  }
}

// Now the CustomMealsTab implementation
class CustomMealsTab extends StatefulWidget {
  const CustomMealsTab({super.key});

  @override
  State<CustomMealsTab> createState() => _CustomMealsTabState();
}

class _CustomMealsTabState extends State<CustomMealsTab> {
  final _formKey = GlobalKey<FormState>();
  final _mealNameController = TextEditingController();
  final List<Ingredient> _ingredients = [];
  List<Meal> _savedMeals = [];
  late final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadSavedMeals();
  }

  Future<void> _loadSavedMeals() async {
    final prefs = await SharedPreferences.getInstance();
    final mealKeys = prefs.getKeys().where((key) => key.startsWith('meal_'));
    debugPrint("Loaded meal keys: $mealKeys");

    final meals = <Meal>[];

    for (final key in mealKeys) {
      final mealJson = prefs.getString(key);
      if (mealJson != null) {
        try {
          meals.add(
            Meal.fromJson(jsonDecode(mealJson) as Map<String, dynamic>),
          );
        } catch (error) {
          debugPrint('Error decoding meal: $error for key: $key');
        }
      }
    }

    if (mounted) {
      setState(() {
        meals.sort((a, b) => b.date.compareTo(a.date));
        _savedMeals = meals;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              controller: _mealNameController,
              decoration: const InputDecoration(
                labelText: 'Meal Name',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value?.isEmpty ?? true ? 'Please enter meal name' : null,
            ),
            const SizedBox(height: 10),

            ..._ingredients.map((ingredient) {
              final index = _ingredients.indexOf(ingredient);
              return IngredientForm(
                ingredient: ingredient,
                onRemove: () => _removeIngredient(index),
              );
            }),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addIngredient,
              child: const Text('Add Ingredient'),
            ),

            if (_ingredients.isNotEmpty)
              MealNutritionSummary(ingredients: _ingredients),

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveMeal,
              child: const Text('Save Meal'),
            ),

            const SizedBox(height: 20),
            const Text(
              'Saved Meals:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._savedMeals.map(
              (meal) => ListTile(
                title: Text(meal.name),
                subtitle: Text(
                  'Calories: ${meal.totalCalories.toStringAsFixed(1)}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteMeal(meal.id, meal.date),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _mealNameController.dispose();
    super.dispose();
  }

  void _addIngredient() {
    setState(() => _ingredients.add(Ingredient()));
  }

  void _removeIngredient(int index) {
    setState(() => _ingredients.removeAt(index));
  }

  Future<void> _saveMeal() async {
    if (!_formKey.currentState!.validate()) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      }
      return;
    }

    if (_ingredients.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one ingredient')),
        );
      }
      return;
    }

    final totalNutrition = _calculateTotalNutrition();
    final meal = Meal(
      id: const Uuid().v4(),
      name: _mealNameController.text,
      date: DateTime.now(),
      ingredients:
          _ingredients.map((ingredient) => ingredient.toJson()).toList(),
      totalCalories: totalNutrition['calories'] ?? 0,
      totalProtein: totalNutrition['protein'] ?? 0,
      totalCarbs: totalNutrition['carbs'] ?? 0,
      totalFats: totalNutrition['fats'] ?? 0,
    );

    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_${_dateFormat.format(meal.date)}_${meal.id}';
    await prefs.setString(key, jsonEncode(meal.toJson()));

    if (mounted) {
      _formKey.currentState!.reset();
      _mealNameController.clear();
      setState(() {
        _ingredients.clear();
        _savedMeals.insert(0, meal);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Meal "${meal.name}" saved! '
            'Calories: ${meal.totalCalories}, '
            'Protein: ${meal.totalProtein}g, '
            'Carbs: ${meal.totalCarbs}g, '
            'Fats: ${meal.totalFats}g',
          ),
        ),
      );
    }
  }

  Future<void> _deleteMeal(String id, DateTime date) async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'meal_${_dateFormat.format(date)}_$id';
    await prefs.remove(key);
    if (mounted) {
      setState(() => _savedMeals.removeWhere((meal) => meal.id == id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Meal deleted successfully!')),
      );
    }
  }

  Map<String, double> _calculateTotalNutrition() {
    return _ingredients.fold<Map<String, double>>(
      {'calories': 0, 'protein': 0, 'carbs': 0, 'fats': 0},
      (previousValue, ingredient) => {
        'calories': previousValue['calories']! + ingredient.calories,
        'protein': previousValue['protein']! + ingredient.protein,
        'carbs': previousValue['carbs']! + ingredient.carbs,
        'fats': previousValue['fats']! + ingredient.fats,
      },
    );
  }
}
