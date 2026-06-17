import 'package:bite_smart/features/profile/screens/insights.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AICoachScreen extends StatelessWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              const Spacer(),

              // الجزء العلوي: الأيقونات والدوائر المتداخلة
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // الدوائر الخلفية الشفافة (التأثير الدائري)
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black.withOpacity(0.03), width: 1),
                      ),
                    ),
                    Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black.withOpacity(0.03), width: 1),
                      ),
                    ),
                    
                    // المربع المتدرج اللي فيه القلب
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF43A047), // أخضر
                            Color(0xFF5C6BC0), // أزرق/بنفسجي
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueAccent.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),

                    // التاج اللي فوق (Analyzing...)
                    Positioned(
                      top: 10,
                      right: -20,
                      child: _buildInfoTag('ai_coach.analyzing'.tr(), Icons.auto_awesome),
                    ),

                    // التاج اللي تحت (Protein: 24g)
                    Positioned(
                      bottom: 10,
                      left: -40,
                      child: _buildInfoTag('ai_coach.protein'.tr(), null),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // النصوص
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                  children: [
                    TextSpan(text: 'ai_coach.title_part1'.tr()),
                    TextSpan(text: 'ai_coach.title_part2'.tr(), style: TextStyle(color: Color(0xFF43A047))),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                'ai_coach.description'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.5),
              ),

              const Spacer(),

              // الـ Page Indicator (النقطة النشطة هي الثانية)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCircleIndicator(isActive: false),
                  const SizedBox(width: 8),
                  _buildCapsuleIndicator(isActive: true),
                  const SizedBox(width: 8),
                  _buildCircleIndicator(isActive: false),
                 
                ],
              ),

              const Spacer(),

              // زرار Next
              SizedBox(
                width: .6*MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) =>  InsightsScreen())
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
                        'ai_coach.next'.tr(),
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

  // ويدجت مساعدة لبناء التاجات (Tags) الصغيرة
  Widget _buildInfoTag(String text, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) Icon(icon, size: 14, color: Colors.green),
          if (icon != null) const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIndicator({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF43A047) : const Color(0xFFD1D9E0),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCapsuleIndicator({required bool isActive}) {
    return Container(
      width: 25,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}