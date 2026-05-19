import 'package:equatable/equatable.dart';

class DietaryPreferenceModel extends Equatable {
  final String id;
  final String userId;
  final List<String> dietTypes;
  final List<String> allergens;
  final List<String> dislikes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DietaryPreferenceModel({
    required this.id,
    required this.userId,
    required this.dietTypes,
    required this.allergens,
    this.dislikes = const [],
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method
  DietaryPreferenceModel copyWith({
    String? id,
    String? userId,
    List<String>? dietTypes,
    List<String>? allergens,
    List<String>? dislikes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DietaryPreferenceModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      dietTypes: dietTypes ?? this.dietTypes,
      allergens: allergens ?? this.allergens,
      dislikes: dislikes ?? this.dislikes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'dietTypes': dietTypes,
      'allergens': allergens,
      'dislikes': dislikes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory DietaryPreferenceModel.fromJson(Map<String, dynamic> json) {
    return DietaryPreferenceModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      dietTypes: List<String>.from(json['dietTypes'] as List),
      allergens: List<String>.from(json['allergens'] as List),
      dislikes: json['dislikes'] != null
          ? List<String>.from(json['dislikes'] as List)
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        dietTypes,
        allergens,
        dislikes,
        createdAt,
        updatedAt,
      ];
}
