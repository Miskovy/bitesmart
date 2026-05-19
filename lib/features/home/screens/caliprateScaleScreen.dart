import 'dart:ui';
import 'package:bite_smart/features/home/screens/cameraScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

// دالة استدعاء الـ Pop-up
void showCalibrationDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return const CalibrateScaleDialog();
    },
  );
}

class CalibrateScaleDialog extends StatelessWidget {
  const CalibrateScaleDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // 1. تأثير التغبيش مع التدريج اللوني بالكامل خلف الـ Dialog (نفس الصورة تماماً)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // تغبيش ناعم وقوي
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF1B5E20).withOpacity(0.3), // أخضر خفيف جداً في الأعلى
                      const Color(0xFF1B5E20).withOpacity(0.9), // أخضر داكن خفيف في الأسفل
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. محاذاة الكارت في منتصف الشاشة
          Center(
            child: Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              elevation: 0,
              backgroundColor: Colors.white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 24),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // يأخذ حجم المحتوى فقط
                  children: [
                    const SizedBox(height: 8), // تعويض مساحة الـ X المحذوفة

                    // الجزء البصري: الطبق والبصمة المعايرة
                    Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F9F7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // الدائرة البيضاء للطبق
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blueGrey.shade100, width: 3),
                            ),
                                  child: const Icon(Icons.lunch_dining, color: Color(0xFF388E3C), size: 90),
                          ),
                          // مقبض الإبهام الأخضر (Scale)
                          Positioned(
                            right: 95,
                            bottom: 55,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E8),
                                    border: Border.all(color: const Color(0xFF388E3C), width: 1),
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(23),
                                      topRight: Radius.circular(23),
                                    ),
                                  ),
                                  child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF388E3C), size: 20),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "calibrate.scale_label".tr(),
                                  style: const TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF388E3C),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // أيقونة البلس البصرية بالأعلى يسار
                          Positioned(
                            top: 25,
                            left: 95,
                            child: Icon(Icons.blur_on, color: Colors.green.shade400, size: 24),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // عنوان الـ Pop-up
                    Text(
                      "calibrate.title".tr(),
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                    ),
                    const SizedBox(height: 12),

                    // الوصف مع تمييز كلمة thumb
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.5, fontFamily: 'Urbanist'),
                          children: [
                            TextSpan(text: "calibrate.description_start".tr()),
                            TextSpan(
                              text: "calibrate.description_thumb".tr(),
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade900),
                            ),
                            TextSpan(text: "calibrate.description_end".tr()),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // زر التأكيد الأخضر البوتون الأساسي (Got it)
                    SizedBox(
                      width: .4* MediaQuery.of(context).size.width,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (_) => const AiCameraScreen())),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF388E3C),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("calibrate.button".tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(width: 8),
                            const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 4), // مساحة صغيرة متناسقة بالأسفل بعد حذف الـ Checkbox
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}