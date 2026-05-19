import 'package:bite_smart/features/profile/screens/dietaryScreen%20.dart';
import 'package:flutter/material.dart';

class PersonalDataScreen extends StatefulWidget {
  const PersonalDataScreen({super.key});

  @override
  State<PersonalDataScreen> createState() => _PersonalDataScreenState();
}

class _PersonalDataScreenState extends State<PersonalDataScreen> {
  // 🟢 المتغيرات الأساسية لحفظ البيانات (جاهزة للربط بالـ Database)
  String selectedGender = "Male";
  int selectedAge = 28;
  int selectedHeight = 170;
  int selectedWeight = 65;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // الخلفية العاجية الهادئة
      body: SafeArea(
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
                    
                    // كارت النوع (Gender)
                    _buildSelectionCard<String>(
                      label: "GENDER",
                      currentValue: selectedGender,
                      icon: Icons.person,
                      items: ['Male', 'Female'],
                      onChanged: (val) => setState(() => selectedGender = val!),
                    ),
                    const SizedBox(height: 16),

                    // كارت العمر (Age)
                    _buildSelectionCard<int>(
                      label: "AGE",
                      currentValue: selectedAge,
                      icon: Icons.calendar_today_rounded,
                      suffix: "years",
                      // توليد قائمة أعمار من 10 لـ 100 سنة
                      items: List.generate(91, (index) => index + 10),
                      onChanged: (val) => setState(() => selectedAge = val!),
                    ),
                    const SizedBox(height: 16),

                    // كارت الطول (Height)
                    _buildSelectionCard<int>(
                      label: "HEIGHT",
                      currentValue: selectedHeight,
                      icon: Icons.unfold_more_rounded,
                      suffix: "cm",
                      // توليد قائمة أطوال من 100 لـ 220 سم
                      items: List.generate(121, (index) => index + 100),
                      onChanged: (val) => setState(() => selectedHeight = val!),
                    ),
                    const SizedBox(height: 16),

                    // كارت الوزن (Weight)
                    _buildSelectionCard<int>(
                      label: "WEIGHT",
                      currentValue: selectedWeight,
                      icon: Icons.scale_rounded,
                      suffix: "kg",
                      // توليد قائمة أوزان من 30 لـ 180 كيلو
                      items: List.generate(151, (index) => index + 30),
                      onChanged: (val) => setState(() => selectedWeight = val!),
                    ),
                  ],
                ),
              ),
            ),

            // 3. زر الحفظ والمتابعة النهائي مثبت بالأسفل
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF388E3C), // اللون الأخضر المعتمد
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                onPressed: () {

                  // هنا تسحب كل البيانات دفعة واحدة للداتا بيز
                  debugPrint("Saved to DB -> Gender: $selectedGender, Age: $selectedAge, Height: $selectedHeight, Weight: $selectedWeight");
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All metrics saved successfully!')),
                  );
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const DietaryPreferencesScreen()));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 💡 ويدجت موحدة وذكية لبناء الكروت تحت بعض بنفس التصميم
  Widget _buildSelectionCard<T>({
    required String label,
    required T currentValue,
    required IconData icon,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String suffix = "", // لتمييز الكلمات المضافة بجانب الرقم مثل (cm, kg, years)
  }) {
    return Container(
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
        children: [
          // الأيقونة جهة اليسار بخلفية خضراء خفيفة
          CircleAvatar(
            backgroundColor: const Color(0xFFE8F5E9),
            child: Icon(icon, color: const Color(0xFF388E3C)),
          ),
          const SizedBox(width: 12),
          // النصوص التعريفية (عنوان الكارت والقيمة الحالية)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                "$currentValue $suffix".trim(),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
            ],
          ),
          const Spacer(),
          // زر الـ Dropdown متخفي ككلمة "Edit" لفتح الخيارات
          DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              icon: const Text(
                "Edit",
                style: TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              items: items.map((T value) {
                return DropdownMenuItem<T>(
                  value: value,
                  child: Text(
                    "$value $suffix".trim(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          )
        ],
      ),
    );
  }
}