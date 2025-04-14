import 'package:flutter/material.dart';
import '../models/meal.dart';

class MealCard extends StatelessWidget {
  final Meal meal;
  final VoidCallback? onTap;

  const MealCard({
    Key? key,
    required this.meal,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal.name,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NutritionItem(
                    label: 'Calories',
                    value: meal.calories.round().toString(),
                  ),
                  _NutritionItem(
                    label: 'Protein',
                    value: '${meal.protein.round()}g',
                  ),
                  _NutritionItem(
                    label: 'Carbs',
                    value: '${meal.carbs.round()}g',
                  ),
                  _NutritionItem(
                    label: 'Fats',
                    value: '${meal.fats.round()}g',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionItem extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
