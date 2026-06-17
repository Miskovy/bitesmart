import 'dart:convert';
import 'dart:typed_data';
import 'package:bite_smart/core/widgets/universal_image_preview.dart';
import 'package:bite_smart/features/home/data/models/meal_model.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:bite_smart/features/home/data/repositories/food_repository.dart';
import 'package:bite_smart/features/home/data/bloc/prediction_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiAnalysizeScreen extends StatelessWidget {
  const AiAnalysizeScreen({
    super.key,
    required this.imagePath,
    this.imageBytes,
    this.foodWidthCm = 8.0,
    this.isCalibration = false,
  });

  final String imagePath;
  final Uint8List? imageBytes;
  final double foodWidthCm;
  final bool isCalibration;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PredictionBloc>(
      create: (context) => PredictionBloc(
        homeRepository: context.read<IHomeRepository>(),
      )..add(AnalyzeImageEvent(
          imagePath: imagePath,
          foodWidthCm: foodWidthCm,
          isCalibration: isCalibration,
        )),
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        body: Stack(
          children: [
            // Display the selected image at the top of the screen
            BlocBuilder<PredictionBloc, PredictionState>(
              builder: (context, state) {
                String? imageUrl;
                if (state is PredictionSuccess) {
                  imageUrl = state.meal.imageUrl;
                }
                return _ImageHeader(
                  imagePath: imagePath,
                  imageBytes: imageBytes,
                  imageUrl: imageUrl,
                );
              },
            ),

            // Top AppBar navigation buttons
            const _TopAppBar(),

            // Bottom sheet contents based on current state
            BlocBuilder<PredictionBloc, PredictionState>(
              builder: (context, state) {
                if (state is PredictionLoading || state is PredictionInitial) {
                  return const _LoadingPanel();
                } else if (state is PredictionError) {
                  return _ErrorPanel(
                    message: state.message,
                    imagePath: imagePath,
                    foodWidthCm: foodWidthCm,
                    isCalibration: isCalibration,
                  );
                } else if (state is PredictionSuccess) {
                  return _SuccessPanel(
                    meal: state.meal,
                    imagePath: imagePath,
                    imageBytes: imageBytes,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageHeader extends StatelessWidget {
  final String imagePath;
  final Uint8List? imageBytes;
  final String? imageUrl;

  const _ImageHeader({
    required this.imagePath,
    this.imageBytes,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    final hasUrl = imageUrl != null && imageUrl!.isNotEmpty;
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: hasUrl
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  UniversalImagePreview(
                imagePath: imagePath,
                imageBytes: imageBytes,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.restaurant,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          : UniversalImagePreview(
              imagePath: imagePath,
              imageBytes: imageBytes,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.grey,
                ),
              ),
            ),
    );
  }
}

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _CircleButton(
              icon: Icons.arrow_back,
              onTap: () => Navigator.maybePop(context),
            ),
            Row(
              children: [
                _CircleButton(icon: Icons.crop, onTap: () {}),
                const SizedBox(width: 8),
                _CircleButton(icon: Icons.more_vert, onTap: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF4CAF50)),
                  const SizedBox(height: 16),
                  Text(
                    'camera.ai_looking'.tr().isNotEmpty
                        ? 'camera.ai_looking'.tr()
                        : 'AI Looking for food...',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  final String message;
  final String imagePath;
  final double foodWidthCm;
  final bool isCalibration;

  const _ErrorPanel({
    required this.message,
    required this.imagePath,
    required this.foodWidthCm,
    required this.isCalibration,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PredictionBloc>().add(
                          AnalyzeImageEvent(
                            imagePath: imagePath,
                            foodWidthCm: foodWidthCm,
                            isCalibration: isCalibration,
                          ),
                        );
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  label: const Text(
                    "Retry",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SuccessPanel extends StatefulWidget {
  final MealModel meal;
  final String imagePath;
  final Uint8List? imageBytes;

  const _SuccessPanel({
    required this.meal,
    required this.imagePath,
    this.imageBytes,
  });

  @override
  State<_SuccessPanel> createState() => _SuccessPanelState();
}

class _SuccessPanelState extends State<_SuccessPanel> {
  double _portionValue = 0.5; // 0=Small, 0.5=Medium, 1=Large
  bool _isSaving = false;

  int get _calories {
    final baseCals = widget.meal.calories;
    if (_portionValue < 0.25) return (baseCals * 0.7).toInt();
    if (_portionValue < 0.75) return baseCals;
    return (baseCals * 1.4).toInt();
  }

  int get _carbs {
    if (widget.meal.nutrition == null) return 0;
    final baseCarbs = widget.meal.nutrition!.carbs;
    if (_portionValue < 0.25) return (baseCarbs * 0.7).toInt();
    if (_portionValue < 0.75) return baseCarbs;
    return (baseCarbs * 1.4).toInt();
  }

  int get _protein {
    if (widget.meal.nutrition == null) return 0;
    final baseProtein = widget.meal.nutrition!.protein;
    if (_portionValue < 0.25) return (baseProtein * 0.7).toInt();
    if (_portionValue < 0.75) return baseProtein;
    return (baseProtein * 1.4).toInt();
  }

  int get _fat {
    if (widget.meal.nutrition == null) return 0;
    final baseFat = widget.meal.nutrition!.fat;
    if (_portionValue < 0.25) return (baseFat * 0.7).toInt();
    if (_portionValue < 0.75) return baseFat;
    return (baseFat * 1.4).toInt();
  }

  Future<void> _addMealToLog() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final repo = context.read<IHomeRepository>();
      final foodRepo = context.read<IFoodRepository>();

      // Create custom food item
      final customFood = await foodRepo.createCustomFood(
        name: widget.meal.name,
        calories: _calories.toDouble(),
        protein: _protein.toDouble(),
        carbs: _carbs.toDouble(),
        fats: _fat.toDouble(),
      );

      // Log food item
      await repo.logMealDirect(
        foodItemId: customFood.id,
        mealType: _getMealTypeByTime(),
        quantity: 100.0,
        unit: 'g',
        imageUrl: widget.meal.imageUrl ?? widget.imagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "analyze.add_success".tr().isNotEmpty
                  ? "analyze.add_success".tr()
                  : "Meal logged successfully!",
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context, true); // Return true to trigger refresh
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _getMealTypeByTime() {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Breakfast';
    if (hour < 16) return 'Lunch';
    if (hour < 22) return 'Dinner';
    return 'Snack';
  }

  @override
  Widget build(BuildContext context) {
    final mealName = widget.meal.name.isNotEmpty ? widget.meal.name : "analyze.meal_title".tr();
    
    double plateDiameterCm = 0.0;
    double estimatedWeightG = 0.0;
    double estimatedVolumeCm3 = 0.0;
    String ingredientsStr = "analyze.ingredients_example".tr();

    if (widget.meal.description != null) {
      try {
        final decoded = jsonDecode(widget.meal.description!);
        if (decoded is Map) {
          plateDiameterCm = (decoded['plateDiameterCm'] as num? ?? 0.0).toDouble();
          estimatedWeightG = (decoded['estimatedWeightG'] as num? ?? 0.0).toDouble();
          estimatedVolumeCm3 = (decoded['estimatedVolumeCm3'] as num? ?? 0.0).toDouble();
          if (decoded.containsKey('ingredients')) {
            ingredientsStr = decoded['ingredients'] as String? ?? "analyze.ingredients_example".tr();
          }
        }
      } catch (_) {
        if (widget.meal.description!.isNotEmpty) {
          ingredientsStr = widget.meal.description!;
        }
      }
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: DraggableScrollableSheet(
        initialChildSize: 0.62,
        minChildSize: 0.55,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // AI Prediction badge + time
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome, color: Color(0xFF4CAF50), size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "analyze.ai_prediction".tr().isNotEmpty
                                    ? "analyze.ai_prediction".tr()
                                    : "AI Prediction",
                                style: const TextStyle(
                                  color: Color(0xFF4CAF50),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('h:mm a').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Title + edit button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            mealName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                        ),
                      ],
                    ),

                    Text(
                      "analyze.edit_hint".tr(),
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Macros row
                    Row(
                      children: [
                        _MacroCard(
                          label: "analyze.carbs".tr(),
                          value: '${_carbs}g',
                          color: const Color(0xFF2196F3),
                        ),
                        const SizedBox(width: 12),
                        _MacroCard(
                          label: "analyze.protein".tr(),
                          value: '${_protein}g',
                          color: const Color(0xFFFFC107),
                        ),
                        const SizedBox(width: 12),
                        _MacroCard(
                          label: "analyze.fat".tr(),
                          value: '${_fat}g',
                          color: const Color(0xFFFF9800),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Portion size title + calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "analyze.portion_size".tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '$_calories',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4CAF50),
                                ),
                              ),
                              TextSpan(
                                text: " ${"analyze.kcal_unit".tr()}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF1A1A1A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: const Color(0xFF4CAF50),
                        inactiveTrackColor: Colors.grey[200],
                        thumbColor: const Color(0xFF4CAF50),
                        overlayColor: const Color(0x334CAF50),
                        trackHeight: 5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                      ),
                      child: Slider(
                        value: _portionValue,
                        onChanged: (val) => setState(() => _portionValue = val),
                      ),
                    ),

                    // Slider labels
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "analyze.portion_small".tr(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _portionValue < 0.25
                                ? "analyze.portion_small".tr()
                                : _portionValue < 0.75
                                    ? "analyze.portion_medium".tr()
                                    : "analyze.portion_large".tr(),
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "analyze.portion_large".tr(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // AI Measurements Card
                    if (plateDiameterCm > 0 || estimatedWeightG > 0 || estimatedVolumeCm3 > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.straighten_rounded, color: Color(0xFF4CAF50), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  "analyze.measurements".tr().isNotEmpty
                                      ? "analyze.measurements".tr()
                                      : "AI Measurements",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MeasurementItem(
                                  label: "analyze.plate_diameter".tr().isNotEmpty
                                      ? "analyze.plate_diameter".tr()
                                      : "Plate Diameter",
                                  value: "${plateDiameterCm.toStringAsFixed(1)} cm",
                                ),
                                _MeasurementItem(
                                  label: "analyze.est_weight".tr().isNotEmpty
                                      ? "analyze.est_weight".tr()
                                      : "Est. Weight",
                                  value: "${estimatedWeightG.toStringAsFixed(1)} g",
                                ),
                                _MeasurementItem(
                                  label: "analyze.est_volume".tr().isNotEmpty
                                      ? "analyze.est_volume".tr()
                                      : "Est. Volume",
                                  value: "${estimatedVolumeCm3.toStringAsFixed(1)} cm³",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Ingredients tile
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.list_alt, color: Colors.grey[600]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "analyze.ingredients".tr(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  ingredientsStr,
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Add to log button
                    SizedBox(
                      width:.6 * double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _addMealToLog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                "analyze.add_to_log".tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementItem extends StatelessWidget {
  final String label;
  final String value;

  const _MeasurementItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
