import 'package:bite_smart/ui/screens/snap&LogScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ChooseGoalScreen extends StatefulWidget {
  const ChooseGoalScreen({super.key});

  @override
  State<ChooseGoalScreen> createState() => _ChooseGoalScreenState();
}

class _ChooseGoalScreenState extends State<ChooseGoalScreen> {
  // متغير لتخزين الاختيار الحالي (بدأنا بـ 0 اللي هو أول اختيار)
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFA), // خلفية فاتحة زي الصورة
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'goal.title'.tr(),
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
              ),
              const SizedBox(height: 12),
              Text(
                'goal.subtitle'.tr(),
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.4),
              ),
              const SizedBox(height: 40),

              // العناصر
              _buildGoalCard(
                index: 0,
                title: 'goal.weight_loss'.tr(),
                description: 'goal.weight_loss_desc'.tr(),
                icon: Icons.trending_down,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                index: 1,
                title: 'goal.maintenance'.tr(),
                description: 'goal.maintenance_desc'.tr(),
                icon: Icons.balance,
              ),
              const SizedBox(height: 16),
              _buildGoalCard(
                index: 2,
                title: 'goal.muscle_gain'.tr(),
                description: 'goal.muscle_gain_desc'.tr(),
                icon: Icons.fitness_center,
              ),

              const Spacer(),

              // زرار Next Step
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const OnboardingScreen())
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('goal.next_step'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت بناء الكارت مع منطق التغيير
  Widget _buildGoalCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index; // تحديث العنصر المختار عند الضغط
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // حركة ناعمة في تغيير اللون
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          // تغيير لون الفريم بناءً على الاختيار
          border: Border.all(
            color: isSelected ? const Color(0xFF43A047) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الأيقونة الصغيرة الملونة
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // لو مختار يبقا اخضر فاتح، لو لا يبقا رمادي فاتح
                color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                // لون الأيقونة بيتغير لاخضر لو مختار
                color: isSelected ? const Color(0xFF43A047) : Colors.black45,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            // الدائرة اللي في الجنب (Checkmark)
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF43A047) : Colors.black12,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF43A047) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}