import 'package:bite_smart/features/profile/data/repositories/settings_repository.dart';
import 'package:bite_smart/features/home/data/repositories/symptom_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Glp1SettingsScreen extends StatefulWidget {
  const Glp1SettingsScreen({super.key});

  @override
  State<Glp1SettingsScreen> createState() => _Glp1SettingsScreenState();
}

class _Glp1SettingsScreenState extends State<Glp1SettingsScreen> {
  bool isLoading = true;
  bool isSaving = false;

  bool isGlpModeEnabled = true;
  bool isHighProteinEnabled = true;
  int selectedNauseaIndex = 1; // 0: None, 1: Mild, 2: Mod, 3: Severe
  double appetiteLevel = 3.0;
  bool smartRemindersEnabled = true;
  int reminderHours = 2;

  final List<Map<String, dynamic>> nauseaLevels = [
    {'label': 'None', 'icon': Icons.sentiment_satisfied_alt},
    {'label': 'Mild', 'icon': Icons.sentiment_neutral},
    {'label': 'Mod', 'icon': Icons.sentiment_dissatisfied},
    {'label': 'Severe', 'icon': Icons.sentiment_very_dissatisfied},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final settingsRepo = context.read<ISettingsRepository>();
      final settings = await settingsRepo.getGlp1Settings();
      setState(() {
        isGlpModeEnabled = settings.isGlp1User;
        isHighProteinEnabled = settings.highProteinGoal;
        reminderHours = settings.hydrationReminderHours;
        smartRemindersEnabled = reminderHours > 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      isSaving = true;
    });

    try {
      final settingsRepo = context.read<ISettingsRepository>();
      final symptomRepo = context.read<ISymptomRepository>();

      // 1. Enable/Disable mode in profile
      await settingsRepo.enableGlp1Mode(isGlpModeEnabled);

      // 2. Save settings
      await settingsRepo.saveGlp1Settings(
        Glp1Settings(
          isGlp1User: isGlpModeEnabled,
          highProteinGoal: isHighProteinEnabled,
          hydrationReminderHours: smartRemindersEnabled ? reminderHours : 0,
        ),
      );

      // 3. Log daily check-in (Nausea + Appetite)
      if (isGlpModeEnabled) {
        await symptomRepo.logDailyCheckIn(
          nauseaLevel: selectedNauseaIndex,
          appetiteLevel: appetiteLevel.toInt(),
          notes: 'Log from GLP-1 Settings check-in',
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('GLP-1 settings saved successfully!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAF8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "GLP-1 Settings",
          style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header icon and description
                  Center(
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Color(0xFFE8F5E9),
                          child: Icon(Icons.medication_liquid_rounded, color: Color(0xFF4CAF50), size: 28),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "Configure Your Mode",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Customize your experience to support your medication journey. We'll adjust your macro targets and reminders accordingly.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. Enable GLP-1 Mode toggle tile
                  _buildToggleTile(
                    "Enable GLP-1 Mode",
                    isGlpModeEnabled,
                    (val) => setState(() => isGlpModeEnabled = val),
                    isMainSwitch: true,
                  ),
                  const SizedBox(height: 20),

                  // Dim elements if GLP-1 Mode is disabled
                  Opacity(
                    opacity: isGlpModeEnabled ? 1.0 : 0.5,
                    child: IgnorePointer(
                      ignoring: !isGlpModeEnabled,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("NUTRITION TARGETS", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 10),

                          // 3. High-Protein Goal card
                          _buildProteinCard(),

                          const SizedBox(height: 24),
                          const Text("DAILY CHECK-IN", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),

                          // 4. Nausea level selector card
                          _buildNauseaSelector(),

                          const SizedBox(height: 16),

                          // 5. Appetite level slider card
                          _buildAppetiteSlider(),

                          const SizedBox(height: 24),
                          const Text("HYDRATION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                          const SizedBox(height: 12),

                          // 6. Water hydration reminders card
                          _buildHydrationCard(),

                          const SizedBox(height: 20),

                          // 7. Medical disclaimer
                          _buildMedicalDisclaimer(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 8. Save button
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String title, bool value, Function(bool) onChanged, {bool isMainSwitch = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isMainSwitch ? const Color(0xFFE8F5E9).withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isMainSwitch ? Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)) : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 15, fontWeight: isMainSwitch ? FontWeight.bold : FontWeight.w500)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildProteinCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: Color(0xFFFFF3E0), child: Icon(Icons.egg_alt_rounded, color: Colors.orange)),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("High-Protein Goal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text("Crucial for muscle maintenance", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              Switch(value: isHighProteinEnabled, onChanged: (val) => setState(() => isHighProteinEnabled = val), activeThumbColor: const Color(0xFF4CAF50)),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text("Target adjusted to 1.6g/kg to prevent muscle loss while on GLP-1.", style: TextStyle(fontSize: 12, color: Colors.black87)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNauseaSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Nausea Level", style: TextStyle(fontWeight: FontWeight.bold)),
              Text(nauseaLevels[selectedNauseaIndex]['label'], style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) {
              bool isSelected = selectedNauseaIndex == index;
              return GestureDetector(
                onTap: () => setState(() => selectedNauseaIndex = index),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFE8F5E9) : const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(12),
                        border: isSelected ? Border.all(color: const Color(0xFF4CAF50)) : null,
                      ),
                      child: Icon(nauseaLevels[index]['icon'], color: isSelected ? const Color(0xFF4CAF50) : Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(nauseaLevels[index]['label'], style: TextStyle(fontSize: 10, color: isSelected ? Colors.black : Colors.grey)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildAppetiteSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Appetite", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(6)),
                child: Text("Level ${appetiteLevel.toInt()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          Slider(
            value: appetiteLevel,
            min: 1,
            max: 4,
            activeColor: const Color(0xFF4CAF50),
            inactiveColor: const Color(0xFFE0E0E0),
            onChanged: (val) => setState(() => appetiteLevel = val),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("No Appetite", style: TextStyle(fontSize: 10, color: Colors.grey)),
              Text("Ravenous", style: TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHydrationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Color(0xFFE1F5FE), child: Icon(Icons.water_drop, color: Colors.blue)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Smart Reminders", style: TextStyle(fontWeight: FontWeight.bold)),
                Text("Every $reminderHours hours", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: smartRemindersEnabled,
            onChanged: (v) => setState(() => smartRemindersEnabled = v),
            activeThumbColor: const Color(0xFF4CAF50),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFFFF9C4), borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              "Medical Disclaimer: These settings are for tracking purposes only. Always follow the dosage and dietary advice prescribed by your healthcare provider.",
              style: TextStyle(fontSize: 11, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangle_circular(16),
        ),
        onPressed: isSaving ? null : _saveSettings,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSaving)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            else ...[
              const Text("Save Settings", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              const Icon(Icons.check, color: Colors.white, size: 20),
            ]
          ],
        ),
      ),
    );
  }

  RoundedRectangleBorder RoundedRectangle_circular(double radius) => RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
}