import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_state.dart';
import 'package:bite_smart/features/profile/data/models/dietary_preference_model.dart';
import 'package:bite_smart/features/profile/data/models/macro_targets_model.dart';
import 'package:bite_smart/features/profile/data/models/user_profile_model.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IProfileRepository profileRepository;

  ProfileBloc({required this.profileRepository}) : super(const ProfileInitial()) {
    on<LoadProfileEvent>(_onLoadProfileEvent);
    on<UpdateProfileEvent>(_onUpdateProfileEvent);
    on<UploadAvatarEvent>(_onUploadAvatarEvent);
    on<UpdateDietaryPreferencesEvent>(_onUpdateDietaryPreferencesEvent);
    on<UpdateMacroTargetsEvent>(_onUpdateMacroTargetsEvent);
    on<UpdateMedicalInfoEvent>(_onUpdateMedicalInfoEvent);
    on<SelectGoalEvent>(_onSelectGoalEvent);
    on<LoadDietaryPreferencesEvent>(_onLoadDietaryPreferencesEvent);
    on<LoadMacroTargetsEvent>(_onLoadMacroTargetsEvent);
  }

  // Handle load profile
  Future<void> _onLoadProfileEvent(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final profile =
          await profileRepository.getUserProfile(userId: event.userId);
      emit(ProfileLoaded(
        userId: profile.id,
        displayName: profile.displayName,
        email: profile.email,
        profileImageUrl: profile.profileImageUrl,
        phone: profile.phone,
        userGoal: profile.userGoal,
        activityLevel: profile.activityLevel,
        age: profile.age,
        gender: profile.gender,
        height: profile.height,
        weight: profile.weight,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle update profile
  Future<void> _onUpdateProfileEvent(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final updatedProfile = UserProfileModel(
        id: event.userId,
        email: event.email ?? '',
        displayName: event.displayName,
        profileImageUrl: event.profileImageUrl,
        phone: event.phone,
        userGoal: event.userGoal,
        activityLevel: event.activityLevel,
        age: event.age,
        gender: event.gender,
        height: event.height,
        weight: event.weight,
      );

      await profileRepository.updateUserProfile(
        userId: event.userId,
        profile: updatedProfile,
      );

      emit(ProfileLoaded(
        userId: event.userId,
        displayName: event.displayName,
        email: event.email,
        profileImageUrl: event.profileImageUrl,
        phone: event.phone,
        userGoal: event.userGoal,
        activityLevel: event.activityLevel,
        age: event.age,
        gender: event.gender,
        height: event.height,
        weight: event.weight,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle update dietary preferences
  Future<void> _onUpdateDietaryPreferencesEvent(
    UpdateDietaryPreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final preferences = DietaryPreferenceModel(
        id: 'dietary_${event.userId}',
        userId: event.userId,
        dietTypes: event.selectedDiets,
        allergens: event.selectedAllergens,
      );

      await profileRepository.updateDietaryPreferences(
        userId: event.userId,
        preferences: preferences,
      );

      emit(DietaryPreferencesUpdated(
        selectedDiets: event.selectedDiets,
        selectedAllergens: event.selectedAllergens,
        message: 'Dietary preferences updated successfully',
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle update macro targets
  Future<void> _onUpdateMacroTargetsEvent(
    UpdateMacroTargetsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final targets = MacroTargetsModel(
        id: 'macros_${event.userId}',
        userId: event.userId,
        proteinTarget: event.proteinTarget,
        carbsTarget: event.carbsTarget,
        fatTarget: event.fatTarget,
        calorieTarget: event.calorieTarget,
      );

      await profileRepository.updateMacroTargets(
        userId: event.userId,
        targets: targets,
      );

      emit(MacroTargetsUpdated(
        proteinTarget: event.proteinTarget,
        carbsTarget: event.carbsTarget,
        fatTarget: event.fatTarget,
        calorieTarget: event.calorieTarget,
        message: 'Macro targets updated successfully',
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle update medical info
  Future<void> _onUpdateMedicalInfoEvent(
    UpdateMedicalInfoEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // TODO: Implement medical info update
      emit(MedicalInfoUpdated(
        conditions: event.conditions,
        medications: event.medications,
        message: 'Medical information updated successfully',
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle select goal
  Future<void> _onSelectGoalEvent(
    SelectGoalEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      // TODO: Implement goal selection
      emit(GoalSelected(
        goal: event.goal,
        message: 'Goal selected successfully',
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle load dietary preferences
  Future<void> _onLoadDietaryPreferencesEvent(
    LoadDietaryPreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final preferences = await profileRepository.getDietaryPreferences(
        userId: event.userId,
      );
      emit(DietaryPreferencesUpdated(
        selectedDiets: preferences.dietTypes,
        selectedAllergens: preferences.allergens,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle load macro targets
  Future<void> _onLoadMacroTargetsEvent(
    LoadMacroTargetsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final targets = await profileRepository.getMacroTargets(
        userId: event.userId,
      );
      emit(MacroTargetsUpdated(
        proteinTarget: targets.proteinTarget,
        carbsTarget: targets.carbsTarget,
        fatTarget: targets.fatTarget,
        calorieTarget: targets.calorieTarget,
      ));
    } catch (e) {
      emit(ProfileError(message: e.toString()));
    }
  }

  // Handle upload avatar
  Future<void> _onUploadAvatarEvent(
    UploadAvatarEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(const ProfileLoading());
    try {
      final newAvatarUrl = await profileRepository.uploadAvatar(
        userId: event.userId,
        filePath: event.filePath,
      );
      
      if (currentState is ProfileLoaded) {
        emit(ProfileLoaded(
          userId: currentState.userId,
          displayName: currentState.displayName,
          email: currentState.email,
          profileImageUrl: newAvatarUrl,
          phone: currentState.phone,
          userGoal: currentState.userGoal,
          activityLevel: currentState.activityLevel,
          age: currentState.age,
          gender: currentState.gender,
          height: currentState.height,
          weight: currentState.weight,
        ));
      } else {
        final profile = await profileRepository.getUserProfile(userId: event.userId);
        emit(ProfileLoaded(
          userId: profile.id,
          displayName: profile.displayName,
          email: profile.email,
          profileImageUrl: newAvatarUrl,
          phone: profile.phone,
          userGoal: profile.userGoal,
          activityLevel: profile.activityLevel,
          age: profile.age,
          gender: profile.gender,
          height: profile.height,
          weight: profile.weight,
        ));
      }
    } catch (e) {
      emit(ProfileError(message: e.toString()));
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }
}
