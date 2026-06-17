import 'dart:async';
import 'package:bite_smart/features/auth/screens/resetScreen.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_bloc.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_event.dart';
import 'package:bite_smart/features/auth/data/bloc/auth_state.dart';

class otpScreen extends StatefulWidget {
  final String email;
  const otpScreen({super.key, required this.email});

  @override
  State<otpScreen> createState() => _otpScreenState();
}

class _otpScreenState extends State<otpScreen> {
  int _start = 59;
  Timer? _timer;
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  bool _hasError = false;

  // تشغيل العداد
  void startTimer() {
    _timer?.cancel();
    _start = 59;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_start == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _start--;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel(); // إيقاف العداد عند الخروج من الصفحة
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
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
          ],
        ),
        centerTitle: true,
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (ModalRoute.of(context)?.isCurrent != true) return;
          if (state is AuthOtpVerified) {
            setState(() {
              _hasError = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'OTP verified successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                  token: state.token ?? '',
                ),
              ),
            );
          } else if (state is AuthError) {
            setState(() {
              _hasError = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // أيقونة الدرع المتدرجة
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF43A047), Color(0xFF2196F3)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'otp.security_check'.tr(),
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF101828),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'otp.sent_to'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
                Text(
                  widget.email,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 40),

                // خانات الـ OTP الستة
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _otpBox(context, 0, first: true),
                    _otpBox(context, 1),
                    _otpBox(context, 2),
                    _otpBox(context, 3),
                    _otpBox(context, 4),
                    _otpBox(context, 5, last: true),
                  ],
                ),

                const SizedBox(height: 12),

                // العداد (Resend Code)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'otp.resend_code'.tr(),
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    _start > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2F0D9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              "00:${_start.toString().padLeft(2, '0')}",
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : TextButton(
                            onPressed: () {
                              context.read<AuthBloc>().add(
                                    SendOtpEvent(emailOrPhone: widget.email),
                                  );
                              startTimer();
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(
                              'Resend',
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),

                const SizedBox(height: 12),

                // تغيير الإيميل
                TextButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: Colors.blueGrey,
                  ),
                  label: Text(
                    'otp.change_email'.tr(),
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // زرار التحقق والاستمرار
                BlocBuilder<AuthBloc, AuthState>(
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
                        onPressed: () {
                          final otp = _controllers.map((c) => c.text).join();
                          if (otp.length < 6) {
                            setState(() {
                              _hasError = true;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a 6-digit code'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          context.read<AuthBloc>().add(
                                VerifyOtpEvent(
                                  emailOrPhone: widget.email,
                                  otp: otp,
                                ),
                              );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF43A047),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'otp.verify_continue'.tr(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 10),

                Text(
                  'otp.by_continuing'.tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ويدجت الخانة الواحدة للـ OTP
  Widget _otpBox(
    BuildContext context,
    int index, {
    bool first = false,
    bool last = false,
  }) {
    return Container(
      height: 60,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _hasError ? Colors.red : Colors.blue.withOpacity(0.1),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        autofocus: first,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number, // بتفتح كيبورد الأرقام
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // بتمنع كتابة أي حاجة غير الأرقام
        ],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
          hintText: "•",
          hintStyle: TextStyle(color: Colors.black12),
        ),
        onChanged: (value) {
          if (_hasError) {
            setState(() {
              _hasError = false;
            });
          }

          if (value.length > 1) {
            // User pasted a code
            final cleanValue = value.replaceAll(RegExp(r'\D'), '');
            if (cleanValue.isNotEmpty) {
              for (int i = 0; i < 6; i++) {
                final targetIdx = index + i;
                if (targetIdx < 6 && i < cleanValue.length) {
                  _controllers[targetIdx].text = cleanValue[i];
                }
              }
              final nextIndex = index + cleanValue.length;
              if (nextIndex < 6) {
                _focusNodes[nextIndex].requestFocus();
              } else {
                _focusNodes[5].requestFocus();
              }
            }
            return;
          }

          if (value.length == 1 && !last) {
            _focusNodes[index + 1].requestFocus(); // الانتقال للخانة التالية
          }
          if (value.isEmpty && !first) {
            _focusNodes[index - 1].requestFocus(); // الرجوع للخانة السابقة عند المسح
          }
        },
      ),
    );
  }
}
