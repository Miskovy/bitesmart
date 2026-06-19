import 'package:bite_smart/features/profile/data/models/dietary_preference_model.dart';
import 'package:bite_smart/features/profile/data/models/macro_targets_model.dart';
import 'package:bite_smart/features/profile/data/models/user_profile_model.dart';
import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:bite_smart/features/profile/data/models/user_insights_model.dart';
import 'package:bite_smart/core/network/api_client.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

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
  Future<MacroTargetsModel> calculateTargets({required String userId});
  Future<UserInsightsModel> getUserInsights({required String range});
}

class ProfileRepository implements IProfileRepository {
  @override
  Future<void> submitProfileSetup(ProfileSetupModel data) async {
    final response = await ApiClient.instance.put('/profile', data: data.toJson());
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to submit profile setup');
    }
  }

  @override
  Future<UserProfileModel> getUserProfile({required String userId}) async {
    try {
      final response = await ApiClient.instance.get('/profile');
      final resBody = response.data;
      if (resBody['success'] == true) {
        final rawData = resBody['data'];
        final profileMap = (rawData is Map && rawData.containsKey('data')) 
            ? rawData['data'] as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } else {
        throw Exception(resBody['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
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
      if (profile.bmi != null) {
        data['bmi'] = profile.bmi;
        data['BMI'] = profile.bmi;
      }
      if (profile.profileImageUrl != null) {
        String avatarToSend = profile.profileImageUrl!;
        if (!avatarToSend.startsWith('data:image/')) {
          if (avatarToSend.startsWith('https://bitesmart-production.up.railway.app')) {
            avatarToSend = avatarToSend.replaceFirst('https://bitesmart-production.up.railway.app', '');
          } else if (avatarToSend.contains('localhost:3000')) {
            avatarToSend = avatarToSend.replaceFirst('http://localhost:3000', '');
          }
        }
        data['avatar'] = avatarToSend;
      }
      if (profile.phone != null) data['phone'] = profile.phone;
      if (profile.userGoal != null) data['userGoal'] = profile.userGoal;
      if (profile.activityLevel != null) data['activityLevel'] = profile.activityLevel;

      if (profile.medicalConditions != null) {
        data['medicalConditions'] = profile.medicalConditions!.toJson();
      }
      if (profile.dietaryPreferences != null) {
        data['dietaryPreferences'] = profile.dietaryPreferences!.toJson();
      }
      if (profile.targets != null) {
        data['targets'] = profile.targets!.toJson();
      }

      final response = await ApiClient.instance.put('/profile', data: data);
      final resBody = response.data;
      if (resBody['success'] == true) {
        final rawData = resBody['data'];
        final profileMap = (rawData is Map && rawData.containsKey('data')) 
            ? rawData['data'] as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        return UserProfileModel.fromJson(profileMap);
      } else {
        throw Exception(resBody['message'] ?? 'Failed to update profile');
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
      final response = await ApiClient.instance.get('/profile');
      final resBody = response.data;
      if (resBody['success'] == true) {
        final rawData = resBody['data'];
        final profileMap = (rawData is Map && rawData.containsKey('data')) 
            ? rawData['data'] as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        final dietaryPrefs = profileMap['dietaryPreferences'] as Map<String, dynamic>? ?? {};

        final List<String> dietTypes = [];
        if (dietaryPrefs['isVegetarian'] == true) dietTypes.add('vegetarian');
        if (dietaryPrefs['isVegan'] == true) dietTypes.add('vegan');
        if (dietaryPrefs['isKeto'] == true) dietTypes.add('keto');
        if (dietaryPrefs['isPaleo'] == true) dietTypes.add('paleo');
        if (dietaryPrefs['isGlutenFree'] == true) dietTypes.add('gluten_free');
        if (dietaryPrefs['isHalal'] == true) dietTypes.add('halal');
        if (dietaryPrefs['isPescatarian'] == true) dietTypes.add('pescatarian');

        return DietaryPreferenceModel(
          id: dietaryPrefs['id'] ?? 'dietary_$userId',
          userId: userId,
          dietTypes: dietTypes,
          allergens: const [],
        );
      } else {
        throw Exception(resBody['message'] ?? 'Failed to load dietary preferences');
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
      final payload = {
        "dietaryPreferences": {
          "isVegetarian": preferences.dietTypes.contains("vegetarian"),
          "isVegan": preferences.dietTypes.contains("vegan"),
          "isKeto": preferences.dietTypes.contains("keto"),
          "isPaleo": preferences.dietTypes.contains("paleo"),
          "isGlutenFree": preferences.dietTypes.contains("gluten_free"),
          "isHalal": preferences.dietTypes.contains("halal"),
          "isPescatarian": preferences.dietTypes.contains("pescatarian"),
        }
      };

      final response = await ApiClient.instance.put('/profile', data: payload);
      final resBody = response.data;
      if (resBody['success'] == true) {
        return preferences;
      } else {
        throw Exception(resBody['message'] ?? 'Failed to update dietary preferences');
      }
    } catch (e) {
      return preferences;
    }
  }

  @override
  Future<MacroTargetsModel> getMacroTargets({required String userId}) async {
    try {
      final response = await ApiClient.instance.get('/profile');
      final resBody = response.data;
      if (resBody['success'] == true) {
        final rawData = resBody['data'];
        final profileMap = (rawData is Map && rawData.containsKey('data')) 
            ? rawData['data'] as Map<String, dynamic>
            : rawData as Map<String, dynamic>;
        final targets = Map<String, dynamic>.from(profileMap['targets'] as Map? ?? {});
        if (!targets.containsKey('userId')) {
          targets['userId'] = userId;
        }

        return MacroTargetsModel.fromJson(targets);
      } else {
        throw Exception(resBody['message'] ?? 'Failed to load macro targets');
      }
    } catch (e) {
      return MacroTargetsModel(
        id: 'macros_default',
        userId: userId,
        proteinTarget: 150,
        carbsTarget: 225,
        fatTarget: 75,
        calorieTarget: 2000,
        waterMl: 2000,
      );
    }
  }

  @override
  Future<MacroTargetsModel> updateMacroTargets({
    required String userId,
    required MacroTargetsModel targets,
  }) async {
    try {
      final payload = {
        "targets": {
          "calTotal": targets.calorieTarget,
          "proteins": targets.proteinTarget,
          "carbs": targets.carbsTarget,
          "fats": targets.fatTarget,
          "water_ml": targets.waterMl,
          "autoCalculateWithAi": false,
        }
      };

      final response = await ApiClient.instance.put('/profile', data: payload);
      final resBody = response.data;
      if (resBody['success'] == true) {
        return targets;
      } else {
        throw Exception(resBody['message'] ?? 'Failed to update macro targets');
      }
    } catch (e) {
      return targets;
    }
  }

  @override
  Future<String> uploadAvatar({required String userId, required String filePath}) async {
    final file = XFile(filePath);
    final bytes = await file.readAsBytes();

    final extension = filePath.split('.').last.toLowerCase();
    String mimeType = 'image/jpeg';
    if (extension == 'png') {
      mimeType = 'image/png';
    } else if (extension == 'gif') {
      mimeType = 'image/gif';
    } else if (extension == 'webp') {
      mimeType = 'image/webp';
    }

    final base64String = base64Encode(bytes);
    final base64DataUri = 'data:$mimeType;base64,$base64String';

    final response = await ApiClient.instance.put('/profile', data: {
      'avatar': base64DataUri,
    });
    final resBody = response.data;

    if (resBody['success'] == true || resBody['status'] == 'success') {
      final rawData = resBody['data'];
      final data = (rawData is Map && rawData.containsKey('data')) 
          ? rawData['data'] as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      final avatarUrl = data['avatar'] as String? ?? data['profileImageUrl'] as String?;
      if (avatarUrl != null) {
        return avatarUrl;
      }
      throw Exception('Avatar not found in response');
    } else {
      throw Exception(resBody['message'] ?? 'Failed to upload avatar');
    }
  }

  @override
  Future<MacroTargetsModel> calculateTargets({required String userId}) async {
    final response = await ApiClient.instance.post('/profile/targets/calculate');
    final resBody = response.data;

    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final targets = Map<String, dynamic>.from(
        (rawData is Map && rawData.containsKey('data')) 
            ? rawData['data'] as Map
            : rawData as Map
      );
      if (!targets.containsKey('userId')) {
        targets['userId'] = userId;
      }

      return MacroTargetsModel.fromJson(targets);
    } else {
      throw Exception(resBody['message'] ?? 'Failed to calculate targets');
    }
  }

  @override
  Future<UserInsightsModel> getUserInsights({required String range}) async {
    final String trimmed = range.trim().toLowerCase();
    final String periodValue = trimmed.isEmpty
        ? 'Weekly'
        : '${trimmed[0].toUpperCase()}${trimmed.substring(1)}';
    final response = await ApiClient.instance.get('/insights?period=$periodValue');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final dataMap = (rawData is Map && rawData.containsKey('data'))
          ? rawData['data'] as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      return UserInsightsModel.fromJson(dataMap);
    }
    throw Exception(resBody['message'] ?? 'Failed to load insights');
  }
}
