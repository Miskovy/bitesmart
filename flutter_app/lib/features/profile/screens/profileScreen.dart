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
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_state.dart';
import 'package:bite_smart/features/profile/data/repositories/profile_repository.dart';
import 'package:bite_smart/core/utils/avatar_utils.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  double _weightChange = 0.0;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is! ProfileLoaded) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileBloc>().add(LoadProfileEvent(userId: authState.userId));
      }
    }
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final repo = context.read<IProfileRepository>();
      final insights = await repo.getUserInsights(range: 'weekly');
      if (mounted) {
        setState(() {
          _weightChange = insights.weightChange;
        });
      }
    } catch (_) {
      // Fallback if network is not available
    }
  }

  void _showImageDialog(BuildContext context, String? imageUrl) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: AvatarUtils.buildAvatarWidget(
                    avatar: imageUrl ?? 'https://i.pravatar.cc/150?img=47',
                    size: MediaQuery.of(context).size.width - 40,
                    fit: BoxFit.contain,
                    placeholder: const Icon(
                      Icons.person,
                      size: 150,
                      color: Color(0xFFB09080),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
                        child: BlocBuilder<ProfileBloc, ProfileState>(
                          builder: (context, state) {
                            String? imageUrl;
                            if (state is ProfileLoaded && state.profileImageUrl != null && state.profileImageUrl!.isNotEmpty) {
                              imageUrl = state.profileImageUrl!;
                            }
                            return GestureDetector(
                              onTap: () => _showImageDialog(context, imageUrl),
                              child: AvatarUtils.buildAvatarWidget(
                                avatar: imageUrl ?? '',
                                size: 90,
                                fit: BoxFit.cover,
                                placeholder: const Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Color(0xFFB09080),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ── Name & goal ─────────────────────────────────────────────
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    String name = 'profile_screen.user_name'.tr();
                    String subText = 'profile_screen.goal_maintenance'.tr();
                    if (state is ProfileLoaded) {
                      name = state.displayName ?? 'profile_screen.user_name'.tr();
                      if (state.userGoal != null && state.userGoal!.isNotEmpty) {
                        subText = 'Goal: ${state.userGoal}';
                      } else {
                        subText = state.email ?? '';
                      }
                    } else {
                      final authState = context.read<AuthBloc>().state;
                      if (authState is AuthAuthenticated) {
                        name = authState.displayName ?? authState.email.split('@').first;
                        subText = authState.email;
                      }
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
                  child:  Text(
                    'profile_screen.edit_profile'.tr(),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),

                const SizedBox(height: 24),

                // ── Stats row ───────────────────────────────────────────────
                BlocBuilder<ProfileBloc, ProfileState>(
                  builder: (context, state) {
                    String streak = '0';
                    String lbsLost = '0.0';
                    String healthScore = '0';

                    if (state is ProfileLoaded) {
                      streak = '${state.loginStreak ?? 0}';
                      lbsLost = _weightChange >= 0
                          ? '+${_weightChange.toStringAsFixed(1)}'
                          : _weightChange.toStringAsFixed(1);
                      
                      // Calculate personalized Health Score
                      double bmiScore = 90.0;
                      if (state.weight != null && state.height != null && state.weight! > 0 && state.height! > 0) {
                        final heightInMeters = state.height! / 100.0;
                        final bmi = state.weight! / (heightInMeters * heightInMeters);
                        if (bmi >= 18.5 && bmi <= 24.9) {
                          bmiScore = 100.0;
                        } else if ((bmi >= 17.0 && bmi < 18.5) || (bmi > 24.9 && bmi <= 29.9)) {
                          bmiScore = 85.0;
                        } else {
                          bmiScore = 70.0;
                        }
                      }

                      double activityScore = 75.0;
                      if (state.activityLevel != null) {
                        switch (state.activityLevel) {
                          case 'Sedentary':
                            activityScore = 70.0;
                            break;
                          case 'LightlyActive':
                            activityScore = 85.0;
                            break;
                          case 'ModeratelyActive':
                            activityScore = 95.0;
                            break;
                          case 'VeryActive':
                          case 'ExtraActive':
                            activityScore = 100.0;
                            break;
                          default:
                            activityScore = 80.0;
                        }
                      }

                      final streakBonus = ((state.loginStreak ?? 0) * 1.5).clamp(0.0, 10.0);
                      final calculatedScore = ((bmiScore * 0.55) + (activityScore * 0.35) + streakBonus).round().clamp(50, 100);
                      healthScore = '$calculatedScore';
                    }

                    return Row(
                      children: [
                        _statCard(streak, 'profile_screen.streak'.tr()),
                        const SizedBox(width: 10),
                        _statCard(lbsLost, 'profile_screen.lbs_lost'.tr()),
                        const SizedBox(width: 10),
                        _statCard(healthScore, 'profile_screen.health_score'.tr()),
                      ],
                    );
                  },
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
                        title: 'profile_screen.insights_title'.tr(),
                        subtitle: 'profile_screen.insights_sub'.tr(),
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
                        title: 'profile_screen.my_plan_title'.tr(),
                        subtitle: 'profile_screen.my_plan_sub'.tr(),
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
                        title: 'profile_screen.glp1_title'.tr(),
                        subtitle: 'profile_screen.glp1_sub'.tr(),
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
                        title: 'profile_screen.language'.tr(),
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
                          style:  TextStyle(
                            fontSize: 13,
                            color: Color(0xFF888888),
                          ),
                          items:  [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('profile_screen.en'.tr()),
                            ),
                            DropdownMenuItem(
                              value: 'ar',
                              child: Text('profile_screen.ar'.tr()),
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
