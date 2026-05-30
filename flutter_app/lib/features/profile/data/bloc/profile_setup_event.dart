import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileSetupEvent extends Equatable {
  const ProfileSetupEvent();

  @override
  List<Object?> get props => [];
}

class SetGoalEvent extends ProfileSetupEvent {
  final String goal;

  const SetGoalEvent(this.goal);

  @override
  List<Object?> get props => [goal];
}

class SetMedicalConditionsEvent extends ProfileSetupEvent {
  final MedicalConditionsData medicalConditions;

  const SetMedicalConditionsEvent(this.medicalConditions);

  @override
  List<Object?> get props => [medicalConditions];
}

class SetPersonalDataEvent extends ProfileSetupEvent {
  final String gender;
  final int age;
  final double height;
  final double weight;

  const SetPersonalDataEvent({
    required this.gender,
    required this.age,
    required this.height,
    required this.weight,
  });

  @override
  List<Object?> get props => [gender, age, height, weight];
}

class SetActivityLevelEvent extends ProfileSetupEvent {
  final String activityLevel;

  const SetActivityLevelEvent(this.activityLevel);

  @override
  List<Object?> get props => [activityLevel];
}

class SetDietaryPreferencesEvent extends ProfileSetupEvent {
  final DietaryPreferencesData dietaryPreferences;

  const SetDietaryPreferencesEvent(this.dietaryPreferences);

  @override
  List<Object?> get props => [dietaryPreferences];
}

class SetTargetsEvent extends ProfileSetupEvent {
  final TargetsData targets;

  const SetTargetsEvent(this.targets);

  @override
  List<Object?> get props => [targets];
}

class SubmitProfileSetupEvent extends ProfileSetupEvent {
  const SubmitProfileSetupEvent();
}

class ResetProfileSetupEvent extends ProfileSetupEvent {
  const ResetProfileSetupEvent();
}
