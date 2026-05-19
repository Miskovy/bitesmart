import 'package:bite_smart/features/home/data/models/nutrition_model.dart';
import 'package:equatable/equatable.dart';

class MealModel extends Equatable {
  final String id;
  final String name;
  final int calories;
  final DateTime dateTime;
  final String? imageUrl;
  final String? description;
  final NutritionModel? nutrition;

  const MealModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.dateTime,
    this.imageUrl,
    this.description,
    this.nutrition,
  });

  // Copy with method
  MealModel copyWith({
    String? id,
    String? name,
    int? calories,
    DateTime? dateTime,
    String? imageUrl,
    String? description,
    NutritionModel? nutrition,
  }) {
    return MealModel(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      dateTime: dateTime ?? this.dateTime,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      nutrition: nutrition ?? this.nutrition,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'dateTime': dateTime.toIso8601String(),
      'imageUrl': imageUrl,
      'description': description,
      'nutrition': nutrition?.toJson(),
    };
  }

  // Convert from JSON
  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as String,
      name: json['name'] as String,
      calories: json['calories'] as int,
      dateTime: DateTime.parse(json['dateTime'] as String),
      imageUrl: json['imageUrl'] as String?,
      description: json['description'] as String?,
      nutrition: json['nutrition'] != null
          ? NutritionModel.fromJson(json['nutrition'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        calories,
        dateTime,
        imageUrl,
        description,
        nutrition,
      ];
}
