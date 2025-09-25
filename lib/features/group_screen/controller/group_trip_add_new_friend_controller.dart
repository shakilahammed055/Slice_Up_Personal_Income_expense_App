import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';

class GroupTripAddNewFriendController extends GetxController {
  // Observable list to hold the names of selected friends
  final RxList<String> selectedFriendNames = <String>[].obs;
  final RxList<Map<String, dynamic>> allFriends = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;

  // Current trip info for API calls
  String? currentTripName;
  String? currentTripId;

  // A list of predefined colors for avatars (can be extended)
  final List<Color> avatarColors = [
    Colors.cyan,
    Colors.purple[200]!,
    Colors.orange[300]!,
    Colors.green[300]!,
    Colors.blue[300]!,
    Colors.red[300]!,
  ];

  @override
  void onInit() {
    super.onInit();
    // Fetch all friends from API
    fetchAllFriendsFromAPI();
  }

  // Set the current trip (simplified since we're using specific group API)
  void setCurrentTrip(String tripName, {String? tripId}) {
    currentTripName = tripName;
    currentTripId = tripId;
    // No need to fetch trip members since we're using the specific addGroupMember API
  }

  // Fetch trip members from API using getGroupTransactions
  Future<void> fetchTripMembersFromAPI(String tripId) async {
    try {
      isLoading.value = true;

      String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        return;
      }

      var headers = {'Authorization': token, 'Content-Type': 'text/plain'};

      // Use dynamic getGroupTransactions API with the specific tripId
      var request = http.Request(
        'GET',
        Uri.parse(Urls.getGroupTransactions(tripId)),
      );
      request.body =
          '''//Query Parameters\r\n//expenseView=involving_me_only\r\n//transactionType=i_borrowed | i_lent\r\n//search=Transport''';
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // Extract group members from the response
        if (jsonResponse['data'] != null &&
            jsonResponse['data']['group'] != null) {
          var groupData = jsonResponse['data']['group'];
          List<dynamic> groupMembers = groupData['groupMembers'] ?? [];
          String ownerEmail = groupData['ownerEmail'] ?? '';

          List<String> memberNames = [];

          // Add owner first if exists
          if (ownerEmail.isNotEmpty) {
            String ownerName = ownerEmail.split('@')[0];
            memberNames.add(ownerName);
          }

          // Add other group members
          for (var memberEmail in groupMembers) {
            if (memberEmail != ownerEmail) {
              // Avoid duplicate owner
              String memberName = memberEmail.split('@')[0];
              memberNames.add(memberName);
            }
          }

          selectedFriendNames.assignAll(memberNames);
        }
      } else {
        // If no members found, that's okay - start with empty list
        selectedFriendNames.clear();
      }
    } catch (e) {
      selectedFriendNames.clear();
    } finally {
      isLoading.value = false;
    }
  }

  // Save trip members to API
  Future<void> saveTripMembersToAPI(
    String tripId,
    List<String> friendNames,
  ) async {
    try {
      String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        return;
      }

      // Get friend IDs from names
      List<String> friendIds = [];
      for (String friendName in friendNames) {
        for (var friend in allFriends) {
          if (friend['name'] == friendName) {
            friendIds.add(friend['id']);
            break;
          }
        }
      }

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var request = http.Request(
        'POST',
        Uri.parse(Urls.addGroupExpense(tripId)),
      );
      request.body = json.encode({'tripId': tripId, 'memberIds': friendIds});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ignore: unused_local_variable
        String responseBody = await response.stream.bytesToString();
      } else {
        // ignore: unused_local_variable
        String errorBody = await response.stream.bytesToString();
      }
      // ignore: empty_catches
    } catch (e) {}
  }

  // Fetch all friends from API
  Future<void> fetchAllFriendsFromAPI() async {
    try {
      isLoading.value = true;

      // Get token from AuthService
      String? token = await AuthService.getApprovalToken();

      if (token == null || token.isEmpty) {
        return;
      }

      var headers = {'Authorization': token};
      var request = http.Request('GET', Uri.parse(Urls.allfriends));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        // Debug print
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        if (jsonResponse['data'] != null) {
          List<dynamic> friendsData = jsonResponse['data'];
          allFriends.clear();

          for (var friend in friendsData) {
            allFriends.add({
              'id': friend['_id'] ?? '',
              'name':
                  friend['name'] ??
                  friend['email']?.split('@')[0] ??
                  'Unknown Friend',
              'email': friend['email'] ?? '',
            });
          }
        }
      } else {
        // ignore: unused_local_variable
        String errorBody = await response.stream.bytesToString();
        // Debug print
      }
    } catch (e) {
      // Debug print
    } finally {
      isLoading.value = false;
    }
  }

  // This method will be called by GroupTripAddNewFriendBottom when a friend is selected/deselected
  void updateSelectedFriends(List<Map<String, dynamic>> friendsData) {
    List<String> newSelectedFriends = [];

    for (var friend in friendsData) {
      if (friend['isSelected'] is RxBool &&
          friend['isSelected'].value == true) {
        newSelectedFriends.add(friend['name'] as String);
      }
    }

    selectedFriendNames.assignAll(newSelectedFriends);
  }

  // Add selected friends manually (for confirmation)
  void addSelectedFriends(List<String> friendNames) {
    for (String friendName in friendNames) {
      if (!selectedFriendNames.contains(friendName)) {
        selectedFriendNames.add(friendName);
      }
    }
    // No need to save to API here since it's handled by the bottom sheet controller
  }

  // Remove a friend from selected list
  void removeFriend(String friendName) {
    selectedFriendNames.remove(friendName);
  }

  // Clear all selected friends
  void clearSelectedFriends() {
    selectedFriendNames.clear();
  }

  // Get a color for an avatar based on its index
  Color getAvatarColor(int index) {
    return avatarColors[index % avatarColors.length];
  }

  // Refresh friends data
  Future<void> refreshFriends() async {
    await fetchAllFriendsFromAPI();
  }
}
