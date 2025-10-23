// ignore_for_file: collection_methods_unrelated_type

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/scheduler.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';

// File-scoped debug toggle: set to `true` to enable debugPrints inside this file.
// This shadows the imported debugPrint within this file only and prevents
// the console from being flooded without editing every call-site.
const bool _tripTextDebugLocal = false;

void debugPrint(Object? message) {
  if (_tripTextDebugLocal) {
    // Use standard print for simplicity. This intentionally shadows
    // Flutter's debugPrint for file-scoped control over logs.
    // ignore: avoid_print
    print(message?.toString() ?? '');
  }
}

enum TripTextType { expenses, sliceup, status }

class TripTextController extends GetxController {
  // Toggle this to false to silence TripTextController debug logs in debug console
  static const bool _tripTextDebug = false;

  void _d(Object? message) {
    if (_tripTextDebug) debugPrint(message?.toString() ?? '');
  }

  final currentType = TripTextType.expenses.obs;

  // API related observables
  var isLoading = false.obs;
  final summaryData = <String, dynamic>{}.obs;
  var currentGroupId = ''.obs;
  var error = ''.obs;

  // SliceUp controller reference
  SliceUpController? _sliceUpController;

  // Guard to avoid scheduling multiple refreshes in the same frame
  bool _refreshScheduled = false;

  // Mock data for status (until their APIs are integrated)
  final statusData = {}.obs;

  @override
  void onClose() {
    _d(
      '🔄 [TRIP_TEXT_CONTROLLER] onClose called for group: ${currentGroupId.value}',
    );
    super.onClose();
  }

  // ✅ Method to clear data when switching groups
  void clearData() {
    _d(
      '🧹 [TRIP_TEXT_CONTROLLER] Clearing data for group: ${currentGroupId.value}',
    );
    summaryData.clear();
    statusData.clear();
    error.value = '';
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _d('🔄 [TRIP_TEXT_CONTROLLER] onInit called');
    // Don't auto-load data in onInit, wait for explicit group ID setting
  }

  @override
  void onReady() {
    super.onReady();
    _d('🔄 [TRIP_TEXT_CONTROLLER] onReady called');
    // Refresh data when controller becomes ready if we have a group ID
    if (currentGroupId.value.isNotEmpty) {
      refreshCurrentData();
    }
  }

  // Auto-fetch first group if no group ID is set
  Future<void> autoFetchFirstGroup() async {
    try {
      _d('🔍 [TRIP_TEXT_CONTROLLER] Auto-fetching first group...');
      final token = await AuthService.getApprovalToken();
      if (token != null && token.isNotEmpty) {
        final firstGroupId = await getUserGroupsAndGetFirst(token);
        if (firstGroupId.isNotEmpty) {
          _d('✅ [TRIP_TEXT_CONTROLLER] Auto-setting groupId: $firstGroupId');
          setGroupId(firstGroupId);
        }
      }
    } catch (e) {
      _d('❌ [TRIP_TEXT_CONTROLLER] Error auto-fetching group: $e');
    }
  }

  void setTripTextType(TripTextType type) {
    final previousType = currentType.value;
    currentType.value = type;

    // Debug: Check current state when type changes
    _d('🔄 [TRIP_TEXT_CONTROLLER] setTripTextType called: $type');
    _d('🔄 [TRIP_TEXT_CONTROLLER] currentGroupId: ${currentGroupId.value}');

    // ✅ Always refresh data when changing type to ensure real-time updates
    if (currentGroupId.value.isNotEmpty) {
      _d(
        '🚀 [TRIP_TEXT_CONTROLLER] Scheduling refresh for type change: $previousType -> $type',
      );
      _scheduleRefreshAfterBuild();
    } else {
      debugPrint('⚠️ [TRIP_TEXT_CONTROLLER] Cannot refresh: no group ID set');
    }
  }

  // Initialize SliceUpController when needed
  void _initializeSliceUpController() {
    final tag = currentGroupId.value;
    if (_sliceUpController == null ||
        !Get.isRegistered<SliceUpController>(tag: tag)) {
      _sliceUpController = Get.put(
        SliceUpController(),
        tag:
            tag, // ✅ Use group ID as tag for unique SliceUpController per group
      );
      _sliceUpController!.setGroupId(currentGroupId.value);
    }
  }

  // Method to set group ID and auto-fetch data
  void setGroupId(String groupId) {
    _d('🎯 [TRIP_TEXT_CONTROLLER] setGroupId called with: $groupId');
    if (currentGroupId.value != groupId) {
      currentGroupId.value = groupId;
      // Clear previous data when switching groups
      summaryData.clear();
      statusData.clear();
      error.value = '';

      // Auto-fetch expense data when group changes and we're on expenses tab
      if (currentType.value == TripTextType.expenses && groupId.isNotEmpty) {
        _d(
          '🚀 [TRIP_TEXT_CONTROLLER] Scheduling fetch for new group: $groupId',
        );
        _scheduleRefreshAfterBuild();
      } else if (currentType.value == TripTextType.sliceup &&
          groupId.isNotEmpty) {
        _d(
          '🚀 [TRIP_TEXT_CONTROLLER] Initializing slice-up controller for new group: $groupId',
        );
        // Initialization is lightweight - do it immediately
        _initializeSliceUpController();
      }
    } else {
      _d('🔄 [TRIP_TEXT_CONTROLLER] Group ID unchanged: $groupId');
      // Even if group ID is same, schedule a refresh to ensure it's up to date
      _scheduleRefreshAfterBuild();
    }
  }

  // ✅ Method to refresh current data based on current type and group
  void refreshCurrentData() {
    if (currentGroupId.value.isEmpty) return;

    debugPrint(
      '🔄 [TRIP_TEXT_CONTROLLER] Refreshing data for type: ${currentType.value}, group: ${currentGroupId.value}',
    );

    switch (currentType.value) {
      case TripTextType.expenses:
        fetchExpenseData(currentGroupId.value);
        break;
      case TripTextType.sliceup:
        _initializeSliceUpController();
        break;
      case TripTextType.status:
        // For now, status data is handled differently
        // You can add status data refresh logic here when APIs are ready
        break;
    }
  }

  // Schedule a refresh after the current frame to avoid calling setState/markNeedsBuild
  // during the widget build phase which causes the Obx exception.
  void _scheduleRefreshAfterBuild() {
    if (_refreshScheduled) return;
    _refreshScheduled = true;
    SchedulerBinding.instance.addPostFrameCallback((_) {
      try {
        refreshCurrentData();
      } catch (e) {
        debugPrint(
          '❌ [TRIP_TEXT_CONTROLLER] Error during scheduled refresh: $e',
        );
      } finally {
        _refreshScheduled = false;
      }
    });
  }

  // TEMPORARY: Method to test API with hardcoded group ID
  void testApiCall() async {
    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] === STARTING DEBUG TEST ===');

    // First check if we have authentication
    final token = await AuthService.getApprovalToken();
    debugPrint(
      '🔑 [TRIP_TEXT_CONTROLLER] Token available: ${token != null && token.isNotEmpty}',
    );
    if (token != null) {
      debugPrint('🔑 [TRIP_TEXT_CONTROLLER] Token length: ${token.length}');
      debugPrint(
        '🔑 [TRIP_TEXT_CONTROLLER] Token starts with: ${token.substring(0, math.min(20, token.length))}...',
      );
    }

    // Check current controller state before API call
    debugPrint('📊 [TRIP_TEXT_CONTROLLER] === BEFORE API CALL ===');
    debugCurrentState();

    // Try to get the first available group ID dynamically
    String testGroupId = '';
    if (token != null && token.isNotEmpty) {
      debugPrint(
        '🔍 [TRIP_TEXT_CONTROLLER] Getting first available group ID...',
      );
      testGroupId = await getUserGroupsAndGetFirst(token);
      debugPrint('📋 [TRIP_TEXT_CONTROLLER] Found group ID: $testGroupId');
    }

    // If no group ID found, use current group ID if available
    if (testGroupId.isEmpty && currentGroupId.value.isNotEmpty) {
      testGroupId = currentGroupId.value;
      debugPrint(
        '🔄 [TRIP_TEXT_CONTROLLER] Using current group ID: $testGroupId',
      );
    }

    // If still no group ID, show error
    if (testGroupId.isEmpty) {
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] No group ID available for testing');
      debugPrint(
        '❌ [TRIP_TEXT_CONTROLLER] Make sure you have at least one group created',
      );
      return;
    }

    debugPrint(
      '🧪 [TRIP_TEXT_CONTROLLER] Testing with dynamic group ID: $testGroupId',
    );

    // Set group ID and watch for changes
    setGroupId(testGroupId);

    // Wait a bit for the API call to complete
    await Future.delayed(Duration(seconds: 3));

    // Check state after API call
    debugPrint('📊 [TRIP_TEXT_CONTROLLER] === AFTER API CALL ===');
    debugCurrentState();

    // Test manual URL construction
    final testUrl = Urls.getGroupTransactions(testGroupId);
    debugPrint('🌐 [TRIP_TEXT_CONTROLLER] Constructed URL: $testUrl');

    // Test if we can reach the endpoint manually
    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] Testing manual API call...');
    await testManualApiCall(testGroupId, token);

    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] === DEBUG TEST COMPLETE ===');
  }

  // Manual API test method
  Future<void> testManualApiCall(String groupId, String? token) async {
    if (token == null || token.isEmpty) {
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] No token for manual test');
      return;
    }

    try {
      debugPrint('🔧 [TRIP_TEXT_CONTROLLER] === MANUAL API TEST START ===');

      final url = Urls.getGroupTransactions(groupId);
      debugPrint('🌐 [TRIP_TEXT_CONTROLLER] Manual test URL: $url');

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      debugPrint('🔑 [TRIP_TEXT_CONTROLLER] Manual test headers: $headers');

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      debugPrint('📤 [TRIP_TEXT_CONTROLLER] Sending manual request...');
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint(
        '📥 [TRIP_TEXT_CONTROLLER] Manual response status: ${response.statusCode}',
      );
      debugPrint(
        '📥 [TRIP_TEXT_CONTROLLER] Manual response headers: ${response.headers}',
      );
      debugPrint(
        '📋 [TRIP_TEXT_CONTROLLER] Manual response body: $responseString',
      );

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(responseString) as Map<String, dynamic>;
          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] Manual parsed JSON: $responseData',
          );

          // Check response structure
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] Response keys: ${responseData.keys}',
          );
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] Status: ${responseData['status']}',
          );
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] Has data: ${responseData['data'] != null}',
          );

          if (responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            debugPrint('🔍 [TRIP_TEXT_CONTROLLER] Data keys: ${data.keys}');
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] Has summary: ${data['summary'] != null}',
            );
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] Has transactions: ${data['transactions'] != null}',
            );
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] Has totals: ${data['totals'] != null}',
            );

            if (data['summary'] != null) {
              debugPrint(
                '📊 [TRIP_TEXT_CONTROLLER] Summary structure: ${data['summary']}',
              );
            }
            if (data['transactions'] != null) {
              final transactions = data['transactions'] as List;
              debugPrint(
                '📊 [TRIP_TEXT_CONTROLLER] Transactions count: ${transactions.length}',
              );
              if (transactions.isNotEmpty) {
                debugPrint(
                  '📊 [TRIP_TEXT_CONTROLLER] First transaction: ${transactions[0]}',
                );
              }
            }
            if (data['totals'] != null) {
              debugPrint(
                '📊 [TRIP_TEXT_CONTROLLER] Totals structure: ${data['totals']}',
              );
            }
          }
        } catch (e) {
          debugPrint(
            '❌ [TRIP_TEXT_CONTROLLER] Error parsing manual response JSON: $e',
          );
        }
      } else {
        debugPrint(
          '❌ [TRIP_TEXT_CONTROLLER] Manual API failed: ${response.statusCode}',
        );
        if (response.statusCode == 401) {
          debugPrint(
            '🔐 [TRIP_TEXT_CONTROLLER] Unauthorized - token might be invalid',
          );
        } else if (response.statusCode == 404) {
          debugPrint(
            '🚫 [TRIP_TEXT_CONTROLLER] Not found - group ID might be invalid',
          );
        }
      }

      debugPrint('🔧 [TRIP_TEXT_CONTROLLER] === MANUAL API TEST END ===');
    } catch (e) {
      debugPrint('💥 [TRIP_TEXT_CONTROLLER] Manual API test exception: $e');
    }
  }

  // TEMPORARY: Method to manually set test data
  void setTestData() {
    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] Setting manual test data');
    summaryData.clear();
    summaryData.addAll({
      'youllPay': {'currency': 'USD', 'amount': 0},
      'youllCollect': {'currency': 'USD', 'amount': 480},
    });
    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] Test data set: $summaryData');
    summaryData.refresh();
    debugPrint('🧪 [TRIP_TEXT_CONTROLLER] UI refresh called');
  }

  // TEMPORARY: Method to force data fetch for testing
  void forceRefresh() {
    debugPrint('🔄 [TRIP_TEXT_CONTROLLER] Force refresh called');
    if (currentGroupId.value.isNotEmpty) {
      fetchExpenseData(currentGroupId.value);
    } else {
      autoFetchFirstGroup();
    }
  }

  // TEMPORARY: Quick debug method to check state
  void quickDebug() {
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] === QUICK DEBUG ===');
    debugPrint(
      '⚡ [TRIP_TEXT_CONTROLLER] currentGroupId: ${currentGroupId.value}',
    );
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] currentType: ${currentType.value}');
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] isLoading: ${isLoading.value}');
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] error: ${error.value}');
    debugPrint(
      '⚡ [TRIP_TEXT_CONTROLLER] summaryData.isEmpty: ${summaryData.isEmpty}',
    );
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] summaryData: $summaryData');

    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] primaryAmount: $primaryAmount');
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] secondaryAmount: $secondaryAmount');
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] === QUICK DEBUG END ===');
  }

  // Debug method to check current state
  void debugCurrentState() {
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] === DEBUG STATE ===');
    debugPrint(
      '🔍 [TRIP_TEXT_CONTROLLER] summaryData.isEmpty: ${summaryData.isEmpty}',
    );
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] summaryData: $summaryData');
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] isLoading: ${isLoading.value}');
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] error: ${error.value}');
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] currentType: ${currentType.value}');
    if (summaryData.isNotEmpty) {
      debugPrint(
        '🔍 [TRIP_TEXT_CONTROLLER] youllPay: ${summaryData['youllPay']}',
      );
      debugPrint(
        '🔍 [TRIP_TEXT_CONTROLLER] youllCollect: ${summaryData['youllCollect']}',
      );
    }
    debugPrint('🔍 [TRIP_TEXT_CONTROLLER] === END DEBUG ===');
  }

  // Method to fetch expense data from API
  Future<void> fetchExpenseData(String groupId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view expense data';
        debugPrint('❌ [TRIP_TEXT_CONTROLLER] No token available');
        return;
      }

      // Store token in StorageService
      await StorageService.saveToken(
        token,
        await AuthService.getUserId() ?? '',
      );

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Make API call to getGroupTransactions
      final url = Urls.getGroupTransactions(groupId);
      debugPrint('🌐 [TRIP_TEXT_CONTROLLER] Fetching expense data from: $url');
      debugPrint('🔑 [TRIP_TEXT_CONTROLLER] Headers: $headers');

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);
      // Note: No body for GET request

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint(
        '📋 [TRIP_TEXT_CONTROLLER] Response status: ${response.statusCode}',
      );
      debugPrint('📋 [TRIP_TEXT_CONTROLLER] Raw Response: $responseString');

      if (response.statusCode == 200) {
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] Parsed responseData keys: ${responseData.keys}',
        );
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] Response status field: ${responseData['status']}',
        );
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] Has data field: ${responseData['data'] != null}',
        );

        if (responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          debugPrint('🔍 [TRIP_TEXT_CONTROLLER] Data keys: ${data.keys}');
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] Has summary: ${data['summary'] != null}',
          );

          if (data['summary'] != null) {
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] Summary content: ${data['summary']}',
            );
          }
        }

        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['summary'] != null) {
          final summary =
              responseData['data']['summary'] as Map<String, dynamic>;
          debugPrint('✅ [TRIP_TEXT_CONTROLLER] Summary data found: $summary');

          // Update summary data with proper reactive updates
          // Normalize summary so callers can always read 'youllPay' and 'youllCollect'
          final normalized = _normalizeSummary(summary);
          summaryData.clear();
          summaryData.addAll(normalized);

          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] summaryData after update: $summaryData',
          );
          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] summaryData.isEmpty: ${summaryData.isEmpty}',
          );
          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] youllPay in summaryData: ${summaryData['youllPay']}',
          );
          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] youllCollect in summaryData: ${summaryData['youllCollect']}',
          );

          // Force UI update using refresh() instead of update()
          summaryData.refresh();
          debugPrint('✅ [TRIP_TEXT_CONTROLLER] summaryData.refresh() called');
        } else {
          // Check if data exists but without summary - handle different response structures
          if (responseData['status'] == 'success' &&
              responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] No summary field, checking for alternative structure',
            );
            debugPrint(
              '🔍 [TRIP_TEXT_CONTROLLER] Available data keys: ${data.keys}',
            );

            // Try to extract summary data from alternative structures
            Map<String, dynamic> extractedSummary = {};

            // Check for transactions to calculate summary
            if (data['transactions'] != null) {
              extractedSummary = calculateSummaryFromTransactions(
                data['transactions'],
              );
              debugPrint(
                '🔄 [TRIP_TEXT_CONTROLLER] Calculated summary from transactions: $extractedSummary',
              );
            }

            // Check for totals field
            if (data['totals'] != null && extractedSummary.isEmpty) {
              extractedSummary = processTotalsData(data['totals']);
              debugPrint(
                '🔄 [TRIP_TEXT_CONTROLLER] Extracted summary from totals: $extractedSummary',
              );
            }

            if (extractedSummary.isNotEmpty) {
              summaryData.clear();
              summaryData.addAll(extractedSummary);
              summaryData.refresh();
              debugPrint(
                '✅ [TRIP_TEXT_CONTROLLER] Alternative summary data set: $extractedSummary',
              );
            } else {
              error.value = 'No summary data found in response';
              debugPrint(
                '❌ [TRIP_TEXT_CONTROLLER] No summary data: $responseData',
              );
            }
          } else {
            error.value = 'No summary data found in response';
            debugPrint(
              '❌ [TRIP_TEXT_CONTROLLER] No summary data: $responseData',
            );
          }
        }
      } else {
        error.value = 'Failed to fetch expense data: ${response.statusCode}';
        debugPrint(
          '❌ [TRIP_TEXT_CONTROLLER] HTTP Error: ${response.statusCode}',
        );
        debugPrint('❌ [TRIP_TEXT_CONTROLLER] Response body: $responseString');
      }
    } catch (e) {
      error.value = 'Error fetching expense data: $e';
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to format summary amount
  String _formatSummaryAmount(Map<String, dynamic> summaryItem) {
    final currency = summaryItem['currency'] ?? 'USD';
    final amount = summaryItem['amount'] ?? 0;
    return _formatCurrency(amount, currency);
  }

  // Normalize various possible summary shapes from the API into a consistent
  // map containing 'youllPay' and 'youllCollect' entries with {currency, amount}.
  Map<String, dynamic> _normalizeSummary(Map<String, dynamic> src) {
    try {
      // Prefer explicit totals when available (backend may provide both forms).
      final altPay =
          src['totalUserBorrowed'] ?? src['totalUserOwed'] ?? src['totalOwed'];
      final altCollect =
          src['totalUserLent'] ?? src['totalUserLended'] ?? src['totalLent'];

      final currencyFromYoullPay = (src['youllPay'] is Map)
          ? (src['youllPay']['currency'] ?? src['currency'] ?? 'USD')
          : (src['currency'] ?? 'USD');

      final currencyFromYoullCollect = (src['youllCollect'] is Map)
          ? (src['youllCollect']['currency'] ?? src['currency'] ?? 'USD')
          : (src['currency'] ?? 'USD');

      // If backend provides totalUserBorrowed/totalUserLent prefer those values
      if (altPay != null || altCollect != null) {
        return {
          'youllPay': {
            'currency': currencyFromYoullPay,
            'amount':
                altPay ??
                (src['youllPay'] is Map
                    ? src['youllPay']['amount'] ?? 0
                    : src['youllPay'] ?? 0),
          },
          'youllCollect': {
            'currency': currencyFromYoullCollect,
            'amount':
                altCollect ??
                (src['youllCollect'] is Map
                    ? src['youllCollect']['amount'] ?? 0
                    : src['youllCollect'] ?? 0),
          },
          'totalExpenses': src['totalExpenses'] ?? 0,
          'totalUserBorrowed': altPay ?? (src['totalUserBorrowed'] ?? 0),
          'totalUserLent': altCollect ?? (src['totalUserLent'] ?? 0),
        };
      }

      // If no alternate totals, fall back to existing youllPay/youllCollect or zeros
      final pay = src['youllPay'];
      final collect = src['youllCollect'];
      final youllPayAmt = pay is Map ? (pay['amount'] ?? 0) : (pay ?? 0);
      final youllCollectAmt = collect is Map
          ? (collect['amount'] ?? 0)
          : (collect ?? 0);

      return {
        'youllPay': {'currency': currencyFromYoullPay, 'amount': youllPayAmt},
        'youllCollect': {
          'currency': currencyFromYoullCollect,
          'amount': youllCollectAmt,
        },
        'totalExpenses': src['totalExpenses'] ?? 0,
        'totalUserBorrowed': src['totalUserBorrowed'] ?? 0,
        'totalUserLent': src['totalUserLent'] ?? 0,
      };
    } catch (e) {
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] Error normalizing summary: $e');
      return {
        'youllPay': {'currency': 'USD', 'amount': 0},
        'youllCollect': {'currency': 'USD', 'amount': 0},
      };
    }
  }

  // Helper method to format currency
  String _formatCurrency(dynamic amount, String currency) {
    try {
      double val = 0.0;
      if (amount is num) {
        val = amount.toDouble();
      } else if (amount is String) {
        val = double.tryParse(amount) ?? 0.0;
      }
      final currencySymbol = _getCurrencySymbol(currency);
      // If the amount is an integer value, show without decimals
      if ((val % 1) == 0) {
        return '$currencySymbol ${val.toInt()}';
      }
      return '$currencySymbol ${val.toStringAsFixed(2)}';
    } catch (e) {
      return 'US\$0';
    }
  }

  // ✅ Static method to clean up controller for a specific group
  static void cleanupControllerForGroup(String groupId) {
    final tag = groupId.isNotEmpty ? groupId : 'default';
    if (Get.isRegistered<TripTextController>(tag: tag)) {
      debugPrint(
        '🧹 [TRIP_TEXT_CONTROLLER] Cleaning up controller for group: $groupId',
      );
      final controller = Get.find<TripTextController>(tag: tag);
      controller.clearData();
      // Optionally delete the controller if you want to free memory completely
      // Get.delete<TripTextController>(tag: tag);
    }
  }

  // Helper method to get currency symbol
  String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return 'US\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'SGD':
        return 'S\$';
      default:
        return currency;
    }
  }

  // Getters for different text formats
  String get primaryText {
    switch (currentType.value) {
      case TripTextType.expenses:
        // Ensure a trailing space so the amount doesn't stick to the text
        return '${'You\'ll pay'.tr} ';
      case TripTextType.sliceup:
        // Ensure a trailing space so the amount doesn't stick to the text
        return '${'You\'ll pay'.tr} ';
      case TripTextType.status:
        return 'All sliced up and settled!'.tr;
    }
  }

  String get primaryAmount {
    switch (currentType.value) {
      case TripTextType.expenses:
        // Use API summary data only (no verbose logs)
        if (summaryData.isNotEmpty && summaryData['youllPay'] != null) {
          if (summaryData['youllPay'] is Map) {
            final amount = _formatSummaryAmount(summaryData['youllPay']);
            return amount;
          }
        }
        return 'US\$0'; // Default when no API data
      case TripTextType.sliceup:
        // Use SliceUpController data
        if (_sliceUpController != null &&
            _sliceUpController!.youllPayAmount.value.isNotEmpty) {
          return _sliceUpController!.youllPayAmount.value;
        }
        return 'US\$0'; // Default when no slice-up data
      case TripTextType.status:
        return ''; // No amount for status screen
    }
  }

  // Check if secondary text should be shown
  bool get shouldShowSecondaryText {
    return currentType.value != TripTextType.status;
  }

  String get secondaryText {
    switch (currentType.value) {
      case TripTextType.expenses:
        // Add trailing space for spacing before amount
        return '${'You\'ll collect'.tr} ';
      case TripTextType.sliceup:
        // Add trailing space for spacing before amount
        return '${'You\'ll collect'.tr} ';
      case TripTextType.status:
        return 'Pending'.tr;
    }
  }

  String get secondaryAmount {
    switch (currentType.value) {
      case TripTextType.expenses:
        // Use API summary data only (no verbose logs)
        if (summaryData.isNotEmpty && summaryData['youllCollect'] != null) {
          if (summaryData['youllCollect'] is Map) {
            return ' ${_formatSummaryAmount(summaryData['youllCollect'])}';
          }
        }
        return ' US\$0'; // Default when no API data
      case TripTextType.sliceup:
        // Use SliceUpController data
        if (_sliceUpController != null &&
            _sliceUpController!.youllCollectAmount.value.isNotEmpty) {
          return ' ${_sliceUpController!.youllCollectAmount.value}';
        }
        return ' US\$0'; // Default when no slice-up data
      case TripTextType.status:
        return ' ${statusData['pending'] ?? 'US\$0'}';
    }
  }

  // Method to update data from API - now delegates to SliceUpController
  void updateSliceupData({String? totalExpenses, String? yourShare}) {
    // This method is now handled by SliceUpController
    // Can be removed or kept for backward compatibility
    debugPrint(
      '🔄 [TRIP_TEXT_CONTROLLER] updateSliceupData called - now handled by SliceUpController',
    );
  }

  void updateStatusData({String? settled, String? pending}) {
    if (settled != null) statusData['settled'] = settled;
    if (pending != null) statusData['pending'] = pending;
  }

  // Get user's groups and return the first group ID
  Future<String> getUserGroupsAndGetFirst(String token) async {
    try {
      debugPrint('🔄 [TRIP_TEXT_CONTROLLER] Getting user groups...');

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Urls.getGroups));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        debugPrint('🔍 [TRIP_TEXT_CONTROLLER] Groups response: $responseData');

        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          // ✅ Fix: Handle the correct API structure
          if (data['groups'] != null) {
            final groups = data['groups'] as List<dynamic>;
            if (groups.isNotEmpty) {
              final firstGroup = groups[0] as Map<String, dynamic>;
              final groupId = firstGroup['groupId']?.toString() ?? '';
              debugPrint(
                '✅ [TRIP_TEXT_CONTROLLER] Found first group ID: $groupId',
              );
              return groupId;
            }
          } else if (data is List<dynamic>) {
            // Fallback: if data is directly a list
            final groups = data;
            if (groups.isNotEmpty) {
              final firstGroup = groups[0] as Map<String, dynamic>;
              final groupId = firstGroup['id']?.toString() ?? '';
              debugPrint(
                '✅ [TRIP_TEXT_CONTROLLER] Found first group ID (fallback): $groupId',
              );
              return groupId;
            }
          }
        }
      } else {
        debugPrint(
          '❌ [TRIP_TEXT_CONTROLLER] Failed to get groups: ${response.statusCode}',
        );
      }
    } catch (e) {
      debugPrint(
        '❌ [TRIP_TEXT_CONTROLLER] Exception in getUserGroupsAndGetFirst: $e',
      );
    }

    return '';
  }

  // Helper method to calculate summary from transactions
  Map<String, dynamic> calculateSummaryFromTransactions(
    List<dynamic> transactions,
  ) {
    try {
      double youllPay = 0.0;
      double youllCollect = 0.0;

      for (var transaction in transactions) {
        final userInvolvement = transaction['userInvolvement'] ?? {};
        final netAmount = userInvolvement['net'] ?? 0.0;

        if (netAmount < 0) {
          youllPay += netAmount.abs();
        } else if (netAmount > 0) {
          youllCollect += netAmount;
        }
      }

      return {
        'youllPay': {'currency': 'USD', 'amount': youllPay},
        'youllCollect': {'currency': 'USD', 'amount': youllCollect},
      };
    } catch (e) {
      debugPrint(
        '❌ [TRIP_TEXT_CONTROLLER] Error calculating summary from transactions: $e',
      );
      return {};
    }
  }

  // Helper method to process totals data
  Map<String, dynamic> processTotalsData(Map<String, dynamic> totals) {
    try {
      final youllPay = _parseAmount(
        totals['totalOwed'] ?? totals['youOwn'] ?? 0,
      );
      final youllCollect = _parseAmount(
        totals['totalLent'] ?? totals['youAreOwned'] ?? 0,
      );

      return {
        'youllPay': {'currency': 'USD', 'amount': youllPay},
        'youllCollect': {'currency': 'USD', 'amount': youllCollect},
      };
    } catch (e) {
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] Error processing totals data: $e');
      return {};
    }
  }

  // Helper method to parse amount from various formats
  double _parseAmount(dynamic amount) {
    if (amount == null) return 0.0;
    if (amount is double) return amount;
    if (amount is int) return amount.toDouble();
    if (amount is String) {
      // Remove currency symbols and parse
      String cleanAmount = amount.replaceAll(RegExp(r'[^\d.-]'), '');
      return double.tryParse(cleanAmount) ?? 0.0;
    }
    return 0.0;
  }
}
