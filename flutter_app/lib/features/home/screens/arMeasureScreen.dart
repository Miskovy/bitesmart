import 'package:arcore_flutter_plus/arcore_flutter_plus.dart';
import 'package:bite_smart/features/home/screens/aiAnalysizeScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:vector_math/vector_math_64.dart' as vector;

// ── Shared design tokens ──────────────────────────────────────────────────────
const _kGreen      = Color(0xFF4CAF50);
const _kGreenLight = Color(0xFF81C784);
const _kBlack60    = Color(0x99000000); // Colors.black.withOpacity(0.6)
const _kBlack70    = Color(0xB3000000); // Colors.black.withOpacity(0.7)
const _kBlack80    = Color(0xCC000000); // Colors.black.withOpacity(0.8)

// ─────────────────────────────────────────────────────────────────────────────
class ArMeasureScreen extends StatefulWidget {
  const ArMeasureScreen({super.key});

  @override
  State<ArMeasureScreen> createState() => _ArMeasureScreenState();
}

class _ArMeasureScreenState extends State<ArMeasureScreen> {
  // ── AR state ────────────────────────────────────────────────────────────────
  ArCoreController? _arCoreController;

  // Key swap is needed for reset because the native ArCoreView.dispose()
  // destroys the ArSceneView entirely — there is no way to "clear" it.
  Key _arViewKey = UniqueKey();

  final List<vector.Vector3> _points = [];
  final List<String> _placedNodeNames = [];

  double? _measuredWidthCm;
  bool _isArReady = false;
  bool _isTapping = false;
  String _instruction = '';

  // ── Localised strings ───────────────────────────────────────────────────────
  String get _tapLeftText  => 'ar_measure.tap_left'.tr();
  String get _tapRightText => 'ar_measure.tap_right'.tr();

  // ── Lifecycle ────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _instruction = _tapLeftText;
  }

  @override
  void dispose() {
    // We intentionally DO NOT call _arCoreController?.dispose() here!
    // Flutter's AndroidView automatically handles native platform view tear-down.
    // Manually invoking dispose over the MethodChannel during widget destruction
    // causes a double-free/race condition that crashes the app on re-entry.
    super.dispose();
  }

  // ── AR callbacks ─────────────────────────────────────────────────────────────
  void _onArCoreViewCreated(ArCoreController controller) {
    if (!mounted) return;

    _arCoreController = controller;
    _arCoreController!.onPlaneTap = _onPlaneTap;

    // Force the AR session to start tracking. Sometimes the Activity lifecycle
    // misses the onResume trigger, leaving the AR camera black or frozen.
    _arCoreController!.resume();

    // Surface native ARCore errors so they're not silently swallowed.
    _arCoreController!.onError = (String error) {
      debugPrint('ARCore error: $error');
    };

    setState(() => _isArReady = true);
  }

  void _onPlaneTap(List<ArCoreHitTestResult> hits) {
    if (hits.isEmpty || _points.length >= 2 || _isTapping) return;
    _isTapping = true;

    final pose     = hits.first.pose;
    final position = vector.Vector3(
      pose.translation.x,
      pose.translation.y,
      pose.translation.z,
    );

    _addMarkerNode(position);
    _points.add(position);

    if (_points.length == 1) {
      setState(() => _instruction = _tapRightText);
    } else {
      final distanceCm = _points[0].distanceTo(_points[1]) * 100.0;
      _addLineBetweenPoints(_points[0], _points[1]);

      setState(() {
        _measuredWidthCm = distanceCm;
        _instruction =
            '${'ar_measure.width_label'.tr()}: '
            '${distanceCm.toStringAsFixed(1)} cm';
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => _isTapping = false);
  }

  // ── AR node helpers ──────────────────────────────────────────────────────────
  void _addMarkerNode(vector.Vector3 position) {
    final node = ArCoreNode(
      shape: ArCoreSphere(
        materials: [ArCoreMaterial(color: _kGreen, metallic: 1.0)],
        radius: 0.01,
      ),
      position: position,
    );
    // addArCoreNodeWithAnchor creates a proper ARCore Anchor at this position
    // via session.createAnchor(Pose(...)). This anchors the sphere to the
    // real-world surface so it stays fixed as the camera moves.
    _arCoreController?.addArCoreNodeWithAnchor(node);
    if (node.name != null) _placedNodeNames.add(node.name!);
  }

  void _addLineBetweenPoints(vector.Vector3 a, vector.Vector3 b) {
    final midpoint  = (a + b) * 0.5;
    final length    = a.distanceTo(b);
    final direction = (b - a).normalized();

    final yAxis = vector.Vector3(0.0, 1.0, 0.0);
    vector.Quaternion q;

    if (direction.dot(yAxis) < -0.9999) {
      q = vector.Quaternion.axisAngle(
        vector.Vector3(1.0, 0.0, 0.0),
        3.14159265358979,
      );
    } else {
      q = vector.Quaternion.fromTwoVectors(yAxis, direction)..normalize();
    }

    final node = ArCoreNode(
      shape: ArCoreCylinder(
        materials: [ArCoreMaterial(color: _kGreenLight, metallic: 0.1)],
        radius: 0.004,
        height: length,
      ),
      position: midpoint,
      rotation: vector.Vector4(q.x, q.y, q.z, q.w),
    );
    _arCoreController?.addArCoreNodeWithAnchor(node);
    if (node.name != null) _placedNodeNames.add(node.name!);
  }

  // ── User actions ─────────────────────────────────────────────────────────────

  /// Reset: dispose the current controller and swap the key so Flutter
  /// unmounts the old ArCoreView and creates a fresh one.
  void _resetMeasurement() {
    // Dispose the old controller first so the native side can clean up.
    _arCoreController?.dispose();
    _arCoreController = null;

    _placedNodeNames.clear();
    _points.clear();

    setState(() {
      _measuredWidthCm = null;
      _isArReady       = false;
      _arViewKey       = UniqueKey();
      _instruction     = _tapLeftText;
    });
  }

  /// Close the AR screen safely. Let the Flutter engine tear down the AndroidView.
  void _closeArScreen() {
    if (mounted) Navigator.pop(context);
  }

  Future<void> _confirmAndCapture() async {
    if (_measuredWidthCm == null) return;
    
    // Dispose AR controller to release the camera
    _arCoreController?.dispose();
    _arCoreController = null;

    if (mounted) {
      Navigator.pop(context, _measuredWidthCm);
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── AR camera view ─────────────────────────────────────────────────
          ArCoreView(
            key: _arViewKey,
            onArCoreViewCreated: _onArCoreViewCreated,
            enableTapRecognizer: true,
            enablePlaneRenderer: true,
            debug: true,
          ),

          // ── Top bar ────────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _StatusBadge(isReady: _isArReady),
                  GestureDetector(
                    onTap: _closeArScreen,
                    child: const CircleAvatar(
                      backgroundColor: _kBlack60,
                      radius: 22,
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Instruction banner ─────────────────────────────────────────────
          Positioned(
            top  : MediaQuery.of(context).padding.top + 70,
            left : 24,
            right: 24,
            child: _InstructionBanner(
              instruction: _instruction,
              pointCount : _points.length,
              isMeasured : _measuredWidthCm != null,
            ),
          ),

          // ── Measurement badge (shown once both points are set) ─────────────
          if (_measuredWidthCm != null)
            Center(child: _MeasurementBadge(widthCm: _measuredWidthCm!)),

          // ── Points progress counter ────────────────────────────────────────
          if (_points.isNotEmpty && _measuredWidthCm == null)
            Positioned(
              bottom: 140,
              left  : 0,
              right : 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: _kBlack60,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_points.length}/2 '
                    '${'ar_measure.points_placed'.tr()}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ),
              ),
            ),

          // ── Bottom control bar ─────────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _BottomControlBar(
              isMeasured: _measuredWidthCm != null,
              onReset   : _resetMeasurement,
              onCapture : _confirmAndCapture,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets – extracted for readability and to keep build() clean
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  final bool isReady;
  const _StatusBadge({required this.isReady});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _kBlack60, borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(
              color : isReady ? _kGreen : Colors.orange,
              shape : BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'ar_measure.title'.tr(),
            style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InstructionBanner extends StatelessWidget {
  final String instruction;
  final int    pointCount;
  final bool   isMeasured;

  const _InstructionBanner({
    required this.instruction,
    required this.pointCount,
    required this.isMeasured,
  });

  @override
  Widget build(BuildContext context) {
    final IconData icon  = isMeasured
        ? Icons.check_circle
        : pointCount == 0 ? Icons.touch_app : Icons.ads_click;
    final Color    color = isMeasured ? _kGreen : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: _kBlack70,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMeasured ? _kGreen : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MeasurementBadge extends StatelessWidget {
  final double widthCm;
  const _MeasurementBadge({required this.widthCm});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: BoxDecoration(
        color: _kGreen.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _kGreen.withValues(alpha: 0.4),
            blurRadius: 20, spreadRadius: 2,
          ),
        ],
      ),
      child: Text(
        '${widthCm.toStringAsFixed(1)} cm',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _BottomControlBar extends StatelessWidget {
  final bool          isMeasured;
  final VoidCallback  onReset;
  final VoidCallback  onCapture;

  const _BottomControlBar({
    required this.isMeasured,
    required this.onReset,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        bottom: 40, top: 20, left: 24, right: 24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin  : Alignment.bottomCenter,
          end    : Alignment.topCenter,
          colors : [_kBlack80, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _IconTextButton(
            icon : Icons.refresh,
            label: 'ar_measure.reset'.tr(),
            onTap: onReset,
            color: Colors.white,
          ),

          // Confirm & Capture CTA
          GestureDetector(
            onTap: isMeasured ? onCapture : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 72, height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isMeasured ? _kGreen : Colors.grey[700],
                border: Border.all(
                  color: isMeasured ? Colors.white : Colors.grey,
                  width: 3,
                ),
                boxShadow: isMeasured
                    ? [
                        BoxShadow(
                          color: _kGreen.withValues(alpha: 0.4),
                          blurRadius: 12, spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                Icons.check,
                color: isMeasured ? Colors.white : Colors.grey[400],
                size: 30,
              ),
            ),
          ),

          const SizedBox(width: 60), // mirror the left button for symmetry
        ],
      ),
    );
  }
}

class _IconTextButton extends StatelessWidget {
  final IconData    icon;
  final String      label;
  final VoidCallback onTap;
  final Color       color;

  const _IconTextButton({
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
            backgroundColor: Colors.white.withValues(alpha: 0.15),
            radius: 24,
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(color: color, fontSize: 11)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
