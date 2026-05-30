import 'dart:math';
import 'package:bite_smart/features/home/screens/navBar.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_state.dart';
import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class DonutChartPainter extends CustomPainter {
  final double proteinPer;
  final double carbsPer;
  final double fatsPer;

  DonutChartPainter({
    required this.proteinPer,
    required this.carbsPer,
    required this.fatsPer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const strokeWidth = 22.0;
    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final total = proteinPer + carbsPer + fatsPer;
    final gap = 0.03; // gap in radians between segments

    final proteinSweep = (proteinPer / total) * 2 * pi - gap;
    final carbsSweep = (carbsPer / total) * 2 * pi - gap;
    final fatsSweep = (fatsPer / total) * 2 * pi - gap;

    final startAngle = -pi / 2;

    // Background track
    paint.color = const Color(0xFFEEF2EE);
    canvas.drawArc(rect, 0, 2 * pi, false, paint);

    // Protein (green)
    paint.color = const Color(0xFF4CAF50);
    canvas.drawArc(rect, startAngle, proteinSweep, false, paint);

    // Carbs (blue)
    paint.color = const Color(0xFF2196F3);
    final carbsStart = startAngle + proteinSweep + gap;
    canvas.drawArc(rect, carbsStart, carbsSweep, false, paint);

    // Fats (amber)
    paint.color = const Color(0xFFFFC107);
    final fatsStart = carbsStart + carbsSweep + gap;
    canvas.drawArc(rect, fatsStart, fatsSweep, false, paint);
  }

  @override
  bool shouldRepaint(DonutChartPainter old) =>
      old.proteinPer != proteinPer ||
      old.carbsPer != carbsPer ||
      old.fatsPer != fatsPer;
}

class MacrosTargetScreen extends StatefulWidget {
  const MacrosTargetScreen({super.key});

  @override
  State<MacrosTargetScreen> createState() => _MacrosTargetScreenState();
}

class _MacrosTargetScreenState extends State<MacrosTargetScreen>
    with SingleTickerProviderStateMixin {
  bool _isAiEnabled = false;
  double _proteinPer = 40.0;
  double _carbsPer = 35.0;
  double _fatsPer = 25.0;
  final int _totalCalories = 2450;

  late AnimationController _saveController;
  late Animation<double> _saveScale;

  int get _proteinGrams => ((_totalCalories * (_proteinPer / 100)) / 4).round();
  int get _carbsGrams => ((_totalCalories * (_carbsPer / 100)) / 4).round();
  int get _fatsGrams => ((_totalCalories * (_fatsPer / 100)) / 9).round();

  @override
  void initState() {
    super.initState();
    _saveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _saveScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _saveController, curve: Curves.easeInOut),
    );

    // Read initial values from bloc if they exist
    final currentTargets = context.read<ProfileSetupBloc>().state.data.targets;
    if (currentTargets != null) {
      _isAiEnabled = currentTargets.autoCalculateWithAi;
      final double proteinCals = currentTargets.proteins * 4;
      final double carbsCals = currentTargets.carbs * 4;
      final double fatsCals = currentTargets.fats * 9;
      final double sum = proteinCals + carbsCals + fatsCals;
      if (sum > 0) {
        _proteinPer = (proteinCals / sum) * 100;
        _carbsPer = (carbsCals / sum) * 100;
        _fatsPer = (fatsCals / sum) * 100;
      }
    }
  }

  @override
  void dispose() {
    _saveController.dispose();
    super.dispose();
  }

  void _onSavePressed() async {
    await _saveController.forward();
    await _saveController.reverse();
    
    final targets = TargetsData(
      calTotal: _totalCalories,
      proteins: _proteinGrams,
      carbs: _carbsGrams,
      fats: _fatsGrams,
      autoCalculateWithAi: _isAiEnabled,
    );

    context.read<ProfileSetupBloc>().add(SetTargetsEvent(targets));
    context.read<ProfileSetupBloc>().add(const SubmitProfileSetupEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSetupBloc, ProfileSetupState>(
      listener: (context, state) {
        if (state.status == ProfileSetupStatus.success) {
          final authState = context.read<AuthBloc>().state;
          if (authState is AuthAuthenticated) {
            context.read<ProfileBloc>().add(LoadProfileEvent(userId: authState.userId));
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('macros.save_success'.tr()),
              backgroundColor: const Color(0xFF388E3C),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.all(16),
            ),
          );
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainHome()),
            (route) => false,
          );
        } else if (state.status == ProfileSetupStatus.failure) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error'),
              content: Text(state.errorMessage ?? 'An error occurred during submission'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF4F7F4),
        appBar: AppBar(
          title: Text(
            'macros.title'.tr(),
            style: const TextStyle(
              color: Color(0xFF1B2E1B),
              fontWeight: FontWeight.w700,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
        ),  
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            children: [
              _buildAiToggleCard(),
              const SizedBox(height: 10),
              _buildCalorieChart(),
              const SizedBox(height: 10),
              _buildLegend(),
              const SizedBox(height: 10),
              _buildMacroCard(
                label: "macros.protein".tr(),
                percentage: _proteinPer,
                grams: _proteinGrams,
                color: const Color(0xFF4CAF50),
                bgColor: const Color(0xFFE8F5E9),
                icon: Icons.fitness_center_rounded,
                onChanged: (val) => setState(() => _proteinPer = val),
              ),
              const SizedBox(height: 10),
              _buildMacroCard(
                label: "macros.carbs".tr(),
                percentage: _carbsPer,
                grams: _carbsGrams,
                color: const Color(0xFF2196F3),
                bgColor: const Color(0xFFE3F2FD),
                icon: Icons.grain_rounded,
                onChanged: (val) => setState(() => _carbsPer = val),
              ),
              const SizedBox(height: 10),
              _buildMacroCard(
                label: "macros.fats".tr(),
                percentage: _fatsPer,
                grams: _fatsGrams,
                color: const Color(0xFFFFC107),
                bgColor: const Color(0xFFFFF8E1),
                icon: Icons.local_fire_department_rounded,
                onChanged: (val) => setState(() => _fatsPer = val),
              ),
              const SizedBox(height: 20),
              _buildSaveButton(),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ── AI Toggle Card ──────────────────────────
  Widget _buildAiToggleCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _isAiEnabled
              ? const Color(0xFF4CAF50).withOpacity(0.3)
              : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isAiEnabled
                  ? const Color(0xFFE8F5E9)
                  : const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _isAiEnabled
                  ? const Color(0xFF4CAF50)
                  : Colors.grey.shade400,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "macros.ai_toggle".tr(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF1B2E1B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isAiEnabled
                      ? "macros.ai_enabled".tr()
                      : "macros.ai_disabled".tr(),
                  style: TextStyle(
                    color: _isAiEnabled
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade500,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _isAiEnabled,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFF4CAF50),
            inactiveThumbColor: Colors.grey.shade300,
            inactiveTrackColor: Colors.grey.shade200,
            onChanged: (val) => setState(() => _isAiEnabled = val),
          ),
        ],
      ),
    );
  }

  // ── Donut Chart ─────────────────────────────
  Widget _buildCalorieChart() {
    return SizedBox(
      height: 150,
      width: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(150, 150),
            painter: DonutChartPainter(
              proteinPer: _proteinPer,
              carbsPer: _carbsPer,
              fatsPer: _fatsPer,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: _totalCalories),
                duration: const Duration(milliseconds: 600),
                builder: (context, val, _) => Text(
                  "$val",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1B2E1B),
                    height: 1,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "macros.kcal_goal".tr(),
                  style: const TextStyle(
                    color: Color(0xFF388E3C),
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Legend ──────────────────────────────────
  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("macros.protein".tr(), const Color(0xFF4CAF50)),
        const SizedBox(width: 18),
        _legendItem("macros.carbs".tr(), const Color(0xFF2196F3)),
        const SizedBox(width: 18),
        _legendItem("macros.fats".tr(), const Color(0xFFFFC107)),
      ],
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Macro Card ──────────────────────────────
  Widget _buildMacroCard({
    required String label,
    required double percentage,
    required int grams,
    required Color color,
    required Color bgColor,
    required IconData icon,
    required Function(double) onChanged,
  }) {
    final isDisabled = _isAiEnabled;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isDisabled ? 0.75 : 1.0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Color(0xFF37474F),
                  ),
                ),
                const Spacer(),
                Text(
                  "${percentage.round()}%",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "${grams}g",
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: color,
                inactiveTrackColor: color.withOpacity(0.12),
                thumbColor: Colors.white,
                overlayColor: color.withOpacity(0.12),
                trackHeight: 5,
                thumbShape: const RoundSliderThumbShape(
                  enabledThumbRadius: 11,
                  elevation: 4,
                ),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 20),
                disabledActiveTrackColor: color.withOpacity(0.4),
                disabledInactiveTrackColor: color.withOpacity(0.08),
                disabledThumbColor: Colors.grey.shade300,
              ),
              child: Slider(
                value: percentage,
                min: 5,
                max: 80,
                onChanged: isDisabled ? null : (val) => onChanged(val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return BlocBuilder<ProfileSetupBloc, ProfileSetupState>(
      builder: (context, state) {
        final isSubmitting = state.status == ProfileSetupStatus.submitting;
        return ScaleTransition(
          scale: _saveScale,
          child: SizedBox(
            width: .4 * MediaQuery.of(context).size.width,
            height: 46,
            child: ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () {
                      _onSavePressed();
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF43A047),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "macros.save_targets".tr(),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 22),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}