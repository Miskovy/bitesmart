import 'package:bite_smart/ui/screens/language.dart';
import 'package:bite_smart/ui/screens/loginScreen.dart';
import 'package:bite_smart/ui/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // 1. استيراد المكتبة

class Welcomescreen extends StatelessWidget {
  const Welcomescreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 🔹 Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  "https://i.postimg.cc/X7JcDHNp/Background-Image-Container.jpg",
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            child: Center(
              child: Column(
                // تم إزالة spacing لضمان التوافق مع إصدارات أقدم إذا لزم الأمر، أو اتركها كما هي
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white, width: .5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircleAvatar(
                          radius: 5,
                          backgroundColor: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "welcome.app_name".tr(), // 2. ترجمة اسم التطبيق
                          style: TextStyle(
                            color: Colors.black.withOpacity(0.8),
                            fontSize: 12,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 3. استخدام RichText مع الترجمة
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo', // يفضل استخدام خط يدعم العربية مثل Cairo
                      ),
                      children: [
                        TextSpan(
                          text: "welcome.title_part1".tr(),
                          style: const TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "welcome.title_health".tr(),
                          style: TextStyle(color: Colors.green[700]),
                        ),
                        TextSpan(
                          text: "welcome.title_part2".tr(),
                          style: const TextStyle(color: Colors.black),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Description
                  Text(
                    "welcome.description".tr(), // 4. ترجمة الوصف
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.5),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// 🔹 Button
                  SizedBox(
                    width: 300,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignupScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "welcome.get_started".tr(), // 5. ترجمة زر البداية
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 6. جعل الأيقونة تقلب اتجاهها تلقائياً مع اللغة
                          const Icon(Icons.arrow_forward, color: Colors.black),
                        ],
                      ),
                    ),
                  ),

                  /// 🔹 Login Text
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Loginscreen(),
                      ),
                    ),
                    child: Text(
                      "welcome.have_account".tr(), // 7. ترجمة نص الدخول
                      style: TextStyle(color: Colors.black.withOpacity(0.8)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// 🔹 Terms
                  Text(
                    "welcome.terms".tr(), // 8. ترجمة الشروط
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}