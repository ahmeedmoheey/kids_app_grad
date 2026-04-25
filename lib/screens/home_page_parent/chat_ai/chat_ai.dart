import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_app_grad/utils/api_constants.dart';
import 'package:kids_app_grad/utils/assets_manager.dart';
import 'package:kids_app_grad/utils/colors_manager.dart';
import 'bot_message.dart';
import 'user_message.dart';
import 'bot_typing.dart';

class ChatAi extends StatefulWidget {
  const ChatAi({super.key});

  @override
  State<ChatAi> createState() => _ChatAiState();
}

class _ChatAiState extends State<ChatAi> {
  final TextEditingController controller = TextEditingController();
  final ScrollController scrollController = ScrollController();
  List<Map<String, String>> messages = [];
  bool isTyping = false;

  @override
  void initState() {
    super.initState();
    fetchChatHistory();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 300), () {
        scrollController.animateTo(scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      });
    }
  }

  Future<void> fetchChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.get(Uri.parse(ApiConstants.chatbotHistory),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List history = data['messages'] ?? [];
        setState(() {
          messages = history.map<Map<String, String>>((m) => {
                "role": m['role'] == 'user' ? 'user' : 'ai',
                "text": m['message'].toString()
              }).toList();
        });
        scrollToBottom();
      }
    } catch (e) {}
  }

  void sendMessage() async {
    String text = controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({"role": "user", "text": text});
      controller.clear();
      isTyping = true;
    });
    scrollToBottom();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      
      final response = await http.post(
        Uri.parse(ApiConstants.chatbotSend),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'message': text}), 
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // استخراج الرد بناءً على الـ JSON اللي بعتهولي بالظبط
        String reply = "...";
        if (data['message'] != null && data['message'] is Map) {
          reply = data['message']['message'] ?? "I am here!";
        } else if (data['reply'] != null) {
          reply = data['reply'];
        }

        setState(() {
          isTyping = false;
          messages.add({"role": "ai", "text": reply});
        });
      } else {
        setState(() => isTyping = false);
      }
    } catch (e) {
      setState(() => isTyping = false);
    }
    scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0.5,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.grey), onPressed: () => Navigator.pop(context)),
        title: Row(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(radius: 20.r, backgroundColor: ColorManager.ff, child: Icon(Icons.android, color: ColorManager.pinkk)),
                CircleAvatar(radius: 5.r, backgroundColor: Colors.green, child: Container()),
              ],
            ),
            SizedBox(width: 10.w),
            const Text("KidZoo Bot", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(image: AssetImage(AssetsManager.backGround), fit: BoxFit.cover, opacity: 0.4),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                itemCount: messages.length + (isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isTyping && index == messages.length) return const BotTyping();
                  final msg = messages[index];
                  return msg["role"] == "user" ? UserMessage(text: msg["text"]!) : BotMessage(text: msg["text"]!);
                },
              ),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.edit, color: Colors.blue, size: 20.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: TextField(
              controller: controller,
              onSubmitted: (_) => sendMessage(),
              decoration: const InputDecoration(hintText: "Ask Something...", border: InputBorder.none),
            ),
          ),
          IconButton(icon: Icon(Icons.send, color: ColorManager.pinkk), onPressed: sendMessage),
        ],
      ),
    );
  }
}
