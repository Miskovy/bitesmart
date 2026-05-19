import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/home/data/bloc/home_event.dart';
import 'package:bite_smart/features/home/data/bloc/home_state.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:bite_smart/features/home/data/models/meal_model.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IHomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(const HomeInitial()) {
    on<LoadMealsEvent>(_onLoadMealsEvent);
    on<AddMealEvent>(_onAddMealEvent);
    on<RemoveMealEvent>(_onRemoveMealEvent);
    on<UpdateHydrationEvent>(_onUpdateHydrationEvent);
    on<OpenCameraEvent>(_onOpenCameraEvent);
    on<AnalyzeMealEvent>(_onAnalyzeMealEvent);
    on<RefreshHomeDataEvent>(_onRefreshHomeDataEvent);
  }

  // Handle load meals
  Future<void> _onLoadMealsEvent(
    LoadMealsEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final meals = await homeRepository.getMeals(userId: event.userId);
      final calories = await homeRepository.getTodayCalories(userId: event.userId);
      final macros = await homeRepository.getTodayMacros(userId: event.userId);
      
      emit(HomeMealsLoaded(
        meals: meals,
        remainingCalories: 2000 - calories, // Assuming 2000 is daily target
        macros: macros,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Handle add meal
  Future<void> _onAddMealEvent(
    AddMealEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final meal = MealModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.mealName,
        calories: event.calories,
        dateTime: DateTime.now(),
      );
      
      final addedMeal = await homeRepository.addMeal(meal: meal);
      
      emit(HomeMealAdded(
        mealId: addedMeal.id,
        mealName: addedMeal.name,
        calories: addedMeal.calories,
        message: 'Meal added successfully',
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Handle remove meal
  Future<void> _onRemoveMealEvent(
    RemoveMealEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      await homeRepository.removeMeal(mealId: event.mealId);
      emit(const HomeInitial());
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Handle update hydration
  Future<void> _onUpdateHydrationEvent(
    UpdateHydrationEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      // Assuming 8 glasses is the daily target
      await homeRepository.updateHydration(
        userId: 'current_user_id',
        glasses: event.glassesConsumed,
      );
      
      emit(HomeHydrationUpdated(
        glassesConsumed: event.glassesConsumed,
        targetGlasses: 8,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Handle open camera
  Future<void> _onOpenCameraEvent(
    OpenCameraEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeCameraReady());
  }

  // Handle analyze meal from image
  Future<void> _onAnalyzeMealEvent(
    AnalyzeMealEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final analyzedMeal = await homeRepository.analyzeMealFromImage(
        imagePath: event.imagePath,
      );
      
      emit(HomeMealAnalyzed(
        mealName: analyzedMeal.name,
        calories: analyzedMeal.calories,
        macros: {
          'protein': analyzedMeal.nutrition?.protein ?? 0,
          'carbs': analyzedMeal.nutrition?.carbs ?? 0,
          'fat': analyzedMeal.nutrition?.fat ?? 0,
        },
        message: 'Meal analyzed successfully',
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  // Handle refresh home data
  Future<void> _onRefreshHomeDataEvent(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      final meals = await homeRepository.getMeals(userId: event.userId);
      final calories = await homeRepository.getTodayCalories(userId: event.userId);
      final macros = await homeRepository.getTodayMacros(userId: event.userId);
      
      emit(HomeMealsLoaded(
        meals: meals,
        remainingCalories: 2000 - calories,
        macros: macros,
      ));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
