import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:bite_smart/features/home/data/repositories/coach_repository.dart';
import 'package:bite_smart/features/home/data/models/coach_models.dart';
import 'package:bite_smart/features/home/screens/aiChatScreen.dart';

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
  bool _isLoading = false;
  List<CoachSessionModel> _sessions = [];
  String? _errorMessage;
  final List<String> _deletedSessionIds = [];

  @override
  void initState() {
    super.initState();
    _fetchSessions();
  }

  Future<void> _fetchSessions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final repo = context.read<ICoachRepository>();
      final sessions = await repo.getCoachSessions();
      setState(() {
        _sessions = sessions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  Future<void> _deleteSession(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Chat"),
        content: const Text("Are you sure you want to delete this chat session?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm == true) {
     try {
  setState(() {
    _sessions.removeWhere((session) => session.id == id);
  });

  await context.read<ICoachRepository>().deleteCoachSession(id);

  _deletedSessionIds.add(id);

  await Future.delayed(const Duration(seconds: 2));

  await _fetchSessions();
} catch (e) {
  debugPrint("DELETE ERROR: $e");

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Failed to delete chat: $e")),
  );
}
     
    }
  }

  Color _getTagColor(String category) {
    switch (category) {
      case 'Advice':
        return const Color(0xFF2F80ED);
      case 'Nutrition':
        return const Color(0xFF9A8446);
      default:
        return const Color(0xFF666666);
    }
  }

  Color _getTagBgColor(String category) {
    switch (category) {
      case 'Advice':
        return const Color(0xFFE2EEFF);
      case 'Nutrition':
        return const Color(0xFFF4EED9);
      default:
        return const Color(0xFFEAEAEA);
    }
  }

  IconData _getTagIcon(String category) {
    switch (category) {
      case 'Advice':
        return Icons.person;
      case 'Nutrition':
        return Icons.eco_rounded;
      default:
        return Icons.chat_bubble_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showLoadMore = _sessions.length > 4;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E7D32)))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
                : _sessions.isEmpty
                    ? const Center(child: Text("No chat history found"))
                    : Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _sessions.length,
                              itemBuilder: (context, index) {
                                final session = _sessions[index];
                                return _buildHistoryCard(session);
                              },
                            ),
                          ),
                          if (showLoadMore)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24.0, top: 8.0),
                              child: InkWell(
                                onTap: () {
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
                                        color: Color(0xFF2E7D32),
                                        size: 20,
                                      ),
                                      Spacer(),
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

  Widget _buildHistoryCard(CoachSessionModel session) {
    final String category = session.category;
    final Color tagColor = _getTagColor(category);
    final Color tagBgColor = _getTagBgColor(category);
    final IconData icon = _getTagIcon(category);
    final Color iconBgColor = const Color(0xFFE8F5E9);
    final Color iconColor = const Color(0xFF2E7D32);
    final String formattedDate = "${session.updatedAt.day}/${session.updatedAt.month}/${session.updatedAt.year}";

    return GestureDetector(
      onTap: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context, session.id);
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AiChatScreen(chatId: session.id),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
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
            CircleAvatar(
              radius: 26,
              backgroundColor: iconBgColor,
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          session.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 6),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => _deleteSession(session.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Tap to open this session",
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: tagBgColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: tagColor,
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
      ),
    );
  }
}