import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';

class SettlementBottomController extends GetxController {
  /// API call state
  var isProcessing = false.obs;
  var apiError = ''.obs;

  /// Marks whether controller has been prepared for a given group to avoid re-init
  var prepared = false.obs;

  /// Optional reference to the SliceUpController for the group
  SliceUpController? sliceUpController;

  /// Holds selected state for the "To Pay" list
  var groupOneSelected = <bool>[].obs;

  /// Holds selected state for the "To Collect" list
  var groupTwoSelected = <bool>[].obs;

  /// Toggle a specific checkbox in Group One
  void toggleGroupOne(int index) {
    if (index < 0 || index >= groupOneSelected.length) return;
    groupOneSelected[index] = !groupOneSelected[index];
  }

  /// Toggle a specific checkbox in Group Two
  void toggleGroupTwo(int index) {
    if (index < 0 || index >= groupTwoSelected.length) return;
    groupTwoSelected[index] = !groupTwoSelected[index];
  }

  /// Select or unselect all in Group One
  void selectAllGroupOne(bool isSelected) {
    for (var i = 0; i < groupOneSelected.length; i++) {
      groupOneSelected[i] = isSelected;
    }
  }

  /// Select or unselect all in Group Two
  void selectAllGroupTwo(bool isSelected) {
    for (var i = 0; i < groupTwoSelected.length; i++) {
      groupTwoSelected[i] = isSelected;
    }
  }

  /// Initialize Group One selection list to [false] * length
  void initGroupOne(int length) {
    groupOneSelected.clear();
    for (var i = 0; i < length; i++) {
      groupOneSelected.add(false);
    }
  }

  /// Initialize Group Two selection list to [false] * length
  void initGroupTwo(int length) {
    groupTwoSelected.clear();
    for (var i = 0; i < length; i++) {
      groupTwoSelected.add(false);
    }
  }

  /// Check if all items in Group One are selected
  bool get isAllGroupOneSelected =>
      groupOneSelected.every((selected) => selected);

  /// Check if all items in Group Two are selected
  bool get isAllGroupTwoSelected =>
      groupTwoSelected.every((selected) => selected);

  /// Submit settlements to backend for a given groupId.
  ///
  /// `settlements` should be a list of maps with keys: fromEmail, toEmail, amount
  /// Example: [{"fromEmail": "a@x.com", "toEmail": "b@y.com", "amount": 12.5}]
  Future<bool> submitSettlements(
    String groupId,
    List<Map<String, dynamic>> settlements,
  ) async {
    apiError.value = '';
    if (groupId.isEmpty) {
      apiError.value = 'Group id is required';
      return false;
    }

    if (settlements.isEmpty) {
      apiError.value = 'No settlements to process';
      return false;
    }

    try {
      isProcessing.value = true;

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        apiError.value = 'Please login to perform settlements';
        return false;
      }

      // Persist token similarly to other controllers
      await StorageService.saveToken(
        token,
        await AuthService.getUserId() ?? '',
      );

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final url = Urls.postFilterSliceUp(groupId);
      debugPrint('🌐 [SETTLEMENT_BOTTOM] POST to: $url');
      debugPrint('🔑 [SETTLEMENT_BOTTOM] Headers: $headers');
      debugPrint(
        '📦 [SETTLEMENT_BOTTOM] Payload: ${json.encode({'settlements': settlements})}',
      );

      var request = http.Request('POST', Uri.parse(url));
      request.headers.addAll(headers);
      request.body = json.encode({'settlements': settlements});

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();
      debugPrint(
        '📋 [SETTLEMENT_BOTTOM] Response status: ${response.statusCode}',
      );
      debugPrint('📋 [SETTLEMENT_BOTTOM] Raw response: $responseString');

      if (response.statusCode == 200) {
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;
        if (responseData['success'] == true) {
          // Optionally refresh slice-up data if controller exists for this group
          try {
            final slice = Get.find<SliceUpController>(tag: groupId);
            await slice.fetchSliceUpData(groupId);
            debugPrint(
              '🔁 [SETTLEMENT_BOTTOM] Refreshed SliceUpController for $groupId',
            );
          } catch (e) {
            debugPrint(
              'ℹ️ [SETTLEMENT_BOTTOM] No SliceUpController found to refresh: $e',
            );
          }

          apiError.value = '';
          return true;
        } else {
          apiError.value =
              responseData['message']?.toString() ?? 'Unknown error';
          return false;
        }
      } else {
        apiError.value = 'HTTP Error: ${response.statusCode}';
        return false;
      }
    } catch (e) {
      apiError.value = 'Exception: $e';
      debugPrint('❌ [SETTLEMENT_BOTTOM] Exception: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  /// Prepare this controller for a specific group id by finding/creating
  /// the SliceUpController for that group and initializing selection arrays.
  Future<void> prepareForGroup(String groupId) async {
    if (prepared.value) return;
    if (groupId.isEmpty) return;

    try {
      try {
        sliceUpController = Get.find<SliceUpController>(tag: groupId);
      } catch (_) {
        sliceUpController = Get.put(SliceUpController(), tag: groupId);
        sliceUpController?.setGroupId(groupId);
      }

      final settlements =
          sliceUpController?.getSettlementsForCurrentUser() ?? [];
      initGroupOne(settlements.length);

      final balances = sliceUpController?.getBalanceEntries() ?? [];
      // We'll treat positive balances as 'to collect' items
      final toCollect = balances
          .where((b) => b.amount.startsWith('+'))
          .toList();
      initGroupTwo(toCollect.length);
    } catch (e) {
      debugPrint('❌ [SETTLEMENT_BOTTOM_CTRL] prepareForGroup error: $e');
    } finally {
      prepared.value = true;
    }
  }
}
