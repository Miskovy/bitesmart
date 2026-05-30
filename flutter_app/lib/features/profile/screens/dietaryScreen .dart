import 'package:bite_smart/features/profile/screens/macroTarget.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_state.dart';
import 'package:bite_smart/features/profile/data/models/profile_setup_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class DietaryPreferencesScreen extends StatefulWidget {
  const DietaryPreferencesScreen({super.key});

  @override
  State<DietaryPreferencesScreen> createState() => _DietaryPreferencesScreenState();
}

class _DietaryPreferencesScreenState extends State<DietaryPreferencesScreen> {
  // تخزين الحالات المختارة
  final Set<String> _selectedDiets = {'vegetarian', 'gluten_free'};
  bool _glp1Enabled = false;

  @override
  void initState() {
    super.initState();
    final currentPrefs = context.read<ProfileSetupBloc>().state.data.dietaryPreferences;
    _selectedDiets.clear();
    if (currentPrefs.isVegetarian) _selectedDiets.add('vegetarian');
    if (currentPrefs.isVegan) _selectedDiets.add('vegan');
    if (currentPrefs.isKeto) _selectedDiets.add('keto');
    if (currentPrefs.isPaleo) _selectedDiets.add('paleo');
    if (currentPrefs.isGlutenFree) _selectedDiets.add('gluten_free');
    if (currentPrefs.isHalal) _selectedDiets.add('halal');
    if (currentPrefs.isPescatarian) _selectedDiets.add('pescatarian');

    if (_selectedDiets.isEmpty && context.read<ProfileSetupBloc>().state.status == ProfileSetupStatus.initial) {
      _selectedDiets.addAll({'vegetarian', 'gluten_free'});
    }
    _glp1Enabled = currentPrefs.isGlp1User;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'diet.title'.tr(),
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                ),
                const SizedBox(height: 8),
                Text(
                  'diet.subtitle'.tr(),
                  style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.4),
                ),
                const SizedBox(height: 12),

                _buildSectionTitle('diet.type'.tr()),
                
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,  
                  childAspectRatio: 2 ,
                  children: [
                    _buildDietCard('vegetarian', 'diet.vegetarian'.tr(), Icons.eco_outlined),
                    _buildDietCard('vegan', 'diet.vegan'.tr(), Icons.opacity_outlined),
                    _buildDietCard('keto', 'diet.keto'.tr(), Icons.egg_outlined),
                    _buildDietCard('paleo', 'diet.paleo'.tr(), Icons.set_meal_outlined),
                    _buildDietCard('gluten_free', 'diet.gluten_free'.tr(), Icons.bakery_dining_outlined),
                    _buildDietCard('halal', 'diet.halal'.tr(), Icons.nightlight_round),
                    _buildDietCard('pescatarian', 'diet.pescatarian'.tr(), Icons.directions_boat_outlined),
                    _buildDietCard('none', 'diet.none'.tr(), Icons.block_flipped),
                  ],
                ),
                const SizedBox(height: 12),
                _buildSectionTitle('diet.advanced'.tr()),

                // بطاقة الـ GLP-1
                _buildAdvancedSettingCard(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      
      // زرار التحديث (نصف عرض الشاشة وثابت بالأسفل)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: SizedBox(
              width: .4 * MediaQuery.of(context).size.width,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  final dietaryPreferences = DietaryPreferencesData(
                    isVegetarian: _selectedDiets.contains('vegetarian'),
                    isVegan: _selectedDiets.contains('vegan'),
                    isKeto: _selectedDiets.contains('keto'),
                    isPaleo: _selectedDiets.contains('paleo'),
                    isGlutenFree: _selectedDiets.contains('gluten_free'),
                    isHalal: _selectedDiets.contains('halal'),
                    isPescatarian: _selectedDiets.contains('pescatarian'),
                    isGlp1User: _glp1Enabled,
                    isRamadanMode: false, // Default is false since there's no UI switch for it
                  );

                  context.read<ProfileSetupBloc>().add(
                    SetDietaryPreferencesEvent(dietaryPreferences),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MacrosTargetScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'diet.update'.tr(),
                      style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildDietCard(String key, String label, IconData icon) {
    bool isSelected = _selectedDiets.contains(key);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedDiets.remove(key);
          } else {
            _selectedDiets.add(key);
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF388E3C) : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? const Color(0xFF388E3C) : Colors.grey.shade400, size: 28),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF1B5E20) : Color(0xFF111827),
                  ),
                ),
              ],
            ),
            if (isSelected)
              const Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.check_circle, color: Color(0xFF388E3C), size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedSettingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.medication_liquid, color: Colors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('diet.glp1_title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFE0F2F1), borderRadius: BorderRadius.circular(4)),
                      child: Text('diet.beta'.tr(), style: const TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'diet.glp1_desc'.tr(),
                  style: const TextStyle(fontSize: 12, color: Colors.blueGrey, height: 1.4),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: _glp1Enabled,
            activeTrackColor: const Color(0xFF00C853),
            onChanged: (val) => setState(() => _glp1Enabled = val),
          ),
        ],
      ),
    );
  }
}