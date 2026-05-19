import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

// Initial state
class HomeInitial extends HomeState {
  const HomeInitial();
}

// Loading state
class HomeLoading extends HomeState {
  const HomeLoading();
}

// Meals loaded state
class HomeMealsLoaded extends HomeState {
  final List<dynamic> meals;
  final int remainingCalories;
  final Map<String, int> macros;

  const HomeMealsLoaded({
    required this.meals,
    required this.remainingCalories,
    required this.macros,
  });

  @override
  List<Object?> get props => [meals, remainingCalories, macros];
}

// Meal added state
class HomeMealAdded extends HomeState {
  final String mealId;
  final String mealName;
  final int calories;
  final String? message;

  const HomeMealAdded({
    required this.mealId,
    required this.mealName,
    required this.calories,
    this.message,
  });

  @override
  List<Object?> get props => [mealId, mealName, calories, message];
}

// Hydration updated state
class HomeHydrationUpdated extends HomeState {
  final int glassesConsumed;
  final int targetGlasses;

  const HomeHydrationUpdated({
    required this.glassesConsumed,
    required this.targetGlasses,
  });

  @override
  List<Object?> get props => [glassesConsumed, targetGlasses];
}

// Camera screen state
class HomeCameraReady extends HomeState {
  const HomeCameraReady();
}

// Meal analyzed state
class HomeMealAnalyzed extends HomeState {
  final String mealName;
  final int calories;
  final Map<String, int> macros;
  final String? message;

  const HomeMealAnalyzed({
    required this.mealName,
    required this.calories,
    required this.macros,
    this.message,
  });

  @override
  List<Object?> get props => [mealName, calories, macros, message];
}

// Error state
class HomeError extends HomeState {
  final String message;
  final String? code;

  const HomeError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}
