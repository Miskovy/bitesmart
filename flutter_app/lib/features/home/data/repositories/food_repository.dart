import 'package:bite_smart/core/network/api_client.dart';

class FoodItem {
  final int id;
  final String name;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final String? source;
  final bool isVerified;

  const FoodItem({
    required this.id,
    required this.name,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.source,
    this.isVerified = false,
  });

  factory FoodItem.fromJson(Map<String, dynamic> json) {
    return FoodItem(
      id: json['id'] as int,
      name: (json['class_name'] ?? json['name']) as String,
      caloriesPer100g: (json['cals_per_100g'] ?? json['calories'] ?? json['calsPer100g'] ?? 0.0).toDouble(),
      proteinPer100g: (json['protein_per_100g'] ?? json['protein'] ?? json['proteinPer100g'] ?? 0.0).toDouble(),
      carbsPer100g: (json['carbs_per_100g'] ?? json['carbs'] ?? json['carbsPer100g'] ?? 0.0).toDouble(),
      fatsPer100g: (json['fats_per_100g'] ?? json['fats'] ?? json['fatsPer100g'] ?? 0.0).toDouble(),
      source: json['source'] as String?,
      isVerified: json['isVerified'] ?? false,
    );
  }
}

abstract class IFoodRepository {
  Future<List<FoodItem>> searchFood(String query, {int page = 1, int limit = 20});
  Future<FoodItem> getFoodDetails(int id);
  Future<FoodItem> createCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  });
}

class FoodRepository implements IFoodRepository {
  final Map<String, List<FoodItem>> _searchCache = {};
  final Map<int, FoodItem> _detailsCache = {};

  @override
  Future<List<FoodItem>> searchFood(String query, {int page = 1, int limit = 20}) async {
    final cacheKey = '${query}_${page}_$limit';
    if (_searchCache.containsKey(cacheKey)) {
      return _searchCache[cacheKey]!;
    }

    final response = await ApiClient.instance.get('/food', queryParameters: {
      'search': query,
      'page': page,
      'limit': limit,
    });
    final resBody = response.data;
    if (resBody['success'] == true) {
      final envelope = resBody['data'];
      List list = [];
      if (envelope is Map) {
        // If there's an inner 'success' and 'data' envelope
        final innerData = envelope['data'];
        if (innerData is Map) {
          if (innerData.containsKey('data') && innerData['data'] is List) {
            list = innerData['data'] as List;
          } else if (innerData.containsKey('food') && innerData['food'] is List) {
            list = innerData['food'] as List;
          }
        } else if (innerData is List) {
          list = innerData;
        } else if (envelope.containsKey('food') && envelope['food'] is List) {
          list = envelope['food'] as List;
        } else if (envelope.containsKey('data') && envelope['data'] is List) {
          list = envelope['data'] as List;
        }
      } else if (envelope is List) {
        list = envelope;
      }

      final results = list.map((item) => FoodItem.fromJson(item as Map<String, dynamic>)).toList();
      _searchCache[cacheKey] = results;
      return results;
    }
    throw Exception(resBody['message'] ?? 'Failed to search food items');
  }

  @override
  Future<FoodItem> getFoodDetails(int id) async {
    if (_detailsCache.containsKey(id)) {
      return _detailsCache[id]!;
    }

    final response = await ApiClient.instance.get('/food/$id');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final envelope = resBody['data'];
      Map<String, dynamic>? data;
      if (envelope is Map) {
        final innerData = envelope['data'];
        if (innerData is Map) {
          data = innerData.containsKey('food')
              ? innerData['food'] as Map<String, dynamic>
              : innerData as Map<String, dynamic>;
        } else {
          data = envelope.containsKey('food')
              ? envelope['food'] as Map<String, dynamic>
              : envelope as Map<String, dynamic>;
        }
      }
      if (data != null) {
        final result = FoodItem.fromJson(data);
        _detailsCache[id] = result;
        return result;
      }
    }
    throw Exception(resBody['message'] ?? 'Failed to get food details');
  }

  @override
  Future<FoodItem> createCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fats,
  }) async {
    final response = await ApiClient.instance.post('/food/custom', data: {
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
    });
    final resBody = response.data;
    if (resBody['success'] == true) {
      final envelope = resBody['data'];
      Map<String, dynamic>? data;
      if (envelope is Map) {
        final innerData = envelope['data'];
        if (innerData is Map) {
          data = innerData.containsKey('food')
              ? innerData['food'] as Map<String, dynamic>
              : innerData as Map<String, dynamic>;
        } else {
          data = envelope.containsKey('food')
              ? envelope['food'] as Map<String, dynamic>
              : envelope as Map<String, dynamic>;
        }
      }
      if (data != null) {
        final food = FoodItem.fromJson(data);
        _detailsCache[food.id] = food;
        return food;
      }
    }
    throw Exception(resBody['message'] ?? 'Failed to create custom food');
  }
}
