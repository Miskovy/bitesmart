import 'package:equatable/equatable.dart';
import '../models/macro_targets_model.dart';
import '../models/profile_setup_model.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

// Initial state
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

// Loading state
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

// Profile loaded state
class ProfileLoaded extends ProfileState {
  final String userId;
  final String? displayName;
  final String? email;
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
  final MedicalConditionsData? medicalConditions;
  final DietaryPreferencesData? dietaryPreferences;
  final MacroTargetsModel? targets;

  const ProfileLoaded({
    required this.userId,
    this.displayName,
    this.email,
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
    this.medicalConditions,
    this.dietaryPreferences,
    this.targets,
  });

  @override
  List<Object?> get props => [
        userId,
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
        medicalConditions,
        dietaryPreferences,
        targets,
      ];
}

// Dietary preferences updated state
class DietaryPreferencesUpdated extends ProfileState {
  final List<String> selectedDiets;
  final List<String> selectedAllergens;
  final String? message;

  const DietaryPreferencesUpdated({
    required this.selectedDiets,
    required this.selectedAllergens,
    this.message,
  });

  @override
  List<Object?> get props => [selectedDiets, selectedAllergens, message];
}

// Macro targets updated state
class MacroTargetsUpdated extends ProfileState {
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int calorieTarget;
  final String? message;

  const MacroTargetsUpdated({
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.calorieTarget,
    this.message,
  });

  @override
  List<Object?> get props => [
        proteinTarget,
        carbsTarget,
        fatTarget,
        calorieTarget,
        message,
      ];
}

// Medical information updated state
class MedicalInfoUpdated extends ProfileState {
  final List<String> conditions;
  final List<String> medications;
  final String? message;

  const MedicalInfoUpdated({
    required this.conditions,
    required this.medications,
    this.message,
  });

  @override
  List<Object?> get props => [conditions, medications, message];
}

// Goal selected state
class GoalSelected extends ProfileState {
  final String goal;
  final String? message;

  const GoalSelected({
    required this.goal,
    this.message,
  });

  @override
  List<Object?> get props => [goal, message];
}

// Profile updated state
class ProfileUpdated extends ProfileState {
  final String? message;

  const ProfileUpdated({this.message});

  @override
  List<Object?> get props => [message];
}

// Error state
class ProfileError extends ProfileState {
  final String message;
  final String? code;

  const ProfileError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
