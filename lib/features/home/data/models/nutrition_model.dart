import 'package:equatable/equatable.dart';

class NutritionModel extends Equatable {
  final int protein;
  final int carbs;
  final int fat;
  final int fiber;
  final int sugar;
  final int sodium;

  const NutritionModel({
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
  });

  // Copy with method
  NutritionModel copyWith({
    int? protein,
    int? carbs,
    int? fat,
    int? fiber,
    int? sugar,
    int? sodium,
  }) {
    return NutritionModel(
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      fiber: fiber ?? this.fiber,
      sugar: sugar ?? this.sugar,
      sodium: sodium ?? this.sodium,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sugar': sugar,
      'sodium': sodium,
    };
  }

  // Convert from JSON
  factory NutritionModel.fromJson(Map<String, dynamic> json) {
    return NutritionModel(
      protein: json['protein'] as int,
      carbs: json['carbs'] as int,
      fat: json['fat'] as int,
      fiber: json['fiber'] as int? ?? 0,
      sugar: json['sugar'] as int? ?? 0,
      sodium: json['sodium'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [protein, carbs, fat, fiber, sugar, sodium];
}
