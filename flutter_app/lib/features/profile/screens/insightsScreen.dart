import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';
import 'package:bite_smart/features/profile/data/models/user_insights_model.dart';
import 'package:easy_localization/easy_localization.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  // Fallback default variables
  String dateRange = "Oct 24 - Oct 30";
  int avgCalories = 1850;
  double weightChange = -1.2;
  double currentWeightHighlight = 168.4;

  int carbsIntake = 124;
  int carbsTarget = 150;
  int proteinIntake = 142;
  int proteinTarget = 180;
  int fatsIntake = 32;
  int fatsTarget = 55;

  int selectedTab = 0; // 0: Weight, 1: Calories, 2: Macros
  String _selectedRange = 'weekly';
  bool _isLoading = true;
  String _errorMessage = '';
  UserInsightsModel? _insights;

  @override
  void initState() {
    super.initState();
    _fetchInsights();
  }

  Future<void> _fetchInsights() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      final repo = context.read<IProfileRepository>();
      final data = await repo.getUserInsights(range: _selectedRange);
      setState(() {
        _insights = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAF8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAF8),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                 Text(
                  'insights_screen.failed_load'.tr(),
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _fetchInsights,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child:  Text('insights_screen.retry'.tr(), style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    String dateRangeText = dateRange;
    if (_insights != null && _insights!.periodData.isNotEmpty) {
      final firstDate = _insights!.periodData.first.date;
      final lastDate = _insights!.periodData.last.date;
      dateRangeText = "$firstDate - $lastDate";
    }

    final avgCal = _insights?.avgCalories ?? avgCalories;
    final wtChange = _insights?.weightChange ?? weightChange;
    final carbInt = _insights?.todayBreakdown.carbohydrates ?? carbsIntake;
    final carbTgt = carbsTarget;
    final protInt = _insights?.todayBreakdown.protein ?? proteinIntake;
    final protTgt = proteinTarget;
    final fatInt = _insights?.todayBreakdown.fats ?? fatsIntake;
    final fatTgt = fatsTarget;

    List<double> currentChartPoints = [];
    String highlightLabel = "";
    if (_insights != null) {
      if (selectedTab == 0) {
        currentChartPoints = _insights!.weightGraph.map<double>((e) => e.weight).toList();
        highlightLabel = currentChartPoints.isNotEmpty
            ? "${currentChartPoints.last} kg"
            : "$currentWeightHighlight lbs";
      } else if (selectedTab == 1) {
        currentChartPoints = _insights!.periodData.map<double>((e) => e.calories.toDouble()).toList();
        highlightLabel = currentChartPoints.isNotEmpty
            ? "${currentChartPoints.last.toInt()} kcal"
            : "$avgCal kcal";
      } else {
        currentChartPoints = _insights!.periodData.map<double>((e) => e.protein.toDouble()).toList();
        highlightLabel = currentChartPoints.isNotEmpty
            ? "${currentChartPoints.last.toInt()} g"
            : "$protInt g";
      }
    } else {
      if (selectedTab == 0) {
        currentChartPoints = [170.0, 169.5, 169.0, 168.8, 168.6, 168.4, 168.4];
        highlightLabel = "$currentWeightHighlight lbs";
      } else if (selectedTab == 1) {
        currentChartPoints = [2100, 1800, 1950, 1750, 1850, 1900, 1800];
        highlightLabel = "$avgCalories kcal";
      } else {
        currentChartPoints = [120, 130, 124, 140, 135, 128, 122];
        highlightLabel = "$carbsIntake g";
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title:  Text(
          'insights_screen.title_appbar'.tr(),
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
            // 1. Header with selected range
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Text(
                      'insights_screen.your_progress'.tr(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      dateRangeText,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                _buildDropDown(),
              ],
            ),
            const SizedBox(height: 20),

            // 2. Summary cards
            Row(
              children: [
                _buildSummaryCard(
                  'insights_screen.avg_calories'.tr(),
                  "$avgCal",
                  'insights_screen.kcal_day'.tr(),
                  Colors.pinkAccent,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  'insights_screen.weight_change'.tr(),
                  (wtChange >= 0 ? "+$wtChange" : "$wtChange"),
                  'insights_screen.lbs_period'.tr(),
                  Colors.green,
                  isLoss: wtChange < 0,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 3. Chart section
            _buildChartSection(currentChartPoints, highlightLabel),
            const SizedBox(height: 30),

            // 4. AI Insights section
           
            // 5. Today's Breakdown (Macros)
             Text(
              'insights_screen.breakdown_summary'.tr(),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildMacroRow(
              'insights_screen.carbohydrates'.tr(),
              carbInt,
              carbTgt,
              const Color(0xFFFFEBEE),
              Colors.pinkAccent,
            ),
            _buildMacroRow(
              'insights_screen.protein'.tr(),
              protInt,
              protTgt,
              const Color(0xFFE8F5E9),
              Colors.green,
            ),
            _buildMacroRow(
              'insights_screen.fats'.tr(),
              fatInt,
              fatTgt,
              const Color(0xFFE3F2FD),
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedRange,
          icon: const Icon(Icons.keyboard_arrow_down, size: 18),
          style:  TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black),
          items:  [
            DropdownMenuItem(value: 'weekly', child: Text('insights_screen.weekly'.tr())),
            DropdownMenuItem(value: 'monthly', child: Text('insights_screen.monthly'.tr())),
          ],
          onChanged: (val) {
            if (val != null) {
              setState(() {
                _selectedRange = val;
              });
              _fetchInsights();
            }
          },
        ),
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

  Widget _buildChartSection(List<double> currentChartPoints, String highlightLabel) {
    final List<String> labels = _insights != null
        ? _insights!.periodData.map<String>((e) {
            try {
              final date = DateTime.parse(e.date);
              if (_selectedRange == 'weekly') {
                final weekdays = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"];
                return weekdays[date.weekday - 1];
              } else {
                // For monthly view, show day number of the month (e.g. "12")
                return "${date.day}";
              }
            } catch (_) {
              final parts = e.date.split('-');
              return parts.isNotEmpty ? parts.last : '';
            }
          }).toList()
        : (_selectedRange == 'weekly'
            ? ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
            : ["Week 1", "Week 2", "Week 3", "Week 4"]);

    // To prevent crowding, display at most 5 evenly-spaced labels when data has many points (e.g., monthly)
    List<String> visibleLabels = [];
    if (labels.length > 7) {
      int total = labels.length;
      if (total >= 5) {
        visibleLabels.add(labels[0]); // Start
        visibleLabels.add(labels[(total * 0.25).floor()]); // 25%
        visibleLabels.add(labels[(total * 0.50).floor()]); // 50%
        visibleLabels.add(labels[(total * 0.75).floor()]); // 75%
        visibleLabels.add(labels[total - 1]); // End
      } else {
        visibleLabels = labels;
      }
    } else {
      visibleLabels = labels;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['insights_screen.weight_tab'.tr(), 'insights_screen.calories_tab'.tr(), 'insights_screen.macros_tab'.tr()].asMap().entries.map((entry) {
              bool isSelected = selectedTab == entry.key;
              return GestureDetector(
                onTap: () => setState(() => selectedTab = entry.key),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFF3F4F6) : Colors.transparent,
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
          Stack(
            alignment: Alignment.topCenter,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: CustomPaint(
                  painter: LineChartPainter(
                    dataPoints: currentChartPoints,
                    lineColor: const Color(0xFF4CAF50),
                  ),
                ),
              ),
              if (currentChartPoints.isNotEmpty)
                Positioned(
                  right: 16,
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
                          highlightLabel,
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
                        color: Colors.black.withAlpha(26),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: visibleLabels.map((day) => Text(
                day,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.bold,
                ),
              )).toList(),
            ),
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
    double progress = target > 0 ? (intake / target) : 0.0;
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

class LineChartPainter extends CustomPainter {
  final List<double> dataPoints;
  final Color lineColor;

  LineChartPainter({required this.dataPoints, required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    Paint paint = Paint()
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    double maxVal = dataPoints.reduce((a, b) => a > b ? a : b);
    double minVal = dataPoints.reduce((a, b) => a < b ? a : b);
    double valueRange = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);

    Path path = Path();
    double stepX = size.width / (dataPoints.length - 1 == 0 ? 1 : dataPoints.length - 1);

    for (int i = 0; i < dataPoints.length; i++) {
      double ratio = (dataPoints[i] - minVal) / valueRange;
      double y = size.height - (ratio * size.height * 0.8 + size.height * 0.1);
      double x = i * stepX;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints || oldDelegate.lineColor != lineColor;
  }
}
