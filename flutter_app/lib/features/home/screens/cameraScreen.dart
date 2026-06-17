import 'dart:typed_data';
import 'package:bite_smart/features/home/screens/aiAnalysizeScreen.dart';
import 'package:bite_smart/features/home/data/repositories/home_repository.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiCameraScreen extends StatefulWidget {
  final bool isCalibrating;
  final double foodWidthCm;
  const AiCameraScreen({super.key, this.isCalibrating = false, this.foodWidthCm = 8.0});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isProcessing = false;
  // flashState: (0 = off, 1 = torch, 2 = auto)
  final ValueNotifier<int> flashState = ValueNotifier(0);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Initialize camera
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // Primary back camera
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _controller!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint("Error initializing camera: $e");
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("Image picked from gallery: ${image.path}");
        final bytes = await image.readAsBytes();
        _processPickedImage(image.path, bytes: bytes);
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _processPickedImage(String path, {Uint8List? bytes}) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiAnalysizeScreen(
          imagePath: path,
          imageBytes: bytes,
          foodWidthCm: widget.foodWidthCm,
          isCalibration: widget.isCalibrating,
        ),
      ),
    ).then((shouldRefresh) {
      if (shouldRefresh == true && mounted) {
        Navigator.pop(context, true);
      }
    });
  }

  // Take picture from camera
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized || _isProcessing) return;

    try {
      final XFile picture = await _controller!.takePicture();
      debugPrint("Picture taken: ${picture.path}");
      final bytes = await picture.readAsBytes();
      await _processPickedImage(picture.path, bytes: bytes);
    } catch (e) {
      debugPrint("Error taking picture: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null || _isProcessing) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF4CAF50)),
              const SizedBox(height: 16),
              Text(
                _isProcessing ? "Calibrating smart scale..." : "Initializing camera...",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Full Screen Preview
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. Top Bar: Flash, state info, Close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Flash Button
                  GestureDetector(
                    onTap: () async {
                      if (_controller == null || !_controller!.value.isInitialized) {
                        return;
                      }

                      flashState.value = (flashState.value + 1) % 3;

                      await _controller!.setFlashMode(
                        flashState.value == 0
                            ? FlashMode.off
                            : (flashState.value == 1 ? FlashMode.torch : FlashMode.auto),
                      );
                    },
                    child: ValueListenableBuilder<int>(
                      valueListenable: flashState,
                      builder: (context, value, child) {
                        return Icon(
                          value == 0
                              ? Icons.flash_off
                              : value == 1 ? Icons.flash_on : Icons.flash_auto,
                          color: value == 0 ? Colors.white : Colors.yellow,
                          size: 28,
                        );
                      },
                    ),
                  ),

                  // Capsule info
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CAF50),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.isCalibrating ? "Scale Calibration" : "camera.ai_looking".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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

          // 3. Scan frame
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.width * 0.65,
              decoration: const BoxDecoration(
                color: Colors.transparent,
              ),
              child: Stack(children: [buildScannerOverlay(context)]),
            ),
          ),

          // 4. Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(bottom: 40, top: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Gallery Button
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.photo, color: Colors.grey),
                      ),
                    ),

                    // Shutter Button
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Spacer/History placeholder
                    const SizedBox(width: 50),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required bool isTop,
    required bool isLeft,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
            bottom: !isTop ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
            left: isLeft ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
            right: !isLeft ? const BorderSide(color: Color(0xFF4CAF50), width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget buildScannerOverlay(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double scanSize = constraints.maxWidth * 0.65;

        if (scanSize > 320) scanSize = 320;
        if (scanSize < 180) scanSize = 180;

        return Center(
          child: SizedBox(
            width: scanSize,
            height: scanSize,
            child: Stack(
              children: [
                _buildCorner(top: 0, left: 0, isTop: true, isLeft: true),
                _buildCorner(top: 0, right: 0, isTop: true, isLeft: false),
                _buildCorner(bottom: 0, left: 0, isTop: false, isLeft: true),
                _buildCorner(bottom: 0, right: 0, isTop: false, isLeft: false),
              ],
            ),
          ),
        );
      },
    );
  }
}
