// import 'package:get/get.dart';
// import 'package:flutter/material.dart';

// class AddFriendsController extends GetxController {
//   // Observable list to hold the emails of added friends.
//   // .obs makes it reactive, so any UI widget wrapped in Obx/GetBuilder
//   // will rebuild when this list changes.
//   final RxList<String> addedFriends = <String>[].obs;

//   // TextEditingController for the email input field.
//   final TextEditingController emailTextController = TextEditingController();

//   final FocusNode emailFocusNode = FocusNode();

//   /// Regular expression for email validation.
//   // Using a more robust regex for email validation
//   static final RegExp _emailRegex = RegExp(
//     r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
//   );

//   /// Adds an email to the [addedFriends] list if it's valid and not already present.
//   void addFriend() {
//     final email = emailTextController.text
//         .trim(); // Get text and remove leading/trailing spaces

//     if (email.isEmpty) {
//       Get.snackbar(
//         'Empty Email'.tr,
//         'Please enter an email address.'.tr,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.orangeAccent,
//         colorText: Colors.white,
//       );
//       return; // Stop execution
//     }

//     if (!_emailRegex.hasMatch(email)) {
//       Get.snackbar(
//         'Invalid Email'.tr,
//         'Please enter a valid email address.'.tr,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return; // Stop execution
//     }

//     if (addedFriends.contains(email)) {
//       Get.snackbar(
//         'Duplicate Email'.tr,
//         '$email is already added!',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Colors.redAccent,
//         colorText: Colors.white,
//       );
//       return; // Stop execution
//     }

//     addedFriends.add(email); // Add the email to the observable list
//     emailTextController.clear(); // Clear the text field after adding
//   }

//   /// Removes a specified email from the [addedFriends] list.
//   void removeFriend(String email) {
//     addedFriends.remove(email);
//   }

//   /// Returns the list of added friends for passing to another screen.
//   List<String> getFriendsToInvite() {
//     return addedFriends.toList(); // Return a copy of the list
//   }

//   @override
//   void onInit() {
//     super.onInit();

//     // Auto request focus after a short delay so the sheet animation completes
//     Future.delayed(const Duration(milliseconds: 10), () {
//       emailFocusNode.requestFocus();
//     });
//   }
//   // ignore: annotate_overrides
//   void onClose() {
//     // Dispose the TextEditingController to prevent memory leaks
//     emailTextController.dispose();
//      emailFocusNode.dispose();
//     super.onClose();
//   }
// }

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Add http package for API calls
import 'dart:convert'; // Add for jsonEncode
import 'package:flutter_easyloading/flutter_easyloading.dart'; // Add for loading indicators

import 'package:teddy_5618/core/Urls/endpoint.dart'; // Your API URLs
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart'; // Your AuthService to get the token

class AddFriendsController extends GetxController {
  // Observable list to hold the emails of added friends.
  final RxList<String> addedFriends = <String>[].obs;

  // TextEditingController for the email input field.
  final TextEditingController emailTextController = TextEditingController();

  final FocusNode emailFocusNode = FocusNode();

  /// Regular expression for email validation.
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  /// Adds an email to the [addedFriends] list if it's valid and not already present.
  void addFriend() {
    final email = emailTextController.text.trim();

    if (email.isEmpty) {
      Get.snackbar(
        'Empty Email'.tr,
        'Please enter an email address.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (!_emailRegex.hasMatch(email)) {
      Get.snackbar(
        'Invalid Email'.tr,
        'Please enter a valid email address.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (addedFriends.contains(email)) {
      Get.snackbar(
        'Duplicate Email'.tr,
        '$email is already added!'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return;
    }

    addedFriends.add(email);
    emailTextController.clear();
  }

  /// Removes a specified email from the [addedFriends] list.
  void removeFriend(String email) {
    addedFriends.remove(email);
  }

  /// Returns the list of added friends.
  List<String> getFriendsToInvite() {
    return addedFriends.toList();
  }

  // --- NEW METHOD TO SEND INVITATIONS VIA API ---
  Future<void> inviteFriends() async {
    final friendsToInvite = getFriendsToInvite();

    // 1. Check if the list is empty
    if (friendsToInvite.isEmpty) {
      Get.snackbar(
        'No Emails Added'.tr,
        'Please add at least one email to invite.'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blueAccent,
        colorText: Colors.white,
      );
      return;
    }

    EasyLoading.show(status: 'Sending Invites...'.tr);

    try {
      // 2. Get the authentication token
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }

      // 3. Prepare the request using http.Request to match your example
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var request = http.Request('POST', Uri.parse(Urls.addmultiplefriends));

      // Convert the list of email strings to the required JSON format: `[{"email": "..."}]`
      final List<Map<String, String>> bodyList = friendsToInvite
          .map((email) => {'email': email})
          .toList();

      request.body = json.encode(bodyList);
      request.headers.addAll(headers);

      // 4. Make the POST request
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: unused_local_variable
        String responseBody = await response.stream.bytesToString();
        // Debug print

        EasyLoading.showSuccess('Invitations sent successfully!'.tr);
        // If successful, close the bottom sheet and pass the list of friends back
        Get.back(result: friendsToInvite);
      } else {
        String errorBody = await response.stream.bytesToString();
        // Debug print

        // Try to parse error message
        try {
          final Map<String, dynamic> errorData = jsonDecode(errorBody);
          throw Exception(
            errorData['message'] ?? 'Failed to send invitations.'.tr,
          );
        } catch (e) {
          throw Exception(
            'Failed to send invitations: ${response.reasonPhrase}',
          );
        }
      }
    } catch (e) {
      // Handle any exceptions (network errors, token not found, etc.)
      EasyLoading.showError(e.toString());
    } finally {
      // Ensure the loading indicator is always dismissed
      EasyLoading.dismiss();
    }
  }

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100), () {
      emailFocusNode.requestFocus();
    });
  }

  @override
  void onClose() {
    emailTextController.dispose();
    emailFocusNode.dispose();
    super.onClose();
  }
}
