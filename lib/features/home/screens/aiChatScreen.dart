import 'dart:convert';
import 'package:bite_smart/features/home/screens/chatHistoryScreen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  bool _isLoading = false;

  final List<Map<String, dynamic>> _apiHistory = [];  
  final List<Map<String, dynamic>> _messages = [];

  // ✅ حط الـ Gemini API Key هنا (من aistudio.google.com مجاناً)
  static const String _apiKey = ""; // 👈 غيّر ده بس
  static const String _model = "gemini-1.5-flash";
  static const String _systemPrompt =
      "أنت خبير تغذية ذكي ومساعد لتطبيق يدعى Bite Smart. "
      "مهمتك هي الإجابة على أسئلة المستخدمين بخصوص السعرات الحرارية، "
      "تنظيم الوجبات، والتخسيس أو زيادة الوزن بطريقة ودية، سريعة ومختصرة. "
      "رد دايماً بالعربي إلا لو المستخدم كتب بلغة تانية.";

  String get _apiUrl =>
      "https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent?key=$_apiKey";

  @override
  void initState() {
    super.initState();
    _messages.add({
      "text": "أهلاً بك في Bite Smart Coach! كيف يمكنني مساعدتك في نظامك الغذائي اليوم؟ 🍏",
      "isSender": false,
    });
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
      _apiHistory.add({
        "role": "user",
        "parts": [{"text": text}]
      });
      _isLoading = true;
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "system_instruction": {
            "parts": [{"text": _systemPrompt}]
          },
          "contents": _apiHistory,
          "generationConfig": {
            "maxOutputTokens": 1024,
            "temperature": 0.7,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final replyText =
            data["candidates"][0]["content"]["parts"][0]["text"] as String;

        _apiHistory.add({
          "role": "model",
          "parts": [{"text": replyText}]
        });

        setState(() {
          _isLoading = false;
          _messages.add({"text": replyText, "isSender": false});
        });
      } else {
        debugPrint("Gemini Error: ${response.statusCode} - ${response.body}");
        _addErrorMessage();
      }
    } catch (e) {
      debugPrint("Network Error: $e");
      _addErrorMessage();
    }

    _scrollToBottom();
  }

  void _addErrorMessage() {
    setState(() {
      _isLoading = false;
      _messages.add({
        "text": "حدث خطأ في الاتصال. تأكد من الـ API Key واتصالك بالإنترنت.",
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
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(
                      msg["text"]! as String, msg["isSender"] as bool);
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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.black, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            const CircleAvatar(
              backgroundColor: Color(0xFFE8F5E9),
              radius: 18,
              child: Icon(Icons.auto_awesome,
                  color: Color(0xFF388E3C), size: 18),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("AI Diet Coach",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.bold)),
                Text("Online",
                    style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
              ],
            ),
            Spacer(),
            IconButton(onPressed: ()=>Navigator.push(context,
               MaterialPageRoute(builder: (context) => const ChatHistoryScreen())
            ), icon: const Icon(Icons.menu, color: Colors.black, size: 20))
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isSender) {
    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isSender ? const Color(0xFF388E3C) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isSender ? 16 : 4),
            bottomRight: Radius.circular(isSender ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04), blurRadius: 5)
          ],
        ),
        child: Text(
          text,
          textDirection: TextDirection.rtl,
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
            borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text("AI Coach is thinking",
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            SizedBox(width: 8),
            SizedBox(
              width: 10,
              height: 10,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF388E3C)),
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
              offset: const Offset(0, -5))
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
                    borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: "Ask about your meal or diet...",
                    hintStyle:
                        TextStyle(color: Colors.grey, fontSize: 14),
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
                child: Icon(Icons.send_rounded,
                    color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}