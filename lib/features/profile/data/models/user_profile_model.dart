import 'package:equatable/equatable.dart';

class UserProfileModel extends Equatable {
  final String id;
  final String? displayName;
  final String email;
  final String? profileImageUrl;
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
      'email': email,
      'profileImageUrl': profileImageUrl,
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
      displayName: json['displayName'] as String?,
      profileImageUrl: json['profileImageUrl'] as String?,
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      height: json['height'] as double?,
      weight: json['weight'] as double?,
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
        age,
        gender,
        height,
        weight,
        createdAt,
        updatedAt,
      ];
}
