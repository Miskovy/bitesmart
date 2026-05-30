import 'package:equatable/equatable.dart';

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
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
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
    DateTime? createdAt,
    DateTime? updatedAt,
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
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Convert from JSON
  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: (json['displayName'] ?? json['name']) as String?,
      profileImageUrl: (json['profileImageUrl'] ?? json['avatar']) as String?,
      phone: json['phone'] as String?,
      userGoal: json['userGoal'] as String?,
      activityLevel: json['activityLevel'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
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
        createdAt,
        updatedAt,
      ];
}
