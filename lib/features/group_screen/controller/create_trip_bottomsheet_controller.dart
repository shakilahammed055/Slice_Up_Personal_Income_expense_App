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

          // Try multiple possible ID field names
          final tripId =
              tripData['_id'] ??
              tripData['id'] ??
              tripData['groupId'] ??
              tripData['group_id'];

          final tripName =
              tripData['groupName'] ?? tripData['name'] ?? 'Unnamed Trip';

          debugPrint("🆔 [FETCH] Trip: '$tripName' with ID: '$tripId'");
          debugPrint(
            "🔍 [FETCH] ID fields check: _id=${tripData['_id']}, id=${tripData['id']}, groupId=${tripData['groupId']}, group_id=${tripData['group_id']}",
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
            newTripData['_id'] ??
            newTripData['id'] ??
            newTripData['groupId'] ??
            newTripData['group_id'];
        final tripName = newTripData['groupName'] ?? newTripData['name'];

        debugPrint("🆔 [CREATE] New trip: '$tripName' with ID: '$tripId'");

        if (tripId == null || tripId.toString().isEmpty) {
          debugPrint("⚠️ [CREATE] Warning: New trip has null or empty ID!");
          debugPrint(
            "⚠️ [CREATE] Available ID fields: _id=${newTripData['_id']}, id=${newTripData['id']}, groupId=${newTripData['groupId']}, group_id=${newTripData['group_id']}",
          );
          debugPrint(
            "⚠️ [CREATE] All available keys: ${newTripData.keys.toList()}",
          );
        }

        final newTrip = Trip(
          id: tripId?.toString(), // Ensure it's a string and handle null
          name: tripName,
          date: currentDate,
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

  @override
  void onClose() {
    tripNameController.dispose();
    createTripFocusNode.dispose();
    editTripFocusNode.dispose();
    super.onClose();
  }
}
