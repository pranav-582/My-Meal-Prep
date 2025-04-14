import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GroqAIService {
  static String get _baseUrl => 'https://api.groq.com/openai/v1';
  static String get _apiKey =>
      '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'; // <-- Replace with your actual key
  static String get _modelName => 'deepseek-r1-distill-llama-70b';

  Future<Map<String, dynamic>> generateMealPlan({
    required double targetCalories,
    required List<String> preferences,
    required List<String> restrictions,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful nutrition assistant that creates meal plans.'
            },
            {
              'role': 'user',
              'content': 'Generate a meal plan with the following parameters: '
                  'Target calories: $targetCalories, '
                  'Preferences: ${preferences.join(", ")}, '
                  'Restrictions: ${restrictions.join(", ")}. '
                  'Format the response as JSON with breakfast, lunch, dinner, and snacks.'
            }
          ],
          'response_format': {'type': 'json_object'}
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Ensure the response contains 'choices' and 'message' before accessing
        if (responseData['choices'] == null ||
            responseData['choices'].isEmpty) {
          throw Exception('Invalid API response: No choices found.');
        }
        final mealPlanJson =
            jsonDecode(responseData['choices'][0]['message']['content']);

        // Ensure the decoded meal plan is not null or empty
        if (mealPlanJson == null || mealPlanJson.isEmpty) {
          throw Exception('Invalid API response: Meal plan data is empty.');
        }

        return mealPlanJson;
      } else {
        throw Exception(
            'Failed to generate meal plan: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error connecting to Groq AI: $e');
    }
  }

  Future<Map<String, dynamic>> analyzeImage(String imagePath) async {
    final File imageFile = File(imagePath);
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    try {
      // Note: Groq may not support direct image analysis, so we're using text prompting
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': _modelName,
          'messages': [
            {
              'role': 'system',
              'content':
                  'You are a helpful assistant that analyzes food images and provides nutritional information.'
            },
            {
              'role': 'user',
              'content':
                  'I have an image of food encoded in base64. Please analyze it and provide nutritional information in JSON format.'
                      'Here is the image: data:image/jpeg;base64,$base64Image'
            }
          ],
          'response_format': {'type': 'json_object'}
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Ensure the response contains 'choices' and 'message' before accessing
        if (responseData['choices'] == null ||
            responseData['choices'].isEmpty) {
          throw Exception('Invalid API response: No choices found.');
        }

        final analysisJson =
            jsonDecode(responseData['choices'][0]['message']['content']);

        // Ensure the decoded analysis is not null or empty
        if (analysisJson == null || analysisJson.isEmpty) {
          throw Exception(
              'Invalid API response: Image analysis data is empty.');
        }

        return analysisJson;
      } else {
        throw Exception(
            'Failed to analyze image: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      throw Exception('Error analyzing image: $e');
    }
  }
}
