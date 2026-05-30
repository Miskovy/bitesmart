import 'package:bite_smart/core/network/api_service.dart';
import 'package:bite_smart/features/profile/data/models/dietary_preference_model.dart';
import 'package:bite_smart/features/profile/data/models/macro_targets_model.dart';
import 'package:bite_smart/features/profile/data/models/user_profile_model.dart';
import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';

abstract class IProfileRepository {
  Future<UserProfileModel> getUserProfile({required String userId});
  Future<UserProfileModel> updateUserProfile({
    required String userId,
    required UserProfileModel profile,
  });
  Future<DietaryPreferenceModel> getDietaryPreferences({required String userId});
  Future<DietaryPreferenceModel> updateDietaryPreferences({
    required String userId,
    required DietaryPreferenceModel preferences,
  });
  Future<MacroTargetsModel> getMacroTargets({required String userId});
  Future<MacroTargetsModel> updateMacroTargets({
    required String userId,
    required MacroTargetsModel targets,
  });
  Future<void> submitProfileSetup(ProfileSetupModel data);
  Future<String> uploadAvatar({required String userId, required String filePath});
}

class ProfileRepository implements IProfileRepository {
  @override
  Future<void> submitProfileSetup(ProfileSetupModel data) async {
    final responseData = await ApiService.instance.put('/profile', data.toJson());
    if (responseData['success'] != true) {
      throw Exception(responseData['message'] ?? 'Failed to submit profile setup');
    }
  }

  @override
  Future<UserProfileModel> getUserProfile({required String userId}) async {
    try {
      final responseData = await ApiService.instance.get('/profile');
      if (responseData['success'] == true) {
        final profileMap = responseData['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      // Fallback if endpoint is not fully ready or returns 404
      return UserProfileModel(
        id: userId,
        email: 'user@example.com',
        displayName: 'User',
      );
    }
  }

  @override
  Future<UserProfileModel> updateUserProfile({
    required String userId,
    required UserProfileModel profile,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (profile.displayName != null) data['name'] = profile.displayName;
      if (profile.age != null) data['age'] = profile.age;
      if (profile.gender != null) data['gender'] = profile.gender;
      if (profile.height != null) data['height'] = profile.height;
      if (profile.weight != null) data['weight'] = profile.weight;
      if (profile.profileImageUrl != null) data['avatar'] = profile.profileImageUrl;
      if (profile.phone != null) data['phone'] = profile.phone;
      if (profile.userGoal != null) data['userGoal'] = profile.userGoal;
      if (profile.activityLevel != null) data['activityLevel'] = profile.activityLevel;

      final responseData = await ApiService.instance.put('/profile', data);
      if (responseData['success'] == true) {
        final profileMap = responseData['data'] as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      return profile;
    }
  }

  @override
  Future<DietaryPreferenceModel> getDietaryPreferences({
    required String userId,
  }) async {
    try {
      final responseData = await ApiService.instance.get('/profile/dietary');
      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        return DietaryPreferenceModel.fromJson(data);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load dietary preferences');
      }
    } catch (e) {
      return DietaryPreferenceModel(
        id: 'dietary_default',
        userId: userId,
        dietTypes: const [],
        allergens: const [],
      );
    }
  }

  @override
  Future<DietaryPreferenceModel> updateDietaryPreferences({
    required String userId,
    required DietaryPreferenceModel preferences,
  }) async {
    try {
      final responseData = await ApiService.instance.put(
        '/profile/dietary',
        preferences.toJson(),
      );
      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        return DietaryPreferenceModel.fromJson(data);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update dietary preferences');
      }
    } catch (e) {
      return preferences;
    }
  }

  @override
  Future<MacroTargetsModel> getMacroTargets({required String userId}) async {
    try {
      final responseData = await ApiService.instance.get('/profile/macros');
      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        return MacroTargetsModel.fromJson(data);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load macro targets');
      }
    } catch (e) {
      return MacroTargetsModel(
        id: 'macros_default',
        userId: userId,
        proteinTarget: 150,
        carbsTarget: 225,
        fatTarget: 75,
        calorieTarget: 2000,
      );
    }
  }

  @override
  Future<MacroTargetsModel> updateMacroTargets({
    required String userId,
    required MacroTargetsModel targets,
  }) async {
    try {
      final responseData = await ApiService.instance.put(
        '/profile/macros',
        targets.toJson(),
      );
      if (responseData['success'] == true) {
        final data = responseData['data'] as Map<String, dynamic>;
        return MacroTargetsModel.fromJson(data);
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update macro targets');
      }
    } catch (e) {
      return targets;
    }
  }

  @override
  Future<String> uploadAvatar({required String userId, required String filePath}) async {
    final responseData = await ApiService.instance.postMultipart(
      '/profile/avatar',
      fileKey: 'avatar',
      filePath: filePath,
    );
    if (responseData['success'] == true) {
      final data = responseData['data'] as Map<String, dynamic>;
      final avatarUrl = data['avatarUrl'] as String;
      if (avatarUrl.startsWith('/uploads')) {
        return 'https://bitesmart-production.up.railway.app$avatarUrl';
      }
      return avatarUrl;
    } else {
      throw Exception(responseData['message'] ?? 'Failed to upload avatar');
    }
  }
}
