import 'package:flutter/material.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // 🟢 المتغيرات (Variables) القابلة للتعديل من الداتا بيز
  String dateRange = "Oct 24 - Oct 30";
  int avgCalories = 1850;
  double weightChange = -1.2;
  double currentWeightHighlight = 168.4;

  // بيانات الماكروس (Today's Breakdown)
  int carbsIntake = 124;
  int carbsTarget = 150;
  int proteinIntake = 142;
  int proteinTarget = 180;
  int fatsIntake = 32;
  int fatsTarget = 55;

  int selectedTab = 0; // 0: Weight, 1: Calories, 2: Macros

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Insights",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
       
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. هيدر "Your Progress" مع اختيار النطاق الزمني
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your Progress",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateRange,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                _buildDropDown("Weekly"),
              ],
            ),
            const SizedBox(height: 20),

            // 2. كروت الملخص السريع (Calories & Weight Change)
            Row(
              children: [
                _buildSummaryCard(
                  "AVG. CALORIES",
                  "$avgCalories",
                  "kcal/day",
                  Colors.pinkAccent,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  "WEIGHT CHANGE",
                  "$weightChange",
                  "lbs this week",
                  Colors.green,
                  isLoss: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. قسم الرسم البياني والـ Tabs
            _buildChartSection(),

            const SizedBox(height: 30),

            // 4. قسم AI Insights
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "AI Insights",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    "View All",
                    style: TextStyle(color: Color(0xFF4CAF50)),
                  ),
                ),
              ],
            ),
            _buildInsightCard(),

            const SizedBox(height: 30),

            // 5. قسم Today's Breakdown (Macros)
            const Text(
              "Today's Breakdown",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMacroRow(
              "Carbohydrates",
              carbsIntake,
              carbsTarget,
              const Color(0xFFFFEBEE),
              Colors.pinkAccent,
            ),
            _buildMacroRow(
              "Protein",
              proteinIntake,
              proteinTarget,
              const Color(0xFFE8F5E9),
              Colors.green,
            ),
            _buildMacroRow(
              "Fats",
              fatsIntake,
              fatsTarget,
              const Color(0xFFE3F2FD),
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  // --- ويدجت العناصر الفرعية ---

  Widget _buildDropDown(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const Icon(Icons.keyboard_arrow_down, size: 18),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String label,
    String value,
    String unit,
    Color color, {
    bool isLoss = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Tabs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ["Weight", "Calories", "Macros"].asMap().entries.map((
              entry,
            ) {
              bool isSelected = selectedTab == entry.key;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFF3F4F6)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    entry.value,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 30),
          // الخط البياني (Mockup للشكل الانسيابي)
          Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(painter: LineChartPainter()),
              ),
              // فقرة الوزن المختار
              Positioned(
                left: 140,
                top: 0,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "$currentWeightHighlight lbs",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 40,
                      color: Colors.black.withOpacity(0.1),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
            ), // مسافة أمان من الجوانب عشان متلزقش في الحافة
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
                  .map(
                    (day) => Text(
                      day,
                      style: TextStyle(
                        fontSize: 10, // كبرنا الخط سنة بسيطة عشان القراءة
                        color: Colors.grey.shade500, // درجة رمادي واضحة ونظيفة
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              "ACHIEVEMENT",
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Great Protein Streak",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "You've hit your protein target for 5 days in a row!",
            style: TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Text(
                "See Details",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
              Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(
    String name,
    int intake,
    int target,
    Color bgColor,
    Color progressColor,
  ) {
    double progress = intake / target;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.restaurant_menu, color: progressColor, size: 18),
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
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "$intake",
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: "g of ${target}g goal",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    backgroundColor: Colors.grey.shade200,
                    color: progressColor,
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// رسم الخط الانسيابي للشارت
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = const Color(0xFF4CAF50)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    Path path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.2,
      size.height * 0.8,
      size.width * 0.4,
      size.height * 0.4,
    );
    path.quadraticBezierTo(
      size.width * 0.6,
      size.height * 0.1,
      size.width * 0.8,
      size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.2);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
