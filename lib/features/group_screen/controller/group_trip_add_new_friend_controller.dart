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

  // Method to refresh both friends and trip members data
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchAllFriendsFromAPI(),
      if (currentTripId != null && currentTripId!.isNotEmpty)
        fetchTripMembersFromAPI(currentTripId!),
    ]);
  }

  // Set the current trip and fetch its members
  void setCurrentTrip(String tripName, {String? tripId}) {
    currentTripName = tripName;
    currentTripId = tripId;

    // Automatically fetch trip members when trip is set
    if (tripId != null && tripId.isNotEmpty) {
      fetchTripMembersFromAPI(tripId);
    }
  }

  // Fetch trip members from API using getGroupMembers
  Future<void> fetchTripMembersFromAPI(String tripId) async {
    try {
      isLoading.value = true;
      debugPrint("🔄 Fetching trip members for tripId: $tripId");

      String? token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint("❌ No auth token available");
        return;
      }

      var headers = {'Authorization': token};

      // Use getGroupMembers API with the specific tripId
      var request = http.Request(
        'GET',
        Uri.parse(Urls.getGroupMembers(tripId)),
      );
      request.headers.addAll(headers);

      debugPrint("🌐 Making request to: ${Urls.getGroupMembers(tripId)}");
      http.StreamedResponse response = await request.send();

      debugPrint("📡 Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        debugPrint("📦 Response body: $responseBody");
        Map<String, dynamic> jsonResponse = json.decode(responseBody);

        // Extract group members from the response
        if (jsonResponse['data'] != null) {
          var membersData = jsonResponse['data'];
          List<String> memberNames = [];

          // Handle different response structures
          if (membersData is List) {
            // If data is directly a list of members
            for (var member in membersData) {
              String memberName = '';
              if (member is Map<String, dynamic>) {
                memberName =
                    member['name'] ??
                    member['email']?.split('@')[0] ??
                    'Unknown Member';
              } else if (member is String) {
                memberName = member.contains('@')
                    ? member.split('@')[0]
                    : member;
              }
              if (memberName.isNotEmpty) {
                memberNames.add(memberName);
              }
            }
          } else if (membersData is Map<String, dynamic>) {
            // If data contains nested member information
            List<dynamic> members =
                membersData['members'] ?? membersData['groupMembers'] ?? [];

            for (var member in members) {
              String memberName = '';
              if (member is Map<String, dynamic>) {
                memberName =
                    member['name'] ??
                    member['email']?.split('@')[0] ??
                    'Unknown Member';
              } else if (member is String) {
                memberName = member.contains('@')
                    ? member.split('@')[0]
                    : member;
              }
              if (memberName.isNotEmpty) {
                memberNames.add(memberName);
              }
            }
          }

          debugPrint("👥 Found ${memberNames.length} members: $memberNames");
          selectedFriendNames.assignAll(memberNames);
        } else {
          debugPrint("⚠️ No data field in response");
          selectedFriendNames.clear();
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        debugPrint("❌ Error response: ${response.statusCode} - $errorBody");
        // If no members found, that's okay - start with empty list
        selectedFriendNames.clear();
      }
    } catch (e) {
      debugPrint("💥 Exception in fetchTripMembersFromAPI: $e");
      selectedFriendNames.clear();
    } finally {
      isLoading.value = false;
      debugPrint("✅ Finished fetching trip members");
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
        Uri.parse(Urls.addGroupMember(tripId)),
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
    await refreshAllData();
  }
}
