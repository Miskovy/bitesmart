import 'package:bite_smart/features/home/screens/aiAnalysizeScreen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';

class AiCameraScreen extends StatefulWidget {
  const AiCameraScreen({super.key});

  @override
  State<AiCameraScreen> createState() => _AiCameraScreenState();
}

class _AiCameraScreenState extends State<AiCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  // شلنا الـ FlashMode المعقد وخليناه رقم بسيط (0 = مقفول، 1 = كشاف، 2 = تلقائي)
final ValueNotifier<int> flashState = ValueNotifier(0);
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // تهيئة الكاميرا الخلفية للتطبيق
  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras![0], // الكاميرا الخلفية الأساسية
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

  // دالة فتح المعرض (Gallery) واختيار صورة
  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        debugPrint("Image picked from gallery: ${image.path}");
        // هنا يمكنك أخذ مسار الصورة وإرساله لشاشة التعديل أو التحليل بالـ AI
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // دالة التقاط الصورة من الكاميرا
  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final XFile picture = await _controller!.takePicture();
      debugPrint("Picture taken: ${picture.path}");
      Navigator.pop(context); 
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => AiAnalysizeScreen(
      imagePath: picture.path,
    ),
  ),
);
      // هنا تنقل المستخدم لصفحة مراجعة الوجبة أو الـ AI Log التي صممناها سابقاً
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
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. عرض الكاميرا المباشر ليمر بكامل الشاشة (Full Screen Preview)
          Positioned.fill(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: CameraPreview(_controller!),
            ),
          ),

          // 2. الطبقة العلوية: الفلاش، حالة الـ AI، وزر الإلغاء (X)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // زر الفلاش (Flash)
                  GestureDetector(
  onTap: () async {
    if (_controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    flashState.value = (flashState.value + 1) % 3;

    await _controller!.setFlashMode(
      flashState.value == 0
          ? FlashMode.off
          : (flashState.value == 1
              ? FlashMode.torch
              : FlashMode.auto),
    );
  },

  child: ValueListenableBuilder<int>(
    valueListenable: flashState,
    builder: (context, value, child) {
      return Icon(
        value == 0
            ? Icons.flash_off
            : value == 1
                ? Icons.flash_on
                : Icons.flash_auto,

        color: value == 0
            ? Colors.white
            : Colors.yellow,

        size: 28,
      );
    },
  ),
),
                  // كبسولة حالة الـ AI (AI Looking for food...)
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
                            color: Color(0xFF4CAF50), // النقطة الخضراء النابضة
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "camera.ai_looking".tr(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // زر الإغلاق / إلغاء الأمر (X)
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

          // 3. المنتصف: مربع إرشاد المسح الضوئي الأخضر (Scanner Frame)
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.65,
              height: MediaQuery.of(context).size.width * 0.65,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.transparent), // شفاف من الداخل
              ),
              child: Stack(children: [buildScannerOverlay(context)]),
            ),
          ),

          // 4. الجزء السفلي: التحكم بالوضع (Single/Multi) وأزرار التقاط الصور والمعرض
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
                    // أ) زر فتح الاستوديو / المعرض (Gallery)
                    GestureDetector(
                      onTap: _pickImageFromGallery,
                      child: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          image: const DecorationImage(
                            image: AssetImage(
                              'assets/images/food_placeholder.png',
                            ), // صورة مصغرة تلميحية
                            fit: BoxFit.cover,
                            onError:
                                _handleImageError, // لتجنب الكراش إذا لم تتوفر صورة
                          ),
                        ),
                        // أيقونة احتياطية في حال لم تكن الصورة موجودة بالـ Assets بعد
                        child: const Icon(Icons.photo, color: Colors.grey),
                      ),
                    ),

                    // ب) زر تصوير اللقطة الكبير بالمنتصف (Shutter Button)
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

                    // ج) زر السجل / التوقيت (History Icon) يمين
                    CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      radius: 25,
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ويدجت فرعي لبناء زوايا مربع المسح المخصص (Scanner Corner)
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
            top: isTop
                ? const BorderSide(color: Color(0xFF4CAF50), width: 4)
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(color: Color(0xFF4CAF50), width: 4)
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(color: Color(0xFF4CAF50), width: 4)
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(color: Color(0xFF4CAF50), width: 4)
                : BorderSide.none,
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

  static void _handleImageError(Object exception, StackTrace? stackTrace) {}
}
