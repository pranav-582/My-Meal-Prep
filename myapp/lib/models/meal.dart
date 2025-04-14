class Meal {
  final String id;
  final String name;
  final String type; // breakfast, lunch, dinner, or snack
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final double fat; // Add this line

  Meal({
    required this.id,
    required this.name,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.fat, // Add this line
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      calories: (json['calories'] as num).toDouble(),
      protein: (json['protein'] as num).toDouble(),
      carbs: (json['carbs'] as num).toDouble(),
      fats: (json['fats'] as num).toDouble(),
      fat: (json['fat'] as num).toDouble(), // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'fat': fat, // Add this line
    };
  }
}
