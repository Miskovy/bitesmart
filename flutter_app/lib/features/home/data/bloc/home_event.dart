import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

// Load meals event
class LoadMealsEvent extends HomeEvent {
  final String userId;

  const LoadMealsEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}

// Add meal event
class AddMealEvent extends HomeEvent {
  final String mealName;
  final int calories;
  final Map<String, int> macros;

  const AddMealEvent({
    required this.mealName,
    required this.calories,
    required this.macros,
  });

  @override
  List<Object?> get props => [mealName, calories, macros];
}

// Remove meal event
class RemoveMealEvent extends HomeEvent {
  final String mealId;

  const RemoveMealEvent({required this.mealId});

  @override
  List<Object?> get props => [mealId];
}

// Update hydration event
class UpdateHydrationEvent extends HomeEvent {
  final int glassesConsumed;

  const UpdateHydrationEvent({required this.glassesConsumed});

  @override
  List<Object?> get props => [glassesConsumed];
}

// Open camera event
class OpenCameraEvent extends HomeEvent {
  const OpenCameraEvent();
}

// Analyze meal from image event
class AnalyzeMealEvent extends HomeEvent {
  final String imagePath;

  const AnalyzeMealEvent({required this.imagePath});

  @override
  List<Object?> get props => [imagePath];
}

// Refresh home data event
class RefreshHomeDataEvent extends HomeEvent {
  final String userId;

  const RefreshHomeDataEvent({required this.userId});

  @override
  List<Object?> get props => [userId];
}
