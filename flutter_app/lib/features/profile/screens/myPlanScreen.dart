import 'package:bite_smart/features/home/data/models/nutrition_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bite_smart/core/network/api_client.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:bite_smart/features/home/data/models/meal_model.dart';
import 'package:bite_smart/features/home/data/repositories/food_repository.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_state.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_event.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  // Real plan values
  int consumedCalories = 0;
  int targetCalories =0;
  int consumedProtein = 0;
  int targetProtein = 120;
  
  List<MealModel> breakfastMeals = [];
  List<MealModel> lunchMeals = [];
  List<MealModel> dinnerMeals = [];
  List<MealModel> snackMeals = [];

  List<Map<String, String>> weekDays = [];
  List<DateTime> weekDates = [];
  int selectedDayIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateWeekDays();

    // Ensure profile is loaded to fetch the actual targets
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileBloc>().add(LoadProfileEvent(userId: authState.userId));
      }
    } else if (profileState.targets != null) {
      targetCalories = profileState.targets!.calorieTarget;
      targetProtein = profileState.targets!.proteinTarget;
    }

    _loadDailyLog();
  }

  void _generateWeekDays() {
    final now = DateTime.now();
    // Start week on Saturday (Egypt standard week)
    int diffToSaturday = now.weekday == 7 ? 1 : (now.weekday == 6 ? 0 : now.weekday + 1);
    final saturday = now.subtract(Duration(days: diffToSaturday));
    
    weekDates = List.generate(7, (i) => saturday.add(Duration(days: i)));
    
    weekDays = weekDates.map((date) {
      final dayName = _getDayName(date.weekday);
      return {
        'dayName': dayName,
        'dayNum': date.day.toString(),
        'dateStr': "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
      };
    }).toList();

    // Set default selected index to today's weekday in the generated week
    final todayStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    final todayIndex = weekDays.indexWhere((day) => day['dateStr'] == todayStr);
    selectedDayIndex = todayIndex != -1 ? todayIndex : 0;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
    return 0;
  }

  Future<void> _loadDailyLog() async {
    if (weekDays.isEmpty) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final repo = context.read<IHomeRepository>();
      final dateStr = weekDays[selectedDayIndex]['dateStr']!;

      // Fetch daily summary
      final summary = await repo.getDailySummary(dateStr);
      final consumed = summary['consumed'] as Map<String, dynamic>? ?? {};
      final target = summary['targets'] as Map<String, dynamic>? ?? {};

      // Fetch meals logged on the backend
      final response = await ApiClient.instance.get('/logs', queryParameters: {'date': dateStr});
      final resBody = response.data;
      List<MealModel> allMeals = [];
      if (resBody['success'] == true) {
        final List list = resBody['data'] as List? ?? [];
        allMeals = list.map((item) {
          final food = item['food'] as Map<String, dynamic>? ?? {};
          final nutrition = item['nutrition'] as Map<String, dynamic>? ?? {};
          return MealModel(
            id: item['logId'] as String,
            name: food['name'] as String? ?? 'Logged Meal',
            calories: _toInt(nutrition['calories']),
            dateTime: DateTime.parse(item['loggedAt'] as String),
            imageUrl: item['imageUrl'] as String?,
            description: "${item['mealType']} - ${item['quantity']} ${item['unit']}",
            nutrition: NutritionModel(
              protein: _toInt(nutrition['protein']),
              carbs: _toInt(nutrition['carbs']),
              fat: _toInt(nutrition['fats']),
            ),
          );
        }).toList();
      }

      // Group meals
      breakfastMeals = allMeals.where((m) => _getMealType(m) == 'breakfast').toList();
      lunchMeals = allMeals.where((m) => _getMealType(m) == 'lunch').toList();
      dinnerMeals = allMeals.where((m) => _getMealType(m) == 'dinner').toList();
      snackMeals = allMeals.where((m) => _getMealType(m) == 'snack').toList();

      int tCal = 2000;
      int tProt = 120;
      if (!mounted) return;
      final profileState = context.read<ProfileBloc>().state;
      if (profileState is ProfileLoaded && profileState.targets != null) {
        tCal = profileState.targets!.calorieTarget;
        tProt = profileState.targets!.proteinTarget;
      } else {
        tCal = _toInt(target['calories']);
        tProt = _toInt(target['protein']);
      }
      if (tCal == 0) tCal = 2000;
      if (tProt == 0) tProt = 120;

      if (mounted) {
        setState(() {
          consumedCalories = _toInt(consumed['calories']);
          targetCalories = tCal;
          consumedProtein = _toInt(consumed['protein']);
          targetProtein = tProt;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _getMealType(MealModel meal) {
    final desc = meal.description!.toLowerCase();
    if (desc.contains('breakfast')) return 'breakfast';
    if (desc.contains('lunch')) return 'lunch';
    if (desc.contains('dinner')) return 'dinner';
    return 'snack';
  }

  void _showRecipeDetails(BuildContext context, String mealName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _RecipeDetailsSheet(mealName: mealName);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded && state.targets != null) {
          setState(() {
            targetCalories = state.targets!.calorieTarget;
            targetProtein = state.targets!.proteinTarget;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAF8), // لون الخلفية الهادئ الموحد للأبلكيشن
        
        // 2. شريط العنوان (AppBar) باسم My Plan
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.5,
          title: const Text(
            "My Plan",
            style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF388E3C),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade100),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Failed to load latest plan data",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFFC62828),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _errorMessage!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.red.shade800,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _loadDailyLog,
                              icon: Icon(Icons.refresh_rounded, color: Colors.red.shade600, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // 3. العنوان الرئيسي في أول البادي (This Week) 
                    const Text(
                      "This Week",
                      style: TextStyle(
                        fontSize: 22, 
                        fontWeight: FontWeight.bold, 
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 4. شريط اختيار الأيام الأفقي - Responsive Horizontal Scrollable week list
                    SizedBox(
                      height: 75,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: List.generate(weekDays.length, (index) {
                            bool isSelected = selectedDayIndex == index;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedDayIndex = index;
                                  });
                                  _loadDailyLog();
                                },
                                child: Container(
                                  width: 56,
                                  height: 65,
                                  decoration: BoxDecoration(
                                    color: isSelected ? const Color(0xFF388E3C) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      )
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        weekDays[index]['dayName']!,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: isSelected ? Colors.white70 : Colors.grey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        weekDays[index]['dayNum']!,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isSelected ? Colors.white : Colors.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                        // 5. كارت الـ AI Coach المستطيل الأخضر الداكن
                        _buildCoachSummaryCard(),

                        const SizedBox(height: 24),

                        // Breakfast Section
                        if (breakfastMeals.isNotEmpty)
                          ...breakfastMeals.map((meal) => _buildMealSection(
                            title: "Breakfast",
                            time: DateFormat('hh:mm a').format(meal.dateTime),
                            mealName: meal.name,
                            calories: meal.calories,
                            protein: meal.nutrition!.protein,
                            imageUrl: meal.imageUrl ?? "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&q=80&w=200",
                          ))
                        else
                          _buildEmptyMealSection("Breakfast", "08:00 AM"),
                        
                        // Lunch Section
                        if (lunchMeals.isNotEmpty)
                          ...lunchMeals.map((meal) => _buildMealSection(
                            title: "Lunch",
                            time: DateFormat('hh:mm a').format(meal.dateTime),
                            mealName: meal.name,
                            calories: meal.calories,
                            protein: meal.nutrition!.protein,
                            imageUrl: meal.imageUrl ?? "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=200",
                            hasDot: true,
                          ))
                        else
                          _buildEmptyMealSection("Lunch", "01:00 PM"),
                        
                        // Dinner Section
                        if (dinnerMeals.isNotEmpty)
                          ...dinnerMeals.map((meal) => _buildMealSection(
                            title: "Dinner",
                            time: DateFormat('hh:mm a').format(meal.dateTime),
                            mealName: meal.name,
                            calories: meal.calories,
                            protein: meal.nutrition!.protein,
                            imageUrl: meal.imageUrl ?? "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&q=80&w=200",
                          ))
                        else
                          _buildEmptyMealSection("Dinner", "07:30 PM"),
                        
                        // Snacks Section
                        if (snackMeals.isNotEmpty)
                          ...snackMeals.map((meal) => _buildSnackSection(
                            title: "Snacks",
                            time: DateFormat('hh:mm a').format(meal.dateTime),
                            mealName: meal.name,
                            calories: meal.calories,
                            imageUrl: meal.imageUrl ?? "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=200",
                          ))
                        else
                          _buildEmptySnackSection("Snacks", "Anytime"),
                      ],
                    ),
                  ),
      ),
    );
  }

  // ويدجت كارت الـ AI Coach العلوي
  Widget _buildCoachSummaryCard() {
    double caloriesProgress = targetCalories > 0 ? (consumedCalories / targetCalories) : 0.0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A2B), // لون زيتي داكن مطابق للصورة
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Color(0xFF4CAF50), size: 16),
              SizedBox(width: 6),
              Text(
                "AI COACH",
                style: TextStyle(color: Color(0xFF4CAF50), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // السعرات
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(text: "$consumedCalories ", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                    TextSpan(text: "/ $targetCalories kcal", style: const TextStyle(fontSize: 13, color: Colors.white60)),
                  ],
                ),
              ),
              // البروتين
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Protein", style: TextStyle(color: Colors.white60, fontSize: 11)),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "${consumedProtein}g ", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                        TextSpan(text: "/ ${targetProtein}g", style: const TextStyle(fontSize: 11, color: Colors.white60)),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 12),
          // شريط التقدم الأخضر
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: caloriesProgress > 1 ? 1 : caloriesProgress,
              backgroundColor: Colors.white12,
              color: const Color(0xFF4CAF50),
              minHeight: 6,
            ),
          )
        ],
      ),
    );
  }

  // ويدجت بناء مجموعات الوجبات الأساسية (Breakfast, Lunch, Dinner)
  Widget _buildMealSection({
    required String title,
    required String time,
    required String mealName,
    required int calories,
    required int protein,
    required String imageUrl,
    bool hasDot = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الهيدر الخاص بالوجبة (الاسم والوقت)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(6)),
                child: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // كارت تفاصيل الوجبة
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl, 
                    width: 64, 
                    height: 64, 
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              mealName, 
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (hasDot) ...[
                            const SizedBox(width: 6),
                            const CircleAvatar(radius: 3, backgroundColor: Color(0xFF4CAF50)),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("$calories kcal . ${protein}g Protein", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      // زر الـ Recipe
                      GestureDetector(
                        onTap: () => _showRecipeDetails(context, mealName),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                          decoration: BoxDecoration(color: const Color(0xFFF4F6F4), borderRadius: BorderRadius.circular(10)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.menu_book_rounded, size: 14, color: Colors.black54),
                              SizedBox(width: 6),
                              Text("Recipe", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مخصصة للـ Snacks
  Widget _buildSnackSection({
    required String title,
    required String time,
    required String mealName,
    required int calories,
    required String imageUrl,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(6)),
              child: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl, 
                  width: 50, 
                  height: 50, 
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 50,
                    height: 50,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.restaurant, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text("$calories kcal", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () => _showRecipeDetails(context, mealName),
                      child: const Text("View details ->", style: TextStyle(color: Color(0xFF388E3C), fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ويدجت في حال عدم وجود وجبة مسجلة
  Widget _buildEmptyMealSection(String title, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(6)),
                child: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Icon(Icons.no_meals_rounded, color: Colors.grey.shade400, size: 30),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    "No meals logged yet. Log your food to see it here!",
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت في حال عدم وجود سناك مسجل
  Widget _buildEmptySnackSection(String title, String time) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111827))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: const Color(0xFFECEFF1), borderRadius: BorderRadius.circular(6)),
              child: Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Icon(Icons.cookie_outlined, color: Colors.grey.shade400, size: 30),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  "No snacks logged yet.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeDetailsSheet extends StatefulWidget {
  final String mealName;
  const _RecipeDetailsSheet({required this.mealName});

  @override
  State<_RecipeDetailsSheet> createState() => _RecipeDetailsSheetState();
}

class _RecipeDetailsSheetState extends State<_RecipeDetailsSheet> {
  bool _isLoading = true;
  FoodItem? _foodItem;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchRecipe();
  }

  Future<void> _fetchRecipe() async {
    try {
      final repo = context.read<IFoodRepository>();
      
      // Clean up the query: if it starts with numbers/quantities (e.g. "1 Hamburger" or "100g Chicken"),
      // we can try to extract the main food name by removing leading digits/units if possible,
      // but let's first search by the full meal name.
      String query = widget.mealName.trim();
      
      final results = await repo.searchFood(query);
      if (mounted) {
        setState(() {
          if (results.isNotEmpty) {
            _foodItem = results.first;
          } else {
            // Try fallback search with just the first word in case of "1 Hamburger" or "100g Hamburger"
            final words = query.split(' ');
            if (words.length > 1) {
              _searchFallback(words.skip(1).join(' '));
              return;
            }
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _searchFallback(String fallbackQuery) async {
    try {
      final repo = context.read<IFoodRepository>();
      final results = await repo.searchFood(fallbackQuery);
      if (mounted) {
        setState(() {
          if (results.isNotEmpty) {
            _foodItem = results.first;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recipe Details",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const Divider(height: 24),
          if (_isLoading)
            const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF388E3C),
                ),
              ),
            )
          else if (_foodItem != null)
            _buildFoodDetails(_foodItem!)
          else
            _buildEmptyState(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildFoodDetails(FoodItem item) {
    final double calories = item.caloriesPer100g;
    final double protein = item.proteinPer100g;
    final double carbs = item.carbsPer100g;
    final double fats = item.fatsPer100g;
    final double totalMacros = protein + carbs + fats;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B3A2B),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          "Nutritional values per 100g",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        const SizedBox(height: 20),
        
        // Calories Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F8F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Energy",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Calories in this food item",
                    style: TextStyle(color: Colors.grey, fontSize: 11),
                  ),
                ],
              ),
              Text(
                "${calories.toInt()} kcal",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF388E3C),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        
        const Text(
          "Macro Breakdown",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        const SizedBox(height: 12),

        // Custom Macro progress indicator bars
        _buildMacroRow("Carbohydrates", carbs, totalMacros > 0 ? carbs / totalMacros : 0, const Color(0xFFFFA726), "g"),
        const SizedBox(height: 12),
        _buildMacroRow("Protein", protein, totalMacros > 0 ? protein / totalMacros : 0, const Color(0xFF66BB6A), "g"),
        const SizedBox(height: 12),
        _buildMacroRow("Fats", fats, totalMacros > 0 ? fats / totalMacros : 0, const Color(0xFFEF5350), "g"),
      ],
    );
  }

  Widget _buildMacroRow(String title, double val, double ratio, Color color, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)),
            Text(
              "${val.toStringAsFixed(1)}$unit (${(ratio * 100).toInt()}%)",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            backgroundColor: Colors.grey[100],
            color: color,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    final hasError = _error != null;
    return Column(
      children: [
        const SizedBox(height: 20),
        Center(
          child: Icon(
            hasError ? Icons.error_outline_rounded : Icons.search_off_rounded,
            color: hasError ? Colors.red.shade400 : Colors.grey[400],
            size: 48,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            hasError ? "Failed to query recipe database" : "Recipe not found in database",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.grey[800]),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text(
              hasError
                  ? _error!
                  : "We couldn't find detailed macro stats for '${widget.mealName}' in the food database. However, your logged custom entry remains active in your daily summary.",
              style: const TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}