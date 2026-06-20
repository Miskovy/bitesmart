import 'package:bite_smart/features/profile/screens/aiCoachingScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFA), // نفس لون الخلفية الفاتح
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Spacer(),
              
              // الجزء العلوي: الصورة مع تأثير الـ Scanner
              Stack(
                alignment: Alignment.center,
                children: [
                  // الظل الخارجي للصورة
                  Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                  ),
                  // الصورة الرئيسية داخل الـ Dotted Border
                  Container(
                    width: 240,
                    height: 240,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      // محاكاة للـ Dotted border باستخدام Border.all لو مش عايز تستخدم Package
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                        width: 2,
                        style: BorderStyle.solid, 
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        'assets/image1.jpeg', // صورة طبق سلطة كمثال
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // الـ Tag بتاع السعرات (450 kcal)
                  Positioned(
                    top: 30,
                    right: 30,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
                      ),
                      child: const Text(
                        '450 kcal',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                  // الزرار الأخضر اللي تحت (Shutter button)
                  Positioned(
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Container(
                        height: 45,
                        width: 45,
                        decoration: const BoxDecoration(
                          color: Color(0xFF43A047),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // النصوص
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                  children: [
                    TextSpan(text: 'onboarding.title_part1'.tr()),
                    TextSpan(text: 'onboarding.title_part2'.tr(), style: const TextStyle(color: Color(0xFF43A047))),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'onboarding.description'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.5),
              ),

              const SizedBox(height: 40),

              // الـ Page Indicator (النقاط اللي تحت)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 30,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF43A047),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildCircleIndicator(),
                  const SizedBox(width: 8),
                  _buildCircleIndicator(),
                ],
              ),

              const Spacer(),

              // زرار Next
              SizedBox(
                width: .6* MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AICoachScreen())
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'onboarding.next'.tr(),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.white),
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

  Widget _buildCircleIndicator() {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFD1D9E0),
        shape: BoxShape.circle,
      ),
    );
  }
}