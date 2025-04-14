import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class PreMadeMealsTab extends StatelessWidget {
  const PreMadeMealsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> meals = [
      {
        'name': 'Oatmeal with Berries',
        'calories': 350,
        'protein': 10,
        'carbs': 60,
        'fats': 10,
        'ingredients': [
          '1/2 cup rolled oats',
          '1 cup water or milk',
          '1/2 cup mixed berries',
          '1 tbsp honey',
          '1 tbsp chia seeds',
        ],
        'instructions':
            '1. Cook oats with liquid\n2. Top with berries and seeds\n3. Drizzle with honey',
      },
      {
        'name': 'Chicken Salad Sandwich',
        'calories': 450,
        'protein': 25,
        'carbs': 40,
        'fats': 20,
        'ingredients': [
          '2 slices whole wheat bread',
          '100g cooked chicken breast',
          '1 tbsp Greek yogurt',
          '1 tbsp diced celery',
          'Lettuce leaves',
          'Salt and pepper to taste',
        ],
        'instructions':
            '1. Mix chicken with yogurt and celery\n2. Season to taste\n3. Assemble sandwich with lettuce',
      },
      {
        'name': 'Lentil Soup',
        'calories': 300,
        'protein': 15,
        'carbs': 45,
        'fats': 5,
        'ingredients': [
          '1 cup dried lentils',
          '1 onion, diced',
          '2 carrots, chopped',
          '3 cloves garlic',
          '1 liter vegetable broth',
          '1 tsp cumin',
        ],
        'instructions':
            '1. Sauté onions and garlic\n2. Add lentils and broth\n3. Simmer for 30 minutes\n4. Add spices',
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: meals.length,
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemBuilder: (BuildContext context, int index) {
          final meal = meals[index];
          return ListTile(
            title: Text(
              meal['name'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              '${meal['calories']} calories | Protein: ${meal['protein']}g | Carbs: ${meal['carbs']}g | Fats: ${meal['fats']}g',
            ),
            leading: const Icon(Icons.restaurant_menu),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealDetailsScreen(meal: meal),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class MealDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> meal;

  const MealDetailsScreen({super.key, required this.meal});

  @override
  State<MealDetailsScreen> createState() => _MealDetailsScreenState();
}

class _MealDetailsScreenState extends State<MealDetailsScreen> {
  late final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  Future<void> _addToMealPlan(DateTime selectedDate) async {
    final prefs = await SharedPreferences.getInstance();
    final mealKey =
        'meal_${_dateFormat.format(selectedDate)}_${DateTime.now().millisecondsSinceEpoch}';

    final mealData = {
      'id': mealKey,
      'name': widget.meal['name'],
      'date': selectedDate.toIso8601String(),
      'ingredients': widget.meal['ingredients'],
      'totalCalories': widget.meal['calories'],
      'totalProtein': widget.meal['protein'],
      'totalCarbs': widget.meal['carbs'],
      'totalFats': widget.meal['fats'],
    };

    await prefs.setString(mealKey, jsonEncode(mealData));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added ${widget.meal['name']} to your meal plan for ${_dateFormat.format(selectedDate)}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  Future<void> _selectDateAndAddToMealPlan() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (pickedDate != null && mounted) {
      await _addToMealPlan(pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.meal['name'])),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildNutritionInfo(),
            const SizedBox(height: 24),
            _buildSectionTitle('Ingredients'),
            _buildIngredientsList(),
            const SizedBox(height: 24),
            _buildSectionTitle('Instructions'),
            _buildInstructions(),
            const SizedBox(height: 32),
            _buildAddToMealPlanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNutritionItem('Calories', widget.meal['calories'].toString()),
            _buildNutritionItem('Protein', '${widget.meal['protein']}g'),
            _buildNutritionItem('Carbs', '${widget.meal['carbs']}g'),
            _buildNutritionItem('Fats', '${widget.meal['fats']}g'),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildIngredientsList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children:
              (widget.meal['ingredients'] as List<String>)
                  .map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.circle, size: 8),
                          const SizedBox(width: 8),
                          Expanded(child: Text(ingredient)),
                        ],
                      ),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          widget.meal['instructions'],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildAddToMealPlanButton() {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add to Meal Plan'),
        onPressed: _selectDateAndAddToMealPlan,
      ),
    );
  }
}
