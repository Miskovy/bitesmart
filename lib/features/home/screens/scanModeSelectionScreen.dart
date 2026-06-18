import 'dart:ui';
import 'package:bite_smart/features/home/screens/cameraScreen.dart';
import 'package:bite_smart/features/home/screens/arMeasureScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class ScanModeSelectionScreen extends StatefulWidget {
  const ScanModeSelectionScreen({super.key});

  @override
  State<ScanModeSelectionScreen> createState() => _ScanModeSelectionScreenState();
}

class _ScanModeSelectionScreenState extends State<ScanModeSelectionScreen> {
  bool _showCalibInput = false;
  final TextEditingController _diameterController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onSelectAr() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ArMeasureScreen(),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  void _onStartCalibration() {
    if (_formKey.currentState?.validate() ?? false) {
      final double width = double.tryParse(_diameterController.text) ?? 25.0;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiCameraScreen(
            isCalibrating: true,
            foodWidthCm: width,
          ),
        ),
      ).then((shouldRefresh) {
        if (shouldRefresh == true && mounted) {
          Navigator.pop(context, true);
        }
      });
    }
  }

  @override
  void dispose() {
    _diameterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Premium Blurred Background with Dark Green Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF0C2912), // Dark forest green
                    Color(0xFF051207), // Deep black-green
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(color: Colors.transparent),
            ),
          ),

          // 2. Safe Area Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top close button
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
                // Title and subtitle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: Color(0xFF4CAF50),
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'scan_mode.title'.tr().isNotEmpty ? 'scan_mode.title'.tr() : 'Choose Scanning Mode',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'scan_mode.subtitle'.tr().isNotEmpty ? 'scan_mode.subtitle'.tr() : 'Select the mode to start analyzing your food',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Modes list
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Mode A: AR Food Prediction Card
                          _buildModeCard(
                            title: 'scan_mode.ar_title'.tr().isNotEmpty ? 'scan_mode.ar_title'.tr() : 'AR Food Analysis',
                            description: 'scan_mode.ar_desc'.tr().isNotEmpty 
                                ? 'scan_mode.ar_desc'.tr() 
                                : 'Identify food portions and nutrients using AR prediction.',
                            icon: Icons.view_in_ar_rounded,
                            gradient: const [Color(0xFF1B5E20), Color(0xFF388E3C)],
                            isSelected: false,
                            onTap: _onSelectAr,
                          ),

                          const SizedBox(height: 16),

                          // Mode B: Scale Calibration Card
                          _buildModeCard(
                            title: 'scan_mode.calib_title'.tr().isNotEmpty ? 'scan_mode.calib_title'.tr() : 'Scale Calibration',
                            description: 'scan_mode.calib_desc'.tr().isNotEmpty 
                                ? 'scan_mode.calib_desc'.tr() 
                                : 'Calibrate your device scale factor for accurate weight calculations.',
                            icon: Icons.scale_rounded,
                            gradient: const [Color(0xFF2C3E50), Color(0xFF34495E)],
                            isSelected: _showCalibInput,
                            onTap: () {
                              setState(() {
                                _showCalibInput = !_showCalibInput;
                              });
                            },
                          ),

                          // Dynamic Calibration parameter inputs
                          if (_showCalibInput) ...[
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.only(top: 16, bottom: 8),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color:  Color(0xFF34495E),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.12)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    'scan_mode.enter_diameter'.tr().isNotEmpty 
                                        ? 'scan_mode.enter_diameter'.tr() 
                                        : 'Enter Plate Diameter (cm):',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _diameterController,
                                    keyboardType: TextInputType.number,
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: 'e.g. 25',
                                      hintStyle: const TextStyle(color: Colors.grey),
                                      suffixText: 'cm',
                                      suffixStyle: const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.black.withOpacity(0.2),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Color(0xFF34495E)),
                                      ),
                                    ),
                                    validator: (val) {
                                      if (val == null || val.isEmpty) {
                                        return 'Please enter a diameter';
                                      }
                                      final numVal = double.tryParse(val);
                                      if (numVal == null || numVal <= 0) {
                                        return 'Please enter a valid number';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: _onStartCalibration,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:  Color(0xFF388E3C),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: Text(
                                        'scan_mode.start_scanning'.tr().isNotEmpty 
                                            ? 'scan_mode.start_scanning'.tr() 
                                            : 'Start Scanning',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard({
    required String title,
    required String description,
    required IconData icon,
    required List<Color> gradient,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white.withOpacity(0.15),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
