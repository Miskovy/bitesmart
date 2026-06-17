import 'package:bite_smart/features/profile/screens/permission.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFA),
      body: SafeArea(
        child: Column(
          children: [
            // الجزء العلوي: الرسم البياني والكروت الطائرة
            Expanded(
              flex: 5,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 1. الرسم البياني الخلفي
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 140.0, left: 0, right: 0),
                      child: LineChart(
                        mainData(),
                      ),
                    ),
                  ),

                  // 2. كارت الوزن (Top Right)
                  Positioned(
                    top: 60,
                    right: 40,
                    child: _buildTrendCard(
                      title: 'insights.weight'.tr(),
                      value: '-2.4 kg',
                      icon: Icons.monitor_weight,
                      color: const Color(0xFFFFF3E0),
                      iconColor: Colors.orange,
                    ),
                  ),

                  // 3. كارت البروتين (Middle Left)
                  Positioned(
                    top: 130,
                    left: 20,
                    child: _buildTrendCard(
                      title: 'insights.protein'.tr(),
                      value: '124g ▲',
                      icon: Icons.restaurant,
                      color: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                    ),
                  ),

                  // 4. كارت الحرق (Bottom Right)
                  Positioned(
                    bottom: 40,
                    right: 30,
                    child: _buildTrendCard(
                      title: 'insights.burned'.tr(),
                      value: '840 kcal',
                      icon: Icons.local_fire_department,
                      color: const Color(0xFFE8F5E9),
                      iconColor: Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            // الجزء السفلي: النصوص والتحكم
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'insights.title'.tr(),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D1B2A),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'insights.description'.tr(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.blueGrey,
                        height: 1.5,
                      ),
                    ),
                    const Spacer(),

                    // Page Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCircleIndicator(isActive: false),
                        const SizedBox(width: 8),
                        _buildCircleIndicator(isActive: false),
                        const SizedBox(width: 8),
                        _buildCapsuleIndicator(isActive: true),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Get Started Button
                    SizedBox(
                      width: .6* MediaQuery.of(context).size.width,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.push(context, 
                          MaterialPageRoute(builder: (context) => const PermissionScreen())
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'insights.get_started'.tr(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
          ],
        ),
      ),
    );
  }

  // إعدادات الرسم البياني (مطابق لتموجات الصورة)
  LineChartData mainData() {
    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 2),
            FlSpot(2, 2.3),
            FlSpot(4, 3.5),
            FlSpot(6, 3.0),
            FlSpot(8, 4.8),
          ],
          isCurved: true,
          curveSmoothness: 0.5,
          color: const Color(0xFF5C6BC0),
          barWidth: 4,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF5C6BC0).withOpacity(0.25),
                const Color(0xFF5C6BC0).withOpacity(0.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // بناء الكروت الطائرة بظلال ناعمة
  Widget _buildTrendCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.bold,
                  color: Colors.black38,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIndicator({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
        color: Color(0xFFD1D9E0),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildCapsuleIndicator({required bool isActive}) {
    return Container(
      width: 28,
      height: 8,
      decoration: BoxDecoration(
        color: const Color(0xFF43A047),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}