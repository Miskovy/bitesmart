import 'package:bite_smart/features/profile/screens/activityLevelScreen.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_bloc.dart';
import 'package:bite_smart/features/profile/data/bloc/profile_setup_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  // 🟢 المتغيرات الأساسية لحفظ البيانات (جاهزة للربط بالـ Database)
  String selectedGender = ""; // لا توجد قيمة افتراضية
  
  final TextEditingController _ageController = TextEditingController(text: "");
  final TextEditingController _heightController = TextEditingController(text: "");
  final TextEditingController _weightController = TextEditingController(text: "");
  
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final data = context.read<ProfileSetupBloc>().state.data;
    if (data.gender != null) {
      selectedGender = data.gender!;
    }
    if (data.age != null) {
      _ageController.text = data.age.toString();
    }
    if (data.height != null) {
      _heightController.text = data.height!.round().toString();
    }
    if (data.weight != null) {
      _weightController.text = data.weight!.round().toString();
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // الخلفية العاجية الهادئة
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // 1. النصوص الرئيسية بأعلى الشاشة
                      const Text(
                        "Tell us about\nyourself",
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF111827), height: 1.2),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "To give you better advice, we need to know a little bit about your body metrics.",
                        style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                      ),
                      const SizedBox(height: 30),

                      // 2. كروت الإدخال كلها تحت بعض
                      
                      // عنوان قسم النوع (Gender Label)
                      const Text(
                        "GENDER",
                        style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.1),
                      ),
                      const SizedBox(height: 10),
                      
                      // كارت اختيار النوع المطور (Gender Selector)
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedGender = "Male"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: selectedGender == "Male" ? const Color(0xFFE8F5E9) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selectedGender == "Male" ? const Color(0xFF388E3C) : Colors.grey.shade300,
                                    width: selectedGender == "Male" ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.male,
                                      color: selectedGender == "Male" ? const Color(0xFF388E3C) : Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Male",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedGender == "Male" ? const Color(0xFF388E3C) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => selectedGender = "Female"),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: selectedGender == "Female" ? const Color(0xFFE8F5E9) : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: selectedGender == "Female" ? const Color(0xFF388E3C) : Colors.grey.shade300,
                                    width: selectedGender == "Female" ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.female,
                                      color: selectedGender == "Female" ? const Color(0xFF388E3C) : Colors.grey,
                                      size: 32,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Female",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: selectedGender == "Female" ? const Color(0xFF388E3C) : Colors.grey.shade700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // حقل العمر (Age)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                        
                          _buildNumberInputField(
                            label: "AGE",
                            hint: "Enter your age",
                            icon: Icons.calendar_today_rounded,
                            controller: _ageController,
                            suffix: "years",
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Age is required';
                              }
                              final age = int.tryParse(value);
                              if (age == null) {
                                return 'Please enter a valid number';
                              }
                              if (age < 2 || age > 110) {
                                return 'Please enter a realistic age (2 - 110)';
                              }
                              return null;
                            },
                          ),
                          // hقل الطول (Height)
                      _buildNumberInputField(
                        label: "HEIGHT",
                        hint: "Enter your height",
                        icon: Icons.unfold_more_rounded,
                        controller: _heightController,
                        suffix: "cm",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Height is required';
                          }
                          final height = int.tryParse(value);
                          if (height == null) {
                            return 'Please enter a valid number';
                          }
                          if (height < 50 || height > 250) {
                            return 'Please enter a realistic height (50 - 250 cm)';
                          }
                          return null;
                        },
                      ),
                        ],
                      ),

                      
                      const SizedBox(height: 16),

                      // حقل الوزن (Weight)
                      _buildNumberInputField(
                        label: "WEIGHT",
                        hint: "Enter your weight",
                        icon: Icons.scale_rounded,
                        controller: _weightController,
                        suffix: "kg",
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Weight is required';
                          }
                          final weight = int.tryParse(value);
                          if (weight == null) {
                            return 'Please enter a valid number';
                          }
                          if (weight < 10 || weight > 300) {
                            return 'Please enter a realistic weight (10 - 300 kg)';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // 3. زر الحفظ والمتابعة النهائي مثبت بالأسفل
             Padding(
  padding: const EdgeInsets.all(20.0),
  child: Center(
    child: SizedBox(
      width: .6*MediaQuery.of(context).size.width,
      height: 46,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        onPressed: () {
          if (selectedGender.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select your gender'),
              ),
            );
            return;
          }

          if (_formKey.currentState!.validate()) {
            final int age = int.parse(_ageController.text);
            final double height = double.parse(_heightController.text);
            final double weight = double.parse(_weightController.text);

            context.read<ProfileSetupBloc>().add(
              SetPersonalDataEvent(
                gender: selectedGender,
                age: age,
                height: height,
                weight: weight,
              ),
            );

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ActivityLevelScreen(),
              ),
            );
          }
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Continue",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 8),
            Icon(
              Icons.arrow_forward,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    ),
  ),
)
            ],
          ),
        ),
      ),
    );
  }

  // 💡 ويدجت إدخال الأرقام المطورة
  Widget _buildNumberInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String suffix,
    required String? Function(String?) validator,
  }) {
    return Container(
      width: .4*MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF388E3C)),
          ),
          SizedBox(width: 5,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
               Row(
  children: [
    Expanded(
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(3),
          NoLeadingZeroFormatter(),
        ],
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.black26,
            fontSize: 15,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    ),

    const SizedBox(width: 8),

    Text(
      suffix,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
)
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 💡 فورمات مخصص لمنع إدخال الصفر كأول حرف
class NoLeadingZeroFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('0')) {
      return oldValue;
    }
    return newValue;
  }
}