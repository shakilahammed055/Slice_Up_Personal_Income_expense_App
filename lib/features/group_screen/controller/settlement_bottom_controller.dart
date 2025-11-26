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

  /// Local cached settlements fetched directly from the slice-up API
  final RxList<Map<String, dynamic>> activeSettlements =
      <Map<String, dynamic>>[].obs;

  /// Local cached balances fetched directly from the slice-up API
  // Local balances & "To Collect" selection are disabled for now.
  // If you want to re-enable the "To Collect" option, restore this list
  // and the related methods below.
  // final RxList<Map<String, dynamic>> balances = <Map<String, dynamic>>[].obs;

  /// Holds selected state for the "To Pay" list
  var groupOneSelected = <bool>[].obs;

  /// Holds selected state for the "To Collect" list
  // var groupTwoSelected = <bool>[].obs;

  /// Toggle a specific checkbox in Group One
  void toggleGroupOne(int index) {
    if (index < 0 || index >= groupOneSelected.length) return;
    groupOneSelected[index] = !groupOneSelected[index];
  }

  /// Toggle a specific checkbox in Group Two
  // void toggleGroupTwo(int index) {
  //   if (index < 0 || index >= groupTwoSelected.length) return;
  //   groupTwoSelected[index] = !groupTwoSelected[index];
  // }

  /// Select or unselect all in Group One
  void selectAllGroupOne(bool isSelected) {
    for (var i = 0; i < groupOneSelected.length; i++) {
      groupOneSelected[i] = isSelected;
    }
  }

  /// Select or unselect all in Group Two
  void selectAllGroupTwo(bool isSelected) {
    // for (var i = 0; i < groupTwoSelected.length; i++) {
    //   groupTwoSelected[i] = isSelected;
    // }
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
    // groupTwoSelected.clear();
    // for (var i = 0; i < length; i++) {
    //   groupTwoSelected.add(false);
    // }
  }

  /// Check if all items in Group One are selected
  bool get isAllGroupOneSelected =>
      groupOneSelected.every((selected) => selected);

  /// Check if all items in Group Two are selected
  bool get isAllGroupTwoSelected =>
      // groupTwoSelected.every((selected) => selected);
      false;

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

    // Basic validation of settlement entries to avoid malformed requests that
    // can cause server errors (HTTP 500). Ensure each entry contains required
    // keys and amount is a positive number.
    for (var i = 0; i < settlements.length; i++) {
      final s = settlements[i];
      if (!s.containsKey('fromEmail') ||
          !s.containsKey('toEmail') ||
          !s.containsKey('amount')) {
        apiError.value =
            'Settlement item at index $i is missing required fields';
        return false;
      }
      final amount = s['amount'];
      double? amt;
      if (amount is num) {
        amt = amount.toDouble();
      } else if (amount is String) {
        amt = double.tryParse(amount);
      }
      if (amt == null || amt <= 0) {
        apiError.value = 'Settlement amount at index $i is invalid';
        return false;
      }
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
          // Map server message to a user-friendly message when possible
          final rawMsg = responseData['message']?.toString() ?? '';
          apiError.value = _friendlyMessageFromServer(rawMsg, responseData);
          debugPrint(
            '❌ [SETTLEMENT_BOTTOM] Server returned success=false: $rawMsg',
          );
          return false;
        }
      } else {
        // Non-200: try to parse JSON message and present friendly text
        String friendly = 'Failed to submit settlements. Please try again.';
        try {
          final parsed = json.decode(responseString);
          if (parsed is Map && parsed['message'] != null) {
            friendly = _friendlyMessageFromServer(
              parsed['message'].toString(),
              parsed,
            );
          } else if (parsed is Map && parsed['error'] != null) {
            friendly = _friendlyMessageFromServer(
              parsed['error'].toString(),
              parsed,
            );
          } else {
            friendly = 'Server responded with status ${response.statusCode}';
          }
        } catch (e) {
          // not JSON - show generic message
          friendly =
              'Server error ${response.statusCode}. Please try again later.';
        }

        apiError.value = friendly;
        debugPrint(
          '❌ [SETTLEMENT_BOTTOM] Non-200 response: ${response.statusCode}',
        );
        debugPrint('❌ [SETTLEMENT_BOTTOM] Body: $responseString');
        return false;
      }
    } catch (e) {
      apiError.value = 'An unexpected error occurred. Please try again.';
      debugPrint('❌ [SETTLEMENT_BOTTOM] Exception: $e');
      return false;
    } finally {
      isProcessing.value = false;
    }
  }

  // Map raw server messages and error payloads to concise, user-friendly messages
  String _friendlyMessageFromServer(String rawMessage, dynamic parsedPayload) {
    final msg = rawMessage.toLowerCase();

    // Common validation: amount exceeding debt
    if (msg.contains('amount cannot exceed') ||
        msg.contains('exceed the debt')) {
      // Try to extract which settlement index if provided
      final reg = RegExp(r'Settlement\s*(\d+)', caseSensitive: false);
      final match = reg.firstMatch(rawMessage);
      final idx = match != null ? int.tryParse(match.group(1) ?? '') : null;
      if (idx != null) {
        return 'One of the selected settlements (item $idx) is higher than the outstanding amount. Reduce the amount to the remaining debt and try again.';
      }
      return 'One of the selected settlements is higher than the outstanding debt. Reduce the amount and try again.';
    }

    // Validation errors container
    if (msg.contains('validation') || msg.contains('invalid')) {
      return 'Some settlement entries are invalid. Please check amounts and participants.';
    }

    // Auth / permission issues
    if (msg.contains('unauthorized') || msg.contains('authentication')) {
      return 'You are not authorized. Please log in again.';
    }

    // Generic server error with message
    if (rawMessage.isNotEmpty) {
      // Keep message brief but informative
      return rawMessage.length > 120
          ? '${rawMessage.substring(0, 117)}...'
          : rawMessage;
    }

    return 'Failed to submit settlements. Please try again later.';
  }

  /// Prepare this controller for a specific group id by finding/creating
  /// the SliceUpController for that group and initializing selection arrays.
  Future<void> prepareForGroup(String groupId) async {
    if (prepared.value) return;
    if (groupId.isEmpty) {
      debugPrint(
        '❌ [SETTLEMENT_BOTTOM_CTRL] prepareForGroup: groupId is empty',
      );
      return;
    }

    try {
      debugPrint(
        '🔍 [SETTLEMENT_BOTTOM_CTRL] prepareForGroup: fetching slice-up data directly for: $groupId',
      );

      // Fetch slice-up data directly (prefer API over relying on existing controller)
      await fetchSliceUpDirect(groupId);

      // Initialize selection arrays based on fetched lists
      final settlementsList = activeSettlements
          .where((s) => s['isHistorical'] == false)
          .toList();
      initGroupOne(settlementsList.length);
      debugPrint(
        '📊 [SETTLEMENT_BOTTOM_CTRL] Initialized groupOne with ${settlementsList.length} settlements',
      );

      // "To Collect" initialization disabled. Uncomment balances and
      // initGroupTwo when re-enabling the To Collect feature.
    } catch (e) {
      debugPrint('❌ [SETTLEMENT_BOTTOM_CTRL] prepareForGroup error: $e');
    } finally {
      prepared.value = true;
    }
  }

  /// Fetch slice-up data directly from the API and populate local caches.
  Future<void> fetchSliceUpDirect(String groupId) async {
    try {
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint(
          '❌ [SETTLEMENT_BOTTOM_CTRL] No token available to fetch slice-up',
        );
        return;
      }

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Use the new settlements endpoint rather than the legacy slice-up URL
      final url = Urls.getSettlements(groupId);
      debugPrint(
        '🌐 [SETTLEMENT_BOTTOM_CTRL] Fetching current settlements: $url',
      );

      final request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(body);

        // The new API returns { "status": "success", "data": { ... } }
        final bool ok =
            (jsonData['success'] == true) ||
            (jsonData['statusCode'] == 200) ||
            (jsonData['status'] != null &&
                jsonData['status'].toString().toLowerCase() == 'success');

        if (ok && jsonData['data'] != null) {
          final data = jsonData['data'] as Map<String, dynamic>;

          // Parse settlements
          final rawSettlements = List<Map<String, dynamic>>.from(
            data['settlements'] ?? [],
          );

          // Map the new API settlement objects into the controller's internal shape.
          final parsedSettlements = rawSettlements.map((s) {
            return {
              'from': s['from'] ?? '',
              'to': s['to'] ?? '',
              'amount': s['amount'] ?? 0,
              // The new API does not include historical flag; default to false
              'isHistorical': s['isHistorical'] ?? false,
              'fromName': s['fromName'] ?? s['formName'] ?? '',
              'toName': s['toName'] ?? '',
              'currency': s['currency'] ?? data['currency'] ?? '',
            };
          }).toList();
          activeSettlements.assignAll(parsedSettlements);

          // Parse totalBalances (disabled)
          // final rawBalances = List<Map<String, dynamic>>.from(
          //   data['totalBalances'] ?? [],
          // );
          // final parsedBalances = rawBalances.map((b) {
          //   return {
          //     'memberEmail': b['memberEmail'] ?? '',
          //     'memberName': b['memberName'] ?? b['memberEmail'] ?? '',
          //     'netBalance': b['netBalance'] ?? 0,
          //     'totalPaid': b['totalPaid'] ?? 0,
          //     'totalOwes': b['totalOwes'] ?? 0,
          //   };
          // }).toList();
          // balances.assignAll(parsedBalances);
          debugPrint(
            '✅ [SETTLEMENT_BOTTOM_CTRL] Fetched ${parsedSettlements.length} settlements (balances parsing disabled)',
          );
        } else {
          debugPrint(
            '❌ [SETTLEMENT_BOTTOM_CTRL] Unexpected slice-up response: $jsonData',
          );
        }
      } else {
        debugPrint(
          '❌ [SETTLEMENT_BOTTOM_CTRL] Failed to fetch slice-up: ${response.statusCode} - $body',
        );
      }
    } catch (e) {
      debugPrint('❌ [SETTLEMENT_BOTTOM_CTRL] Exception fetching slice-up: $e');
    }
  }
}
