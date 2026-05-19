import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class DayCompleteScreen extends StatelessWidget {
  // 🟢 المتغيرات القابلة للتعديل عند جلب البيانات من الداتا بيز نهاية اليوم
  final int consumedCalories;
  final int targetCalories;
  final int proteinIntake;
  final int proteinTarget;
  final int carbsIntake;
  final int carbsTarget;
  final int fatIntake;
  final int fatTarget;
  final String coachInsightText;

  const DayCompleteScreen({
    super.key,
    this.consumedCalories = 1850,
    this.targetCalories = 2000,
    this.proteinIntake = 120,
    this.proteinTarget = 120,
    this.carbsIntake = 180,
    this.carbsTarget = 210,
    this.fatIntake = 45,
    this.fatTarget = 65,
    this.coachInsightText = "Great job staying on track! You hit your protein goal perfectly today. Tomorrow, try adding a few more healthy fats at lunch.",
  });

  @override
  Widget build(BuildContext context) {
    double caloriesProgress = consumedCalories / targetCalories;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      backgroundColor: Colors.white,
      // 💡 التعديل السحري هنا: الـ insetPadding دي بتضمن وجود مسافة أمان (فراغ) دائم حول الديالوج من كل الجهات
      insetPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      clipBehavior: Clip.antiAlias,
      child: Container(
        // 💡 نحدد هنا أقصى عرض مسموح بيه للديالوج عشان ميكبرش بزيادة في الشاشات العريضة
        constraints: const BoxConstraints(maxWidth: 360), 
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min, // يخليه ياخد حجم المحتوى بالظبط وميتمددش لآخر الشاشة عمودياً
            children: [
              // 1. أيقونة الكأس الاحتفالية بالأعلى مع الدائرة الملونة والقصاصات
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 80, // صغرنا حجم الدائرة قليلاً لتناسب الحجم الجديد
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: Color(0xFF388E3C),
                      size: 38,
                    ),
                  ),
                  const Positioned(top: 10, left: 0, child: CircleAvatar(radius: 3, backgroundColor: Colors.blueAccent)),
                  const Positioned(top: 0, right: 12, child: CircleAvatar(radius: 2.5, backgroundColor: Colors.orangeAccent)),
                  const Positioned(bottom: 12, left: 5, child: CircleAvatar(radius: 2.5, backgroundColor: Colors.pinkAccent)),
                ],
              ),
              const SizedBox(height: 16),

              // 2. نصوص التهنئة الرئيسية
              Text(
                "dayComplete.day_complete".tr(),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 4),
              Text(
                "dayComplete.logged_everything".tr(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // 3. عرض السعرات المستهلكة مقابل الهدف الكلي
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "$consumedCalories ",
                      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    TextSpan(
                      text: "/ $targetCalories ${"dayComplete.kcal".tr()}",
                      style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // شريط التقدم الأفقي للسعرات
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: caloriesProgress > 1 ? 1 : caloriesProgress,
                  backgroundColor: const Color(0xFFF3F4F6),
                  color: const Color(0xFF388E3C),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 28),

              // 4. الحلقات الدائرية لعرض نسب الماكروس الثلاثة جنبًا إلى جنب
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildMacroCircle("dayComplete.protein".tr(), proteinIntake, proteinTarget, const Color(0xFF388E3C)),
                  _buildMacroCircle("dayComplete.carbs".tr(), carbsIntake, carbsTarget, const Color(0xFFFFB300)),
                  _buildMacroCircle("dayComplete.fat".tr(), fatIntake, fatTarget, const Color(0xFF2196F3)),
                ],
              ),
              const SizedBox(height: 24),

              // 5. قسم نصيحة المدرب الذكي (Coach Insight)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F8F5),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2.0),
                      child: Icon(Icons.auto_awesome_rounded, color: Color(0xFF388E3C), size: 16),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "dayComplete.coach_insight".tr(),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            coachInsightText,
                            style: const TextStyle(fontSize: 11, color: Colors.black87, height: 1.35),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 6. زر الإغلاق والمتابعة السفلي الملون بالأخضر
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  minimumSize: const Size(double.infinity, 50), // صغرنا الارتفاع سنة بسيطة ليناسب الهيكل الجديد
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "dayComplete.close_summary".tr(),
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ويدجت رسم الدائرة التقدمية
  Widget _buildMacroCircle(String title, int intake, int target, Color color) {
    double progress = intake / target;
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 58, // صغرنا قطر الحلقات الدائرية من 68 إلى 58 لتبدو متناسقة وملمومة
              height: 58,
              child: CircularProgressIndicator(
                value: progress > 1 ? 1 : progress,
                backgroundColor: const Color(0xFFF3F4F6),
                color: color,
                strokeWidth: 5, // قللنا السمك قليلاً ليناسب الحجم الأصغر
                strokeCap: StrokeCap.round,
              ),
            ),
            Text(
              "${intake}g",
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "${"dayComplete.goal_label".tr()} ${target}g",
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}