import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bite_smart/features/home/data/models/meal_model.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';

// Events
abstract class PredictionEvent extends Equatable {
  const PredictionEvent();
  @override
  List<Object?> get props => [];
}

class AnalyzeImageEvent extends PredictionEvent {
  final String imagePath;
  final double foodWidthCm;
  final bool isCalibration;

  const AnalyzeImageEvent({
    required this.imagePath,
    required this.foodWidthCm,
    this.isCalibration = false,
  });

  @override
  List<Object?> get props => [imagePath, foodWidthCm, isCalibration];
}

// States
abstract class PredictionState extends Equatable {
  const PredictionState();
  @override
  List<Object?> get props => [];
}

class PredictionInitial extends PredictionState {}

class PredictionLoading extends PredictionState {}

class PredictionSuccess extends PredictionState {
  final MealModel meal;
  const PredictionSuccess(this.meal);

  @override
  List<Object?> get props => [meal];
}

class PredictionError extends PredictionState {
  final String message;
  const PredictionError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class PredictionBloc extends Bloc<PredictionEvent, PredictionState> {
  final IHomeRepository homeRepository;

  PredictionBloc({required this.homeRepository}) : super(PredictionInitial()) {
    on<AnalyzeImageEvent>(_onAnalyzeImage);
  }

  Future<void> _onAnalyzeImage(
    AnalyzeImageEvent event,
    Emitter<PredictionState> emit,
  ) async {
    emit(PredictionLoading());
    try {
      final meal = await homeRepository.analyzeMealFromImage(
        imagePath: event.imagePath,
        foodWidthCm: event.foodWidthCm,
        isCalibration: event.isCalibration,
      );
      emit(PredictionSuccess(meal));
    } catch (e) {
      emit(PredictionError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
