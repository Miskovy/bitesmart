import 'package:equatable/equatable.dart';

class MacroTargetsModel extends Equatable {
  final String id;
  final String userId;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int calorieTarget;
  final bool useAiToggle;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MacroTargetsModel({
    required this.id,
    required this.userId,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.calorieTarget,
    this.useAiToggle = false,
    this.createdAt,
    this.updatedAt,
  });

  // Copy with method
  MacroTargetsModel copyWith({
    String? id,
    String? userId,
    int? proteinTarget,
    int? carbsTarget,
    int? fatTarget,
    int? calorieTarget,
    bool? useAiToggle,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MacroTargetsModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      useAiToggle: useAiToggle ?? this.useAiToggle,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'proteinTarget': proteinTarget,
      'carbsTarget': carbsTarget,
      'fatTarget': fatTarget,
      'calorieTarget': calorieTarget,
      'useAiToggle': useAiToggle,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory MacroTargetsModel.fromJson(Map<String, dynamic> json) {
    return MacroTargetsModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      proteinTarget: json['proteinTarget'] as int,
      carbsTarget: json['carbsTarget'] as int,
      fatTarget: json['fatTarget'] as int,
      calorieTarget: json['calorieTarget'] as int,
      useAiToggle: json['useAiToggle'] as bool? ?? false,
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
        proteinTarget,
        carbsTarget,
        fatTarget,
        calorieTarget,
        useAiToggle,
        createdAt,
        updatedAt,
      ];
}
