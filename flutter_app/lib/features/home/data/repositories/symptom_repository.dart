import 'package:bite_smart/core/network/api_client.dart';

class SymptomLog {
  final String id;
  final String userId;
  final String type; // 'symptom' or 'daily-checkin'
  final String? symptomName;
  final int? severity;
  final int? nauseaLevel;
  final int? appetiteLevel;
  final String? notes;
  final DateTime loggedAt;

  const SymptomLog({
    required this.id,
    required this.userId,
    required this.type,
    this.symptomName,
    this.severity,
    this.nauseaLevel,
    this.appetiteLevel,
    this.notes,
    required this.loggedAt,
  });

  factory SymptomLog.fromJson(Map<String, dynamic> json) {
    return SymptomLog(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: json['symptomName'] != null ? 'symptom' : 'daily-checkin',
      symptomName: json['symptomName'] as String?,
      severity: json['severity'] as int?,
      nauseaLevel: json['nauseaLevel'] as int?,
      appetiteLevel: json['appetiteLevel'] as int?,
      notes: json['notes'] as String?,
      loggedAt: DateTime.parse(json['loggedAt'] as String),
    );
  }
}

abstract class ISymptomRepository {
  Future<void> logSymptom({
    required String symptom,
    required int severity,
    String? notes,
  });
  Future<void> logDailyCheckIn({
    required int nauseaLevel,
    required int appetiteLevel,
    String? notes,
  });
  Future<List<SymptomLog>> getSymptomsByDate(String dateStr);
  Future<List<SymptomLog>> getSymptomHistory({int page = 1, int limit = 20});
}

class SymptomRepository implements ISymptomRepository {
  @override
  Future<void> logSymptom({
    required String symptom,
    required int severity,
    String? notes,
  }) async {
    final response = await ApiClient.instance.post('/symptoms', data: {
      'symptom': symptom,
      'severity': severity,
      'notes': notes,
    });
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to log symptom');
    }
  }

  @override
  Future<void> logDailyCheckIn({
    required int nauseaLevel,
    required int appetiteLevel,
    String? notes,
  }) async {
    final response = await ApiClient.instance.post('/symptoms/daily-checkin', data: {
      'nauseaLevel': nauseaLevel,
      'appetiteLevel': appetiteLevel,
      'notes': notes,
    });
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to log daily check-in');
    }
  }

  @override
  Future<List<SymptomLog>> getSymptomsByDate(String dateStr) async {
    final response = await ApiClient.instance.get('/symptoms', queryParameters: {'date': dateStr});
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final List list = (rawData is Map && rawData.containsKey('logs'))
          ? rawData['logs'] as List
          : (rawData is List ? rawData : []);
      return list.map((item) => SymptomLog.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(resBody['message'] ?? 'Failed to load symptoms');
  }

  @override
  Future<List<SymptomLog>> getSymptomHistory({int page = 1, int limit = 20}) async {
    final response = await ApiClient.instance.get('/symptoms/history', queryParameters: {
      'page': page,
      'limit': limit,
    });
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final List list = (rawData is Map && rawData.containsKey('history'))
          ? rawData['history'] as List
          : (rawData is List ? rawData : []);
      return list.map((item) => SymptomLog.fromJson(item as Map<String, dynamic>)).toList();
    }
    throw Exception(resBody['message'] ?? 'Failed to load symptom history');
  }
}
