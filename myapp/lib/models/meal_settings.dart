import 'package:flutter/material.dart';

class MacroTargets {
  final double protein;
  final double carbs;
  final double fats;

  const MacroTargets({
    this.protein = 0.3,
    this.carbs = 0.4,
    this.fats = 0.3,
  });
}

class MealSettings {
  final TimeOfDay breakfastTime;
  final TimeOfDay lunchTime;
  final TimeOfDay dinnerTime;
  final bool notificationsEnabled;
  final List<String> dietaryPreferences;
  final List<String> restrictions;
  final double targetCalories;
  final Map<String, double> mealCalorieDistribution;
  final MacroTargets macroTargets;
  final Map<int, bool> weekdayMealPrep;
  final int maxPrepTimeMinutes;
  final bool allowLeftovers;

  MealSettings({
    required this.breakfastTime,
    required this.lunchTime,
    required this.dinnerTime,
    required this.notificationsEnabled,
    required this.dietaryPreferences,
    required this.restrictions,
    this.targetCalories = 2000.0,
    this.mealCalorieDistribution = const {
      'breakfast': 0.3,
      'lunch': 0.35,
      'dinner': 0.35,
    },
    this.macroTargets = const MacroTargets(),
    this.weekdayMealPrep = const {
      1: true, // Monday
      2: true, // Tuesday
      3: true, // Wednesday
      4: true, // Thursday
      5: true, // Friday
      6: false, // Saturday
      7: false, // Sunday
    },
    this.maxPrepTimeMinutes = 30,
    this.allowLeftovers = true,
  });

  factory MealSettings.defaultSettings() {
    return MealSettings(
      breakfastTime: const TimeOfDay(hour: 8, minute: 0),
      lunchTime: const TimeOfDay(hour: 13, minute: 0),
      dinnerTime: const TimeOfDay(hour: 19, minute: 0),
      notificationsEnabled: true,
      dietaryPreferences: [],
      restrictions: [],
    );
  }
}
