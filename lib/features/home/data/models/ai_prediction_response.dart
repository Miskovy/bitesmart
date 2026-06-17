class AiPredictionResponse {
  final bool success;
  final PredictionEnvelope data;

  AiPredictionResponse({
    required this.success,
    required this.data,
  });

  factory AiPredictionResponse.fromJson(Map<String, dynamic> json) {
    return AiPredictionResponse(
      success: json['success'] as bool? ?? false,
      data: PredictionEnvelope.fromJson(json['data'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class PredictionEnvelope {
  final bool success;
  final int statusCode;
  final String message;
  final PredictionData? data;

  PredictionEnvelope({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
  });

  factory PredictionEnvelope.fromJson(Map<String, dynamic> json) {
    return PredictionEnvelope(
      success: json['success'] as bool? ?? false,
      statusCode: json['status_code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
      data: json['data'] != null ? PredictionData.fromJson(json['data'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'status_code': statusCode,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class PredictionData {
  final String foodDetected;
  final Measurements measurements;
  final Macros macros;
  final String trainingDataId;

  PredictionData({
    required this.foodDetected,
    required this.measurements,
    required this.macros,
    required this.trainingDataId,
  });

  factory PredictionData.fromJson(Map<String, dynamic> json) {
    return PredictionData(
      foodDetected: json['food_detected'] as String? ?? '',
      measurements: Measurements.fromJson(json['measurements'] as Map<String, dynamic>? ?? {}),
      macros: Macros.fromJson(json['macros'] as Map<String, dynamic>? ?? {}),
      trainingDataId: json['training_data_id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'food_detected': foodDetected,
      'measurements': measurements.toJson(),
      'macros': macros.toJson(),
      'training_data_id': trainingDataId,
    };
  }
}

class Measurements {
  final double plateDiameterCm;
  final double estimatedWeightG;
  final double estimatedVolumeCm3;

  Measurements({
    required this.plateDiameterCm,
    required this.estimatedWeightG,
    required this.estimatedVolumeCm3,
  });

  factory Measurements.fromJson(Map<String, dynamic> json) {
    return Measurements(
      plateDiameterCm: (json['plate_diameter_cm'] as num? ??
              json['ar_width_cm'] as num? ??
              0.0)
          .toDouble(),
      estimatedWeightG: (json['estimated_weight_g'] as num? ?? 0.0).toDouble(),
      estimatedVolumeCm3: (json['estimated_volume_cm3'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'plate_diameter_cm': plateDiameterCm,
      'estimated_weight_g': estimatedWeightG,
      'estimated_volume_cm3': estimatedVolumeCm3,
    };
  }
}

class Macros {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;

  Macros({
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
  });

  factory Macros.fromJson(Map<String, dynamic> json) {
    return Macros(
      calories: (json['calories'] as num? ?? 0.0).toDouble(),
      proteinG: (json['protein_g'] as num? ?? 0.0).toDouble(),
      carbsG: (json['carbs_g'] as num? ?? 0.0).toDouble(),
      fatsG: (json['fats_g'] as num? ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fats_g': fatsG,
    };
  }
}
