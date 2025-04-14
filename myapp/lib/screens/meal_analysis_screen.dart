import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../providers/meal_plan_provider.dart';
import '../models/meal.dart';
import 'dart:io';

class MealAnalysisScreen extends StatefulWidget {
  const MealAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<MealAnalysisScreen> createState() => _MealAnalysisScreenState();
}

class _MealAnalysisScreenState extends State<MealAnalysisScreen> {
  File? _imageFile;
  Meal? _analyzedMeal; // Add this line
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePicture() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
      await _analyzeImage(image.path);
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    try {
      final meal =
          await context.read<MealPlanProvider>().analyzeMealImage(imagePath);
      setState(() {
        _analyzedMeal = meal; // Store the analyzed meal
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Meal analyzed successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error analyzing meal: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyze Meal'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            if (_imageFile != null) Image.file(_imageFile!),
            if (_analyzedMeal != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Results',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Name: ${_analyzedMeal!.name}'),
                    Text('Calories: ${_analyzedMeal!.calories}'),
                    Text('Protein: ${_analyzedMeal!.protein}g'),
                    Text('Carbs: ${_analyzedMeal!.carbs}g'),
                    Text('Fat: ${_analyzedMeal!.fat}g'),
                  ],
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _takePicture,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Picture'),
                  ),
                  const SizedBox(height: 16),
                  if (_imageFile != null)
                    ElevatedButton.icon(
                      onPressed: () => _analyzeImage(_imageFile!.path),
                      icon: const Icon(Icons.analytics),
                      label: const Text('Analyze Again'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
