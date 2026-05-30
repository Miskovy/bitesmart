import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_state.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProfileSetupBloc extends Bloc<ProfileSetupEvent, ProfileSetupState> {
  final IProfileRepository profileRepository;

  ProfileSetupBloc({required this.profileRepository})
      : super(const ProfileSetupState()) {
    on<SetGoalEvent>(_onSetGoal);
    on<SetMedicalConditionsEvent>(_onSetMedicalConditions);
    on<SetPersonalDataEvent>(_onSetPersonalData);
    on<SetActivityLevelEvent>(_onSetActivityLevel);
    on<SetDietaryPreferencesEvent>(_onSetDietaryPreferences);
    on<SetTargetsEvent>(_onSetTargets);
    on<SubmitProfileSetupEvent>(_onSubmitProfileSetup);
    on<ResetProfileSetupEvent>((event, emit) {
      emit(const ProfileSetupState());
    });
  }

  void _onSetGoal(SetGoalEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(userGoal: event.goal),
      status: ProfileSetupStatus.collecting,
    ));
  }

  void _onSetMedicalConditions(
      SetMedicalConditionsEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(medicalConditions: event.medicalConditions),
      status: ProfileSetupStatus.collecting,
    ));
  }

  void _onSetPersonalData(
      SetPersonalDataEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(
        gender: event.gender,
        age: event.age,
        height: event.height,
        weight: event.weight,
      ),
      status: ProfileSetupStatus.collecting,
    ));
  }

  void _onSetActivityLevel(
      SetActivityLevelEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(activityLevel: event.activityLevel),
      status: ProfileSetupStatus.collecting,
    ));
  }

  void _onSetDietaryPreferences(
      SetDietaryPreferencesEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(dietaryPreferences: event.dietaryPreferences),
      status: ProfileSetupStatus.collecting,
    ));
  }

  void _onSetTargets(SetTargetsEvent event, Emitter<ProfileSetupState> emit) {
    emit(state.copyWith(
      data: state.data.copyWith(targets: event.targets),
      status: ProfileSetupStatus.collecting,
    ));
  }

  Future<void> _onSubmitProfileSetup(
      SubmitProfileSetupEvent event, Emitter<ProfileSetupState> emit) async {
    emit(state.copyWith(status: ProfileSetupStatus.submitting));
    try {
      await profileRepository.submitProfileSetup(state.data);
      emit(state.copyWith(status: ProfileSetupStatus.success));
    } catch (e) {
      emit(state.copyWith(
        status: ProfileSetupStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
