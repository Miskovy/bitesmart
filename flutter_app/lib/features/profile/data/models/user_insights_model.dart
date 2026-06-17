class UserInsightsModel {
  final int avgCalories;
  final double weightChange;
  final List<WeightGraphPoint> weightGraph;
  final List<PeriodDataPoint> periodData;
  final TodayBreakdown todayBreakdown;

  const UserInsightsModel({
    required this.avgCalories,
    required this.weightChange,
    required this.weightGraph,
    required this.periodData,
    required this.todayBreakdown,
  });

  factory UserInsightsModel.fromJson(Map<String, dynamic> json) {
    final wg = json['weightGraph'] as List? ?? json['weight_graph'] as List? ?? [];
    final pd = json['periodData'] as List? ?? json['period_data'] as List? ?? [];

    return UserInsightsModel(
      avgCalories: (json['avgCalories'] ?? json['avg_calories'] ?? 0).toInt(),
      weightChange: (json['weightChange'] ?? json['weight_change'] ?? 0.0).toDouble(),
      weightGraph: wg.map((item) => WeightGraphPoint.fromJson(item as Map<String, dynamic>)).toList(),
      periodData: pd.map((item) => PeriodDataPoint.fromJson(item as Map<String, dynamic>)).toList(),
      todayBreakdown: TodayBreakdown.fromJson(json['todayBreakdown'] ?? json['today_breakdown'] ?? {}),
    );
  }
}

class WeightGraphPoint {
  final String date;
  final double weight;

  const WeightGraphPoint({
    required this.date,
    required this.weight,
  });

  factory WeightGraphPoint.fromJson(Map<String, dynamic> json) {
    return WeightGraphPoint(
      date: (json['date'] ?? '') as String,
      weight: (json['weight'] ?? 0.0).toDouble(),
    );
  }
}

class PeriodDataPoint {
  final String date;
  final int calories;
  final int carbs;
  final int protein;
  final int fats;

  const PeriodDataPoint({
    required this.date,
    required this.calories,
    required this.carbs,
    required this.protein,
    required this.fats,
  });

  factory PeriodDataPoint.fromJson(Map<String, dynamic> json) {
    return PeriodDataPoint(
      date: (json['date'] ?? '') as String,
      calories: (json['calories'] ?? 0).toInt(),
      carbs: (json['carbs'] ?? json['carbohydrates'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toInt(),
      fats: (json['fats'] ?? json['fat'] ?? 0).toInt(),
    );
  }
}

class TodayBreakdown {
  final int carbohydrates;
  final int protein;
  final int fats;

  const TodayBreakdown({
    required this.carbohydrates,
    required this.protein,
    required this.fats,
  });

  factory TodayBreakdown.fromJson(Map<String, dynamic> json) {
    return TodayBreakdown(
      carbohydrates: (json['carbohydrates'] ?? json['carbs'] ?? 0).toInt(),
      protein: (json['protein'] ?? 0).toInt(),
      fats: (json['fats'] ?? json['fat'] ?? 0).toInt(),
    );
  }
}
