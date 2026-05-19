import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

// Load profile event
class LoadProfileEvent extends ProfileEvent {
  final String userId;

  const LoadProfileEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Update profile event
class UpdateProfileEvent extends ProfileEvent {
  final String userId;
  final String? displayName;
  final String? email;
  final String? profileImageUrl;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;

  const UpdateProfileEvent({
    required this.userId,
    this.displayName,
    this.email,
    this.profileImageUrl,
    this.age,
    this.gender,
    this.height,
    this.weight,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        profileImageUrl,
        age,
        gender,
        height,
        weight,
      ];
}

// Update dietary preferences event
class UpdateDietaryPreferencesEvent extends ProfileEvent {
  final String userId;
  final List<String> selectedDiets;
  final List<String> selectedAllergens;

  const UpdateDietaryPreferencesEvent({
    required this.userId,
    required this.selectedDiets,
    required this.selectedAllergens,
  });

  @override
  List<Object?> get props => [userId, selectedDiets, selectedAllergens];
}

// Update macro targets event
class UpdateMacroTargetsEvent extends ProfileEvent {
  final String userId;
  final int proteinTarget;
  final int carbsTarget;
  final int fatTarget;
  final int calorieTarget;

  const UpdateMacroTargetsEvent({
    required this.userId,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.calorieTarget,
  });

  @override
  List<Object?> get props => [
        userId,
        proteinTarget,
        carbsTarget,
        fatTarget,
        calorieTarget,
      ];
}

// Update medical information event
class UpdateMedicalInfoEvent extends ProfileEvent {
  final String userId;
  final List<String> conditions;
  final List<String> medications;

  const UpdateMedicalInfoEvent({
    required this.userId,
    required this.conditions,
    required this.medications,
  });

  @override
  List<Object?> get props => [userId, conditions, medications];
}

// Select goal event
class SelectGoalEvent extends ProfileEvent {
  final String userId;
  final String goal;

  const SelectGoalEvent({
    required this.userId,
    required this.goal,
  });

  @override
  List<Object?> get props => [userId, goal];
}

// Load dietary preferences event
class LoadDietaryPreferencesEvent extends ProfileEvent {
  final String userId;

  const LoadDietaryPreferencesEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Load macro targets event
class LoadMacroTargetsEvent extends ProfileEvent {
  final String userId;

  const LoadMacroTargetsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
