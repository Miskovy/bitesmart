import 'package:bite_smart/features/home/screens/aiChatScreen.dart';
import 'package:bite_smart/features/home/screens/communityChallenge.dart';
import 'package:bite_smart/features/home/screens/homeScreen.dart';
import 'package:bite_smart/features/home/screens/scanModeSelectionScreen.dart';
import 'package:bite_smart/features/profile/screens/profileScreen.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // عشان الـ .tr() اللي في كودك

class MainHome extends StatefulWidget {
  const MainHome({super.key});

  @override
  State<MainHome> createState() => _MainHomeState();
}

class _MainHomeState extends State<MainHome> {
  int _currentIndex = 0; // التاب الافتراضية (Home)

  // 1. لستة الشاشات المربوطة بالأزرار بترتيب الـ Index
  late final List<Widget> _screens = [
    const HomeScreen(), // استبدلها بمحتوى صفحة الهوم القديمة (بدون scaffold بتاعها)
    const CommunityChallengesScreen(),       // شاشة التحديات (Index 1)
    const AiChatScreen(),                     // شاشة الشات بوت اللي عملناها (Index 2)
    const ProfileScreen(), // شاشة البروفايل (Index 3)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: const Color(0xFFF8FAF8),
  
  // تغليف الـ IndexedStack بـ Padding لعمل مسافة أمان فوق البار
  body: Padding(
    padding: const EdgeInsets.only(bottom: 30.0), // 👈 المسافة اللي أنت عايزها هنا
    child: IndexedStack(
      index: _currentIndex,
      children: _screens,
    ),
  ), 

  // زر الكاميرا العائم في المنتصف (من كودك بالظبط)
  floatingActionButton: _buildFloatingCameraButton(),
  floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

  // النفيجيشن بار الموحد (من كودك بالظبط)
  bottomNavigationBar: _buildBottomNavigationBar(),
);}
  // دالة بناء البار اللي بعتها مع دمج مسافة الكاميرا والـ Notch
  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8.0,
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      surfaceTintColor: Colors.white,
      child: Container(
        height: 60,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(
                    0,
                    Icons.grid_view_rounded,
                    'home.nav_home'.tr(),
                  ),
                  _buildNavButton(
                    1,
                    Icons.groups_rounded,
                    'home.nav_community'.tr(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 40), // مسافة محجوزة لزر الكاميرا المركزي
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNavButton(
                    2,
                    Icons.emoji_objects_outlined,
                    'home.nav_coach'.tr(),
                  ),
                  _buildNavButton(
                    3,
                    Icons.person_outline_rounded,
                    'home.nav_profile'.tr(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // تعديل الدالة لكي تقوم فقط بتغيير الـ Index جوة الـ MainScreen بدون عمل push للأبلكيشن
  Widget _buildNavButton(int index, IconData icon, String label) {
    bool isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index; // تحديث الشاشة فوراً
          });
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF388E3C) : Colors.grey,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF388E3C) : Colors.grey,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // دالة زر الكاميرا العائم (من كودك بالظبط)
  Widget _buildFloatingCameraButton() {
    return FloatingActionButton(
      backgroundColor: const Color(0xFF111827), 
      shape: const CircleBorder(),
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ScanModeSelectionScreen()),
      ),
      child: const Icon(
        Icons.qr_code_scanner_outlined,
        color: Color(0xFF4CAF50),
        size: 26,
      ),
    );
  }
}