// // ignore_for_file: unnecessary_overrides

// import 'package:get/get.dart';

// class MyFriendBottomController extends GetxController {
//   // This is the reactive list that will hold the friends.
//   final RxList<String> friends = <String>[].obs;

//     RxList<String> get myFriends => friends;

//   // Method to receive the new list of friends and update the state.
//   void addFriends(List<String> newFriends) {
//     // This will replace the entire list. You could also use a loop
//     // to add them one by one if you want to check for duplicates.
//     friends.assignAll(newFriends);
//   }

//   // Method to remove a friend by email.
//   void removeFriend(String email) {
//     friends.remove(email);
//   }

//   @override
//   void onInit() {
//     super.onInit();
//     // You could load existing friends from a database or storage here
//     // when the controller is first created.
//   }
// }



import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';

class MyFriendBottomController extends GetxController {
  final RxList<String> friends = <String>[].obs;
  final RxBool isLoading = true.obs;

  RxList<String> get myFriends => friends;

  @override
  void onInit() {
    super.onInit();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      isLoading.value = true;
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }
      final Uri url = Uri.parse(Urls.allfriends);
      final Map<String, String> headers = {'Authorization': token};
      final http.Response response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final List<dynamic> friendsData = responseData['data'];
        final List<String> friendEmails = friendsData
            .map((friend) => friend['email'].toString())
            .toList();
        friends.assignAll(friendEmails);
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load friends'.tr);
      }
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --- MODIFIED METHOD TO MATCH YOUR NEW DELETE API ---
  Future<void> removeFriend(String email) async {
    EasyLoading.show(status: 'Removing...'.tr);
    try {
      // 1. Get the authentication token
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }

      // 2. Prepare the request URL by adding the email to the path
      // This is the main change to match your API
      final Uri url = Uri.parse('${Urls.allfriends}/$email');

      final Map<String, String> headers = {'Authorization': token};

      // 3. Make the DELETE request (no body is needed)
      final http.Response response = await http.delete(url, headers: headers);

      // 4. Handle the response
      if (response.statusCode == 200) {
        // If the API call is successful, remove the friend from the UI list
        friends.remove(email);
        EasyLoading.showSuccess('$email has been removed.');
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove friend.');
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }
}




