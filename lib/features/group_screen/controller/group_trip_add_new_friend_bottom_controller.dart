// import 'package:get/get.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
// import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
// import 'package:teddy_5618/core/Urls/endpoint.dart';

// class GroupTripAddNewFriendBottomController extends GetxController {
//   final RxList<Map<String, dynamic>> friends = <Map<String, dynamic>>[].obs;
//   final RxList<Map<String, dynamic>> allFriendsFromAPI =
//       <Map<String, dynamic>>[].obs;
//   final RxBool isLoading = false.obs;
//   final RxInt currentFriendIndex = 0.obs;

//   GroupTripAddNewFriendController? _friendSelectionController;

//   @override
//   void onInit() {
//     super.onInit();
//     // Debug print

//     // Try to get the friend selection controller, create if not exists
//     try {
//       _friendSelectionController = Get.find<GroupTripAddNewFriendController>();
//       // Debug print
//     } catch (e) {
//       // Debug print
//       _friendSelectionController = Get.put(GroupTripAddNewFriendController());
//     }

//     // Fetch friends from API on initialization
//     fetchFriendsFromAPI();
//     // Listen for changes in the 'friends' list to update the main selection controller
//     ever(
//       friends,
//       (_) => _friendSelectionController?.updateSelectedFriends(friends),
//     );
//   }

//   // Fetch friends from API
//   Future<void> fetchFriendsFromAPI() async {
//     try {
//       isLoading.value = true;

//       // Get token from AuthService
//       String? token = await AuthService.getApprovalToken();
//       // Show first 20 chars for debugging

//       if (token == null || token.isEmpty) {
//         Get.snackbar('Error', 'Authentication token not found');
//         return;
//       }

//       var headers = {'Authorization': token};
//       var request = http.Request('GET', Uri.parse(Urls.allfriends));
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       String responseBody = await response.stream.bytesToString();

//       if (response.statusCode == 200) {
//         Map<String, dynamic> jsonResponse = json.decode(responseBody);

//         // Check if the response has data
//         if (jsonResponse['data'] != null) {
//           List<dynamic> friendsData = jsonResponse['data'];

//           allFriendsFromAPI.clear();
//           friends.clear(); // Clear the display list as well

//           for (var friend in friendsData) {
//             Map<String, dynamic> friendData = {
//               'id': friend['_id'] ?? '',
//               'name':
//                   friend['name'] ??
//                   friend['email']?.split('@')[0] ??
//                   'Unknown Friend',
//               'email': friend['email'] ?? '',
//               'isSelected': false.obs,
//             };

//             allFriendsFromAPI.add(friendData);
//             // Also add to the display list so they show up in the UI
//             friends.add(Map.from(friendData));
//           }

//         } else {
//         }
//       } else {
//         Get.snackbar(
//           'Error',
//           'Failed to fetch friends: ${response.reasonPhrase} (${response.statusCode})',
//         );
//       }
//     } catch (e) {
//       Get.snackbar('Error', 'An error occurred while fetching friends: $e');
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   void addFriend() {
//     // Since we now load all friends from API automatically,
//     // this method can be used to refresh the friends list
//     fetchFriendsFromAPI();
//   }

//   void toggleFriendSelection(int index) {
//     if (index >= 0 && index < friends.length) {
//       (friends[index]['isSelected'] as RxBool).toggle();
//       // After toggling, explicitly update the shared selection controller
//       _friendSelectionController?.updateSelectedFriends(friends);
//     }
//   }

//   // Method to handle the "Add" button confirmation
//   void confirmAddFriends(BuildContext context) {
//     try {
//       // Debug print
//       List<String> selectedFriendEmails = [];

//       // Debug print

//       // Process each friend safely and collect emails instead of names
//       for (int i = 0; i < friends.length; i++) {
//         try {
//           final friend = friends[i];
//           final isSelected = friend['isSelected'];
//           final email = friend['email']; // Get email instead of name

//           // Debug print

//           if (isSelected is RxBool && isSelected.value == true) {
//             selectedFriendEmails.add(email.toString());
//             // Debug print
//           }
//         // ignore: empty_catches
//         } catch (e) {
//         }
//       }

//       // Debug print

//       // Call API to add group members if friends are selected
//       if (selectedFriendEmails.isNotEmpty) {
//         addGroupMembersToAPI(selectedFriendEmails);
//       } else {
//         Get.snackbar(
//           'Info',
//           'No friends selected. Please select friends first by tapping the checkboxes.',
//           duration: Duration(seconds: 3),
//           backgroundColor: Colors.orange,
//           colorText: Colors.white,
//         );
//         return; // Don't close the sheet if no friends selected
//       }

//       // Debug print

//       // Close the modal bottom sheet properly using Navigator.pop
//       Navigator.of(context).pop();

//       // Debug print
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Something went wrong: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       // Even if there's an error, try to close the bottom sheet
//       try {
//         Navigator.of(context).pop();
//       // ignore: empty_catches
//       } catch (popError) {
//       }
//     }
//   }

//   // Add group members using the specific API
//   Future<void> addGroupMembersToAPI(List<String> memberEmails) async {
//     try {

//       String? token = await AuthService.getApprovalToken();
//       if (token == null || token.isEmpty) {
//         Get.snackbar('Error', 'Authentication token not found');
//         return;
//       }

//       var headers = {
//         'Authorization': token,
//         'Content-Type': 'application/json',
//       };

//       var request = http.Request('POST', Uri.parse(Urls.addGroupMember));
//       request.body = json.encode({"members": memberEmails});
//       request.headers.addAll(headers);

//       http.StreamedResponse response = await request.send();

//       if (response.statusCode == 200) {
//         // ignore: unused_local_variable
//         String responseBody = await response.stream.bytesToString();

//         // Update the main controller with selected friend names (convert emails to names)
//         List<String> selectedFriendNames = [];
//         for (String email in memberEmails) {
//           for (var friend in friends) {
//             if (friend['email'] == email) {
//               selectedFriendNames.add(friend['name']);
//               break;
//             }
//           }
//         }

//         if (_friendSelectionController != null &&
//             selectedFriendNames.isNotEmpty) {
//           _friendSelectionController!.addSelectedFriends(selectedFriendNames);
//           // Debug print
//         }

//         Get.snackbar(
//           'Success',
//           'Successfully added ${memberEmails.length} friend(s) to the group!',
//           duration: Duration(seconds: 3),
//           backgroundColor: Colors.green,
//           colorText: Colors.white,
//         );
//       } else {
//         // ignore: unused_local_variable
//         String errorBody = await response.stream.bytesToString();
//         Get.snackbar(
//           'Error',
//           'Failed to add friends to group: ${response.reasonPhrase}',
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//       }
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'An error occurred while adding friends: $e',
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//     }
//   }

//   // Method to refresh friends list
//   void refreshFriends() {
//     currentFriendIndex.value = 0;
//     friends.clear();
//     allFriendsFromAPI.clear();
//     fetchFriendsFromAPI();
//   }
// }

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';

class GroupTripAddNewFriendBottomController extends GetxController {
  // This will hold the ID of the group we are adding friends to.
  final String groupId;

  // The controller now requires a groupId when it is created.
  GroupTripAddNewFriendBottomController({required this.groupId});

  final RxList<Map<String, dynamic>> friends = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allFriendsFromAPI =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxInt currentFriendIndex = 0.obs;

  GroupTripAddNewFriendController? _friendSelectionController;

  @override
  void onInit() {
    super.onInit();
    debugPrint(
      "🚀 GroupTripAddNewFriendBottomController initialized for groupId: '$groupId'",
    );

    // Validate group ID
    if (groupId.isEmpty) {
      debugPrint("❌ ERROR: Empty group ID provided to controller!");
      Get.snackbar(
        'Error',
        'No group ID provided. Cannot add friends without a valid group.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      _friendSelectionController = Get.find<GroupTripAddNewFriendController>();
    } catch (e) {
      _friendSelectionController = Get.put(GroupTripAddNewFriendController());
    }

    fetchFriendsFromAPI();
    ever(
      friends,
      (_) => _friendSelectionController?.updateSelectedFriends(friends),
    );
  }

  // Fetch friends from the general friends list API
  Future<void> fetchFriendsFromAPI() async {
    try {
      isLoading.value = true;
      String? token = await AuthService.getApprovalToken();

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      var headers = {'Authorization': token};
      var request = http.Request('GET', Uri.parse(Urls.allfriends));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = json.decode(responseBody);
        if (jsonResponse['data'] != null) {
          List<dynamic> friendsData = jsonResponse['data'];

          allFriendsFromAPI.clear();
          friends.clear();

          for (var friend in friendsData) {
            Map<String, dynamic> friendData = {
              'id': friend['_id'] ?? '',
              'name':
                  friend['name'] ??
                  friend['email']?.split('@')[0] ??
                  'Unknown Friend',
              'email': friend['email'] ?? '',
              'isSelected': false.obs,
            };
            allFriendsFromAPI.add(friendData);
            friends.add(Map.from(friendData));
          }
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to fetch friends: ${response.reasonPhrase}',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred while fetching friends: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Toggles the selection state of a friend in the list
  void toggleFriendSelection(int index) {
    if (index >= 0 && index < friends.length) {
      (friends[index]['isSelected'] as RxBool).toggle();
      _friendSelectionController?.updateSelectedFriends(friends);
    }
  }

  // Handles the final confirmation and API call
  void confirmAddFriends(BuildContext context) {
    try {
      debugPrint("📝 Confirming friends for groupId: $groupId");

      List<String> selectedFriendEmails = friends
          .where((friend) => (friend['isSelected'] as RxBool).isTrue)
          .map((friend) => friend['email'].toString())
          .toList();

      debugPrint("👥 Selected friend emails: $selectedFriendEmails");

      if (selectedFriendEmails.isNotEmpty) {
        addGroupMembersToAPI(selectedFriendEmails);
      } else {
        Get.snackbar(
          'Info',
          'No friends selected.',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      Navigator.of(context).pop();
    } catch (e) {
      debugPrint("❌ Error in confirmAddFriends: $e");
      Get.snackbar(
        'Error',
        'Something went wrong: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Posts the selected friends to the group using the addGroupMember API endpoint
  Future<void> addGroupMembersToAPI(List<String> memberEmails) async {
    try {
      // Validate group ID first
      if (groupId.isEmpty) {
        debugPrint("❌ Cannot add group members: Empty group ID");
        Get.snackbar(
          'Error',
          'Invalid group ID. Cannot add friends to group.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint("📤 Adding members to group ID: '$groupId'");
      debugPrint("👥 Members to add: $memberEmails");

      String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // ✅ Using the addGroupExpense endpoint to add members to the group
      final apiUrl = Urls.addGroupMember(groupId);
      debugPrint("🌐 API URL: $apiUrl");

      var request = http.Request('POST', Uri.parse(apiUrl));

      // The body contains the group ID and members to be added
      request.body = json.encode({"groupId": groupId, "members": memberEmails});

      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        debugPrint("✅ Add Group Members Response: $responseBody");

        // Update the main controller with selected friend names
        List<String> selectedFriendNames = friends
            .where((friend) => (friend['isSelected'] as RxBool).isTrue)
            .map((friend) => friend['name'].toString())
            .toList();

        if (_friendSelectionController != null &&
            selectedFriendNames.isNotEmpty) {
          _friendSelectionController!.addSelectedFriends(selectedFriendNames);
        }

        Get.snackbar(
          'Success',
          'Successfully added ${memberEmails.length} friend(s) to the group!',
          duration: Duration(seconds: 3),
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        String errorBody = await response.stream.bytesToString();
        debugPrint("❌ Add Group Members Error: $errorBody");

        try {
          var decodedError = json.decode(errorBody);
          Get.snackbar(
            'Error',
            'Failed: ${decodedError['message'] ?? response.reasonPhrase}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (e) {
          Get.snackbar(
            'Error',
            'Failed to add friends to group: ${response.reasonPhrase}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint("❌ Add Group Members Exception: $e");
      Get.snackbar(
        'Error',
        'An error occurred while adding friends: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Helper methods
  void addFriend() => fetchFriendsFromAPI();
  void refreshFriends() => fetchFriendsFromAPI();
}
