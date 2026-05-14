import 'package:bite_smart/ui/screens/otpScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _inputController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // دالة الـ Validation المزدوجة (إيميل أو رقم موبايل)
  String? _validateInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'forgot.validation.required'.tr();
    }

    // Regex للإيميل
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    // Regex لرقم الموبايل (بيقبل أرقام فقط من 11 رقم)
    final phoneRegex = RegExp(r'^01[0-2,5][0-9]{8}$');

    if (emailRegex.hasMatch(value)) {
      return null; // الإيميل صح
    } else if (phoneRegex.hasMatch(value)) {
      return null; // الرقم صح
    } else {
      return 'forgot.validation.invalid'.tr();
    }
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
              width: 18,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.green,
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
              width: 8,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // الأيقونة بنفس تصميمك
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    color: Color(0xFF4CAF50),
                    size: 50,
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'forgot.title'.tr(),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0D1B2A),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'forgot.subtitle'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'forgot.email_or_phone_label'.tr(),
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // TextFormField بنفس الـ Styling بتاعك بالملي
                    TextFormField(
                      controller: _inputController,
                      validator: _validateInput,
                      decoration: InputDecoration(
                        hintText: 'forgot.email_hint'.tr(),
                        hintStyle: const TextStyle(color: Colors.black26),
                        prefixIcon: const Icon(
                          Icons.alternate_email,
                          color: Colors.black26,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),

                        // الحدود العادية (بدون خطأ)
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.green,
                            width: 1.5,
                          ),
                        ),

                        // الحدود في حالة وجود خطأ (عشان نحافظ على شكل الـ UI)
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1.5,
                          ),
                        ),
                        errorStyle: const TextStyle(
                          height: 1,
                        ), // عشان ميبوظش المسافات
                      ),
                    ),
                  ],
                ),

                Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // لو المدخلات صح، ينقل للصفحة اللي بعدها
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const otpScreen(),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF43A047),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      shadowColor: Colors.green.withOpacity(0.3),
                    ),
                    child: Text(
                      'forgot.send_code'.tr(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'forgot.remembered'.tr(),
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'forgot.log_in'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF43A047),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
