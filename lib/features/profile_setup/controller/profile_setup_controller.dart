
// controller/profile_setup_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';

// --- ADD THESE IMPORTS ---
import 'dart:convert'; // For jsonEncode
import 'package:http/http.dart' as http; // For making the HTTP request
import 'package:teddy_5618/core/Urls/endpoint.dart'; // Your URLs class

class ProfileController extends GetxController {
  final RxString name = ''.obs;
  final RxBool isButtonEnabled = false.obs;
  final isNameFocused = false.obs;

  void onNameFocusChange(bool hasFocus) {
    isNameFocused.value = hasFocus;
  }

  void updateName(String value) {
    name.value = value;
    isButtonEnabled.value = value.trim().isNotEmpty;
  }

  Future<void> onNextPressed() async {
  // ADDED DEBUG PRINT
  debugPrint(
    '--- "Finish" button pressed, starting onNextPressed method ---',
  );

  if (!isButtonEnabled.value) {
    return;
  }

  Get.dialog(
    const Center(child: CircularProgressIndicator()),
    barrierDismissible: false,
  );

  try {
    // 1. Get the approval token
    debugPrint(
      'Attempting to get approval token from AuthService...',
    ); // UPDATED DEBUG PRINT
    final String? approvalToken = await AuthService.getApprovalToken();

    // ADDED a detailed print to show the exact value of the approval token
    debugPrint('>>> Retrieved approval token value: "$approvalToken"');

    if (approvalToken == null || approvalToken.isEmpty) {
      // Also check if it's an empty string
      // ADDED DEBUG PRINT
      debugPrint(
        '!!! APPROVAL TOKEN IS NULL OR EMPTY. Throwing "Authentication token not found" exception.',
      );
      throw Exception('Authentication token not found.');
    }

    debugPrint('Approval token found. Proceeding with API call.'); // UPDATED DEBUG PRINT
    final Uri url = Uri.parse(Urls.updateprofile);

    // 2. Prepare headers and body
    final Map<String, String> headers = {
      'Authorization': approvalToken, // Use approvalToken instead of token
      'Content-Type': 'application/json',
    };
    final String body = jsonEncode({'name': name.value.trim()});

    // 3. Make the PATCH request
    final http.Response response = await http.patch(
      url,
      headers: headers,
      body: body,
    );

    // 4. Close the loading dialog
    Get.back();

    // 5. Handle the response
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    if (response.statusCode == 200 && responseData['success'] == true) {
      Get.snackbar(
        'Success',
        'Your name has been updated!',
        snackPosition: SnackPosition.TOP,
      );
      Get.offAll(() => BottomNavbarView());
    } else {
      throw Exception(responseData['message'] ?? 'Failed to update profile.');
    }
  } catch (e) {
    // 6. Handle any errors
    // ADDED DEBUG PRINT to see the exact error caught
    debugPrint('XXX Error caught in onNextPressed: ${e.toString()}');

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
    Get.snackbar(
      'Update Failed',
      e.toString(),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
}
