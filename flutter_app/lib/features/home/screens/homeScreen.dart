import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int quntityofwater = 0;
  int _waterGlasses = 0; // عدد أكواب الماء المستهلكة حالياً

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF6F9F6,
      ), // لون الخلفية الهادئ المائل للأخضر
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // 1. الجزء العلوي (الترحيب والنوتیفیکیشن)
              _buildHeaderSection(),
              const SizedBox(height: 10),

              // 2. الكارت الرئيسي الكبير (عداد السعرات والماكروس)
              _buildCalorieSummaryCard(),
              const SizedBox(height: 10),

              // 3. كارت نصيحة المدرب بالذكاء الاصطناعي
              _buildCoachTipCard(),
              const SizedBox(height: 10),

              // 4. جزء متابعة شرب الماء (Hydration)
              _buildHydrationCard(),
              const SizedBox(height: 10),

              // 5. قسم وجبات اليوم (Today's Meals)
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

              _buildMealRow(
                title: 'home.breakfast'.tr(),
                subtitle: 'home.breakfast_sub'.tr(),
                calories: '350 kcal',
                isLogged: true,
                imagePlaceholder: Icons.breakfast_dining,
              ),
              _buildMealRow(
                title: 'home.lunch'.tr(),
                subtitle: 'home.lunch_sub'.tr(),
                calories: '420 kcal',
                isLogged: true,
                imagePlaceholder: Icons.lunch_dining,
              ),
              _buildMealRow(
                title: 'home.dinner'.tr(),
                subtitle: 'home.not_logged'.tr(),
                calories: '',
                isLogged: false,
                imagePlaceholder: Icons.dinner_dining,
              ),
              _buildMealRow(
                title: 'home.snacks'.tr(),
                subtitle: 'home.not_logged'.tr(),
                calories: '',
                isLogged: false,
                imagePlaceholder: Icons.apple,
              ),
              const SizedBox(
                height: 30,
              ), // مساحة إضافية حتى لا يغطي شريط التنقل على الوجبات
            ],
          ),
        ),
      ),

      // 6. شريط التنقل السفلي مع زر الكاميرا العائم المدمج
  
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildHeaderSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DateFormat(
                'EEEE, MMM d',
              ).format(DateTime.now()), // يعرض التاريخ الحالي ديناميكياً
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'home.welcome'.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.black,
              ),
              onPressed: () {},
            ),
            const CircleAvatar(
              radius: 18,
              backgroundColor: Colors.amber,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ), // هنا تضع صورة المستخدم الشخصية
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCalorieSummaryCard() {
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
          // عداد الدائرة الكبير للسعرات المتبقية
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
                      value: 0.62, // النسبة المستهلكة
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
                      const Text(
                        '750',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'home.of_kcal'.tr(),
                        style: const TextStyle(fontSize: 6, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // مؤشرات الماكروس الثلاثية الصغير بالأسفل (بروتين، كارب، دهون)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMacroIndicator(
                '80g',
                'home.protein'.tr(),
                Colors.blue,
                0.9,
              ),
              _buildMacroIndicator(
                '120g',
                'home.carbs'.tr(),
                Colors.amber,
                0.45,
              ),
              _buildMacroIndicator(
                '45g',
                'home.fats'.tr(),
                Colors.redAccent,
                0.7,
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
                  'home.coach_tip'.tr(),
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

Widget _buildHydrationCard() {
  // حساب الكمية الحالية: عدد القطرات مضروب في 500 مللي
  int currentWaterIntake = _waterGlasses * 500;

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
            // هنا الـ Text بقا ديناميكي وبيتغير بناءً على الكمية المحسوبة
            Text(
              "$currentWaterIntake ml / 4000ml", 
              style: const TextStyle(color: Colors.lightBlue, fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ...List.generate(8, (index) {
              bool isFilled = index < _waterGlasses;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _waterGlasses = index + 1;
                  });
                },
                child: Icon(
                  Icons.opacity,
                  color: isFilled ? Colors.blue.shade400 : Colors.grey.shade200,
                  size: 28,
                ),
              );
            }),
            GestureDetector(
              onTap: () {
                // شرط عشان الـ (+) ميتخطاش الـ 8 قطرات (4000 مللي) كحد أقصى للتصميم
                if (_waterGlasses < 8) {
                  setState(() {
                    _waterGlasses++;
                  });
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
  Widget _buildMealRow({
    required String title,
    required String subtitle,
    required String calories,
    required bool isLogged,
    required IconData imagePlaceholder,
  }) {
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
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: isLogged ? Colors.grey : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isLogged) ...[
            Text(
              calories,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          ] else
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF388E3C),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, size: 16, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
