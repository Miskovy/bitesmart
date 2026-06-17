import 'package:bite_smart/features/auth/screens/loginScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  bool _isObscured = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // فحص الشروط الأربعة
  bool get has8Chars => _passwordController.text.length >= 8;
  bool get hasSymbol =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get hasNumber =>
      _passwordController.text.contains(RegExp(r'[0-9]')); // شرط الرقم الجديد

  // حساب عدد الشروط المحققة (من 0 لـ 4)
  int get _strengthCount {
    int count = 0;
    if (has8Chars) count++;
    if (hasSymbol) count++;
    if (hasUppercase) count++;
    if (hasNumber) count++;
    return count;
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade100,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        // الـ Stepper اللي فوق في نص الـ AppBar
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 18,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (state is AuthPasswordResetSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Password reset successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const Loginscreen()),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'reset.title'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'reset.description'.tr(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'reset.new_password'.tr(),
                  style: const TextStyle(
                    color: Color(0xFF101828),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscured,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'reset.hint'.tr(),
                    hintStyle: const TextStyle(color: Colors.black12),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black26,
                      ),
                      onPressed: () => setState(() => _isObscured = !_isObscured),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.black12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.green,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // الـ Strength Meter المحدث لـ 4 خطوات
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'reset.password_strength'.tr(),
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      _strengthCount == 0
                          ? ''
                          : (_strengthCount <= 2
                                ? 'reset.weak'.tr()
                                : (_strengthCount == 3
                                      ? 'reset.medium'.tr()
                                      : 'reset.strong'.tr())),
                      style: TextStyle(
                        color: _strengthCount == 4
                            ? Colors.green
                            : (_strengthCount >= 2 ? Colors.orange : Colors.red),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _strengthBar(active: _strengthCount >= 1), // 8 حروف
                    _strengthBar(active: _strengthCount >= 2), // رمز
                    _strengthBar(active: _strengthCount >= 3), // حرف كبير
                    _strengthBar(
                      active: _strengthCount >= 4,
                    ), // رقم (الخط الأخير)
                  ],
                ),
                const SizedBox(height: 12),

                // عرض الشروط الأربعة
                Wrap(
                  spacing: 15,
                  runSpacing: 8,
                  children: [
                    _passwordCondition(
                      label: 'reset.condition_length'.tr(),
                      isMet: has8Chars,
                    ),
                    _passwordCondition(
                      label: 'reset.condition_symbol'.tr(),
                      isMet: hasSymbol,
                    ),
                    _passwordCondition(
                      label: 'reset.condition_uppercase'.tr(),
                      isMet: hasUppercase,
                    ),
                    _passwordCondition(
                      label: 'reset.condition_number'.tr(),
                      isMet: hasNumber,
                    ), // الشرط الجديد

                    Text(
                      'reset.confirm_password'.tr(),
                      style: const TextStyle(
                        color: Color(0xFF101828),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _confirmController,
                      obscureText: _isObscured,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: '********',
                        hintStyle: const TextStyle(color: Colors.black12),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // الزرار مبيشتغلش إلا لو الـ 4 شروط تحققوا والباسورد متطابق
                    Center(
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            return const SizedBox(
                              height: 46,
                              width: 46,
                              child: CircularProgressIndicator(
                                color: Color(0xFF43A047),
                              ),
                            );
                          }
                          return SizedBox(
                            width: .6 * MediaQuery.of(context).size.width,
                            height: 46,
                            child: ElevatedButton(
                              onPressed: _strengthCount == 4 &&
                                      _passwordController.text.isNotEmpty &&
                                      _passwordController.text ==
                                          _confirmController.text
                                  ? () {
                                      context.read<AuthBloc>().add(
                                            ResetPasswordEvent(
                                              token: widget.token,
                                              newPassword: _passwordController.text,
                                              confirmPassword: _confirmController.text,
                                            ),
                                          );
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF43A047),
                                disabledBackgroundColor: Colors.grey.shade300,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'reset.reset_button'.tr(),
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _strengthBar({required bool active}) {
    return Expanded(
      child: Container(
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: active ? Colors.green : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _passwordCondition({required String label, required bool isMet}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isMet ? Colors.green : Colors.grey.shade300,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isMet ? Colors.blueGrey : Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
