import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_event.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_state.dart';
import 'package:bite_smart/features/profile/screens/chooseGoalScreen.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:image_picker/image_picker.dart';
import 'package:bite_smart/core/utils/avatar_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 🟢 1. المتغيرات الخاصة بالبيانات الشخصية (Variables لربط الداتا بيز)
  String imageUrl = '';
  String currentPhase = "Maintenance Phase";
  String currentGoalDescription = "Maintain current composition";

  // المتحكمات بحقول النص (Controllers)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  ProfileLoaded? _lastLoadedProfile;

  @override
  void initState() {
    super.initState();

    // Listen to controller changes to trigger rebuild (so save button status is dynamic)
    _nameController.addListener(_onTextChanged);
    _phoneController.addListener(_onTextChanged);
    _weightController.addListener(_onTextChanged);
    _heightController.addListener(_onTextChanged);

    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _populateControllers(profileState);
    } else {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        context.read<ProfileBloc>().add(
          LoadProfileEvent(userId: authState.userId),
        );
      }
    }
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _populateControllers(ProfileLoaded state) {
    _nameController.text = state.displayName ?? "";
    _emailController.text = state.email ?? "";
    _phoneController.text = state.phone ?? "";
    _weightController.text = state.weight != null
        ? state.weight!.round().toString()
        : "";
    _heightController.text = state.height != null
        ? state.height!.round().toString()
        : "";

    if (state.profileImageUrl != null && state.profileImageUrl!.isNotEmpty) {
      imageUrl = state.profileImageUrl!;
    }
    if (state.userGoal != null && state.userGoal!.isNotEmpty) {
      currentPhase = state.userGoal!;
      // Provide a matching description for goal
      if (currentPhase == 'WeightLoss') {
        currentGoalDescription = 'Lose weight and body fat';
      } else if (currentPhase == 'MuscleGain') {
        currentGoalDescription = 'Gain lean muscle mass';
      } else {
        currentGoalDescription = 'Maintain current composition';
      }
    }
    _lastLoadedProfile = state;
  }

  bool _hasChanges() {
    if (_lastLoadedProfile == null) return false;
    final originalName = _lastLoadedProfile!.displayName ?? "";
    final originalPhone = _lastLoadedProfile!.phone ?? "";
    final originalWeight = _lastLoadedProfile!.weight != null
        ? _lastLoadedProfile!.weight!.round().toString()
        : "";
    final originalHeight = _lastLoadedProfile!.height != null
        ? _lastLoadedProfile!.height!.round().toString()
        : "";

    return _nameController.text != originalName ||
        _phoneController.text != originalPhone ||
        _weightController.text != originalWeight ||
        _heightController.text != originalHeight;
  }

  @override
  void dispose() {
    _nameController.removeListener(_onTextChanged);
    _phoneController.removeListener(_onTextChanged);
    _weightController.removeListener(_onTextChanged);
    _heightController.removeListener(_onTextChanged);

    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // دالة الحفظ
  void _saveProfileData() {
    if (_lastLoadedProfile == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final double? weight = double.tryParse(_weightController.text);
      final double? height = double.tryParse(_heightController.text);

      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          userId: authState.userId,
          displayName: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          weight: weight,
          height: height,
          profileImageUrl: _lastLoadedProfile!.profileImageUrl,
          age: _lastLoadedProfile!.age,
          gender: _lastLoadedProfile!.gender,
          userGoal: _lastLoadedProfile!.userGoal,
          activityLevel: _lastLoadedProfile!.activityLevel,
        ),
      );
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: MediaQuery.of(context).size.width,
        maxHeight: MediaQuery.of(context).size.height,
        imageQuality: 85,
      );
      if (image != null) {
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          context.read<ProfileBloc>().add(
            UploadAvatarEvent(userId: authState.userId, filePath: image.path),
          );
        }
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Error picking image: $e",
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          _populateControllers(state);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "editProfile.save_success".tr(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );

          setState(() {});
        }
      },
      builder: (context, state) {
        final isLoading = state is ProfileLoading;
        final isSaveEnabled = _hasChanges() && !isLoading;

        return Scaffold(
          backgroundColor: const Color(
            0xFFF4F6F2,
          ), // لون الخلفية العاجي المائل للخضار الخفيف جداً
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.grey),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "editProfile.title".tr(),
              style: const TextStyle(
                color: Color(0xFF2E7D32),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: isSaveEnabled ? _saveProfileData : null,
                child: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        "editProfile.save".tr(),
                        style: TextStyle(
                          color: isSaveEnabled
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
          body: isLoading && _lastLoadedProfile == null
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF2E7D32)),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: Column(
                    children: [
                      // 2. بروفايل الصورة الشخصية مع زر التعديل الأخضر
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: CircleAvatar(
                              radius: 46,
                              backgroundColor: const Color(0xFFE8D5C4),
                              backgroundImage: imageUrl.isNotEmpty
                                  ? AvatarUtils.getImageProvider(imageUrl)
                                  : null,
                              child: imageUrl.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Color(0xFFB09080),
                                    )
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 2,
                            child: GestureDetector(
                              onTap: isLoading ? null : _pickAndUploadImage,
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF2E7D32),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.edit,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // الاسم والـ Goal أسفل الصورة
                      Text(
                        _nameController.text.isNotEmpty
                            ? _nameController.text
                            : "user name",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        currentPhase,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // 3. كارت البيانات الشخصية (PERSONAL DETAILS)
                      _buildSectionCard(
                        title: "editProfile.personal_details".tr(),
                        children: [
                          // الاسم هيفضل مفتوح للتعديل عادي
                          _buildInputField(
                            label: "editProfile.full_name".tr(),
                            controller: _nameController,
                          ),

                          // 🔒 الإيميل مقفول
                          _buildInputField(
                            label: "editProfile.email_address".tr(),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            isEditable: false, // 👈 قفلنا التعديل
                          ),

                          // 🔓 رقم الهاتف مفتوح للتعديل
                          _buildInputField(
                            label: "editProfile.phone_number".tr(),
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            isEditable: true, // 👈 فتحنا التعديل
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 4. كارت القياسات الجسدية (BODY METRICS)
                      _buildSectionCard(
                        title: "editProfile.body_metrics".tr(),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildInputField(
                                  label: "editProfile.weight_kg".tr(),
                                  controller: _weightController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildInputField(
                                  label: "editProfile.height_cm".tr(),
                                  controller: _heightController,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 5. كارت الهدف الرئيسي (PRIMARY GOAL)
                      _buildSectionCard(
                        title: "editProfile.primary_goal".tr(),
                        children: [
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE8F5E9),
                              child: Icon(
                                Icons.swap_horizontal_circle_outlined,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            title: Text(
                              currentPhase,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                            ),
                            subtitle: Text(
                              currentGoalDescription,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton(
                          onPressed: () {
                            context.read<ProfileSetupBloc>().add(
                              const ResetProfileSetupEvent(),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChooseGoalScreen(),
                              ),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Color(0xFF2E7D32),
                              width: 1.5,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            "editProfile.re_enter_all_data".tr(),
                            style: const TextStyle(
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
        );
      },
    );
  }

  // ويدجت لبناء بطاقات الأقسام المستقلة بخلفية بيضاء وحواف دائرية ناعمة
  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ويدجت لبناء حقول الإدخال مع ميزة القفل والفتح
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isEditable = true, // 👈 البارامتر للتحكم في القفل
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              // لو الحقل مقفول بنخليه شفاف أكتر شوية عشان يبان إنه Disabled
              color: isEditable
                  ? const Color(0xFFEDF2EC)
                  : const Color(0xFFEDF2EC).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: isEditable, // 👈 هنا بنقفل الإدخال تماماً لو false
              style: TextStyle(
                fontSize: 14,
                // تغيير لون الخط لرمادي هادئ لو الحقل غير قابل للتعديل
                color: isEditable
                    ? const Color(0xFF111827)
                    : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
