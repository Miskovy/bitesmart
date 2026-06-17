import 'package:bite_smart/features/profile/screens/dietaryScreen%20.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ActivityLevelScreen extends StatefulWidget {
  const ActivityLevelScreen({super.key});

  @override
  State<ActivityLevelScreen> createState() => _ActivityLevelScreenState();
}

class _ActivityLevelScreenState extends State<ActivityLevelScreen> {
  int selectedIndex = 2; // Default is ModeratelyActive

  final List<Map<String, dynamic>> activityLevels = [
    {
      'value': 'Sedentary',
      'titleKey': 'activity.sedentary_title',
      'descKey': 'activity.sedentary_desc',
      'icon': Icons.airline_seat_recline_normal,
    },
    {
      'value': 'LightlyActive',
      'titleKey': 'activity.lightly_active_title',
      'descKey': 'activity.lightly_active_desc',
      'icon': Icons.directions_walk,
    },
    {
      'value': 'ModeratelyActive',
      'titleKey': 'activity.moderately_active_title',
      'descKey': 'activity.moderately_active_desc',
      'icon': Icons.directions_run,
    },
    {
      'value': 'VeryActive',
      'titleKey': 'activity.very_active_title',
      'descKey': 'activity.very_active_desc',
      'icon': Icons.fitness_center,
    },
  ];

  @override
  void initState() {
    super.initState();
    final currentActivity = context.read<ProfileSetupBloc>().state.data.activityLevel;
    if (currentActivity != null) {
      final index = activityLevels.indexWhere((element) => element['value'] == currentActivity);
      if (index != -1) {
        selectedIndex = index;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFDFA),
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
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'activity.title'.tr(),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                ),
                const SizedBox(height: 12),
                Text(
                  'activity.subtitle'.tr(),
                  style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.4),
                ),
                const SizedBox(height: 30),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activityLevels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = activityLevels[index];
                    return _buildActivityCard(
                      index: index,
                      title: (item['titleKey'] as String).tr(),
                      description: (item['descKey'] as String).tr(),
                      icon: item['icon'] as IconData,
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: .6 * MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    final selectedValue = activityLevels[selectedIndex]['value'] as String;
                    context.read<ProfileSetupBloc>().add(SetActivityLevelEvent(selectedValue));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DietaryPreferencesScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'activity.continue'.tr(),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityCard({
    required int index,
    required String title,
    required String description,
    required IconData icon,
  }) {
    bool isSelected = selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF43A047) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF43A047) : Colors.black45,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            Container(
              height: 22,
              width: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF43A047) : Colors.black12,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF43A047) : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
