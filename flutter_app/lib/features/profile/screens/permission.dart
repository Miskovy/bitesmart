import 'package:bite_smart/features/profile/screens/medical.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  bool cameraEnabled = false;
  bool notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final notificationsStatus = await Permission.notification.status;
    if (mounted) {
      setState(() {
        cameraEnabled = cameraStatus.isGranted;
        notificationsEnabled = notificationsStatus.isGranted;
      });
    }
  }

  Future<void> _toggleCamera(bool value) async {
    if (value) {
      final status = await Permission.camera.request();
      if (mounted) {
        setState(() {
          cameraEnabled = status.isGranted;
        });
      }
      if (status.isPermanentlyDenied) {
        _showSettingsPrompt();
      }
    } else {
      _showSettingsPrompt();
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      final status = await Permission.notification.request();
      if (mounted) {
        setState(() {
          notificationsEnabled = status.isGranted;
        });
      }
      if (status.isPermanentlyDenied) {
        _showSettingsPrompt();
      }
    } else {
      _showSettingsPrompt();
    }
  }

  void _showSettingsPrompt() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('permission.disable_info'.tr()),
        action: SnackBarAction(
          label: 'permission.settings_btn'.tr(),
          onPressed: () => openAppSettings(),
        ),
      ),
    );
    // Keep switch visually enabled since we can't programmatically disable granted OS permission
    _checkPermissions();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(Icons.health_and_safety_outlined, color: Color(0xFF43A047), size: 34),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'permission.title'.tr(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
              ),
              const SizedBox(height: 10),
              Text(
                'permission.subtitle'.tr(),
                style: const TextStyle(fontSize: 15, color: Colors.blueGrey, height: 1.6),
              ),
              const SizedBox(height: 10),
              _buildPermissionCard(
                icon: Icons.camera_alt_outlined,
                titleKey: 'permission.camera_title',
                subtitleKey: 'permission.camera_description',
                enabled: cameraEnabled,
                onChanged: _toggleCamera,
              ),
              _buildPermissionCard(
                icon: Icons.notifications_outlined,
                titleKey: 'permission.notifications_title',
                subtitleKey: 'permission.notifications_description',
                enabled: notificationsEnabled,
                onChanged: _toggleNotifications,
              ),
              
              const Spacer(),
              SizedBox(
                width: .6*MediaQuery.of(context).size.width,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const MedicalConditionsScreen())
                  ),                  style: ElevatedButton.styleFrom(  
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    'permission.next_button'.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}


  Widget _buildPermissionCard({
    required IconData icon,
    required String titleKey,
    required String subtitleKey,
    required bool enabled,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: enabled ? const Color(0xFFE8F5E9) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: enabled ? const Color(0xFF43A047) : Colors.black45, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titleKey.tr(),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0D1B2A)),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitleKey.tr(),
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey, height: 1.4),
                ),
              ],
            ),
          ),
          Switch(
            value: enabled,
            activeColor: const Color(0xFF43A047),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }