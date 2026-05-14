import 'package:bite_smart/ui/screens/signup.dart';
import 'package:bite_smart/ui/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  @override
  Widget build(BuildContext context) {
    // تحديد اللغة المختارة بناءً على الـ locale الحالي
    final bool isArabicLocale = context.locale.languageCode == 'ar';
    int selectedLanguage = isArabicLocale ? 1 : 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              // الأيقونة اللي فوق (الكرة الأرضية)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.language, color: Colors.green, size: 40),
                ),
              ),
              const SizedBox(height: 24),
              // العنوان
              Text(
                'selectLanguage'.tr(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              // النص الفرعي
              Text(
                'chooseLanguageSubtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // كارت اللغة الإنجليزية
              LanguageCard(
                title: 'English',
                subtitle: 'United States',
                leadingText: 'En',
                isSelected: selectedLanguage == 0,
                onTap: () => context.setLocale(const Locale('en', 'US')),
              ),

              const SizedBox(height: 16),

              // كارت اللغة العربية
              LanguageCard(
                title: 'العربية',
                subtitle: 'المملكة العربية السعودية',
                leadingText: 'ع',
                isSelected: selectedLanguage == 1,
                isArabic: true,
                onTap: () => context.setLocale(const Locale('ar', 'EG')),
              ),

              const Spacer(),

              // زر الاستمرار (Continue)
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const Welcomescreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'continueBtn'.tr(),
                        style: const TextStyle(fontSize: 18, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// "Widget" مخصص للكارت عشان منكررش الكود
class LanguageCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String leadingText;
  final bool isSelected;
  final bool isArabic;
  final VoidCallback onTap;

  const LanguageCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.leadingText,
    required this.isSelected,
    required this.onTap,
    this.isArabic = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
          children: [
            // الدائرة الرمادية اللي فيها الحروف
            Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                leadingText,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            const SizedBox(width: 16),
            // نصوص اللغة
            Expanded(
              child: Column(
                crossAxisAlignment: isArabic
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            // علامة الصح (Checkmark)
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green)
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade100,
                ),
              ),
          ],
        ),
      ),
    );
  }
}