import 'package:equatable/equatable.dart';

class MedicalConditionsData extends Equatable {
  final bool isDiabetesType1;
  final bool isDiabetesType2;
  final bool isHypertension;
  final bool isPCOS;
  final bool isAnemia;
  final bool isCeliacDisease;
  final bool isIBS;

  const MedicalConditionsData({
    this.isDiabetesType1 = false,
    this.isDiabetesType2 = false,
    this.isHypertension = false,
    this.isPCOS = false,
    this.isAnemia = false,
    this.isCeliacDisease = false,
    this.isIBS = false,
  });

  MedicalConditionsData copyWith({
    bool? isDiabetesType1,
    bool? isDiabetesType2,
    bool? isHypertension,
    bool? isPCOS,
    bool? isAnemia,
    bool? isCeliacDisease,
    bool? isIBS,
  }) {
    return MedicalConditionsData(
      isDiabetesType1: isDiabetesType1 ?? this.isDiabetesType1,
      isDiabetesType2: isDiabetesType2 ?? this.isDiabetesType2,
      isHypertension: isHypertension ?? this.isHypertension,
      isPCOS: isPCOS ?? this.isPCOS,
      isAnemia: isAnemia ?? this.isAnemia,
      isCeliacDisease: isCeliacDisease ?? this.isCeliacDisease,
      isIBS: isIBS ?? this.isIBS,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isDiabetesType1': isDiabetesType1,
      'isDiabetesType2': isDiabetesType2,
      'isHypertension': isHypertension,
      'isPCOS': isPCOS,
      'isAnemia': isAnemia,
      'isCeliacDisease': isCeliacDisease,
      'isIBS': isIBS,
    };
  }

  factory MedicalConditionsData.fromJson(Map<String, dynamic> json) {
    return MedicalConditionsData(
      isDiabetesType1: json['isDiabetesType1'] as bool? ?? false,
      isDiabetesType2: json['isDiabetesType2'] as bool? ?? false,
      isHypertension: json['isHypertension'] as bool? ?? false,
      isPCOS: json['isPCOS'] as bool? ?? false,
      isAnemia: json['isAnemia'] as bool? ?? false,
      isCeliacDisease: json['isCeliacDisease'] as bool? ?? false,
      isIBS: json['isIBS'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        isDiabetesType1,
        isDiabetesType2,
        isHypertension,
        isPCOS,
        isAnemia,
        isCeliacDisease,
        isIBS,
      ];
}

class DietaryPreferencesData extends Equatable {
  final bool isVegetarian;
  final bool isVegan;
  final bool isKeto;
  final bool isPaleo;
  final bool isGlutenFree;
  final bool isHalal;
  final bool isPescatarian;
  final bool isGlp1User;
  final bool isRamadanMode;

  const DietaryPreferencesData({
    this.isVegetarian = false,
    this.isVegan = false,
    this.isKeto = false,
    this.isPaleo = false,
    this.isGlutenFree = false,
    this.isHalal = false,
    this.isPescatarian = false,
    this.isGlp1User = false,
    this.isRamadanMode = false,
  });

  DietaryPreferencesData copyWith({
    bool? isVegetarian,
    bool? isVegan,
    bool? isKeto,
    bool? isPaleo,
    bool? isGlutenFree,
    bool? isHalal,
    bool? isPescatarian,
    bool? isGlp1User,
    bool? isRamadanMode,
  }) {
    return DietaryPreferencesData(
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isKeto: isKeto ?? this.isKeto,
      isPaleo: isPaleo ?? this.isPaleo,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isHalal: isHalal ?? this.isHalal,
      isPescatarian: isPescatarian ?? this.isPescatarian,
      isGlp1User: isGlp1User ?? this.isGlp1User,
      isRamadanMode: isRamadanMode ?? this.isRamadanMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isKeto': isKeto,
      'isPaleo': isPaleo,
      'isGlutenFree': isGlutenFree,
      'isHalal': isHalal,
      'isPescatarian': isPescatarian,
      'isGlp1User': isGlp1User,
      'isRamadanMode': isRamadanMode,
    };
  }

  factory DietaryPreferencesData.fromJson(Map<String, dynamic> json) {
    return DietaryPreferencesData(
      isVegetarian: json['isVegetarian'] as bool? ?? false,
      isVegan: json['isVegan'] as bool? ?? false,
      isKeto: json['isKeto'] as bool? ?? false,
      isPaleo: json['isPaleo'] as bool? ?? false,
      isGlutenFree: json['isGlutenFree'] as bool? ?? false,
      isHalal: json['isHalal'] as bool? ?? false,
      isPescatarian: json['isPescatarian'] as bool? ?? false,
      isGlp1User: json['isGlp1User'] as bool? ?? false,
      isRamadanMode: json['isRamadanMode'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        isVegetarian,
        isVegan,
        isKeto,
        isPaleo,
        isGlutenFree,
        isHalal,
        isPescatarian,
        isGlp1User,
        isRamadanMode,
      ];
}

class TargetsData extends Equatable {
  final int calTotal;
  final int proteins;
  final int carbs;
  final int fats;
  final double? ironMg;
  final double? sodiumMg;
  final double? vitaminDIu;
  final int? waterMl;
  final bool autoCalculateWithAi;

  const TargetsData({
    required this.calTotal,
    required this.proteins,
    required this.carbs,
    required this.fats,
    this.ironMg,
    this.sodiumMg,
    this.vitaminDIu,
    this.waterMl,
    this.autoCalculateWithAi = true,
  });

  TargetsData copyWith({
    int? calTotal,
    int? proteins,
    int? carbs,
    int? fats,
    double? ironMg,
    double? sodiumMg,
    double? vitaminDIu,
    int? waterMl,
    bool? autoCalculateWithAi,
  }) {
    return TargetsData(
      calTotal: calTotal ?? this.calTotal,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      ironMg: ironMg ?? this.ironMg,
      sodiumMg: sodiumMg ?? this.sodiumMg,
      vitaminDIu: vitaminDIu ?? this.vitaminDIu,
      waterMl: waterMl ?? this.waterMl,
      autoCalculateWithAi: autoCalculateWithAi ?? this.autoCalculateWithAi,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'calTotal': calTotal,
      'proteins': proteins,
      'carbs': carbs,
      'fats': fats,
      'autoCalculateWithAi': autoCalculateWithAi,
    };
    if (ironMg != null) data['iron_mg'] = ironMg;
    if (sodiumMg != null) data['sodium_mg'] = sodiumMg;
    if (vitaminDIu != null) data['vitamin_d_iu'] = vitaminDIu;
    if (waterMl != null) data['water_ml'] = waterMl;
    return data;
  }

  factory TargetsData.fromJson(Map<String, dynamic> json) {
    return TargetsData(
      calTotal: json['calTotal'] as int? ?? 2000,
      proteins: json['proteins'] as int? ?? 150,
      carbs: json['carbs'] as int? ?? 200,
      fats: json['fats'] as int? ?? 65,
      ironMg: (json['iron_mg'] as num?)?.toDouble(),
      sodiumMg: (json['sodium_mg'] as num?)?.toDouble(),
      vitaminDIu: (json['vitamin_d_iu'] as num?)?.toDouble(),
      waterMl: json['water_ml'] as int?,
      autoCalculateWithAi: json['autoCalculateWithAi'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [
        calTotal,
        proteins,
        carbs,
        fats,
        ironMg,
        sodiumMg,
        vitaminDIu,
        waterMl,
        autoCalculateWithAi,
      ];
}

class ProfileSetupModel extends Equatable {
  final double? height;
  final double? weight;
  final String? gender;
  final int? age;
  final String? activityLevel;
  final String? userGoal;
  final MedicalConditionsData medicalConditions;
  final DietaryPreferencesData dietaryPreferences;
  final TargetsData? targets;

  const ProfileSetupModel({
    this.height,
    this.weight,
    this.gender,
    this.age,
    this.activityLevel,
    this.userGoal,
    this.medicalConditions = const MedicalConditionsData(),
    this.dietaryPreferences = const DietaryPreferencesData(),
    this.targets,
  });

  ProfileSetupModel copyWith({
    double? height,
    double? weight,
    String? gender,
    int? age,
    String? activityLevel,
    String? userGoal,
    MedicalConditionsData? medicalConditions,
    DietaryPreferencesData? dietaryPreferences,
    TargetsData? targets,
  }) {
    return ProfileSetupModel(
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      activityLevel: activityLevel ?? this.activityLevel,
      userGoal: userGoal ?? this.userGoal,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      dietaryPreferences: dietaryPreferences ?? this.dietaryPreferences,
      targets: targets ?? this.targets,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'medicalConditions': medicalConditions.toJson(),
      'dietaryPreferences': dietaryPreferences.toJson(),
    };
    if (height != null) data['height'] = height;
    if (weight != null) data['weight'] = weight;
    if (gender != null) data['gender'] = gender;
    if (age != null) data['age'] = age;
    if (activityLevel != null) data['activityLevel'] = activityLevel;
    if (userGoal != null) data['userGoal'] = userGoal;
    if (targets != null) data['targets'] = targets!.toJson();
    return data;
  }

  factory ProfileSetupModel.fromJson(Map<String, dynamic> json) {
    return ProfileSetupModel(
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      activityLevel: json['activityLevel'] as String?,
      userGoal: json['userGoal'] as String?,
      medicalConditions: json['medicalConditions'] != null
          ? MedicalConditionsData.fromJson(json['medicalConditions'] as Map<String, dynamic>)
          : const MedicalConditionsData(),
      dietaryPreferences: json['dietaryPreferences'] != null
          ? DietaryPreferencesData.fromJson(json['dietaryPreferences'] as Map<String, dynamic>)
          : const DietaryPreferencesData(),
      targets: json['targets'] != null
          ? TargetsData.fromJson(json['targets'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        height,
        weight,
        gender,
        age,
        activityLevel,
        userGoal,
        medicalConditions,
        dietaryPreferences,
        targets,
      ];
}
