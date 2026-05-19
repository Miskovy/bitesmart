import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // 🟢 1. المتغيرات الخاصة بالبيانات الشخصية (Variables لربط الداتا بيز)
  String imageUrl = 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200';
  String currentPhase = "Maintenance Phase";
  String currentGoalDescription = "Maintain current composition";

  // المتحكمات بحقول النص (Controllers)
  final TextEditingController _nameController = TextEditingController(text: "Sarah Jenkins");
  final TextEditingController _emailController = TextEditingController(text: "sarah.j@example.com");
  final TextEditingController _phoneController = TextEditingController(text: "+1 (555) 123-4567");
  final TextEditingController _weightController = TextEditingController(text: "65");
  final TextEditingController _heightController = TextEditingController(text: "170");

  @override
  void dispose() {
    // تنظيف الـ Controllers عند إغلاق الصفحة
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  // دالة الحفظ (اللي هتربط فيها أكشن الداتا بيز مستقبلاً)
  void _saveProfileData() {
    String updatedName = _nameController.text;
    String updatedEmail = _emailController.text;
    String updatedWeight = _weightController.text;

    debugPrint("Saving to DB: $updatedName, $updatedEmail, $updatedWeight kg");
    // هنا تكتب كود الـ Update الخاص بـ Firebase أو الـ API
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("editProfile.save_success".tr(), style: const TextStyle(color: Colors.green)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F2), // لون الخلفية العاجي المائل للخضار الخفيف جداً
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "editProfile.title".tr(),
          style: const TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _saveProfileData,
            child: Text(
              "editProfile.save".tr(),
              style: const TextStyle(color: Color(0xFF4CAF50), fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          children: [
            // 2. بروفايل الصورة الشخصية مع زر التعديل الأخضر
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: CircleAvatar(
                    radius: 46,
                    backgroundImage: NetworkImage(imageUrl),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => debugPrint("Pick Image Action"),
                    child: const CircleAvatar(
                      radius: 14,
                      backgroundColor: Color(0xFF2E7D32), // الأخضر الداكن المحيط بالزر
                      child: Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // الاسم والـ Phase أسفل الصورة
            Text(
              _nameController.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
            ),
            Text(
              currentPhase,
              style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 24),

            // 3. كارت البيانات الشخصية (PERSONAL DETAILS)
            // كارت البيانات الشخصية (PERSONAL DETAILS)
_buildSectionCard(
  title: "editProfile.personal_details".tr(),
  children: [
    // الاسم هيفضل مفتوح للتعديل عادي
    _buildInputField(label: "editProfile.full_name".tr(), controller: _nameController),
    
    // 🔒 الإيميل مقفول
    _buildInputField(
      label: "editProfile.email_address".tr(),
      controller: _emailController, 
      keyboardType: TextInputType.emailAddress,
      isEditable: false, // 👈 قفلنا التعديل
    ),
    
    // 🔒 رقم الهاتف مقفول
    _buildInputField(
      label: "editProfile.phone_number".tr(),
      controller: _phoneController, 
      keyboardType: TextInputType.phone,
      isEditable: false, // 👈 قفلنا التعديل
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
                    Expanded(child: _buildInputField(label: "editProfile.weight_kg".tr(), controller: _weightController, keyboardType: TextInputType.number)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildInputField(label: "editProfile.height_cm".tr(), controller: _heightController, keyboardType: TextInputType.number)),
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
                    child: Icon(Icons.swap_horizontal_circle_outlined, color: Color(0xFF2E7D32)),
                  ),
                  title: Text(
                    currentPhase,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  subtitle: Text(
                    currentGoalDescription,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () => debugPrint("Change Goal Action"),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ويدجت لبناء بطاقات الأقسام المستقلة بخلفية بيضاء وحواف دائرية ناعمة
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ويدجت لبناء حقول الإدخال الملونة المخصصة تماماً كما في التصميم
 // ويدجت لبناء حقول الإدخال مع ميزة القفل والفتح
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool isEditable = true, // 👈 البارامتر الجديد للتحكم في القفل
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              // لو الحقل مقفول بنخليه شفاف أكتر شوية عشان يبان إنه Disabled
              color: isEditable ? const Color(0xFFEDF2EC) : const Color(0xFFEDF2EC).withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              enabled: isEditable, // 👈 هنا بنقفل الإدخال تماماً لو false
              style: TextStyle(
                fontSize: 14, 
                // تغيير لون الخط لرمادي هادئ لو الحقل غير قابل للتعديل
                color: isEditable ? const Color(0xFF111827) : Colors.grey.shade600, 
                fontWeight: FontWeight.w500,
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                if (label == "Full Name") setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }
}