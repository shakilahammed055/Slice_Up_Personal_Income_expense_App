import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatController extends GetxController {
  final messageController = TextEditingController();
  var messages = <ChatMessage>[].obs;
  var currentTime = ''.obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    updateTime();
    // Initialize with some default messages
    messages.addAll([
      ChatMessage(
        text: 'Show me all coffee expense in Apr',
        isUser: true,
      ),
      ChatMessage(
        text: 'Ok, seems you are caffeine addictive.\n5 Apr coffee S\$4\n5 Apr coffee S\$6\n5 Apr coffee S\$7\n5 Apr coffee S\$8\n5 Apr coffee S\$4\n5 Apr coffee S\$5\n5 Apr coffee S\$6',
        isUser: false,
      ),
      ChatMessage(
        text: 'Remind me to pay rent 27th May',
        isUser: true,
      ),
      ChatMessage(
        text: 'Alright, I’ll remind you on May 27th — so you don’t “accidentally” blow it all on takeout again. 💸🏠',
        isUser: false,
      ),
    ]);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void updateTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    Future.delayed(const Duration(seconds: 60), updateTime);
  }

  void sendMessage() {
    if (messageController.text.trim().isEmpty) return;

    // Add user message
    messages.add(ChatMessage(text: messageController.text, isUser: true));

    // Simulate bot response
    final userMessage = messageController.text.toLowerCase();
    String botResponse = 'I got your message!';

    if (userMessage.contains('coffee')) {
      botResponse = 'Checking coffee expenses... Looks like you spent a lot on caffeine! ☕';
    } else if (userMessage.contains('rent')) {
      botResponse = 'Noted! I’ll remind you about the rent. 🏠';
    }

    Future.delayed(const Duration(seconds: 1), () {
      messages.add(ChatMessage(text: botResponse, isUser: false));
      _scrollToBottom();
    });

    messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}