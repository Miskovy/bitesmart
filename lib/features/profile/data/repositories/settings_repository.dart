import 'package:bite_smart/core/network/api_client.dart';

class Glp1Settings {
  final bool isGlp1User;
  final bool highProteinGoal;
  final int hydrationReminderHours;

  const Glp1Settings({
    required this.isGlp1User,
    required this.highProteinGoal,
    required this.hydrationReminderHours,
  });

  factory Glp1Settings.fromJson(Map<String, dynamic> json) {
    return Glp1Settings(
      isGlp1User: json['isGlp1User'] ?? false,
      highProteinGoal: json['highProteinGoal'] ?? false,
      hydrationReminderHours: json['hydrationReminderHours'] ?? 2,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highProteinGoal': highProteinGoal,
      'hydrationReminderHours': hydrationReminderHours,
    };
  }
}

class FastingSettings {
  final bool isFastingMode;
  final String suhoorTime;
  final String iftarTime;
  final bool hydrationFocus;

  const FastingSettings({
    required this.isFastingMode,
    required this.suhoorTime,
    required this.iftarTime,
    required this.hydrationFocus,
  });

  factory FastingSettings.fromJson(Map<String, dynamic> json) {
    return FastingSettings(
      isFastingMode: json['isFastingMode'] ?? false,
      suhoorTime: json['suhoorTime'] ?? "04:30 AM",
      iftarTime: json['iftarTime'] ?? "07:45 PM",
      hydrationFocus: json['hydrationFocus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isFastingMode': isFastingMode,
      'suhoorTime': suhoorTime,
      'iftarTime': iftarTime,
      'hydrationFocus': hydrationFocus,
    };
  }
}

abstract class ISettingsRepository {
  Future<Glp1Settings> getGlp1Settings();
  Future<Glp1Settings> saveGlp1Settings(Glp1Settings settings);
  Future<FastingSettings> getFastingSettings();
  Future<FastingSettings> saveFastingSettings(FastingSettings settings);
  Future<void> enableGlp1Mode(bool enabled);
}

class SettingsRepository implements ISettingsRepository {
  @override
  Future<Glp1Settings> getGlp1Settings() async {
    final response = await ApiClient.instance.get('/settings/glp1');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final data = resBody['data'] as Map<String, dynamic>;
      return Glp1Settings.fromJson(data);
    }
    throw Exception(resBody['message'] ?? 'Failed to load GLP-1 settings');
  }

  @override
  Future<Glp1Settings> saveGlp1Settings(Glp1Settings settings) async {
    final response = await ApiClient.instance.put('/settings/glp1', data: settings.toJson());
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final data = (rawData is Map && rawData.containsKey('settings'))
          ? rawData['settings'] as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      return Glp1Settings.fromJson(data);
    }
    throw Exception(resBody['message'] ?? 'Failed to save GLP-1 settings');
  }

  @override
  Future<FastingSettings> getFastingSettings() async {
    final response = await ApiClient.instance.get('/settings/fasting');
    final resBody = response.data;
    if (resBody['success'] == true) {
      final data = resBody['data'] as Map<String, dynamic>;
      return FastingSettings.fromJson(data);
    }
    throw Exception(resBody['message'] ?? 'Failed to load fasting settings');
  }

  @override
  Future<FastingSettings> saveFastingSettings(FastingSettings settings) async {
    final response = await ApiClient.instance.put('/settings/fasting', data: settings.toJson());
    final resBody = response.data;
    if (resBody['success'] == true) {
      final rawData = resBody['data'];
      final data = (rawData is Map && rawData.containsKey('settings'))
          ? rawData['settings'] as Map<String, dynamic>
          : rawData as Map<String, dynamic>;
      return FastingSettings.fromJson(data);
    }
    throw Exception(resBody['message'] ?? 'Failed to save fasting settings');
  }

  @override
  Future<void> enableGlp1Mode(bool enabled) async {
    final response = await ApiClient.instance.patch('/profile/mode', data: {
      'glp1': enabled,
    });
    final resBody = response.data;
    if (resBody['success'] != true) {
      throw Exception(resBody['message'] ?? 'Failed to enable GLP-1 mode');
    }
  }
}
