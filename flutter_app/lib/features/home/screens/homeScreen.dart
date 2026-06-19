import 'package:bite_smart/features/home/data/models/meal_model.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:bite_smart/features/home/data/repositories/food_repository.dart';
import 'package:bite_smart/features/profile/data/models/user_profile_model.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_state.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/core/utils/avatar_utils.dart';

class DailyLogModel {
  final int caloriesConsumed;
  final int caloriesTarget;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbsConsumed;
  final int carbsTarget;
  final int fatConsumed;
  final int fatTarget;
  final int waterIntakeMl;
  final int waterTargetMl;
  final String coachTip;
  final List<MealModel> meals;

  DailyLogModel({
    required this.caloriesConsumed,
    required this.caloriesTarget,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbsConsumed,
    required this.carbsTarget,
    required this.fatConsumed,
    required this.fatTarget,
    required this.waterIntakeMl,
    required this.waterTargetMl,
    required this.coachTip,
    required this.meals,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  DailyLogModel? _dailyLog;
  UserProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    loadDailyLog();
  }

  int _toInt(dynamic val) {
    if (val == null) return 0;
    if (val is num) return val.toInt();
    if (val is String) return double.tryParse(val)?.toInt() ?? int.tryParse(val) ?? 0;
    return 0;
  }

  Future<void> loadDailyLog() async {
    try {
      final repo = context.read<IHomeRepository>();
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final summary = await repo.getDailySummary(dateStr);
      final meals = await repo.getMeals(userId: '');

      int waterMl = 0;
      try {
        final waterLogs = await repo.getWaterLogs(dateStr);
        waterMl = _toInt(waterLogs['totalConsumed']);
      } catch (_) {}

      UserProfileModel? profile;
      try {
        final profileRepo = context.read<IProfileRepository>();
        profile = await profileRepo.getUserProfile(userId: '');
      } catch (_) {}

      final consumed = summary['consumed'] as Map<String, dynamic>? ?? {};
      final target = summary['targets'] as Map<String, dynamic>? ?? {};

      setState(() {
        _profile = profile;
        final userTargets = profile?.targets;
        _dailyLog = DailyLogModel(
          caloriesConsumed: _toInt(consumed['calories']),
          caloriesTarget: userTargets != null ? userTargets.calorieTarget : _toInt(target['calories'] ?? 0),
          proteinConsumed: _toInt(consumed['protein']),
          proteinTarget: userTargets != null ? userTargets.proteinTarget : _toInt(target['protein'] ?? 0),
          carbsConsumed: _toInt(consumed['carbs']),
          carbsTarget: userTargets != null ? userTargets.carbsTarget : _toInt(target['carbs'] ?? 0),
          fatConsumed: _toInt(consumed['fats']),
          fatTarget: userTargets != null ? userTargets.fatTarget : _toInt(target['fats'] ?? 0),
          waterIntakeMl: waterMl,
          waterTargetMl: userTargets != null ? userTargets.waterMl : 2000,
          coachTip: summary['coachInsight'] as String? ?? 'Keep up the good work!',
          meals: meals,
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logWater(int glassIndex) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = context.read<IHomeRepository>();
      final int newGlasses = glassIndex + 1;
      final int currentMl = _dailyLog?.waterIntakeMl ?? 0;
      final int targetMl = newGlasses * 500;
      final int changeMl = targetMl - currentMl;
      
      await repo.logWater(amountMl: changeMl);
      await loadDailyLog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteMeal(String entryId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final repo = context.read<IHomeRepository>();
      await repo.removeMeal(mealId: entryId);
      await loadDailyLog();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddMealBottomSheet(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return AddMealBottomSheet(
          mealType: mealType,
          onMealAdded: () {
            Navigator.pop(context);
            loadDailyLog();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF6F9F6),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF388E3C)),
        ),
      );
    }

    final double caloriesTarget = _dailyLog?.caloriesTarget.toDouble() ?? 0.0;
    final double caloriesConsumed = _dailyLog?.caloriesConsumed.toDouble() ?? 0.0;
    final double caloriesRemaining = (caloriesTarget - caloriesConsumed).clamp(0.0, caloriesTarget);
    final double caloriesProgress = caloriesTarget > 0 ? (caloriesConsumed / caloriesTarget).clamp(0.0, 1.0) : 0.0;

    final double proteinTarget = _dailyLog?.proteinTarget.toDouble() ?? 0.0;
    final double proteinConsumed = _dailyLog?.proteinConsumed.toDouble() ?? 0.0;
    final double proteinProgress = proteinTarget > 0 ? (proteinConsumed / proteinTarget).clamp(0.0, 1.0) : 0.0;

    final double carbsTarget = _dailyLog?.carbsTarget.toDouble() ?? 0.0;
    final double carbsConsumed = _dailyLog?.carbsConsumed.toDouble() ?? 0.0;
    final double carbsProgress = carbsTarget > 0 ? (carbsConsumed / carbsTarget).clamp(0.0, 1.0) : 0.0;

    final double fatTarget = _dailyLog?.fatTarget.toDouble() ?? 0.0;
    final double fatConsumed = _dailyLog?.fatConsumed.toDouble() ?? 0.0;
    final double fatProgress = fatTarget > 0 ? (fatConsumed / fatTarget).clamp(0.0, 1.0) : 0.0;

    final int waterIntakeMl = _dailyLog?.waterIntakeMl ?? 0;
    final int waterGlasses = (waterIntakeMl / 500).round().clamp(0, 8);

    // Filter meals
    final mealsList = _dailyLog?.meals ?? [];
    final breakfastMeals = mealsList.where((m) => _getMealType(m) == 'breakfast').toList();
    final lunchMeals = mealsList.where((m) => _getMealType(m) == 'lunch').toList();
    final dinnerMeals = mealsList.where((m) => _getMealType(m) == 'dinner').toList();
    final snacksMeals = mealsList.where((m) => _getMealType(m) == 'snack' || _getMealType(m) == 'snacks').toList();

    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          if (_profile == null ||
              _profile!.profileImageUrl != state.profileImageUrl ||
              _profile!.displayName != state.displayName ||
              _profile!.targets != state.targets) {
            loadDailyLog();
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F9F6),
        body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadDailyLog,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildHeaderSection(),
                const SizedBox(height: 10),

                // Calorie Summary
                _buildCalorieSummaryCard(
                  remaining: caloriesRemaining.toInt(),
                  target: caloriesTarget.toInt(),
                  progress: caloriesProgress,
                  protein: '${proteinConsumed.toInt()}g',
                  proteinProg: proteinProgress,
                  carbs: '${carbsConsumed.toInt()}g',
                  carbsProg: carbsProgress,
                  fats: '${fatConsumed.toInt()}g',
                  fatsProg: fatProgress,
                ),
                const SizedBox(height: 10),

                // Coach tip
                _buildCoachTipCard(),
                const SizedBox(height: 10),

                // Hydration
                _buildHydrationCard(waterIntakeMl, waterGlasses),
                const SizedBox(height: 10),

                // Meals title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'home.meals_title'.tr(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF111827),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Breakfast
                _buildMealSection(
                  mealType: 'Breakfast',
                  meals: breakfastMeals,
                  imagePlaceholder: Icons.breakfast_dining,
                ),

                // Lunch
                _buildMealSection(
                  mealType: 'Lunch',
                  meals: lunchMeals,
                  imagePlaceholder: Icons.lunch_dining,
                ),

                // Dinner
                _buildMealSection(
                  mealType: 'Dinner',
                  meals: dinnerMeals,
                  imagePlaceholder: Icons.dinner_dining,
                ),

                // Snacks
                _buildMealSection(
                  mealType: 'Snack',
                  meals: snacksMeals,
                  imagePlaceholder: Icons.apple,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

  String _getMealType(MealModel meal) {
    if (meal.description != null && meal.description!.contains(' - ')) {
      return meal.description!.split(' - ').first.toLowerCase();
    }
    return 'breakfast';
  }

  Widget _buildHeaderSection() {
    final welcomeText = _profile?.displayName != null
        ? "${'home.welcome'.tr()}, ${_profile!.displayName}"
        : 'home.welcome'.tr();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat('EEEE, MMM d').format(DateTime.now()),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              welcomeText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        CircleAvatar(
          radius: 18,
          backgroundImage: _profile?.profileImageUrl != null && _profile!.profileImageUrl!.isNotEmpty
              ? AvatarUtils.getImageProvider(_profile!.profileImageUrl!)
              : null,
          child: _profile?.profileImageUrl == null || _profile!.profileImageUrl!.isEmpty
              ? const Icon(
                  Icons.person,
                  color: Colors.grey,
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildCalorieSummaryCard({
    required int remaining,
    required int target,
    required double progress,
    required String protein,
    required double proteinProg,
    required String carbs,
    required double carbsProg,
    required String fats,
    required double fatsProg,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 10,
                      backgroundColor: Colors.grey.shade100,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF388E3C),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'home.remaining'.tr(),
                        style: const TextStyle(
                          fontSize: 6,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$remaining',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${'home.of'.tr()} $target ${'home.kcal'.tr()}',
                        style: const TextStyle(fontSize: 6, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroIndicator(
                protein,
                'home.protein'.tr(),
                Colors.blue,
                proteinProg,
              ),
              _buildMacroIndicator(
                carbs,
                'home.carbs'.tr(),
                Colors.amber,
                carbsProg,
              ),
              _buildMacroIndicator(
                fats,
                'home.fats'.tr(),
                Colors.redAccent,
                fatsProg,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(
    String amount,
    String label,
    Color color,
    double progress,
  ) {
    return Column(
      children: [
        SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 4,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          amount,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCoachTipCard() {
    final String tipText = _dailyLog?.coachTip ?? 'home.coach_tip'.tr();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFFE8F5E8), Colors.green.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates,
            color: Color(0xFF388E3C),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'home.coach_title'.tr(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'home.coach_badge'.tr(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: Color(0xFF388E3C),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  tipText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard(int waterIntakeMl, int waterGlasses) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('home.hydration'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text(
                "$waterIntakeMl ml / ${_dailyLog?.waterTargetMl ?? 2000}ml",
                style: const TextStyle(color: Colors.lightBlue, fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ...List.generate(8, (index) {
                bool isFilled = index < waterGlasses;
                return GestureDetector(
                  onTap: () => _logWater(index),
                  child: Icon(
                    Icons.opacity,
                    color: isFilled ? Colors.blue.shade400 : Colors.grey.shade200,
                    size: 28,
                  ),
                );
              }),
              GestureDetector(
                onTap: () {
                  if (waterGlasses < 8) {
                    _logWater(waterGlasses);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                  child: const Icon(Icons.add, size: 20, color: Colors.grey),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildMealSection({
    required String mealType,
    required List<MealModel> meals,
    required IconData imagePlaceholder,
  }) {
    if (meals.isEmpty) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(imagePlaceholder, color: Colors.blueGrey.shade300),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mealType,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'home.not_logged'.tr(),
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showAddMealBottomSheet(mealType),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFF388E3C),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: meals.map((meal) {
        String quantityStr = '100';
        String unitStr = 'g';
        if (meal.description != null && meal.description!.contains(' - ')) {
          final parts = meal.description!.split(' - ');
          if (parts.length > 1) {
            final qtyUnitStr = parts[1];
            final subparts = qtyUnitStr.split(' ');
            if (subparts.isNotEmpty) {
              quantityStr = subparts[0];
            }
            if (subparts.length > 1) {
              unitStr = subparts[1];
            }
          }
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: meal.imageUrl != null && meal.imageUrl!.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          meal.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(imagePlaceholder, color: Colors.blueGrey.shade300),
                        ),
                      )
                    : Icon(imagePlaceholder, color: Colors.blueGrey.shade300),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$quantityStr $unitStr · $mealType',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${meal.calories} kcal',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                onPressed: () => _deleteMeal(meal.id),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Add Meal Bottom Sheet ───────────────────────────────────────────────────

class AddMealBottomSheet extends StatefulWidget {
  final String mealType;
  final VoidCallback onMealAdded;
  const AddMealBottomSheet({super.key, required this.mealType, required this.onMealAdded});

  @override
  State<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<AddMealBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController(text: '100');
  final ScrollController _scrollController = ScrollController();

  List<FoodItem> _searchResults = [];
  FoodItem? _selectedFood;
  bool _searching = false;
  bool _saving = false;

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchController.addListener(_onSearchTextChanged);
    _loadFoods(isRefresh: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    setState(() {}); // Rebuild to update suffix clear icon visibility
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      if (!_searching && !_isLoadingMore && _hasMore) {
        _loadFoods();
      }
    }
  }

  Future<void> _loadFoods({bool isRefresh = false}) async {
    if (isRefresh) {
      setState(() {
        _searching = true;
        _currentPage = 1;
        _hasMore = true;
      });
    } else {
      setState(() {
        _isLoadingMore = true;
      });
    }

    try {
      final repo = context.read<IFoodRepository>();
      final query = _searchController.text;
      final results = await repo.searchFood(query, page: _currentPage, limit: 20);

      setState(() {
        if (isRefresh) {
          _searchResults = results;
        } else {
          _searchResults.addAll(results);
        }

        if (results.length < 20) {
          _hasMore = false;
        } else {
          _currentPage++;
        }
        _searching = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _searching = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _searchFood(String query) async {
    _loadFoods(isRefresh: true);
  }

  Future<void> _addMeal() async {
    if (_selectedFood == null) return;
    setState(() {
      _saving = true;
    });
    try {
      final homeRepo = context.read<IHomeRepository>();
      final qty = double.tryParse(_quantityController.text) ?? 100.0;
      await homeRepo.logMealDirect(
        foodItemId: _selectedFood!.id,
        mealType: widget.mealType,
        quantity: qty,
        unit: 'g',
      );
      widget.onMealAdded();
    } catch (e) {
      setState(() {
        _saving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding meal: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 24,
        left: 24,
        right: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Log ${widget.mealType}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search food database...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _loadFoods(isRefresh: true);
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: () => _searchFood(_searchController.text),
                  ),
                ],
              ),
            ),
            onChanged: (value) {
              if (value.isEmpty) {
                _loadFoods(isRefresh: true);
              }
            },
            onSubmitted: _searchFood,
          ),
          const SizedBox(height: 16),
          if (_searching)
            const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator(color: Color(0xFF388E3C))),
            )
          else if (_selectedFood != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _selectedFood!.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _selectedFood = null),
                    child: const Text('Change'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Portion size',
                      suffixText: 'g',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _saving ? null : _addMeal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _saving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Add to Log',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ] else
            SizedBox(
              height: 300,
              child: _searchResults.isEmpty
                  ? Center(
                      child: Text(
                        'No food items found',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _searchResults.length + (_hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _searchResults.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF388E3C),
                              ),
                            ),
                          );
                        }
                        final item = _searchResults[index];
                        return ListTile(
                          leading: const Icon(Icons.restaurant_menu, color: Color(0xFF388E3C)),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text('${item.caloriesPer100g.toInt()} kcal per 100g'),
                          trailing: const Icon(Icons.add_circle_outline, color: Color(0xFF388E3C)),
                          onTap: () {
                            setState(() {
                              _selectedFood = item;
                            });
                          },
                        );
                      },
                    ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
