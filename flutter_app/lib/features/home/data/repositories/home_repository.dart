import 'dart:convert';
import 'package:bite_smart/core/network/api_client.dart';
import 'package:bite_smart/features/home/data/models/meal_model.dart';
import 'package:bite_smart/features/home/data/models/nutrition_model.dart';
import 'package:bite_smart/features/home/data/models/ai_prediction_response.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

abstract class IHomeRepository {
  Future<List<MealModel>> getMeals({required String userId});
  Future<MealModel> addMeal({required MealModel meal});
  Future<void> removeMeal({required String mealId});
  Future<int> getTodayCalories({required String userId});
  Future<Map<String, int>> getTodayMacros({required String userId});
  Future<void> updateHydration({required String userId, required int glasses});
  Future<MealModel> analyzeMealFromImage({
    required String imagePath,
    double foodWidthCm = 8.0,
    bool isCalibration = false,
  });

  // Additional CRUD / logs helpers
  Future<void> logMealDirect({
    required int foodItemId,
    required String mealType,
    required double quantity,
    String? unit,
    String? imageUrl,
  });
  Future<Map<String, dynamic>> getDailySummary(String dateStr);
  Future<void> logWater({required int amountMl, String? dateStr});
  Future<Map<String, dynamic>> getWaterLogs(String dateStr);
  Future<void> completeDay(String dateStr);
  Future<Map<String, dynamic>> getCompletionSummary(String dateStr);
  Future<Map<String, dynamic>> calibrateScaleFromImage({required String imagePath, double plateDiameterCm = 25.0});
}

class HomeRepository implements IHomeRepository {
  @override
  Future<List<MealModel>> getMeals({required String userId}) async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final response = await ApiClient.instance.get('/logs', queryParameters: {'date': dateStr});
      final resBody = response.data;
      if (resBody['success'] == true) {
        final List list = resBody['data'] as List? ?? [];
        return list.map((item) {
          final food = item['food'] as Map<String, dynamic>? ?? {};
          final nutrition = item['nutrition'] as Map<String, dynamic>? ?? {};
          return MealModel(
            id: item['logId'] as String,
            name: food['name'] as String? ?? 'Logged Meal',
            calories: (nutrition['calories'] ?? 0) as int,
            dateTime: DateTime.parse(item['loggedAt'] as String),
            imageUrl: item['imageUrl'] as String?,
            description: "${item['mealType']} - ${item['quantity']} ${item['unit']}",
            nutrition: NutritionModel(
              protein: (nutrition['protein'] ?? 0) as int,
              carbs: (nutrition['carbs'] ?? 0) as int,
              fat: (nutrition['fats'] ?? 0) as int,
            ),
          );
        }).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<MealModel> addMeal({required MealModel meal}) async {
    try {
      // Helper mapping to backend POST /logs
      // Since addMeal takes a MealModel, we will assume foodItemId is parsed from description or name
      // or we can use default food item (e.g. 1) if not found.
      // For more direct and robust usage, screens will call logMealDirect.
      await logMealDirect(
        foodItemId: 1, // Default fallback
        mealType: 'Breakfast',
        quantity: 100.0,
        unit: 'g',
        imageUrl: meal.imageUrl,
      );
      return meal;
    } catch (e) {
      throw Exception('Failed to add meal: $e');
    }
  }

  @override
  Future<void> removeMeal({required String mealId}) async {
    final response = await ApiClient.instance.delete('/logs/$mealId');
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to delete meal log');
    }
  }

  @override
  Future<int> getTodayCalories({required String userId}) async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final summary = await getDailySummary(dateStr);
      final consumed = summary['consumed'] as Map<String, dynamic>? ?? {};
      return (consumed['calories'] ?? 0) as int;
    } catch (e) {
      return 0;
    }
  }

  @override
  Future<Map<String, int>> getTodayMacros({required String userId}) async {
    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final summary = await getDailySummary(dateStr);
      final consumed = summary['consumed'] as Map<String, dynamic>? ?? {};
      return {
        'protein': (consumed['protein'] ?? 0) as int,
        'carbs': (consumed['carbs'] ?? 0) as int,
        'fat': (consumed['fats'] ?? 0) as int,
      };
    } catch (e) {
      return {'protein': 0, 'carbs': 0, 'fat': 0};
    }
  }

  @override
  Future<void> updateHydration({
    required String userId,
    required int glasses,
  }) async {
    // 1 glass is approx 250ml
    await logWater(amountMl: glasses * 250);
  }

  @override
  Future<MealModel> analyzeMealFromImage({
    required String imagePath,
    double foodWidthCm = 8.0,
    bool isCalibration = false,
  }) async {
    final filename = imagePath.split('/').last;
    final Map<String, dynamic> fields = {
      'file': MultipartFile.fromBytes(
        await XFile(imagePath).readAsBytes(),
        filename: filename,
        contentType: _getMediaTypeForPath(imagePath),
      ),
    };

    if (isCalibration) {
      fields['plate_diameter_cm'] = foodWidthCm;
    } else {
      fields['food_width_cm'] = foodWidthCm;
    }

    final formData = FormData.fromMap(fields);
    final endpoint = isCalibration ? '/prediction/callibration' : '/prediction/ar';

    final response = await ApiClient.instance.post(endpoint, data: formData);
    final resBody = response.data;

    final predictionRes = AiPredictionResponse.fromJson(resBody as Map<String, dynamic>);

    if (predictionRes.success && predictionRes.data.success && predictionRes.data.data != null) {
      final pData = predictionRes.data.data!;
      
      final descriptionJson = jsonEncode({
        'plateDiameterCm': pData.measurements.plateDiameterCm,
        'estimatedWeightG': pData.measurements.estimatedWeightG,
        'estimatedVolumeCm3': pData.measurements.estimatedVolumeCm3,
        'trainingDataId': pData.trainingDataId,
        'foodItemId': pData.foodItemId,
      });

      return MealModel(
        id: pData.trainingDataId,
        name: pData.foodDetected,
        calories: pData.macros.calories.toInt(),
        dateTime: DateTime.now(),
        imageUrl: null,
        description: descriptionJson,
        nutrition: NutritionModel(
          protein: pData.macros.proteinG.toInt(),
          carbs: pData.macros.carbsG.toInt(),
          fat: pData.macros.fatsG.toInt(),
        ),
      );
    } else {
      throw Exception(predictionRes.data.message.isNotEmpty
          ? predictionRes.data.message
          : 'Failed to analyze food image');
    }
  }

  @override
  Future<void> logMealDirect({
    required int foodItemId,
    required String mealType,
    required double quantity,
    String? unit,
    String? imageUrl,
  }) async {
    final response = await ApiClient.instance.post('/logs', data: {
      'foodItemId': foodItemId,
      'mealType': mealType,
      'quantity': quantity,
      'unit': unit ?? 'g',
      'imageUrl': imageUrl,
    });
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to log meal');
    }
  }

  @override
  Future<Map<String, dynamic>> getDailySummary(String dateStr) async {
    final response = await ApiClient.instance.get('/logs/summary', queryParameters: {'date': dateStr});
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      return (rawData is Map && rawData.containsKey('date'))
          ? rawData as Map<String, dynamic>
          : (rawData['data'] as Map<String, dynamic>? ?? {});
    }
    throw Exception(resBody['message'] ?? 'Failed to get daily summary');
  }

  @override
  Future<void> logWater({required int amountMl, String? dateStr}) async {
    final response = await ApiClient.instance.post('/logs/water', data: {
      'amount_ml': amountMl,
      'dateStr': dateStr,
    });
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to log water');
    }
  }

  @override
  Future<Map<String, dynamic>> getWaterLogs(String dateStr) async {
    final response = await ApiClient.instance.get('/logs/water', queryParameters: {'date': dateStr});
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      return (rawData is Map && rawData.containsKey('totalConsumed'))
          ? rawData as Map<String, dynamic>
          : (rawData['data'] as Map<String, dynamic>? ?? {});
    }
    throw Exception(resBody['message'] ?? 'Failed to get water logs');
  }

  @override
  Future<void> completeDay(String dateStr) async {
    final response = await ApiClient.instance.post('/logs/complete', data: {'date': dateStr});
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to complete day');
    }
  }

  @override
  Future<Map<String, dynamic>> getCompletionSummary(String dateStr) async {
    final response = await ApiClient.instance.get('/logs/complete', queryParameters: {'date': dateStr});
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      return (rawData is Map && rawData.containsKey('coachInsight'))
          ? rawData as Map<String, dynamic>
          : (rawData['data'] as Map<String, dynamic>? ?? {});
    }
    throw Exception(resBody['message'] ?? 'Failed to get completion summary');
  }

  @override
  Future<Map<String, dynamic>> calibrateScaleFromImage({required String imagePath, double plateDiameterCm = 25.0}) async {
    final filename = imagePath.split('/').last;
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        await XFile(imagePath).readAsBytes(),
        filename: filename,
        contentType: _getMediaTypeForPath(imagePath),
      ),
      'plate_diameter_cm': plateDiameterCm,
    });

    final response = await ApiClient.instance.post('/prediction/callibration', data: formData);
    final resBody = response.data;

    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      return (rawData is Map && rawData.containsKey('callibration'))
          ? rawData as Map<String, dynamic>
          : (rawData['data'] as Map<String, dynamic>? ?? {});
    } else {
      throw Exception(resBody['message'] ?? 'Failed to calibrate scale from image');
    }
  }

  MediaType _getMediaTypeForPath(String path) {
    final filename = path.split('/').last.toLowerCase();
    if (filename.endsWith('.png')) {
      return MediaType('image', 'png');
    } else if (filename.endsWith('.gif')) {
      return MediaType('image', 'gif');
    } else if (filename.endsWith('.webp')) {
      return MediaType('image', 'webp');
    } else {
      return MediaType('image', 'jpeg');
    }
  }
}
