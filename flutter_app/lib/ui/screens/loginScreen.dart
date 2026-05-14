import 'package:bite_smart/ui/screens/forgetPass.dart';
import 'package:bite_smart/ui/screens/signup.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({super.key});

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isObscured = true;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // وظيفة التحقق عند الضغط على الزر
  void _submitData() {
    if (_formKey.currentState!.validate()) {
      // إذا كانت البيانات صحيحة
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('login.processing'.tr()), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // اللوجو (الأيقونة الخضراء)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2F0D9), // لون خلفية الورقة
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.eco, // أيقونة الورقة
                    color: Color(0xFF4CAF50),
                    size: 40,
                  ),
                ),
                Text(
                  'login.welcome_back'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'login.subtitle'.tr(),
                  style: const TextStyle(fontSize: 14, color: Colors.blueGrey),
                ),
                TextField(
                  controller: _emailController,
                  decoration: _inputDecoration(
                    label: 'login.email_or_phone'.tr(),
                    hint: 'login.email_hint'.tr(),
                    icon: Icons.email_outlined,
                  ),
                ),
                TextField(
                  controller: _passwordController,
                  obscureText: _isObscured, // يستخدم المتغير للتحكم في الظهور
                  decoration: _inputDecoration(
                    label: 'login.password'.tr(),
                    hint: 'login.password_hint'.tr(),
                    icon: Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(
                        // تغيير شكل الأيقونة بناءً على الحالة
                        _isObscured
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.black26,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                ),

                // نسيت كلمة المرور
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ForgotPasswordScreen(),
                      ),
                    ),
                    child: Text(
                      'login.forgot_password'.tr(),
                      style: const TextStyle(color: Colors.blueGrey, fontSize: 13),
                    ),
                  ),
                ),

                // زر تسجيل الدخول
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'login.log_in'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),

                // خط الفاصل
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'login.or_continue'.tr(),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                // أزرار Google و Apple
                Row(
                  children: [
                    Expanded(
                      child: _buildSocialButton(
                        label: 'login.google'.tr(),
                        icon: Icons.g_mobiledata,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildSocialButton(
                        label: 'login.apple'.tr(),
                        icon: Icons.apple,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
                // إنشاء حساب
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'login.no_account'.tr(),
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(),
                        ),
                      ),
                      child: Text(
                        'login.sign_up'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: Colors.blueGrey,
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      floatingLabelStyle: TextStyle(
        color: Colors.green[700],
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      floatingLabelBehavior: FloatingLabelBehavior.always,
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black26),
      prefixIcon: Icon(icon, color: Colors.black26),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required Color color,
  }) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: color),
      label: Text(label, style: const TextStyle(color: Colors.black)),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
