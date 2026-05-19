import 'package:flutter/material.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  // 🟢 1. المتغيرات (Variables) الخاصة بالخطة لربطها بالداتا بيز لاحقاً
  int consumedCalories = 1450;
  int targetCalories = 1800;
  int consumedProtein = 92;
  int targetProtein = 120;
  
  int selectedDayIndex = 1; // اليوم المختار افتراضياً (Tue 12)

  // بيانات شريط الأيام العلوي
  final List<Map<String, String>> weekDays = [
     {'dayName': 'sat', 'dayNum': '9'},
    {'dayName': 'sun', 'dayNum': '10'},
    {'dayName': 'Mon', 'dayNum': '11'},
    {'dayName': 'Tue', 'dayNum': '12'},
    {'dayName': 'Wed', 'dayNum': '13'},
    {'dayName': 'Thu', 'dayNum': '14'},
    {'dayName': 'Fri', 'dayNum': '15'},
       
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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

            // 4. شريط اختيار الأيام الأفقي
            SizedBox(
              height: 75,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(weekDays.length, (index) {
                  bool isSelected = selectedDayIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => selectedDayIndex = index),
                    child: Container(
                      width: 58,
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF388E3C) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.02),
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
                              fontSize: 12,
                              color: isSelected ? Colors.white70 : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            weekDays[index]['dayNum']!,
                            style: TextStyle(
                              fontSize: 16,
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 4),
                            const CircleAvatar(radius: 2, backgroundColor: Colors.white),
                          ]
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),

            // 5. كارت الـ AI Coach المستطيل الأخضر الداكن
            _buildCoachSummaryCard(),

            const SizedBox(height: 24),

            // 6. قائمة الوجبات اليومية (Breakfast, Lunch, Dinner, Snacks)
            _buildMealSection(
              title: "Breakfast",
              time: "08:00 AM",
              mealName: "Avocado Toast & Egg",
              calories: 350,
              protein: 18,
              imageUrl: "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&q=80&w=200",
            ),
            
            _buildMealSection(
              title: "Lunch",
              time: "01:00 PM",
              mealName: "Quinoa Power Bowl",
              calories: 450,
              protein: 22,
              imageUrl: "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&q=80&w=200",
              hasDot: true, // النقطة الخضراء الصغيرة بجانب اسم الوجبة
            ),
            
            _buildMealSection(
              title: "Dinner",
              time: "07:30 PM",
              mealName: "Grilled Salmon & Asparagus",
              calories: 550,
              protein: 45,
              imageUrl: "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&q=80&w=200",
            ),
            
            _buildSnackSection(
              title: "Snacks",
              time: "Anytime",
              mealName: "Greek Yogurt & Berries",
              calories: 150,
              imageUrl: "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&q=80&w=200",
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت كارت الـ AI Coach العلوي
  Widget _buildCoachSummaryCard() {
    double caloriesProgress = consumedCalories / targetCalories;
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
                  child: Image.network(imageUrl, width: 64, height: 64, fit: BoxFit.cover),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(mealName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF111827))),
                          if (hasDot) ...[
                            const SizedBox(width: 6),
                            const CircleAvatar(radius: 3, backgroundColor: Color(0xFF4CAF50)),
                          ]
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("$calories kcal · ${protein}g Protein", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 8),
                      // زر الـ Recipe
                      Container(
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
                      )
                    ],
                  ),
                ),
                // زر التحديث الدائري على اليمين
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: const Color(0xFFF4F6F4), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.refresh_rounded, size: 18, color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت مخصصة للـ Snacks (لأن تصميم زر الإضافة فيها مختلف)
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
                child: Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover),
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
                    const Text("View details ->", style: TextStyle(color: Color(0xFF388E3C), fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              // زر الإضافة الدائري الخاص بالـ Snacks
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.grey, size: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}