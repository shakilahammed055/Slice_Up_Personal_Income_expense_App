import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';

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
  void toggleFriendSelection(int index) async {
    if (index < 0 || index >= friends.length) return;

    final friend = friends[index];
    final RxBool friendIsSelected = friend['isSelected'] as RxBool;
    final String memberEmail = (friend['email'] ?? '').toString();

    // If currently selected -> user is trying to deselect (i.e., remove member)
    if (friendIsSelected.value == true) {
      // Check outstanding debts/settlements for this member
      final bool hasDebts = await _checkMemberHasOutstandingDebts(memberEmail);

      final ctx = Get.context;
      if (ctx == null) {
        debugPrint('toggleFriendSelection: Get.context is null');
        return;
      }

      if (hasDebts) {
        // Show dialog: can't remove yet (single 'Okay' button)
        showCupertinoDialog(
          // ignore: use_build_context_synchronously
          context: ctx,
          builder: (BuildContext context) => ConfirmationDialog(
            title: 'You can’t remove them or leave this group just yet'.tr,
            content:
                'You can only remove them or leave the group after all debts are settled or they (or you) are no longer part of any shared expenses'.tr
                    .tr,
            button1: 'Okay'.tr,
            singleButton: true,
            onConfirm: () {},
          ),
        );
        return;
      }

      // No debts -> show confirmation with Yes/No
      showCupertinoDialog(
        // ignore: use_build_context_synchronously
        context: ctx,
        builder: (BuildContext context) => ConfirmationDialog(
          title:
              'Are you sure you want to remove them or leave the group yourself?'
                  .tr,
          content: '',
          button1: 'No'.tr,
          button2: 'Yes'.tr,
          singleButton: false,
          onConfirm: () async {
            // Call API to remove member
            final success = await removeMemberFromGroup(memberEmail);
            if (success) {
              // Update local list: remove the member entry
              friends.removeAt(index);
              _friendSelectionController?.updateSelectedFriends(friends);
              Get.snackbar('Success'.tr, 'Member removed'.tr);
            }
          },
        ),
      );
      return;
    }

    // Otherwise, simply toggle selection on (select to add)
    friendIsSelected.toggle();
    _friendSelectionController?.updateSelectedFriends(friends);
  }

  /// Calls the remove member API to delete a member from the group.
  /// Returns true on success, false otherwise.
  Future<bool> removeMemberFromGroup(String memberEmail) async {
    try {
      if (groupId.isEmpty) {
        debugPrint('removeMemberFromGroup: groupId empty');
        return false;
      }

      // Try StorageService first, fallback to AuthService
      String? token = StorageService.token;
      if (token == null || token.isEmpty) {
        token = await AuthService.getApprovalToken();
      }

      if (token == null || token.isEmpty) {
        Get.snackbar('Error', 'Authentication token not found');
        return false;
      }

      final apiUrl = Urls.removeMember(groupId, memberEmail);
      debugPrint('DELETE remove member API: $apiUrl');

      var request = http.Request('DELETE', Uri.parse(apiUrl));
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'text/plain',
      });

      // Body not required but keeping as in example (sanity)
      request.body = '';

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint('removeMemberFromGroup status: ${response.statusCode}');
      debugPrint('removeMemberFromGroup body: $responseBody');

      if (response.statusCode == 200) {
        return true;
      } else {
        try {
          final decoded = json.decode(responseBody);
          Get.snackbar('Error', decoded['message'] ?? response.reasonPhrase);
        } catch (e) {
          Get.snackbar('Error', response.reasonPhrase ?? 'Failed');
        }
        return false;
      }
    } catch (e) {
      debugPrint('removeMemberFromGroup exception: $e');
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  /// Returns true if the given member email has unsettled debts in this group.
  Future<bool> _checkMemberHasOutstandingDebts(String memberEmail) async {
    try {
      if (memberEmail.isEmpty) return false;

      String? token = StorageService.token;
      if (token == null || token.isEmpty) {
        token = await AuthService.getApprovalToken();
      }
      if (token == null || token.isEmpty) return false;

      final url = Urls.getSliceUp(groupId);
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      http.StreamedResponse response = await request.send();
      final resp = await response.stream.bytesToString();
      if (response.statusCode != 200) return false;

      final decoded = json.decode(resp);
      final data = decoded['data'];
      if (data == null) return false;

      // Check settlements list
      if (data is Map && data['settlements'] is List) {
        final List settlements = data['settlements'];
        for (var s in settlements) {
          if (s is Map) {
            final from = (s['from'] ?? '').toString();
            final to = (s['to'] ?? '').toString();
            final amount = (s['amount'] ?? 0);
            if ((from == memberEmail || to == memberEmail) && (amount != 0)) {
              return true;
            }
          }
        }
      }

      // Check total balances
      if (data is Map && data['totalBalances'] is List) {
        final List totals = data['totalBalances'];
        for (var t in totals) {
          if (t is Map) {
            final email = (t['memberEmail'] ?? '').toString();
            final net = (t['netBalance'] ?? 0);
            if (email == memberEmail && (net != 0)) return true;
          }
        }
      }

      // Fallback: if data is a List and contains entries involving the member
      if (data is List) {
        for (var entry in data) {
          if (entry is Map) {
            final from = (entry['from'] ?? '').toString();
            final to = (entry['to'] ?? '').toString();
            final amount = (entry['amount'] ?? 0);
            if ((from == memberEmail || to == memberEmail) && (amount != 0)) {
              return true;
            }
          }
        }
      }

      return false;
    } catch (e) {
      debugPrint('_checkMemberHasOutstandingDebts error: $e');
      return false;
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
