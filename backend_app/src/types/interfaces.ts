export interface userModes {
    glp1?: boolean;
    ramadanMode?: boolean;
    //! Created by Antigravity: Added renamed fasting mode parameter
    fastingMode?: boolean;
};

export interface UpdateProfileData {
    name?: string;
    email?: string;
    avatar?: string;
    phone?: string;
    height?: number;
    weight?: number;
    BMI?: number;
    gender?: "Male" | "Female";
    age?: number;
    activityLevel?: "Sedentary" | "LightlyActive" | "ModeratelyActive" | "VeryActive";
    userGoal?: "WeightLoss" | "Maintenance" | "MuscleGain";

    medicalConditions?: {
        isDiabetesType1?: boolean;
        isDiabetesType2?: boolean;
        isHypertension?: boolean;
        isPCOS?: boolean;
        isAnemia?: boolean;
        isCeliacDisease?: boolean;
        isIBS?: boolean;
    };

    dietaryPreferences?: {
        isVegetarian?: boolean;
        isVegan?: boolean;
        isKeto?: boolean;
        isPaleo?: boolean;
        isGlutenFree?: boolean;
        isHalal?: boolean;
        isPescatarian?: boolean;
        isGlp1User?: boolean;
        isRamadanMode?: boolean;
    };

    targets?: {
        calTotal?: number;
        proteins?: number;
        carbs?: number;
        fats?: number;
        iron_mg?: number;
        sodium_mg?: number;
        vitamin_d_iu?: number;
        water_ml?: number;
        //! Created by Antigravity: State flag for auto calculation of macros
        autoCalculateWithAi?: boolean;
    };
}

