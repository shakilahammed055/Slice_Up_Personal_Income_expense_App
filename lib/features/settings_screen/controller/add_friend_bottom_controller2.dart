import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AddFriendsController2 extends GetxController {

  final RxList<String> addedFriends = <String>[].obs;
  // TextEditingController for the email input field.
  final TextEditingController emailTextController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  static final RegExp _emailRegex = RegExp(
    r"^[a-zA-Z0-9.a-zA-Z0-9!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
  );

  /// Adds an email to the [addedFriends] list if it's valid and not already present.
  void addFriend() {
    final email = emailTextController.text
        .trim(); // Get text and remove leading/trailing spaces

    if (email.isEmpty) {
      Get.snackbar(
        'Empty Email',
        'Please enter an email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return; // Stop execution
    }

    if (!_emailRegex.hasMatch(email)) {
      Get.snackbar(
        'Invalid Email',
        'Please enter a valid email address.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return; // Stop execution
    }

    if (addedFriends.contains(email)) {
      Get.snackbar(
        'Duplicate Email',
        '$email is already added!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
      return; // Stop execution
    }

    addedFriends.add(email); // Add the email to the observable list
    emailTextController.clear(); // Clear the text field after adding
  }

  /// Removes a specified email from the [addedFriends] list.
  void removeFriend(String email) {
    addedFriends.remove(email);
  }

  /// Returns the list of added friends for passing to another screen.
  List<String> getFriendsToInvite() {
    return addedFriends.toList(); // Return a copy of the list
  }

  @override
    void onInit() {
    super.onInit();

    // Auto request focus after a short delay so the sheet animation completes
    Future.delayed(const Duration(milliseconds: 10), () {
      emailFocusNode.requestFocus();
    });
  }
  // ignore: annotate_overrides
  void onClose() {
    // Dispose the TextEditingController to prevent memory leaks
    emailTextController.dispose();
       emailFocusNode.dispose();
    super.onClose();
  }
}
