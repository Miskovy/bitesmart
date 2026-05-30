import 'package:bite_smart/features/auth/screens/loginScreen.dart';
import 'package:bite_smart/features/profile/screens/chooseGoalScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;
  bool _isConfirmObscured = true;
  bool _isAgreed = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (ModalRoute.of(context)?.isCurrent != true) return;
        if (state is AuthSignupSuccess || state is AuthAuthenticated) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChooseGoalScreen(),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message.tr()),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          // مضاف عشان الشاشة متعملش Error لو الكيبورد فتحت
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // اللوجو (نفس شكل الـ Login)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2F0D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco,
                      color: Color(0xFF4CAF50),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'signup.title'.tr(),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'signup.subtitle'.tr(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                  ),
                  const SizedBox(height: 10),

                  // حقل الاسم
                  _buildTextField(
                    label: 'signup.full_name'.tr(),
                    hint: 'signup.name_hint'.tr(),
                    icon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'signup.name_error'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // حقل الإيميل
                  _buildTextField(
                    label: 'signup.email'.tr(),
                    hint: 'signup.email_hint'.tr(),
                    icon: Icons.email_outlined,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'signup.email_error'.tr();
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value.trim())) {
                        return 'signup.email_invalid_error'.tr();
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // حقل الباسورد (بنفس الـ Toggle بتاعك)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _isObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'signup.password_required'.tr();
                          }
                          if (value.length < 8) {
                            return 'signup.password_len_error'.tr();
                          }
                          if (!value.contains(RegExp(r'[A-Z]'))) {
                            return 'signup.password_uppercase_error'.tr();
                          }
                          if (!value.contains(RegExp(r'[a-z]'))) {
                            return 'signup.password_lowercase_error'.tr();
                          }
                          if (!value.contains(RegExp(r'[0-9]'))) {
                            return 'signup.password_number_error'.tr();
                          }
                          if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                            return 'signup.password_special_error'.tr();
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          Label: 'signup.password'.tr(),
                          hint: 'signup.password_hint'.tr(),
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _isObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black26,
                            ),
                            onPressed: () =>
                                setState(() => _isObscured = !_isObscured),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // حقل تأكيد الباسورد
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _isConfirmObscured,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'signup.confirm_password_required'.tr();
                          }
                          if (value != _passwordController.text) {
                            return 'signup.passwords_dont_match'.tr();
                          }
                          return null;
                        },
                        decoration: _inputDecoration(
                          Label: 'signup.confirm_password'.tr(),
                          hint: 'signup.confirm_password_hint'.tr(),
                          icon: Icons.lock_outline,
                          suffix: IconButton(
                            icon: Icon(
                              _isConfirmObscured
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.black26,
                            ),
                            onPressed: () =>
                                setState(() => _isConfirmObscured = !_isConfirmObscured),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // الشروط والأحكام
                  Row(
                    children: [
                      Checkbox(
                        value: _isAgreed,
                        onChanged: (val) => setState(() => _isAgreed = val!),
                        activeColor: const Color(0xFF43A047),
                      ),
                      Expanded(
                        child: Text(
                          'signup.agree'.tr(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // زرار التسجيل
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Center(
                          child: SizedBox(
                            height: 46,
                            width: 46,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF43A047)),
                            ),
                          ),
                        );
                      }
                      return SizedBox(
                        width: .5 * MediaQuery.of(context).size.width,
                        height: 46,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              if (!_isAgreed) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('signup.agree_error'.tr()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                return;
                              }
                              context.read<AuthBloc>().add(
                                    SignupEvent(
                                      fullName: _nameController.text,
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                      agreeToTerms: _isAgreed,
                                    ),
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF43A047),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'signup.create_btn'.tr(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // الفاصل
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'signup.or_continue'.tr(),
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.grey.shade300)),
                    ],
                  ),

                  const SizedBox(height: 10),
                  // أزرار Google و Apple
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: 'signup.google'.tr(),
                          icon: Icons.g_mobiledata,
                          color: Colors.black,
                          onPressed: () {
                            context.read<AuthBloc>().add(const GoogleSignInEvent());
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSocialButton(
                          label: 'signup.apple'.tr(),
                          icon: Icons.apple,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // الرجوع للـ Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'signup.have_account'.tr(),
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Loginscreen(),
                          ),
                        ),
                        // بيرجع لصفحة الـ Login
                        child: Text(
                          'signup.login'.tr(),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    );
  }

  // ميثود مساعدة لتقليل تكرار كود الـ Decoration
  InputDecoration _inputDecoration({
    required String Label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: Label,
      floatingLabelStyle: TextStyle(
        color: Colors.green[700],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon, color: Colors.black26),
      suffixIcon: suffix,
      floatingLabelBehavior: FloatingLabelBehavior.always,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
    VoidCallback? onPressed,
  }) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: color),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ميثود لبناء الحقول العادية
  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: _inputDecoration(Label: label, hint: hint, icon: icon),
        ),
      ],
    );
  }
}
