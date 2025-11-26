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

  // Observable list to hold group members with full details
  final RxList<Map<String, dynamic>> groupMembers =
      <Map<String, dynamic>>[].obs;

  // When true, local members were just updated from a successful add
  // and we should be careful not to overwrite them with a stale
  // getGroupMembers response that may not yet include the new members.
  final RxBool hasFreshLocalMembers = false.obs;

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
    // If the same tripId is being set repeatedly, skip redundant work
    if (tripId != null && tripId.isNotEmpty && tripId == currentTripId) {
      // already set for this tripId; nothing to do
      return;
    }

    currentTripName = tripName;
    currentTripId = tripId;

    // Automatically fetch trip members when trip is set (only for new tripId)
    if (tripId != null && tripId.isNotEmpty) {
      // We are changing trip; clear any freshness flag so that
      // the first getGroupMembers for this trip can populate normally.
      hasFreshLocalMembers.value = false;
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
          List<Map<String, dynamic>> fetchedMembers = [];
          List<String> memberNames = [];

          // Only process members from the 'members' array in the response
          // Ignore the separate 'owner' field - owner is already included in 'members' with isOwner: true
          if (membersData is Map<String, dynamic>) {
            // Extract members array from the API response structure
            List<dynamic> members =
                membersData['members'] ?? membersData['groupMembers'] ?? [];

            // Get total members count from the response
            int totalMembers = membersData['totalMembers'] ?? members.length;

            debugPrint("📊 Total members from API: $totalMembers");

            // Process each member from the members array only
            for (var member in members) {
              if (member is Map<String, dynamic>) {
                String email = member['email'] ?? '';
                String name = member['name'] ?? '';
                bool isOwner = member['isOwner'] ?? false;

                if (email.isNotEmpty) {
                  String initial = name.isNotEmpty
                      ? name[0].toUpperCase()
                      : email[0].toUpperCase();

                  fetchedMembers.add({
                    'email': email,
                    'name': name,
                    'initial': initial,
                    'isOwner': isOwner,
                  });
                  memberNames.add(name.isNotEmpty ? name : email);
                }
              }
            }
          } else if (membersData is List) {
            // Fallback: if data is directly a list of members
            for (var member in membersData) {
              if (member is Map<String, dynamic>) {
                String email = member['email'] ?? '';
                String name = member['name'] ?? '';
                bool isOwner = member['isOwner'] ?? false;

                if (email.isNotEmpty) {
                  String initial = name.isNotEmpty
                      ? name[0].toUpperCase()
                      : email[0].toUpperCase();

                  fetchedMembers.add({
                    'email': email,
                    'name': name,
                    'initial': initial,
                    'isOwner': isOwner,
                  });
                  memberNames.add(name.isNotEmpty ? name : email);
                }
              }
            }
          }

          debugPrint(
            "👥 Found ${fetchedMembers.length} members from 'members' array: $memberNames",
          );

          // If we already have locally fresh members from a recent
          // addGroupMember call, avoid overwriting them with an API
          // response that still only contains the owner or fewer
          // members than we already display. This prevents the
          // "need to tap Add twice" behaviour.
          if (hasFreshLocalMembers.value &&
              fetchedMembers.length < groupMembers.length &&
              groupMembers.isNotEmpty) {
            debugPrint(
              "⚠️ Skipping overwrite of groupMembers with stale API response (fetched=${fetchedMembers.length}, local=${groupMembers.length})",
            );
            return;
          }

          groupMembers.assignAll(fetchedMembers);
          selectedFriendNames.assignAll(memberNames);
        } else {
          debugPrint("⚠️ No data field in response");
          groupMembers.clear();
          selectedFriendNames.clear();
        }
      } else {
        String errorBody = await response.stream.bytesToString();
        debugPrint("❌ Error response: ${response.statusCode} - $errorBody");
        // If no members found, that's okay - start with empty list
        groupMembers.clear();
        selectedFriendNames.clear();
      }
    } catch (e) {
      debugPrint("💥 Exception in fetchTripMembersFromAPI: $e");
      groupMembers.clear();
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

  // Get the initial letter from a member name/email
  String getMemberInitial(String? name, String? email) {
    if (name != null && name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    if (email != null && email.isNotEmpty) {
      return email[0].toUpperCase();
    }
    return '?';
  }

  // Get member by email (for uniqueness)
  Map<String, dynamic>? getMemberByEmail(String email) {
    try {
      return groupMembers.firstWhere((member) => member['email'] == email);
    } catch (e) {
      return null;
    }
  }

  // Get all member emails (unique identifiers)
  List<String> getAllMemberEmails() {
    return groupMembers.map((member) => member['email'] as String).toList();
  }

  // Add or update members locally based on their email and name so that
  // UI avatars can update immediately after adding, without waiting for
  // the backend getGroupMembers response to reflect the change.
  void upsertMembersFromEmails(List<Map<String, String>> membersToAdd) {
    // Mark that local members are now the freshest source of truth
    // so that a stale getGroupMembers response does not immediately
    // wipe them out.
    hasFreshLocalMembers.value = true;

    for (var member in membersToAdd) {
      final String email = member['email'] ?? '';
      final String name = member['name'] ?? '';

      if (email.isEmpty) {
        continue;
      }

      final int existingIndex = groupMembers.indexWhere(
        (m) => m['email'] == email,
      );

      final String initial = getMemberInitial(name, email);

      final Map<String, dynamic> newMember = {
        'email': email,
        'name': name,
        'initial': initial,
        'isOwner': false,
      };

      if (existingIndex >= 0) {
        groupMembers[existingIndex] = newMember;
      } else {
        groupMembers.add(newMember);
      }

      final String displayName = name.isNotEmpty ? name : email;
      if (!selectedFriendNames.contains(displayName)) {
        selectedFriendNames.add(displayName);
      }
    }
  }

  // Refresh friends data
  Future<void> refreshFriends() async {
    // Manual refresh should trust the API again.
    hasFreshLocalMembers.value = false;
    await refreshAllData();
  }
}
