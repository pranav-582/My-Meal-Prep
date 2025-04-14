import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_settings.dart';
import '../providers/meal_plan_provider.dart';

class MealSettingsScreen extends StatefulWidget {
  const MealSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MealSettingsScreen> createState() => _MealSettingsScreenState();
}

class _MealSettingsScreenState extends State<MealSettingsScreen> {
  late MealSettings settings;
  final List<String> _availablePreferences = [
    'Vegetarian',
    'Vegan',
    'Low-carb',
    'High-protein',
    'Keto',
    'Mediterranean',
  ];

  final List<String> _availableRestrictions = [
    'Gluten-free',
    'Dairy-free',
    'Nut-free',
    'Shellfish-free',
    'Egg-free',
    'Soy-free',
  ];

  @override
  void initState() {
    super.initState();
    settings = context.read<MealPlanProvider>().settings;
  }

  Future<void> _saveSettings(BuildContext context) async {
    try {
      await context.read<MealPlanProvider>().updateSettings(settings);

      if (!mounted) return;

      if (settings.notificationsEnabled) {
        await _scheduleNotifications();
      }

      _showSnackBar('Settings saved');
      _navigateBack();
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Error saving settings: $e');
    }
  }

  Future<void> _scheduleNotifications() async {
    final notificationService =
        context.read<MealPlanProvider>().notificationService;

    await notificationService.scheduleMealReminder(
      id: 1,
      title: 'Breakfast Time',
      body: 'Time for breakfast!',
      scheduledTime: _getDateTime(settings.breakfastTime),
    );

    await notificationService.scheduleMealReminder(
      id: 2,
      title: 'Lunch Time',
      body: 'Time for lunch!',
      scheduledTime: _getDateTime(settings.lunchTime),
    );

    await notificationService.scheduleMealReminder(
      id: 3,
      title: 'Dinner Time',
      body: 'Time for dinner!',
      scheduledTime: _getDateTime(settings.dinnerTime),
    );
  }

  DateTime _getDateTime(TimeOfDay time) {
    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _navigateBack() {
    Navigator.pop(context);
  }

  Widget _buildNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Reminders',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        SwitchListTile(
          title: const Text('Enable Notifications'),
          value: settings.notificationsEnabled,
          onChanged: (bool value) {
            setState(() {
              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: settings.lunchTime,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: value,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
              );
            });
          },
        ),
        if (settings.notificationsEnabled) ...[
          _buildTimePickerTile('Breakfast Time', settings.breakfastTime,
              (time) {
            setState(() {
              settings = MealSettings(
                breakfastTime: time,
                lunchTime: settings.lunchTime,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
              );
            });
          }),
          _buildTimePickerTile('Lunch Time', settings.lunchTime, (time) {
            setState(() {
              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: time,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
              );
            });
          }),
          _buildTimePickerTile('Dinner Time', settings.dinnerTime, (time) {
            setState(() {
              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: settings.lunchTime,
                dinnerTime: time,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
              );
            });
          }),
        ],
      ],
    );
  }

  Widget _buildTimePickerTile(
    String title,
    TimeOfDay currentTime,
    void Function(TimeOfDay) onTimeChanged,
  ) {
    return ListTile(
      title: Text(title),
      trailing: Text(currentTime.format(context)),
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: currentTime,
        );
        if (picked != null) {
          onTimeChanged(picked);
        }
      },
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availablePreferences.map((preference) {
            final isSelected = settings.dietaryPreferences.contains(preference);
            return FilterChip(
              label: Text(preference),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  final newPreferences =
                      List<String>.from(settings.dietaryPreferences);
                  if (selected) {
                    newPreferences.add(preference);
                  } else {
                    newPreferences.remove(preference);
                  }
                  settings = MealSettings(
                    breakfastTime: settings.breakfastTime,
                    lunchTime: settings.lunchTime,
                    dinnerTime: settings.dinnerTime,
                    notificationsEnabled: settings.notificationsEnabled,
                    dietaryPreferences: newPreferences,
                    restrictions: settings.restrictions,
                    targetCalories: settings.targetCalories,
                    mealCalorieDistribution: settings.mealCalorieDistribution,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRestrictionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Dietary Restrictions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _availableRestrictions.map((restriction) {
            final isSelected = settings.restrictions.contains(restriction);
            return FilterChip(
              label: Text(restriction),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  final newRestrictions =
                      List<String>.from(settings.restrictions);
                  if (selected) {
                    newRestrictions.add(restriction);
                  } else {
                    newRestrictions.remove(restriction);
                  }
                  settings = MealSettings(
                    breakfastTime: settings.breakfastTime,
                    lunchTime: settings.lunchTime,
                    dinnerTime: settings.dinnerTime,
                    notificationsEnabled: settings.notificationsEnabled,
                    dietaryPreferences: settings.dietaryPreferences,
                    restrictions: newRestrictions,
                    targetCalories: settings.targetCalories,
                    mealCalorieDistribution: settings.mealCalorieDistribution,
                  );
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalorieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Calorie Goals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: settings.targetCalories.toString(),
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Daily Target Calories',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final calories = double.tryParse(value);
            if (calories != null) {
              setState(() {
                settings = MealSettings(
                  breakfastTime: settings.breakfastTime,
                  lunchTime: settings.lunchTime,
                  dinnerTime: settings.dinnerTime,
                  notificationsEnabled: settings.notificationsEnabled,
                  dietaryPreferences: settings.dietaryPreferences,
                  restrictions: settings.restrictions,
                  targetCalories: calories,
                  mealCalorieDistribution: settings.mealCalorieDistribution,
                );
              });
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Meal Distribution',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        _buildCalorieDistributionSlider('Breakfast', 'breakfast'),
        _buildCalorieDistributionSlider('Lunch', 'lunch'),
        _buildCalorieDistributionSlider('Dinner', 'dinner'),
      ],
    );
  }

  Widget _buildCalorieDistributionSlider(String label, String meal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
            '$label (${(settings.mealCalorieDistribution[meal]! * 100).round()}%)'),
        Slider(
          value: settings.mealCalorieDistribution[meal]!,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(settings.mealCalorieDistribution[meal]! * 100).round()}%',
          onChanged: (value) {
            setState(() {
              final newDistribution =
                  Map<String, double>.from(settings.mealCalorieDistribution);
              newDistribution[meal] = value;

              // Adjust other meals proportionally
              final remaining = 1.0 - value;
              final others = settings.mealCalorieDistribution.keys
                  .where((k) => k != meal)
                  .toList();
              final currentOthersTotal = others.fold<double>(
                0.0,
                (sum, key) => sum + settings.mealCalorieDistribution[key]!,
              );

              if (currentOthersTotal > 0) {
                for (final other in others) {
                  newDistribution[other] =
                      settings.mealCalorieDistribution[other]! *
                          remaining /
                          currentOthersTotal;
                }
              }

              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: settings.lunchTime,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: newDistribution,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildMacroSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Macro Nutrient Goals',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        _buildMacroSlider('Protein', settings.macroTargets.protein, (value) {
          final remaining = 1.0 - value;
          final currentCarbs = settings.macroTargets.carbs;
          final currentFats = settings.macroTargets.fats;
          final total = currentCarbs + currentFats;

          setState(() {
            settings = MealSettings(
              breakfastTime: settings.breakfastTime,
              lunchTime: settings.lunchTime,
              dinnerTime: settings.dinnerTime,
              notificationsEnabled: settings.notificationsEnabled,
              dietaryPreferences: settings.dietaryPreferences,
              restrictions: settings.restrictions,
              targetCalories: settings.targetCalories,
              mealCalorieDistribution: settings.mealCalorieDistribution,
              macroTargets: MacroTargets(
                protein: value,
                carbs: total > 0
                    ? currentCarbs * remaining / total
                    : remaining / 2,
                fats:
                    total > 0 ? currentFats * remaining / total : remaining / 2,
              ),
            );
          });
        }),
        _buildMacroSlider('Carbs', settings.macroTargets.carbs, (value) {
          // Similar implementation for carbs
        }),
        _buildMacroSlider('Fats', settings.macroTargets.fats, (value) {
          // Similar implementation for fats
        }),
      ],
    );
  }

  Widget _buildMacroSlider(
      String label, double value, void Function(double) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label (${(value * 100).round()}%)'),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          divisions: 20,
          label: '${(value * 100).round()}%',
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildMealPlanningSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal Planning Preferences',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Text(
          'Meal Prep Days',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        ...[
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ].asMap().entries.map((entry) {
          final weekday = entry.key + 1;
          return CheckboxListTile(
            title: Text(entry.value),
            value: settings.weekdayMealPrep[weekday],
            onChanged: (bool? value) {
              if (value != null) {
                setState(() {
                  final newWeekdayPrep =
                      Map<int, bool>.from(settings.weekdayMealPrep);
                  newWeekdayPrep[weekday] = value;
                  settings = MealSettings(
                    breakfastTime: settings.breakfastTime,
                    lunchTime: settings.lunchTime,
                    dinnerTime: settings.dinnerTime,
                    notificationsEnabled: settings.notificationsEnabled,
                    dietaryPreferences: settings.dietaryPreferences,
                    restrictions: settings.restrictions,
                    targetCalories: settings.targetCalories,
                    mealCalorieDistribution: settings.mealCalorieDistribution,
                    macroTargets: settings.macroTargets,
                    weekdayMealPrep: newWeekdayPrep,
                    maxPrepTimeMinutes: settings.maxPrepTimeMinutes,
                    allowLeftovers: settings.allowLeftovers,
                  );
                });
              }
            },
          );
        }).toList(),
        const SizedBox(height: 16),
        Text(
          'Maximum Prep Time',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: settings.maxPrepTimeMinutes.toDouble(),
          min: 15,
          max: 120,
          divisions: 7,
          label: '${settings.maxPrepTimeMinutes} minutes',
          onChanged: (value) {
            setState(() {
              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: settings.lunchTime,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
                macroTargets: settings.macroTargets,
                weekdayMealPrep: settings.weekdayMealPrep,
                maxPrepTimeMinutes: value.round(),
                allowLeftovers: settings.allowLeftovers,
              );
            });
          },
        ),
        SwitchListTile(
          title: const Text('Allow Leftovers'),
          subtitle: const Text('Include extra portions for next day meals'),
          value: settings.allowLeftovers,
          onChanged: (bool value) {
            setState(() {
              settings = MealSettings(
                breakfastTime: settings.breakfastTime,
                lunchTime: settings.lunchTime,
                dinnerTime: settings.dinnerTime,
                notificationsEnabled: settings.notificationsEnabled,
                dietaryPreferences: settings.dietaryPreferences,
                restrictions: settings.restrictions,
                targetCalories: settings.targetCalories,
                mealCalorieDistribution: settings.mealCalorieDistribution,
                macroTargets: settings.macroTargets,
                weekdayMealPrep: settings.weekdayMealPrep,
                maxPrepTimeMinutes: settings.maxPrepTimeMinutes,
                allowLeftovers: value,
              );
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCalorieSection(),
          const Divider(),
          _buildMacroSection(),
          const Divider(),
          _buildMealPlanningSection(),
          const Divider(),
          _buildNotificationSection(),
          const Divider(),
          _buildPreferencesSection(),
          const Divider(),
          _buildRestrictionsSection(),
        ],
      ),
    );
  }
}
