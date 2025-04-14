import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../widgets/meal_card.dart';
import '../models/meal.dart';
import '../models/nutrition_summary.dart';
import 'meal_analysis_screen.dart';
import 'meal_settings_screen.dart'; // Add this import

class MealPlannerScreen extends StatefulWidget {
  const MealPlannerScreen({Key? key}) : super(key: key);

  @override
  State<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends State<MealPlannerScreen> {
  final _calorieController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Consumer<MealPlanProvider>(
      builder: (context, mealPlanProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('AI Meal Planner'),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MealSettingsScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
          body: mealPlanProvider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildPlanGenerator(),
                      if (mealPlanProvider.currentPlan != null) ...[
                        const SizedBox(height: 24),
                        _buildMealSection(
                          'Breakfast',
                          mealPlanProvider.currentPlan!.breakfast,
                        ),
                        _buildMealSection(
                          'Lunch',
                          mealPlanProvider.currentPlan!.lunch,
                        ),
                        _buildMealSection(
                          'Dinner',
                          mealPlanProvider.currentPlan!.dinner,
                        ),
                        if (mealPlanProvider.currentPlan!.snacks.isNotEmpty)
                          _buildMealSection(
                            'Snacks',
                            mealPlanProvider.currentPlan!.snacks,
                          ),
                        const SizedBox(height: 16),
                        _buildNutritionSummary(
                          mealPlanProvider.currentPlan!.dailyNutrition,
                        ),
                      ],
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MealAnalysisScreen(),
                ),
              );
            },
            child: const Icon(Icons.camera_alt),
          ),
        );
      },
    );
  }

  Widget _buildPlanGenerator() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _calorieController,
              decoration: const InputDecoration(
                labelText: 'Target Daily Calories',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final calories = double.tryParse(_calorieController.text);
                if (calories != null) {
                  await context.read<MealPlanProvider>().generateMealPlan(
                        targetCalories: calories,
                      );
                }
              },
              icon: const Icon(Icons.food_bank),
              label: const Text('Generate Meal Plan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<Meal> meals) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        ...meals.map((meal) => MealCard(meal: meal)).toList(),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildNutritionSummary(NutritionSummary summary) {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Daily Nutrition Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _NutritionSummaryItem(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: summary.totalCalories.round().toString(),
                ),
                _NutritionSummaryItem(
                  icon: Icons.fitness_center,
                  label: 'Protein',
                  value: '${summary.totalProtein.round()}g',
                ),
                _NutritionSummaryItem(
                  icon: Icons.grain,
                  label: 'Carbs',
                  value: '${summary.totalCarbs.round()}g',
                ),
                _NutritionSummaryItem(
                  icon: Icons.opacity,
                  label: 'Fats',
                  value: '${summary.totalFats.round()}g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _NutritionSummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _NutritionSummaryItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[800]),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.blue[800],
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
