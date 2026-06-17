import 'package:equatable/equatable.dart';

class MacroTargetsModel extends Equatable {
  final String id;
  final String userId;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int calorieTarget;
  final int waterMl;
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
    this.waterMl = 2000,
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
    int? waterMl,
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
      waterMl: waterMl ?? this.waterMl,
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
      'proteins': proteinTarget,
      'carbsTarget': carbsTarget,
      'carbs': carbsTarget,
      'fatTarget': fatTarget,
      'fats': fatTarget,
      'calorieTarget': calorieTarget,
      'calTotal': calorieTarget,
      'waterMl': waterMl,
      'water_ml': waterMl,
      'useAiToggle': useAiToggle,
      'autoCalculateWithAi': useAiToggle,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory MacroTargetsModel.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic val, int fallback) {
      if (val == null) return fallback;
      if (val is num) return val.toInt();
      if (val is String) return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? fallback;
      return fallback;
    }

    return MacroTargetsModel(
      id: (json['id'] ?? '') as String,
      userId: (json['userId'] ?? '') as String,
      proteinTarget: toInt(json['proteinTarget'] ?? json['proteins'], 150),
      carbsTarget: toInt(json['carbsTarget'] ?? json['carbs'], 225),
      fatTarget: toInt(json['fatTarget'] ?? json['fats'], 75),
      calorieTarget: toInt(json['calorieTarget'] ?? json['calTotal'], 2000),
      waterMl: toInt(json['waterMl'] ?? json['water_ml'], 2000),
      useAiToggle: (json['useAiToggle'] ?? json['autoCalculateWithAi'] ?? false) as bool,
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
        waterMl,
        useAiToggle,
        createdAt,
        updatedAt,
      ];
}
