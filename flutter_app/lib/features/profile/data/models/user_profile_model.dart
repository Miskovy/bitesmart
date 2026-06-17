import 'package:equatable/equatable.dart';
import 'macro_targets_model.dart';
import 'profile_setup_model.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String? displayName;
  final String email;
  final String? profileImageUrl;
  final String? phone;
  final String? userGoal;
  final String? activityLevel;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final double? bmi;
  final int? loginStreak;
  final int? xp;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final MedicalConditionsData? medicalConditions;
  final DietaryPreferencesData? dietaryPreferences;
  final MacroTargetsModel? targets;

  const UserProfileModel({
    required this.id,
    required this.email,
    this.displayName,
    this.profileImageUrl,
    this.phone,
    this.userGoal,
    this.activityLevel,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.bmi,
    this.loginStreak,
    this.xp,
    this.createdAt,
    this.updatedAt,
    this.medicalConditions,
    this.dietaryPreferences,
    this.targets,
  });

  // Copy with method
  UserProfileModel copyWith({
    String? id,
    String? displayName,
    String? email,
    String? profileImageUrl,
    String? phone,
    String? userGoal,
    String? activityLevel,
    int? age,
    String? gender,
    double? height,
    double? weight,
    double? bmi,
    int? loginStreak,
    int? xp,
    DateTime? createdAt,
    DateTime? updatedAt,
    MedicalConditionsData? medicalConditions,
    DietaryPreferencesData? dietaryPreferences,
    MacroTargetsModel? targets,
  }) {
    return UserProfileModel(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      phone: phone ?? this.phone,
      userGoal: userGoal ?? this.userGoal,
      activityLevel: activityLevel ?? this.activityLevel,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      loginStreak: loginStreak ?? this.loginStreak,
      xp: xp ?? this.xp,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      targets: targets ?? this.targets,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> jsonMap = {
      'id': id,
      'displayName': displayName,
      'name': displayName,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'avatar': profileImageUrl,
      'phone': phone,
      'userGoal': userGoal,
      'activityLevel': activityLevel,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'loginStreak': loginStreak,
      'xp': xp,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'targets': targets?.toJson(),
    };
    if (bmi != null) {
      jsonMap['bmi'] = bmi;
      jsonMap['BMI'] = bmi;
    }
    if (medicalConditions != null) {
      jsonMap['medicalConditions'] = medicalConditions!.toJson();
    }
    if (dietaryPreferences != null) {
      jsonMap['dietaryPreferences'] = dietaryPreferences!.toJson();
    }
    return jsonMap;
  }

  static String? _resolveAvatarUrl(dynamic avatar) {
    if (avatar == null || avatar is! String || avatar.isEmpty) return null;
    if (avatar.startsWith('/uploads')) {
      return 'https://bitesmart-production.up.railway.app$avatar';
    }
    if (avatar.contains('localhost:3000')) {
      return avatar.replaceFirst('http://localhost:3000', 'https://bitesmart-production.up.railway.app');
    }
    return avatar;
  }

  // Convert from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (json['displayName'] ?? json['name']) as String?,
      profileImageUrl: _resolveAvatarUrl(json['profileImageUrl'] ?? json['avatar']),
      phone: json['phone'] as String?,
      userGoal: json['userGoal'] as String?,
      activityLevel: json['activityLevel'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      bmi: (json['bmi'] ?? json['BMI'] as num?)?.toDouble(),
      loginStreak: (json['loginStreak'] ?? json['login_streak']) as int?,
      xp: json['xp'] as int?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      medicalConditions: json['medicalConditions'] != null
          ? MedicalConditionsData.fromJson(json['medicalConditions'] as Map<String, dynamic>)
          : null,
      dietaryPreferences: json['dietaryPreferences'] != null
          ? DietaryPreferencesData.fromJson(json['dietaryPreferences'] as Map<String, dynamic>)
          : null,
      targets: json['targets'] != null
          ? MacroTargetsModel.fromJson(json['targets'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        email,
        profileImageUrl,
        phone,
        userGoal,
        activityLevel,
        age,
        gender,
        height,
        weight,
        bmi,
        loginStreak,
        xp,
        createdAt,
        updatedAt,
        medicalConditions,
        dietaryPreferences,
        targets,
      ];
}
