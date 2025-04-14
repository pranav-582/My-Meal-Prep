import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Fix import path
import '../models/meal_plan.dart';
import '../models/meal.dart';
import '../models/nutrition_summary.dart';
import '../services/grok_ai_service.dart';
import '../services/notification_service.dart';
import '../models/meal_settings.dart';

class MealPlanProvider with ChangeNotifier {
  MealPlan? _currentPlan;
  final GroqAIService _groqService = GroqAIService();
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  MealSettings _settings = MealSettings.defaultSettings();

  MealPlanProvider() {
    _loadSettings();
  }

  MealSettings get settings => _settings;

  MealPlan? get currentPlan => _currentPlan;
  bool get isLoading => _isLoading;
  NotificationService get notificationService => _notificationService;

  Future<void> generateMealPlan({
    required double targetCalories,
    List<String>? preferences,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _groqService.generateMealPlan(
        targetCalories: targetCalories,
        preferences: preferences ?? [], // Convert nullable list to non-nullable
        restrictions: [], // Add empty restrictions list
      );

      // Convert response to List<Meal>
      final List<Meal> meals = (response['meals'] as List)
          .map((mealData) => Meal.fromJson(mealData as Map<String, dynamic>))
          .toList();

      // Create a new meal plan
      _currentPlan = MealPlan(
        id: DateTime.now().toString(),
        date: DateTime.now(),
        breakfast: meals.where((m) => m.type == 'breakfast').toList(),
        lunch: meals.where((m) => m.type == 'lunch').toList(),
        dinner: meals.where((m) => m.type == 'dinner').toList(),
        snacks: meals.where((m) => m.type == 'snack').toList(),
        dailyNutrition: _calculateNutritionSummary(meals),
      );

      // Schedule notifications for meals
      await _scheduleMealReminders();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<Meal> analyzeMealImage(String imagePath) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _groqService.analyzeImage(imagePath);
      final analyzedMeal = Meal.fromJson(response);

      // Add the analyzed meal to current plan if one exists
      if (_currentPlan != null) {
        _currentPlan!.snacks.add(analyzedMeal);
        notifyListeners();
      }

      _isLoading = false;
      notifyListeners();
      return analyzedMeal;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to analyze meal: $e');
    }
  }

  Future<void> _scheduleMealReminders() async {
    if (_currentPlan == null) return;

    // Schedule breakfast reminder
    if (_currentPlan!.breakfast.isNotEmpty) {
      await _notificationService.scheduleMealReminder(
        id: 1,
        title: 'Breakfast Time!',
        body: 'Time for ${_currentPlan!.breakfast.first.name}',
        scheduledTime: DateTime.now().copyWith(hour: 8, minute: 0),
      );
    }

    // Schedule lunch reminder
    if (_currentPlan!.lunch.isNotEmpty) {
      await _notificationService.scheduleMealReminder(
        id: 2,
        title: 'Lunch Time!',
        body: 'Time for ${_currentPlan!.lunch.first.name}',
        scheduledTime: DateTime.now().copyWith(hour: 13, minute: 0),
      );
    }

    // Schedule dinner reminder
    if (_currentPlan!.dinner.isNotEmpty) {
      await _notificationService.scheduleMealReminder(
        id: 3,
        title: 'Dinner Time!',
        body: 'Time for ${_currentPlan!.dinner.first.name}',
        scheduledTime: DateTime.now().copyWith(hour: 19, minute: 0),
      );
    }
  }

  NutritionSummary _calculateNutritionSummary(List<Meal> meals) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFats = 0;

    for (final meal in meals) {
      totalCalories += meal.calories;
      totalProtein += meal.protein;
      totalCarbs += meal.carbs;
      totalFats += meal.fats;
    }

    return NutritionSummary(
      totalCalories: totalCalories,
      totalProtein: totalProtein,
      totalCarbs: totalCarbs,
      totalFats: totalFats,
    );
  }

  Future<void> updateSettings(MealSettings newSettings) async {
    _settings = newSettings;
    await _saveSettings();
    notifyListeners();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _settings = MealSettings(
      breakfastTime: TimeOfDay(
        hour: prefs.getInt('breakfast_hour') ?? 8,
        minute: prefs.getInt('breakfast_minute') ?? 0,
      ),
      lunchTime: TimeOfDay(
        hour: prefs.getInt('lunch_hour') ?? 13,
        minute: prefs.getInt('lunch_minute') ?? 0,
      ),
      dinnerTime: TimeOfDay(
        hour: prefs.getInt('dinner_hour') ?? 19,
        minute: prefs.getInt('dinner_minute') ?? 0,
      ),
      notificationsEnabled: prefs.getBool('notifications_enabled') ?? true,
      dietaryPreferences: prefs.getStringList('dietary_preferences') ?? [],
      restrictions: prefs.getStringList('restrictions') ?? [],
    );
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('breakfast_hour', _settings.breakfastTime.hour);
    await prefs.setInt('breakfast_minute', _settings.breakfastTime.minute);
    await prefs.setInt('lunch_hour', _settings.lunchTime.hour);
    await prefs.setInt('lunch_minute', _settings.lunchTime.minute);
    await prefs.setInt('dinner_hour', _settings.dinnerTime.hour);
    await prefs.setInt('dinner_minute', _settings.dinnerTime.minute);
    await prefs.setBool(
        'notifications_enabled', _settings.notificationsEnabled);
    await prefs.setStringList(
        'dietary_preferences', _settings.dietaryPreferences);
    await prefs.setStringList('restrictions', _settings.restrictions);
  }
}
