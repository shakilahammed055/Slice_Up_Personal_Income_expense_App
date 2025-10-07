// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart' as dio;

// class ChatMessage {
//   final String text;
//   final bool isUser;
//   final DateTime createdAt;

//   ChatMessage({required this.text, required this.isUser, required this.createdAt});
// }

// class ChatController extends GetxController {
//   final messageController = TextEditingController();
//   var messages = <ChatMessage>[].obs;
//   var currentTime = ''.obs;
//   final ScrollController scrollController = ScrollController();
//   final dio.Dio _dio = dio.Dio();
//   final String userId = '68ce20c4d066875ce51cff64'; // Dynamic userId from auth

//   @override
//   void onInit() {
//     super.onInit();
//     updateTime();
//     _fetchChatHistory();
//   }

//   @override
//   void onClose() {
//     messageController.dispose();
//     scrollController.dispose();
//     super.onClose();
//   }

//   void updateTime() {
//     final now = DateTime.now();
//     currentTime.value = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
//     Future.delayed(const Duration(seconds: 60), updateTime);
//   }

//   Future<void> _fetchChatHistory() async {
//     try {
//       final response = await _dio.get(
//         'https://teddybackend-mivk.onrender.com/api/v1/history/get-history',
//         queryParameters: {'userId': userId},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> historyData = response.data;
//         List<ChatMessage> chatMessages = [];

//         for (var item in historyData) {
//           final humanMessage = ChatMessage(
//             text: item['human'] ?? '',
//             isUser: true,
//             createdAt: DateTime.parse(item['createdAt']),
//           );
//           final assistantMessage = ChatMessage(
//             text: item['assistant'] ?? '',
//             isUser: false,
//             createdAt: DateTime.parse(item['createdAt']),
//           );

//           chatMessages.add(humanMessage);
//           chatMessages.add(assistantMessage);
//         }

//         // Sort by createdAt ascending (time wise)
//         chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

//         messages.value = chatMessages;
//         _scrollToBottom();
//       }
//     } catch (e) {
//       debugPrint('Error fetching chat history: $e');
//       // Fallback to default messages if API fails
//       messages.addAll([
//         ChatMessage(
//           text: 'Show me all coffee expense in Apr',
//           isUser: true,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
//         ),
//         ChatMessage(
//           text: 'Ok, seems you are caffeine addictive.\n5 Apr coffee S\$4\n5 Apr coffee S\$6\n5 Apr coffee S\$7\n5 Apr coffee S\$8\n5 Apr coffee S\$4\n5 Apr coffee S\$5\n5 Apr coffee S\$6',
//           isUser: false,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
//         ),
//         ChatMessage(
//           text: 'Remind me to pay rent 27th May',
//           isUser: true,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
//         ),
//         ChatMessage(
//           text: 'Alright, I’ll remind you on May 27th — so you don’t “accidentally” blow it all on takeout again. 💸🏠',
//           isUser: false,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
//         ),
//       ]);
//     }
//   }

//   Future<void> sendMessage() async {
//     final text = messageController.text.trim();
//     if (text.isEmpty) return;

//     final userMessage = ChatMessage(
//       text: text,
//       isUser: true,
//       createdAt: DateTime.now(),
//     );

//     // Add user message
//     messages.add(userMessage);
//     messageController.clear();
//     _scrollToBottom();

//     try {
//       final requestBody = {
//         'message': text,
//         'user_id': userId,
//       };

//       final response = await _dio.post(
//         'https://sliceup-2-lpvh.onrender.com/chat/',
//         data: requestBody,
//       );

//       if (response.statusCode == 200) {
//         // Assuming response has 'assistant' field for the reply
//         final assistantText = response.data['assistant'] ?? response.data['response'] ?? 'I got your message!';
//         final assistantMessage = ChatMessage(
//           text: assistantText,
//           isUser: false,
//           createdAt: DateTime.now(),
//         );
//         messages.add(assistantMessage);
//         _scrollToBottom();
//       } else {
//         // Fallback response on error
//         final assistantMessage = ChatMessage(
//           text: 'Sorry, I encountered an error processing your message.',
//           isUser: false,
//           createdAt: DateTime.now(),
//         );
//         messages.add(assistantMessage);
//         _scrollToBottom();
//       }
//     } catch (e) {
//       debugPrint('Error sending message: $e');
//       // Fallback response on error
//       final assistantMessage = ChatMessage(
//         text: 'Sorry, I encountered an error processing your message.',
//         isUser: false,
//         createdAt: DateTime.now(),
//       );
//       messages.add(assistantMessage);
//       _scrollToBottom();
//     }
//   }

//   void _scrollToBottom() {
//     if (scrollController.hasClients) {
//       scrollController.animateTo(
//         scrollController.position.maxScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     }
//   }
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({required this.text, required this.isUser, required this.createdAt});
}

class ChatController extends GetxController {
  final messageController = TextEditingController();
  var messages = <ChatMessage>[].obs;
  var currentTime = ''.obs;
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final dio.Dio _dio = dio.Dio();
  final String userId = '68ce20c4d066875ce51cff64'; // Dynamic userId from auth

  @override
  void onInit() {
    super.onInit();
    updateTime();
    _fetchChatHistory();
    focusNode.addListener(_onFocusChange);
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    focusNode.removeListener(_onFocusChange);
    super.onClose();
  }

  void _onFocusChange() {
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
    }
  }

  void updateTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    Future.delayed(const Duration(seconds: 60), updateTime);
  }

  Future<void> _fetchChatHistory() async {
    try {
      final response = await _dio.get(
        'https://teddybackend-mivk.onrender.com/api/v1/history/get-history',
        queryParameters: {'userId': userId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> historyData = response.data;
        List<ChatMessage> chatMessages = [];

        for (var item in historyData) {
          final humanMessage = ChatMessage(
            text: item['human'] ?? '',
            isUser: true,
            createdAt: DateTime.parse(item['createdAt']),
          );
          final assistantMessage = ChatMessage(
            text: item['assistant'] ?? '',
            isUser: false,
            createdAt: DateTime.parse(item['createdAt']),
          );

          chatMessages.add(humanMessage);
          chatMessages.add(assistantMessage);
        }

        // Sort by createdAt ascending (time wise)
        chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

        messages.value = chatMessages;
      }
    } catch (e) {
      debugPrint('Error fetching chat history: $e');
      // Fallback to default messages if API fails
      messages.addAll([
        ChatMessage(
          text: 'Show me all coffee expense in Apr',
          isUser: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        ),
        ChatMessage(
          text: 'Ok, seems you are caffeine addictive.\n5 Apr coffee S\$4\n5 Apr coffee S\$6\n5 Apr coffee S\$7\n5 Apr coffee S\$8\n5 Apr coffee S\$4\n5 Apr coffee S\$5\n5 Apr coffee S\$6',
          isUser: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
        ),
        ChatMessage(
          text: 'Remind me to pay rent 27th May',
          isUser: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
        ),
        ChatMessage(
          text: 'Alright, Ill remind you on May 27th — so you dont "accidentally" blow it all on takeout again. 💸🏠',
          isUser: false,
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        ),
      ]);
    }
  }

  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );

    // Add user message
    messages.add(userMessage);
    messageController.clear();

    try {
      final requestBody = {
        'message': text,
        'user_id': userId,
      };

      final response = await _dio.post(
        'https://sliceup-2-lpvh.onrender.com/chat/',
        data: requestBody,
      );

      if (response.statusCode == 200) {
        // Assuming response has 'assistant' field for the reply
        final assistantText = response.data['assistant'] ?? response.data['response'] ?? 'I got your message!';
        final assistantMessage = ChatMessage(
          text: assistantText,
          isUser: false,
          createdAt: DateTime.now(),
        );
        messages.add(assistantMessage);
      } else {
        // Fallback response on error
        final assistantMessage = ChatMessage(
          text: 'Sorry, I encountered an error processing your message.',
          isUser: false,
          createdAt: DateTime.now(),
        );
        messages.add(assistantMessage);
      }
    } catch (e) {
      debugPrint('Error sending message: $e');
      // Fallback response on error
      final assistantMessage = ChatMessage(
        text: 'Sorry, I encountered an error processing your message.',
        isUser: false,
        createdAt: DateTime.now(),
      );
      messages.add(assistantMessage);
    }

    scrollToBottom();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}