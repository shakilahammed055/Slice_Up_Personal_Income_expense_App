// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:dio/dio.dart' as dio;
// import 'package:teddy_5618/core/Urls/endpoint.dart';
// import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';

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
//   final FocusNode focusNode = FocusNode();
//   final dio.Dio _dio = dio.Dio();

//   @override
//   void onInit() {
//     super.onInit();
//     debugPrint('ChatController: onInit started');
//     updateTime();
//     _fetchChatHistory();
//     focusNode.addListener(_onFocusChange);
//     debugPrint('ChatController: onInit completed');
//   }

//   @override
//   void onClose() {
//     debugPrint('ChatController: onClose started');
//     messageController.dispose();
//     scrollController.dispose();
//     focusNode.dispose();
//     focusNode.removeListener(_onFocusChange);
//     super.onClose();
//     debugPrint('ChatController: onClose completed');
//   }

//   void _onFocusChange() {
//     debugPrint('ChatController: _onFocusChange - hasFocus: ${focusNode.hasFocus}');
//     if (focusNode.hasFocus) {
//       Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
//     }
//   }

//   void updateTime() {
//     debugPrint('ChatController: updateTime called');
//     final now = DateTime.now();
//     currentTime.value = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
//     debugPrint('ChatController: Time updated to ${currentTime.value}');
//     Future.delayed(const Duration(seconds: 60), updateTime);
//   }

//   Future<void> _fetchChatHistory() async {
//     debugPrint('ChatController: _fetchChatHistory started');
//     try {
//       debugPrint('ChatController: Awaiting getUserId...');
//       String? userId = await AuthService.getUserId();
//       debugPrint('ChatController: getUserId result: $userId');
//       if (userId == null || userId.isEmpty) {
//         debugPrint('ChatController: No userId found - skipping fetch or handle auth error');
//         // Optional: Get.snackbar('Error', 'Please log in to view chat history');
//         return; // Or fallback to default messages
//       }

//       debugPrint('ChatController: Making API GET request with userId: $userId');
//       final response = await _dio.get(
//         Urls.gethistory,
//         queryParameters: {'userId': userId},
//       );

//       debugPrint('ChatController: API response status: ${response.statusCode}');
//       debugPrint('ChatController: API response data: ${response.data}');

//       if (response.statusCode == 200) {
//         final List<dynamic> historyData = response.data;
//         debugPrint('ChatController: Processing ${historyData.length} history items');
//         List<ChatMessage> chatMessages = [];

//         for (int i = 0; i < historyData.length; i++) {
//           var item = historyData[i];
//           debugPrint('ChatController: Processing item $i: $item');
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
//           debugPrint('ChatController: Added messages for item $i');
//         }

//         // Sort by createdAt ascending (time wise)
//         chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
//         debugPrint('ChatController: Sorted ${chatMessages.length} messages');

//         messages.value = chatMessages;
//         debugPrint('ChatController: Updated messages observable with ${messages.length} items');
//       }
//     } catch (e) {
//       debugPrint('ChatController: Error fetching chat history: $e');
//       // Fallback to default messages if API fails
//       debugPrint('ChatController: Adding fallback messages');
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
//           text: 'Alright, Ill remind you on May 27th — so you dont "accidentally" blow it all on takeout again. 💸🏠',
//           isUser: false,
//           createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
//         ),
//       ]);
//       debugPrint('ChatController: Fallback messages added');
//     }
//     debugPrint('ChatController: _fetchChatHistory completed');
//   }

//   Future<void> sendMessage() async {
//     debugPrint('ChatController: sendMessage started');
//     final text = messageController.text.trim();
//     debugPrint('ChatController: Message text: $text');
//     if (text.isEmpty) {
//       debugPrint('ChatController: Empty message, returning early');
//       return;
//     }

//     final userMessage = ChatMessage(
//       text: text,
//       isUser: true,
//       createdAt: DateTime.now(),
//     );
//     debugPrint('ChatController: Created userMessage: ${userMessage.text}');

//     // Add user message
//     messages.add(userMessage);
//     debugPrint('ChatController: Added userMessage to messages (${messages.length} total)');
//     messageController.clear();
//     debugPrint('ChatController: Cleared messageController');

//     try {
//       debugPrint('ChatController: Awaiting getProfileId...');
//       String? profileId = await AuthService.getUserId();
//       debugPrint('ChatController: getProfileId result: $profileId');
//       debugPrint('ChatController: Awaiting getAssistantType...');
//       String? assistantType = await AuthService.getAssistantType();
//       debugPrint('ChatController: getAssistantType result: $assistantType');
//       if (profileId == null || profileId.isEmpty) {
//         debugPrint('ChatController: No profileId found - using fallback');
//         profileId = ''; // Or handle error
//       }

//       final requestBody = {
//         'message': text,
//         'user_id': profileId,
//         "assistant_type": assistantType ?? 'null',
//       };
//       debugPrint('ChatController: Request body: $requestBody');

//       debugPrint('ChatController: Making API POST request');
//       final response = await _dio.post(
//         'https://ai.thesliceup.com/chat/',
//         data: requestBody,
//       );

//       debugPrint('ChatController: API response status: ${response.statusCode}');
//       debugPrint('ChatController: API response data: ${response.data}');

//       if (response.statusCode == 200) {
//         // Assuming response has 'assistant' field for the reply
//         final assistantText = response.data['assistant'] ?? response.data['response'] ?? 'I got your message!';
//         debugPrint('ChatController: Assistant text: $assistantText');
//         final assistantMessage = ChatMessage(
//           text: assistantText,
//           isUser: false,
//           createdAt: DateTime.now(),
//         );
//         messages.add(assistantMessage);
//         debugPrint('ChatController: Added assistantMessage to messages (${messages.length} total)');
//       } else {
//         // Fallback response on error
//         debugPrint('ChatController: Non-200 status, using fallback response');
//         final assistantMessage = ChatMessage(
//           text: 'Sorry, I encountered an error processing your message.',
//           isUser: false,
//           createdAt: DateTime.now(),
//         );
//         messages.add(assistantMessage);
//         debugPrint('ChatController: Added fallback assistantMessage');
//       }
//     } catch (e) {
//       debugPrint('ChatController: Error sending message: $e');
//       // Fallback response on error
//       debugPrint('ChatController: Using fallback response due to exception');
//       final assistantMessage = ChatMessage(
//         text: 'Sorry, I encountered an error processing your message.',
//         isUser: false,
//         createdAt: DateTime.now(),
//       );
//       messages.add(assistantMessage);
//       debugPrint('ChatController: Added exception fallback assistantMessage');
//     }

//     debugPrint('ChatController: Calling scrollToBottom');
//     scrollToBottom();
//     debugPrint('ChatController: sendMessage completed');
//   }

//   void scrollToBottom() {
//     debugPrint('ChatController: scrollToBottom called');
//     if (scrollController.hasClients) {
//       debugPrint('ChatController: Scroll controller has clients, animating to bottom');
//       scrollController.animateTo(
//         scrollController.position.minScrollExtent,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeOut,
//       );
//     } else {
//       debugPrint('ChatController: Scroll controller has no clients, skipping animation');
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime createdAt;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.createdAt,
  });
}

class ChatController extends GetxController {
  final messageController = TextEditingController();
  var messages = <ChatMessage>[].obs;
  var currentTime = ''.obs;
  var historyCount = 0.obs; // New observable for historyCount
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();
  final dio.Dio _dio = dio.Dio();

  @override
  void onInit() {
    super.onInit();
    debugPrint('ChatController: onInit started');
    updateTime();
    _fetchChatHistory();
    focusNode.addListener(_onFocusChange);
    debugPrint('ChatController: onInit completed');
  }

  @override
  void onClose() {
    debugPrint('ChatController: onClose started');
    messageController.dispose();
    scrollController.dispose();
    focusNode.dispose();
    focusNode.removeListener(_onFocusChange);
    super.onClose();
    debugPrint('ChatController: onClose completed');
  }

  void _onFocusChange() {
    debugPrint(
      'ChatController: _onFocusChange - hasFocus: ${focusNode.hasFocus}',
    );
    if (focusNode.hasFocus) {
      Future.delayed(const Duration(milliseconds: 300), scrollToBottom);
    }
  }

  void updateTime() {
    debugPrint('ChatController: updateTime called');
    final now = DateTime.now();
    currentTime.value = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    debugPrint('ChatController: Time updated to ${currentTime.value}');
    Future.delayed(const Duration(seconds: 60), updateTime);
  }

  // Future<void> _fetchChatHistory() async {
  //   debugPrint('ChatController: _fetchChatHistory started');
  //   try {
  //     debugPrint('ChatController: Awaiting getUserId...');
  //     String? userId = await AuthService.getUserId();
  //     debugPrint('ChatController: getUserId result: $userId');
  //     if (userId == null || userId.isEmpty) {
  //       debugPrint(
  //         'ChatController: No userId found - skipping fetch or handle auth error',
  //       );
  //       // Optional: Get.snackbar('Error', 'Please log in to view chat history');
  //       return; // Or fallback to default messages
  //     }

  //     debugPrint('ChatController: Making API GET request with userId: $userId');
  //     final response = await _dio.get(
  //       Urls.gethistory,
  //       queryParameters: {'userId': userId},
  //     );

  //     debugPrint('ChatController: API response status: ${response.statusCode}');
  //     debugPrint('ChatController: API response data: ${response.data}');

  //     if (response.statusCode == 200) {
  //       final responseData = response.data;
  //       final List<dynamic> historyData = responseData['data'];
  //       historyCount.value =
  //           responseData['historyCount'] ?? 0; // Store historyCount
  //       debugPrint(
  //         'ChatController: Processing ${historyData.length} history items, historyCount: ${historyCount.value}',
  //       );
  //       List<ChatMessage> chatMessages = [];

  //       for (int i = 0; i < historyData.length; i++) {
  //         var item = historyData[i];
  //         debugPrint('ChatController: Processing item $i: $item');
  //         final humanMessage = ChatMessage(
  //           text: item['human'] ?? '',
  //           isUser: true,
  //           createdAt: DateTime.parse(item['createdAt']),
  //         );
  //         final assistantMessage = ChatMessage(
  //           text: item['assistant'] ?? '',
  //           isUser: false,
  //           createdAt: DateTime.parse(item['createdAt']),
  //         );

  //         chatMessages.add(humanMessage);
  //         chatMessages.add(assistantMessage);
  //         debugPrint('ChatController: Added messages for item $i');
  //       }

  //       // Sort by createdAt ascending (time wise)
  //       chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
  //       debugPrint('ChatController: Sorted ${chatMessages.length} messages');

  //       messages.value = chatMessages;
  //       debugPrint(
  //         'ChatController: Updated messages observable with ${messages.length} items',
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint('ChatController: Error fetching chat history: $e');
  //     // Fallback to default messages if API fails
  //     debugPrint('ChatController: Adding fallback messages');
  //     messages.addAll([
  //       ChatMessage(
  //         text: 'Show me all coffee expense in Apr',
  //         isUser: true,
  //         createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
  //       ),
  //       ChatMessage(
  //         text:
  //             'Ok, seems you are caffeine addictive.\n5 Apr coffee S\$4\n5 Apr coffee S\$6\n5 Apr coffee S\$7\n5 Apr coffee S\$8\n5 Apr coffee S\$4\n5 Apr coffee S\$5\n5 Apr coffee S\$6',
  //         isUser: false,
  //         createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
  //       ),
  //       ChatMessage(
  //         text: 'Remind me to pay rent 27th May',
  //         isUser: true,
  //         createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
  //       ),
  //       ChatMessage(
  //         text:
  //             'Alright, Ill remind you on May 27th — so you dont "accidentally" blow it all on takeout again. 💸🏠',
  //         isUser: false,
  //         createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
  //       ),
  //     ]);
  //     debugPrint('ChatController: Fallback messages added');
  //   }
  //   debugPrint('ChatController: _fetchChatHistory completed');
  // }
  Future<void> _fetchChatHistory() async {
  debugPrint('ChatController: _fetchChatHistory started');
  try {
    debugPrint('ChatController: Awaiting getUserId...');
    String? userId = await AuthService.getUserId();
    debugPrint('ChatController: getUserId result: $userId');
    
    if (userId == null || userId.isEmpty) {
      debugPrint('ChatController: No userId found - skipping fetch or handle auth error');
      // Optional: Get.snackbar('Error', 'Please log in to view chat history');
      return; // Or fallback to default messages
    }

    debugPrint('ChatController: Making API GET request with userId: $userId');
    final response = await _dio.get(
      Urls.gethistory,
      queryParameters: {'userId': userId},
    );
    
    debugPrint('ChatController: API response status: ${response.statusCode}');
    debugPrint('ChatController: API response data: ${response.data}');
    
    if (response.statusCode == 200) {
      final responseData = response.data;
      debugPrint('ChatController: Response data received: $responseData');
      
      final List<dynamic> historyData = responseData['data'];
      historyCount.value = responseData['historyCount'] ?? 0; // Store historyCount
      debugPrint('ChatController: Processing ${historyData.length} history items, historyCount: ${historyCount.value}');
      
      List<ChatMessage> chatMessages = [];
      
      for (int i = 0; i < historyData.length; i++) {
        var item = historyData[i];
        debugPrint('ChatController: Processing item $i: $item');
        
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
        debugPrint('ChatController: Added messages for item $i');
      }

      // Sort by createdAt ascending (time wise)
      chatMessages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      debugPrint('ChatController: Sorted ${chatMessages.length} messages');
      
      messages.value = chatMessages;
      debugPrint('ChatController: Updated messages observable with ${messages.length} items');
    }
  } catch (e) {
    debugPrint('ChatController: Error fetching chat history: $e');
    
    // Fallback to default messages if API fails
    debugPrint('ChatController: Adding fallback messages');
    messages.addAll([
      ChatMessage(
        text: 'Show me all coffee expense in Apr',
        isUser: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      ChatMessage(
        text:
            'Ok, seems you are caffeine addictive.\n5 Apr coffee S\$4\n5 Apr coffee S\$6\n5 Apr coffee S\$7\n5 Apr coffee S\$8\n5 Apr coffee S\$4\n5 Apr coffee S\$5\n5 Apr coffee S\$6',
        isUser: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      ChatMessage(
        text: 'Remind me to pay rent 27th May',
        isUser: true,
        createdAt: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
      ChatMessage(
        text:
            'Alright, Ill remind you on May 27th — so you dont "accidentally" blow it all on takeout again. 💸🏠',
        isUser: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
    ]);
    debugPrint('ChatController: Fallback messages added');
  }
  
  debugPrint('ChatController: _fetchChatHistory completed');
}


  Future<void> sendMessage() async {
    debugPrint('ChatController: sendMessage started');
    final text = messageController.text.trim();
    debugPrint('ChatController: Message text trimmed: "$text"');
    if (text.isEmpty) {
      debugPrint('ChatController: Message is empty, returning early');
      return;
    }
    debugPrint('ChatController: Message is not empty, proceeding');

    // Check subscription status and history count
    debugPrint(
      'ChatController: Checking subscription status and history count',
    );
    bool isSubscribed = await AuthService.isSubscribed();
    debugPrint('ChatController: isSubscribed value: $isSubscribed');
    debugPrint('ChatController: Current historyCount: ${historyCount.value}');
    if (!isSubscribed && historyCount.value >= 99) {
      debugPrint(
        'ChatController: User not subscribed and historyCount >= 99, blocking API call',
      );
      debugPrint('ChatController: Showing subscription required snackbar');
      Get.snackbar(
        'Subscription Required',
        'Please subscribe to continue sending messages after reaching the chat history limit of 99.',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 5),
      );
      debugPrint('ChatController: Snackbar displayed, returning early');
      return;
    }
    debugPrint(
      'ChatController: Subscription check passed, proceeding with API call',
    );

    debugPrint('ChatController: Creating user message');
    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      createdAt: DateTime.now(),
    );
    debugPrint(
      'ChatController: User message created: text="${userMessage.text}", isUser=${userMessage.isUser}, createdAt=${userMessage.createdAt}',
    );

    debugPrint('ChatController: Adding user message to messages list');
    messages.add(userMessage);
    debugPrint(
      'ChatController: User message added, total messages: ${messages.length}',
    );
    debugPrint('ChatController: Clearing message controller text');
    messageController.clear();
    debugPrint('ChatController: Message controller cleared');

    try {
      debugPrint('ChatController: Fetching profileId from AuthService');
      String? profileId = await AuthService.getUserId();
      debugPrint('ChatController: ProfileId fetched: $profileId');
      debugPrint('ChatController: Fetching assistantType from AuthService');
      String? assistantType = await AuthService.getAssistantType();
      debugPrint('ChatController: AssistantType fetched: $assistantType');
      if (profileId == null || profileId.isEmpty) {
        debugPrint(
          'ChatController: ProfileId is null or empty, setting fallback to empty string',
        );
        profileId = '';
      }
      debugPrint('ChatController: Using profileId: $profileId');

      debugPrint('ChatController: Creating request body for API call');
      final requestBody = {
        'message': text,
        'user_id': profileId,
        'assistant_type': assistantType ?? 'null',
      };
      debugPrint('ChatController: Request body created: $requestBody');

      debugPrint(
        'ChatController: Making API POST request to https://ai.thesliceup.com/chat/',
      );
      final response = await _dio.post(
        'https://ai.thesliceup.com/chat/',
        data: requestBody,
      );
      debugPrint('ChatController: API POST request completed');
      debugPrint(
        'ChatController: API response status code: ${response.statusCode}',
      );
      debugPrint('ChatController: API response data: ${response.data}');

      if (response.statusCode == 200) {
        debugPrint(
          'ChatController: API response status is 200, processing response',
        );
        final assistantText =
            response.data['assistant'] ??
            response.data['response'] ??
            'I got your message!';
        debugPrint('ChatController: Assistant response text: "$assistantText"');
        debugPrint('ChatController: Creating assistant message');
        final assistantMessage = ChatMessage(
          text: assistantText,
          isUser: false,
          createdAt: DateTime.now(),
        );
        debugPrint(
          'ChatController: Assistant message created: text="${assistantMessage.text}", isUser=${assistantMessage.isUser}, createdAt=${assistantMessage.createdAt}',
        );
        debugPrint('ChatController: Adding assistant message to messages list');
        messages.add(assistantMessage);
        debugPrint(
          'ChatController: Assistant message added, total messages: ${messages.length}',
        );
        debugPrint('ChatController: Incrementing historyCount');
        historyCount.value += 1;
        debugPrint(
          'ChatController: historyCount incremented to: ${historyCount.value}',
        );
      } else {
        debugPrint(
          'ChatController: API response status is not 200, using fallback response',
        );
        debugPrint('ChatController: Creating fallback assistant message');
        final assistantMessage = ChatMessage(
          text: 'Sorry, I encountered an error processing your message.',
          isUser: false,
          createdAt: DateTime.now(),
        );
        debugPrint(
          'ChatController: Fallback assistant message created: text="${assistantMessage.text}", isUser=${assistantMessage.isUser}, createdAt=${assistantMessage.createdAt}',
        );
        debugPrint(
          'ChatController: Adding fallback assistant message to messages list',
        );
        messages.add(assistantMessage);
        debugPrint(
          'ChatController: Fallback assistant message added, total messages: ${messages.length}',
        );
      }
    } catch (e) {
      debugPrint('ChatController: Exception caught during API call: $e');
      debugPrint(
        'ChatController: Creating exception fallback assistant message',
      );
      final assistantMessage = ChatMessage(
        text: 'Sorry, I encountered an error processing your message.',
        isUser: false,
        createdAt: DateTime.now(),
      );
      debugPrint(
        'ChatController: Exception fallback assistant message created: text="${assistantMessage.text}", isUser=${assistantMessage.isUser}, createdAt=${assistantMessage.createdAt}',
      );
      debugPrint(
        'ChatController: Adding exception fallback assistant message to messages list',
      );
      messages.add(assistantMessage);
      debugPrint(
        'ChatController: Exception fallback assistant message added, total messages: ${messages.length}',
      );
    }

    debugPrint('ChatController: Calling scrollToBottom');
    scrollToBottom();
    debugPrint('ChatController: sendMessage completed');
  }

  void scrollToBottom() {
    debugPrint('ChatController: scrollToBottom called');
    if (scrollController.hasClients) {
      debugPrint(
        'ChatController: Scroll controller has clients, animating to bottom',
      );
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      debugPrint(
        'ChatController: Scroll controller has no clients, skipping animation',
      );
    }
  }
}
