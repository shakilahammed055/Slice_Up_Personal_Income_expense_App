import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';

import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';

class TripController extends GetxController {
  final RxList<Trip> trips = <Trip>[].obs;
  final TextEditingController tripNameController = TextEditingController();
  final createTripFocusNode = FocusNode();
  final editTripFocusNode = FocusNode();
  final String currentDate = DateFormat('MMM yyyy').format(DateTime.now());

  // Add these variables for group updating
  final RxString currentGroupId = ''.obs;
  final RxBool isUpdating = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint("--- TripController Initialized ---");
    fetchTrips();
  }

  /// Fetches the list of all trips from the API and updates the local list.
  Future<void> fetchTrips() async {
    debugPrint("🚀 [FETCH] Starting to fetch trips...");
    EasyLoading.show(status: 'Loading Trips...'.tr);
    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }
      debugPrint("🔑 [FETCH] Token found.");

      final Uri url = Uri.parse(Urls.getallgroup);
      final Map<String, String> headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final http.Response response = await http.get(url, headers: headers);
      debugPrint("📈 [FETCH] API Response Status Code: ${response.statusCode}");
      debugPrint("📄 [FETCH] API Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // --- FIX: Access the list from responseData['data']['groups'] ---
        if (responseData['data'] == null ||
            responseData['data']['groups'] == null ||
            responseData['data']['groups'] is! List) {
          debugPrint(
            "⚠️ [FETCH] Warning: 'data.groups' key is not a List or is null in the response.",
          );
          debugPrint("📋 [FETCH] Full response data: $responseData");
          EasyLoading.dismiss();
          return;
        }

        final List<dynamic> tripListFromApi =
            responseData['data']['groups']; // <-- FIX
        debugPrint(
          "📦 [FETCH] Found ${tripListFromApi.length} groups in API response.",
        );

        // Parse aiData to create a map of groupId -> aiSummary for quick lookup
        final Map<String, String> aiSummaryMap = {};
        if (responseData['data']['aiData'] != null &&
            responseData['data']['aiData'] is List) {
          final List<dynamic> aiDataList = responseData['data']['aiData'];
          for (var aiData in aiDataList) {
            if (aiData['groupId'] != null && aiData['summary'] != null) {
              String fullSummary = aiData['summary'];
              // Extract only the relevant part after the group name prefix
              // Look for pattern like "💸 GroupName: " and extract what comes after
              String cleanSummary = _extractCleanSummary(fullSummary);
              aiSummaryMap[aiData['groupId'].toString()] = cleanSummary;
            }
          }
          debugPrint("🤖 [FETCH] Found ${aiSummaryMap.length} AI summaries");
        }

        // Log the first trip's structure for debugging
        if (tripListFromApi.isNotEmpty) {
          debugPrint(
            "🔍 [FETCH] First trip structure: ${tripListFromApi.first}",
          );
          debugPrint(
            "🔍 [FETCH] Available keys: ${tripListFromApi.first.keys.toList()}",
          );
        }

        if (tripListFromApi.isEmpty) {
          trips.clear();
          EasyLoading.dismiss();
          return;
        }

        final List<Trip> fetchedTrips = tripListFromApi.map((tripData) {
          debugPrint("🔍 [FETCH] Processing trip data: $tripData");

          // --- FIX: Use 'groupCreateDate' key for the date ---
          final String dateString =
              tripData['groupCreateDate'] ??
              tripData['createdAt'] ??
              DateTime.now().toIso8601String(); // <-- FIX
          final DateTime parsedDate = DateTime.parse(dateString);

          // Try multiple possible ID field names - prioritize groupId for API compatibility
          final tripId =
              tripData['groupId'] ??
              tripData['group_id'] ??
              tripData['id'] ??
              tripData['_id'];

          final tripName =
              tripData['groupName'] ?? tripData['name'] ?? 'Unnamed Trip';

          // Get AI summary for this trip
          final aiSummary =
              aiSummaryMap[tripId?.toString()] ??
              'Ready to track your group expenses!';

          debugPrint("🆔 [FETCH] Trip: '$tripName' with ID: '$tripId'");
          debugPrint("🤖 [FETCH] AI Summary: '$aiSummary'");
          debugPrint(
            "🔍 [FETCH] ID fields check: groupId=${tripData['groupId']}, group_id=${tripData['group_id']}, id=${tripData['id']}, _id=${tripData['_id']}",
          );

          if (tripId == null || tripId.toString().isEmpty) {
            debugPrint(
              "⚠️ [FETCH] Warning: Trip '$tripName' has null or empty ID!",
            );
            debugPrint(
              "⚠️ [FETCH] All available keys: ${tripData.keys.toList()}",
            );
          }

          return Trip(
            id: tripId?.toString(), // Ensure it's a string and handle null
            name: tripName,
            date: DateFormat('MMM yyyy').format(parsedDate),
            aiSummary: aiSummary,
          );
        }).toList();

        debugPrint(
          "✅ [FETCH] Successfully mapped ${fetchedTrips.length} trips.",
        );
        trips.assignAll(fetchedTrips);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch trips.'.tr);
      }
    } catch (e) {
      debugPrint("🔥 [FETCH] An error occurred: ${e.toString()}");
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  // No changes are needed for the addTrip method as it's working correctly.
  Future<void> addTrip() async {
    final tripName = tripNameController.text.trim();
    if (tripName.isEmpty) {
      Get.snackbar(
        'Trip Name Required'.tr,
        'Please enter a name for your trip'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }
    EasyLoading.show(status: 'Creating Trip...'.tr);
    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception(
          'Authentication token not found. Please log in again.'.tr,
        );
      }
      final Uri url = Uri.parse(Urls.creategroup);
      final Map<String, String> headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      final String body = jsonEncode({'groupName': tripName});
      final http.Response response = await http.post(
        url,
        headers: headers,
        body: body,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        debugPrint("📋 [CREATE] Full API response: $responseData");

        final newTripData = responseData['data'];
        debugPrint("🔍 [CREATE] Trip data from API: $newTripData");

        if (newTripData != null && newTripData is Map) {
          debugPrint(
            "🔍 [CREATE] Available keys in trip data: ${newTripData.keys.toList()}",
          );
        }

        final tripId =
            newTripData['groupId'] ??
            newTripData['group_id'] ??
            newTripData['id'] ??
            newTripData['_id'];
        final tripName = newTripData['groupName'] ?? newTripData['name'];

        debugPrint("🆔 [CREATE] New trip: '$tripName' with ID: '$tripId'");

        if (tripId == null || tripId.toString().isEmpty) {
          debugPrint("⚠️ [CREATE] Warning: New trip has null or empty ID!");
          debugPrint(
            "⚠️ [CREATE] Available ID fields: groupId=${newTripData['groupId']}, group_id=${newTripData['group_id']}, id=${newTripData['id']}, _id=${newTripData['_id']}",
          );
          debugPrint(
            "⚠️ [CREATE] All available keys: ${newTripData.keys.toList()}",
          );
        }

        final newTrip = Trip(
          id: tripId?.toString(), // Ensure it's a string and handle null
          name: tripName,
          date: currentDate,
          aiSummary:
              'Ready to track your group expenses!'.tr, // Default for new trips
        );
        trips.insert(0, newTrip);
        tripNameController.clear();
        Get.back();
        EasyLoading.showSuccess('Trip created successfully!'.tr);
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to create trip.'.tr);
      }
    } catch (e) {
      EasyLoading.showError(e.toString());
    } finally {
      EasyLoading.dismiss();
    }
  }

  // Method to update group name
  Future<void> updateGroupName() async {
    final newGroupName = tripNameController.text.trim();
    if (newGroupName.isEmpty) {
      Get.snackbar(
        'Group Name Required',
        'Please enter a new name for the group',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white,
      );
      return;
    }

    if (currentGroupId.value.isEmpty) {
      Get.snackbar(
        'Error',
        'No group selected for update',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    isUpdating.value = true;
    EasyLoading.show(status: 'Updating Group Name...');

    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final request = http.Request(
        'PATCH',
        Uri.parse(Urls.updateGroupName(currentGroupId.value)),
      );
      request.body = json.encode({"groupName": newGroupName});
      request.headers.addAll(headers);

      debugPrint(
        '🔄 Updating group name to: $newGroupName for groupId: ${currentGroupId.value}',
      );

      http.StreamedResponse response = await request.send();
      final responseBody = await response.stream.bytesToString();

      debugPrint(
        '📊 Update Group Name Response Status: ${response.statusCode}',
      );
      debugPrint('📋 Update Group Name Response Body: $responseBody');

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);

        if (responseData['status'] == 'success') {
          // Update the trip in local list
          final tripIndex = trips.indexWhere(
            (trip) => trip.id == currentGroupId.value,
          );
          if (tripIndex != -1) {
            trips[tripIndex] = Trip(
              id: trips[tripIndex].id,
              name: newGroupName,
              date: trips[tripIndex].date,
              aiSummary:
                  trips[tripIndex].aiSummary, // Preserve existing AI summary
            );
          }

          tripNameController.clear();
          Get.back();
          EasyLoading.showSuccess('Group name updated successfully!');

          debugPrint('✅ Group name updated successfully: $newGroupName');
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to update group name',
          );
        }
      } else {
        final errorData = json.decode(responseBody);
        throw Exception(errorData['message'] ?? 'Failed to update group name');
      }
    } catch (e) {
      debugPrint('❌ Error updating group name: $e');
      EasyLoading.showError('Failed to update group name: ${e.toString()}');
    } finally {
      isUpdating.value = false;
      EasyLoading.dismiss();
    }
  }

  // Method to set current group for editing
  void setCurrentGroup(String groupId, String currentName) {
    currentGroupId.value = groupId;
    tripNameController.text = currentName;
    debugPrint(
      '🎯 Set current group for editing: $groupId with name: $currentName',
    );
  }

  void focusCreate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      createTripFocusNode.requestFocus();
    });
  }

  void focusEdit() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      editTripFocusNode.requestFocus();
    });
  }

  // Method to extract clean summary text (removes group name prefix)
  String _extractCleanSummary(String fullSummary) {
    // Look for patterns like "💸 GroupName: " and extract what comes after
    // First, try to find colon after emoji and group name
    final colonIndex = fullSummary.indexOf(': ');
    if (colonIndex != -1) {
      // Extract text after ": "
      return fullSummary.substring(colonIndex + 2).trim();
    }

    // If no colon pattern found, try to remove emoji and group name at start
    // Look for common patterns like "💸 Text: " or "🏝️ Text: "
    final RegExp pattern = RegExp(
      r'^[🎉💸🏝️✈️🍽️💰🎯🏆📊🎊🌟⭐🔥💯🚀🎈]+ .+?: ',
    );
    final match = pattern.firstMatch(fullSummary);
    if (match != null) {
      return fullSummary.substring(match.end).trim();
    }

    // If no pattern matches, return the full summary as fallback
    return fullSummary.trim();
  }

  // Method to get AI summary for display (returns summary from first trip if available)
  String get currentAiSummary {
    if (trips.isNotEmpty && trips.first.aiSummary != null) {
      return trips.first.aiSummary!;
    }
    return 'Ready to track your group expenses!'.tr;
  }

  @override
  void onClose() {
    tripNameController.dispose();
    createTripFocusNode.dispose();
    editTripFocusNode.dispose();
    super.onClose();
  }
}
