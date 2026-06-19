import 'package:bite_smart/features/home/screens/chatHistoryScreen.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bite_smart/features/home/data/repositories/coach_repository.dart';

class AiChatScreen extends StatefulWidget {
  final String? chatId;
  const AiChatScreen({super.key, this.chatId});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;
  bool _isLoadingHistory = false;
  String? _activeChatId;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _activeChatId = widget.chatId;
    if (_activeChatId != null) {
      _loadHistory();
    } else {
      _messages.add({
        "text":
            "أهلاً بك في Bite Smart Coach! كيف يمكنني مساعدتك في نظامك الغذائي اليوم؟ 🍏",
        "isSender": false,
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoadingHistory = true;
    });
    try {
      final history = await context.read<ICoachRepository>().getChatHistory(
        _activeChatId!,
      );
      setState(() {
        _messages.clear();
        for (var msg in history) {
          _messages.add({"text": msg.content, "isSender": msg.isUser});
        }
        _isLoadingHistory = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoadingHistory = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to load history: $e")));
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _messageController.clear();
    _focusNode.requestFocus();

    setState(() {
      _messages.add({"text": text, "isSender": true});
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final repo = context.read<ICoachRepository>();
      final result = await repo.sendCoachMessage(
        message: text,
        chatId: _activeChatId,
      );

      final replyText = result['reply'] as String;
      final returnedChatId = result['chatId'] as String?;

      if (returnedChatId != null && returnedChatId.isNotEmpty) {
        _activeChatId = returnedChatId;
      }

      setState(() {
        _isLoading = false;
        _messages.add({"text": replyText, "isSender": false});
      });
    } catch (e) {
      debugPrint("Coach Send Error: $e");
      _addErrorMessage();
    }

    _scrollToBottom();
  }

  void _addErrorMessage() {
    setState(() {
      _isLoading = false;
      _messages.add({
        "text": "حدث خطأ في الاتصال. يرجى المحاولة مرة أخرى.",
        "isSender": false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF8),
      body: GestureDetector(
        onTap: () => _focusNode.requestFocus(),
        behavior: HitTestBehavior.translucent,
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: _isLoadingHistory
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF388E3C),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _buildChatBubble(
                          msg["text"]! as String,
                          msg["isSender"] as bool,
                        );
                      },
                    ),
            ),
            if (_isLoading) _buildTypingIndicator(),
            _buildMessageInputField(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              radius: 18,
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFF388E3C),
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Diet Coach",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Online",
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Spacer(),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu, color: Colors.black, size: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 4,
              onSelected: (value) {
                final isArabic =
                    EasyLocalization.of(context)?.locale.languageCode == 'ar';
                if (value == 'new_chat') {
                  setState(() {
                    _activeChatId = null;
                    _messages.clear();
                    _messages.add({
                      "text": isArabic
                          ? "أهلاً بك في Bite Smart Coach! كيف يمكنني مساعدتك في نظامك الغذائي اليوم؟ 🍏"
                          : "Welcome to Bite Smart Coach! How can I help you with your nutrition today? 🍏",
                      "isSender": false,
                    });
                  });
                } else if (value == 'history') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatHistoryScreen(),
                    ),
                  ).then((returnedData) async {
                    if (returnedData is String && returnedData.isNotEmpty) {
                      setState(() {
                        _activeChatId = returnedData;
                        _isLoadingHistory = true;
                      });
                      _loadHistory();
                    } else {
                      // Returned via back button/gesture
                      // Verify if our current active chat session was deleted
                      if (_activeChatId != null) {
                        try {
                          final repo = context.read<ICoachRepository>();
                          final sessions = await repo.getCoachSessions();
                          final exists = sessions.any(
                            (s) => s.id == _activeChatId,
                          );
                          if (!exists) {
                            setState(() {
                              _activeChatId = null;
                              _messages.clear();
                              _messages.add({
                                "text": isArabic
                                    ? "أهلاً بك في Bite Smart Coach! كيف يمكنني مساعدتك في نظامك الغذائي اليوم؟ 🍏"
                                    : "Welcome to Bite Smart Coach! How can I help you with your nutrition today? 🍏",
                                "isSender": false,
                              });
                            });
                          }
                        } catch (e) {
                          debugPrint("Error checking session existence: $e");
                        }
                      }
                    }
                  });
                }
              },
              itemBuilder: (BuildContext context) {
                final isArabic =
                    EasyLocalization.of(context)?.locale.languageCode == 'ar';
                return [
                  PopupMenuItem<String>(
                    value: 'new_chat',
                    child: Row(
                      mainAxisAlignment: isArabic
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isArabic)
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF388E3C),
                            size: 18,
                          ),
                        if (!isArabic) const SizedBox(width: 8),
                        Text(
                          isArabic ? "محادثة جديدة" : "New Chat",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isArabic) const SizedBox(width: 8),
                        if (isArabic)
                          const Icon(
                            Icons.chat_bubble_outline,
                            color: Color(0xFF388E3C),
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                  PopupMenuItem<String>(
                    value: 'history',
                    child: Row(
                      mainAxisAlignment: isArabic
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!isArabic)
                          const Icon(
                            Icons.history,
                            color: Colors.black54,
                            size: 18,
                          ),
                        if (!isArabic) const SizedBox(width: 8),
                        Text(
                          isArabic ? "سجل المحادثات" : "Chat History",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (isArabic) const SizedBox(width: 8),
                        if (isArabic)
                          const Icon(
                            Icons.history,
                            color: Colors.black54,
                            size: 18,
                          ),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  TextDirection _getTextDirection(String text) {
    final arabicRegex = RegExp(
      r'[\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF]',
    );
    if (arabicRegex.hasMatch(text)) {
      return TextDirection.rtl;
    }
    return TextDirection.ltr;
  }

  Widget _buildChatBubble(String text, bool isSender) {
    final textDirection = _getTextDirection(text);
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFF388E3C) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSender ? 16 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5),
          ],
        ),
        child: Text(
          text,
          textDirection: textDirection,
          style: TextStyle(
            color: isSender ? Colors.white : const Color(0xFF111827),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "AI Coach is thinking",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            SizedBox(width: 8),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF388E3C),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInputField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: "Ask about your meal or diet...",
                    hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                    border: InputBorder.none,
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: _sendMessage,
              child: const CircleAvatar(
                backgroundColor: Color(0xFF388E3C),
                radius: 22,
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
