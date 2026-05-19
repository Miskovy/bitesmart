import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';


class AiAnalysizeScreen extends StatefulWidget {
  const AiAnalysizeScreen({super.key, required this.imagePath});

  final String imagePath;

  @override
  State<AiAnalysizeScreen> createState() => _AiAnalysizeScreenState();
}

class _AiAnalysizeScreenState extends State<AiAnalysizeScreen> {
  double _portionValue = 0.5; // 0=Small, 0.5=Medium, 1=Large

  int get _calories {
    if (_portionValue < 0.25) return 245;
    if (_portionValue < 0.75) return 350;
    return 490;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          // Food Image at the top
          SizedBox(
            height: 300,
            width: double.infinity,
            child: Image.network(
              widget.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[300],
                child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
              ),
            ),
          ),

          // Top navigation bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.maybePop(context),
                  ),
                  Row(
                    children: [
                      _CircleButton(icon: Icons.crop, onTap: () {}),
                      const SizedBox(width: 8),
                      _CircleButton(icon: Icons.more_vert, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Bottom sheet panel
          Align(
            alignment: Alignment.bottomCenter,
            child: DraggableScrollableSheet(
              initialChildSize: 0.62,
              minChildSize: 0.55,
              maxChildSize: 0.92,
              builder: (context, scrollController) {
                return Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Handle
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(top: 12, bottom: 20),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                          ),

                          // Match badge + meal time
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      '95 ${"analyze.match".tr()}',
                                      style: const TextStyle(
                                        color: Color(0xFF4CAF50),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                ' 9:42 AM',
                                style: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          // Title + edit icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "analyze.meal_title".tr(),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.edit, color: Color(0xFF4CAF50)),
                              ),
                            ],
                          ),

                          Text(
                            "analyze.edit_hint".tr(),
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Macros row
                          Row(
                            children: [
                              _MacroCard(
                                label: "analyze.carbs".tr(),
                                value: '28g',
                                color: const Color(0xFF2196F3),
                              ),
                              const SizedBox(width: 12),
                              _MacroCard(
                                label: "analyze.protein".tr(),
                                value: '12g',
                                color: const Color(0xFFFFC107),
                              ),
                              const SizedBox(width: 12),
                              _MacroCard(
                                label: "analyze.fat".tr(),
                                value: '18g',
                                color: const Color(0xFFFF9800),
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),

                          // Portion Size
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "analyze.portion_size".tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1A1A1A),
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$_calories',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4CAF50),
                                      ),
                                    ),
                                    TextSpan(
                                      text: " ${"analyze.kcal_unit".tr()}",
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1A1A1A),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Slider
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: const Color(0xFF4CAF50),
                              inactiveTrackColor: Colors.grey[200],
                              thumbColor: const Color(0xFF4CAF50),
                              overlayColor: const Color(0x334CAF50),
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                            ),
                            child: Slider(
                              value: _portionValue,
                              onChanged: (val) => setState(() => _portionValue = val),
                            ),
                          ),

                          // Slider labels
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("analyze.portion_small".tr(),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                Text(
                                  _portionValue < 0.25
                                      ? "analyze.portion_small".tr()
                                      : _portionValue < 0.75
                                          ? "analyze.portion_medium".tr()
                                          : "analyze.portion_large".tr(),
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text("analyze.portion_large".tr(),
                                    style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Ingredients tile
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.list_alt, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "analyze.ingredients".tr(),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "analyze.ingredients_example".tr(),
                                        style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.chevron_right, color: Colors.grey[400]),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Add to log button
                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                "analyze.add_to_log".tr(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}

class _MacroCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}