import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool isYearly = true; // الحالة الافتراضية كما في الصورة

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // لون خلفية مائل للأخضر الفاتح
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              'premium.restore'.tr(),
              style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),
              // أيقونة الجوهرة (Logo)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF66BB6A), Color(0xFF9575CD)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.diamond, color: Colors.white, size: 40),
                ),
              ),
              const SizedBox(height: 30),
              // العناوين
              Text(
                'premium.title'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
              ),
              const SizedBox(height: 15),
              Text(
                'premium.subtitle'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.5),
              ),
              const SizedBox(height: 30),
              
              // الـ Toggle Switch (Monthly / Yearly)
              _buildToggleSwitch(),
              
              const SizedBox(height: 25),
              
              // جدول المميزات
              _buildFeaturesTable(),
              
              const SizedBox(height: 40),
              
              // السعر والزرار
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('premium.total'.tr(), style: const TextStyle(fontSize: 16, color: Colors.blueGrey)),
                  const Text('\$0.00', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('premium.start_btn'.tr(), style: const TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'premium.footer'.tr(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = false),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: !isYearly ? const Color(0xFF43A047) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('premium.monthly'.tr(), style: TextStyle(color: !isYearly ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isYearly = true),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isYearly ? const Color(0xFF43A047) : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text('premium.yearly'.tr(), style: TextStyle(color: isYearly ? Colors.white : Colors.blueGrey, fontWeight: FontWeight.bold)),
                    Positioned(
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), borderRadius: BorderRadius.circular(5)),
                        child: Text('premium.save'.tr(), style: const TextStyle(fontSize: 8, color: Colors.white)),
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

  Widget _buildFeaturesTable() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: Text('premium.features'.tr(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
              Expanded(child: Text('premium.free'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
              const Expanded(child: Icon(Icons.stars, color: Color(0xFF43A047), size: 24)),
            ],
          ),
          const Divider(height: 30),
          _buildFeatureRow('premium.calorie_track'.tr(), 'premium.basic_log'.tr(), true, true),
          const Divider(height: 30),
          _buildFeatureRow('premium.ai_meal'.tr(), 'premium.instant_scan'.tr(), false, true),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String title, String subtitle, bool inFree, bool inPro) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        Expanded(child: inFree ? const Icon(Icons.check_circle, color: Colors.grey, size: 22) : const Text('—', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
        Expanded(child: inPro ? const Icon(Icons.check_circle, color: Color(0xFF43A047), size: 22) : const Icon(Icons.close, color: Colors.red)),
      ],
    );
  }
}