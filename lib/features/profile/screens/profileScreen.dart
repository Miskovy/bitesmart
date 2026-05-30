import 'package:bite_smart/features/profile/screens/editProfileScreen.dart';
import 'package:bite_smart/features/profile/screens/glpModeScreen.dart';
import 'package:bite_smart/features/profile/screens/insightsScreen.dart';
import 'package:bite_smart/features/profile/screens/myPlanScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/auth/screens/language.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const LanguageSelectionScreen(),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F0),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Avatar ──────────────────────────────────────────────────
                Stack(
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE8D5C4),
                        border: Border.all(color: Colors.white, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          'https://i.pravatar.cc/150?img=47',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 50,
                            color: Color(0xFFB09080),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2d7a4f),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 13,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Name & goal ─────────────────────────────────────────────
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    String name = 'Sarah Jenkins';
                    String subText = 'Goal: Maintenance Phase';
                    if (state is AuthAuthenticated) {
                      name = state.displayName ?? state.email.split('@').first;
                      subText = state.email;
                    }
                    return Column(
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 14),

                // ── Edit Profile button ──────────────────────────────────────
                OutlinedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                    side: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Stats row ───────────────────────────────────────────────
                Row(
                  children: [
                    _statCard('14', 'STREAK'),
                    const SizedBox(width: 10),
                    _statCard('-12', 'LBS LOST'),
                    const SizedBox(width: 10),
                    _statCard('88', 'HEALTH\nSCORE'),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Settings list ────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE8E8E3),
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      _settingsTile(
                        icon: Icons.insights,
                        iconColor: const Color(0xFF2d7a4f),
                        iconBg: const Color(0xFFFFE8E8),
                        title: 'Insights',
                        subtitle: 'Your all data insights & progress',
                        subtitleColor: const Color(0xFF888888),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InsightsScreen(),
                          ),
                        ),
                      ),
                      _divider(),
                      _settingsTile(
                        icon: Icons.calendar_month_outlined,
                        iconColor: const Color.fromARGB(255, 230, 232, 230),
                        iconBg: const Color.fromARGB(255, 23, 86, 26),
                        title: 'My Plan',
                        subtitle: 'Your dishes, meals & workout plan',
                        subtitleColor: const Color(0xFF888888),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MyPlanScreen(),
                          ),
                        ),
                      ),
                      _divider(),

                      // GLP-1 Mode (toggle)
                      _settingsTile(
                        icon: Icons.medication_rounded,
                        iconColor: const Color(0xFF378ADD),
                        iconBg: const Color(0xFFE8F4FF),
                        title: 'GLP-1 Mode',
                        subtitle: 'Adjusts nutrition targets',
                        subtitleColor: const Color(0xFF888888),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFCCCCCC),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const Glp1SettingsScreen(),
                          ),
                        ),
                      ),

                      _divider(),
                      _settingsTile(
                        icon: Icons.language_rounded,
                        iconColor: const Color(0xFF534AB7),
                        iconBg: const Color(0xFFEEEEFE),
                        title: 'Language',
                        subtitle: null,
                        subtitleColor: null,
                        trailing: DropdownButton<String>(
                          value: context.locale.languageCode,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFFCCCCCC),
                          ),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English 🇺🇸'),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('العربية 🇪🇬'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val == 'ar') {
                              context.setLocale(const Locale('ar', 'EG'));
                            } else {
                              context.setLocale(const Locale('en', 'US'));
                            }
                          },
                        ),
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: () => _showSignOutDialog(context),
                  icon: const Icon(Icons.logout_rounded, color: Colors.black),
                  label: Text('profile.sign_out'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('profile.sign_out'.tr()),
          content: Text('profile.sign_out_confirm'.tr()),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'profile.cancel'.tr(),
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                context.read<AuthBloc>().add(const LogoutEvent());
              },
              child: Text(
                'profile.confirm'.tr(),
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _statCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE8E8E3), width: 0.5),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFAAAAAA),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String? subtitle,
    required Color? subtitleColor,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: subtitleColor ?? const Color(0xFF888888),
                        fontWeight: subtitleColor == const Color(0xFF2d7a4f)
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 0.5,
    indent: 68,
    endIndent: 0,
    color: Color(0xFFEEEEEE),
  );
}
