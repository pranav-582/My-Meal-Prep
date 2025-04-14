import 'meal.dart';
import 'nutrition_summary.dart';

class MealPlan {
  final String id;
  final DateTime date;
  final List<Meal> breakfast;
  final List<Meal> lunch;
  final List<Meal> dinner;
  final List<Meal> snacks;
  final NutritionSummary dailyNutrition;

  MealPlan({
    required this.id,
    required this.date,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
    required this.dailyNutrition,
  });
}
