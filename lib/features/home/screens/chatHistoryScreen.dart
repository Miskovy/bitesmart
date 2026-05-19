import 'package:flutter/material.dart';

// موديل بيانات المحادثة لتسهيل العرض والتحكم في الـ Logic
class ChatHistoryItem {
  final String title;
  final String subtitle;
  final String date;
  final String tag;
  final Color tagColor;
  final Color tagBgColor;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final bool isProfileImage; // عشان نحدد لو هنعرض صورة مدرب أو أيقونة عادية

  ChatHistoryItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.tag,
    required this.tagColor,
    required this.tagBgColor,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.isProfileImage = false,
  });
}

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  // لستة البيانات المطابقة تماماً للصورة المرفقة
  final List<ChatHistoryItem> _allConversations = [
    ChatHistoryItem(
      title: "Morning Routin...",
      subtitle: "Great job on hitting your water go...",
      date: "Today, 9:30 AM",
      tag: "Advice",
      tagColor: const Color(0xFF2F80ED),
      tagBgColor: const Color(0xFFE2EEFF),
      icon: Icons.person,
      iconBgColor: const Color(0xFFE8F5E9), // سيتم استبدالها بصورة بروفايل في الـ UI
      iconColor: Colors.blue,
      isProfileImage: true,
    ),
    ChatHistoryItem(
      title: "Post-Workout Nutr...",
      subtitle: "I suggest adding a bit more protei...",
      date: "Yesterday",
      tag: "Nutrition",
      tagColor: const Color(0xFF9A8446),
      tagBgColor: const Color(0xFFF4EED9),
      icon: Icons.spa_rounded,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
    ),
    ChatHistoryItem(
      title: "Healthy Snack Ideas",
      subtitle: "Here are 5 quick snack recipes yo...",
      date: "Oct 24",
      tag: "Nutrition",
      tagColor: const Color(0xFF9A8446),
      tagBgColor: const Color(0xFFF4EED9),
      icon: Icons.eco_rounded,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
    ),
    ChatHistoryItem(
      title: "Weekly Sync",
      subtitle: "Looking forward to reviewing your ...",
      date: "Oct 20",
      tag: "General",
      tagColor: const Color(0xFF666666),
      tagBgColor: const Color(0xFFEAEAEA),
      icon: Icons.chat_bubble_rounded,
      iconBgColor: const Color(0xFFEFEFEF),
      iconColor: const Color(0xFF757575),
    ),
    
    // يمكنك إلغاء تعليق (Uncomment) هذه العناصر لاختبار ظهور زر "Load Older Conversations"
    /*
    ChatHistoryItem(
      title: "Calorie Breakdown",
      subtitle: "Let's check your intake from last week...",
      date: "Oct 15",
      tag: "Nutrition",
      tagColor: const Color(0xFF9A8446),
      tagBgColor: const Color(0xFFF4EED9),
      icon: Icons.analytics_rounded,
      iconBgColor: const Color(0xFFE8F5E9),
      iconColor: const Color(0xFF2E7D32),
    ),
    */
  ];

  @override
  Widget build(BuildContext context) {
    // الـ Logic المطلوب: يظهر الزر فقط لو عدد الشاتات أكبر من 4
    bool showLoadMore = _allConversations.length > 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8), // لون الخلفية الهادئ المائل للخضار النظيف
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Chat History",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // قائمة كروت المحادثات السابقة
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _allConversations.length,
                itemBuilder: (context, index) {
                  final item = _allConversations[index];
                  return _buildHistoryCard(item);
                },
              ),
            ),

            // الـ Logic اللي طلبته: زر تحكم "إظهار المزيد" يظهر بشرط ديناميكي
            if (showLoadMore)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                child: InkWell(
                  onTap: () {
                    // الأكشن الخاص بتحميل المحادثات الأقدم
                    debugPrint("Loading older conversations...");
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF2E7D32), // اللون الأخضر المميز لتطبيقك
                          size: 20,
                        ),
                        SizedBox(width: 6),
                        Text(
                          "LOAD OLDER CONVERSATIONS",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ويدجت مخصصة لبناء كارت الشات الموحد تماماً كالصورة
  Widget _buildHistoryCard(ChatHistoryItem item) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الـ Leading Icon أو الـ Profile Image مع نقطة أونلاين خضراء
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: item.iconBgColor,
                child: item.isProfileImage
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(26),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&q=80&w=200', // صورة افتراضية للمدرب
                          fit: BoxFit.cover,
                          width: 52,
                          height: 52,
                          errorBuilder: (context, error, stackTrace) => Icon(item.icon, color: Colors.grey),
                        ),
                      )
                    : Icon(item.icon, color: item.iconColor, size: 24),
              ),
              if (item.isProfileImage) // النقطة الخضراء في الصورة الأولى للمدرب المتاح
                Positioned(
                  bottom: 1,
                  right: 1,
                  child: Container(
                    width: 11,
                    height: 11,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // تفاصيل النصوص والـ Tags
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      item.date,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                
                // كبسولة الـ Tag الملونة (Advice / Nutrition / General)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.tagBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.tag,
                    style: TextStyle(
                      color: item.tagColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}