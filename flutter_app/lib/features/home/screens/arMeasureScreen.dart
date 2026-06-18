import 'dart:typed_data';
import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:bite_smart/features/home/screens/aiAnalysizeScreen.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vector_math/vector_math_64.dart' as vector;
import 'package:image_picker/image_picker.dart';

class ArMeasureScreen extends StatefulWidget {
  const ArMeasureScreen({super.key});

  @override
  State<ArMeasureScreen> createState() => _ArMeasureScreenState();
}

class _ArMeasureScreenState extends State<ArMeasureScreen> {
  ArCoreController? _arCoreController;
  final List<vector.Vector3> _points = [];
  double? _measuredWidthCm;
  bool _isArReady = false;
  String _instruction = '';
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _instruction = 'ar_measure.tap_left'.tr().isNotEmpty
        ? 'ar_measure.tap_left'.tr()
        : 'Tap the left edge of the food';
  }

  void _onArCoreViewCreated(ArCoreController controller) {
    _arCoreController = controller;
    _arCoreController!.onPlaneTap = _onPlaneTap;
    setState(() {
      _isArReady = true;
    });
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty || _points.length >= 2) return;

    final hit = hits.first;
    final pose = hit.pose;
    final position = vector.Vector3(
      pose.translation.x,
      pose.translation.y,
      pose.translation.z,
    );

    // Add a visual marker sphere at the tapped position
    _addMarkerNode(position);
    _points.add(position);

    if (_points.length == 1) {
      setState(() {
        _instruction = 'ar_measure.tap_right'.tr().isNotEmpty
            ? 'ar_measure.tap_right'.tr()
            : 'Now tap the right edge of the food';
      });
    } else if (_points.length == 2) {
      // Calculate distance between the two points (in meters) → convert to cm
      final distanceM = _points[0].distanceTo(_points[1]);
      final distanceCm = distanceM * 100.0;

      // Draw a line between the two points
      _addLineBetweenPoints(_points[0], _points[1]);

      setState(() {
        _measuredWidthCm = distanceCm;
        _instruction = 'ar_measure.width_label'.tr().isNotEmpty
            ? '${'ar_measure.width_label'.tr()}: ${distanceCm.toStringAsFixed(1)} cm'
            : 'Measured Width: ${distanceCm.toStringAsFixed(1)} cm';
      });
    }
  }

  void _addMarkerNode(vector.Vector3 position) {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        materials: [
          ArCoreMaterial(
            color: const Color(0xFF4CAF50),
            metallic: 0.2,
          ),
        ],
        radius: 0.008, // 8mm sphere
      ),
      position: position,
    );
    _arCoreController?.addArCoreNodeWithAnchor(node);
  }

  void _addLineBetweenPoints(vector.Vector3 a, vector.Vector3 b) {
    // Place small spheres along the line to visualize the connection
    const int segments = 20;
    for (int i = 1; i < segments; i++) {
      final t = i / segments;
      final point = vector.Vector3(
        a.x + (b.x - a.x) * t,
        a.y + (b.y - a.y) * t,
        a.z + (b.z - a.z) * t,
      );
      final node = ArCoreNode(
        shape: ArCoreSphere(
          materials: [
            ArCoreMaterial(
              color: const Color(0xFF81C784),
              metallic: 0.1,
            ),
          ],
          radius: 0.003, // 3mm small dots for the line
        ),
        position: point,
      );
      _arCoreController?.addArCoreNodeWithAnchor(node);
    }
  }

  void _resetMeasurement() {
    _arCoreController?.dispose();
    _points.clear();
    setState(() {
      _measuredWidthCm = null;
      _isArReady = false;
      _instruction = 'ar_measure.tap_left'.tr().isNotEmpty
          ? 'ar_measure.tap_left'.tr()
          : 'Tap the left edge of the food';
    });
    // Recreate will happen automatically via ArCoreView rebuild
    setState(() {});
  }

  Future<void> _confirmAndCapture() async {
    if (_measuredWidthCm == null) return;

    try {
      // Pick or capture image for prediction
      final XFile? image = await showModalBottomSheet<XFile?>(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) => _ImageSourceSheet(picker: _picker),
      );

      if (image != null && mounted) {
        final bytes = await image.readAsBytes();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AiAnalysizeScreen(
              imagePath: image.path,
              imageBytes: bytes,
              foodWidthCm: _measuredWidthCm!,
              isCalibration: false,
            ),
          ),
        ).then((shouldRefresh) {
          if (shouldRefresh == true && mounted) {
            Navigator.pop(context, true);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  void dispose() {
    _arCoreController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // AR Camera View
          ArCoreView(
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Title badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _isArReady
                                ? const Color(0xFF4CAF50)
                                : Colors.orange,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'ar_measure.title'.tr().isNotEmpty
                              ? 'ar_measure.title'.tr()
                              : 'AR Measurement',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      radius: 22,
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Instruction overlay
          Positioned(
            top: MediaQuery.of(context).padding.top + 70,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _measuredWidthCm != null
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _measuredWidthCm != null
                        ? Icons.check_circle
                        : _points.isEmpty
                            ? Icons.touch_app
                            : Icons.ads_click,
                    color: _measuredWidthCm != null
                        ? const Color(0xFF4CAF50)
                        : Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _instruction,
                      style: TextStyle(
                        color: _measuredWidthCm != null
                            ? const Color(0xFF4CAF50)
                            : Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Measurement badge (shown after measurement)
          if (_measuredWidthCm != null)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.9),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  '${_measuredWidthCm!.toStringAsFixed(1)} cm',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

          // Points counter
          if (_points.isNotEmpty && _measuredWidthCm == null)
            Positioned(
              bottom: 140,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_points.length}/2 points placed',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(
                bottom: 40,
                top: 20,
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Reset button
                  _BottomButton(
                    icon: Icons.refresh,
                    label: 'ar_measure.reset'.tr().isNotEmpty
                        ? 'ar_measure.reset'.tr()
                        : 'Reset',
                    onTap: _resetMeasurement,
                    color: Colors.white,
                  ),

                  // Confirm & Capture button
                  GestureDetector(
                    onTap: _measuredWidthCm != null ? _confirmAndCapture : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _measuredWidthCm != null
                            ? const Color(0xFF4CAF50)
                            : Colors.grey[700],
                        border: Border.all(
                          color: _measuredWidthCm != null
                              ? Colors.white
                              : Colors.grey,
                          width: 3,
                        ),
                        boxShadow: _measuredWidthCm != null
                            ? [
                                BoxShadow(
                                  color:
                                      const Color(0xFF4CAF50).withOpacity(0.4),
                                  blurRadius: 12,
                                  spreadRadius: 2,
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: _measuredWidthCm != null
                            ? Colors.white
                            : Colors.grey[400],
                        size: 30,
                      ),
                    ),
                  ),

                  // Spacer for symmetry
                  const SizedBox(width: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _BottomButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: Colors.white.withOpacity(0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _ImageSourceSheet extends StatelessWidget {
  final ImagePicker picker;

  const _ImageSourceSheet({required this.picker});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[600],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'ar_measure.capture_title'.tr().isNotEmpty
                ? 'ar_measure.capture_title'.tr()
                : 'Capture Food Image',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'ar_measure.capture_subtitle'.tr().isNotEmpty
                ? 'ar_measure.capture_subtitle'.tr()
                : 'Take a photo or pick from gallery',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _SourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () async {
                    final img = await picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (context.mounted) Navigator.pop(context, img);
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _SourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () async {
                    final img = await picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (context.mounted) Navigator.pop(context, img);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _SourceOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50), size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
