// ignore_for_file: collection_methods_unrelated_type

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/scheduler.dart';
import 'package:flutter/foundation.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';

// Note: debug printing removed for production cleanliness.
// Use Flutter's `debugPrint` from `foundation.dart` for logging.

enum TripTextType { expenses, sliceup, status }

class TripTextController extends GetxController {
  // Toggle this to false to silence TripTextController debug logs in debug console

  // Internal debug helper is a no-op (debugging removed)
  void _d(Object? message) {}

  final currentType = TripTextType.expenses.obs;

  // API related observables
  var isLoading = false.obs;
  final summaryData = <String, dynamic>{}.obs;
  var currentGroupId = ''.obs;
  var error = ''.obs;

  // SliceUp controller reference
  SliceUpController? _sliceUpController;

  // Mirror of SliceUpController.isAllSettled so this controller's Rx
  // dependencies are tracked by Obx when building TripText.
  // Using this avoids relying on Rxs from another controller to trigger
  // rebuilds for the TripText widget.
  var sliceupIsAllSettled = false.obs;

  // Guard to avoid scheduling multiple refreshes in the same frame
  bool _refreshScheduled = false;

  // Mock data for status (until their APIs are integrated)
  final statusData = {}.obs;

  // ✅ Reactive mirrors of SliceUpController data for real-time UI updates
  // These fields are synchronized with SliceUpController when it's initialized
  // Mirrors removed: TripTextController no longer keeps formatted string copies

  @override
  void onClose() {
    _d('onClose called for group: ${currentGroupId.value}');
    super.onClose();
  }

  // ✅ Method to clear data when switching groups
  void clearData() {
    _d('Clearing data for group: ${currentGroupId.value}');
    summaryData.clear();
    statusData.clear();
    error.value = '';
    isLoading.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _d('onInit called');
    // Don't auto-load data in onInit, wait for explicit group ID setting
  }

  @override
  void onReady() {
    super.onReady();
    _d('onReady called');
    // Refresh data when controller becomes ready if we have a group ID
    if (currentGroupId.value.isNotEmpty) {
      refreshCurrentData();
    }
  }

  // Auto-fetch first group if no group ID is set
  // Note: Removed - no longer needed as group ID should be provided explicitly
  Future<void> autoFetchFirstGroup() async {
    _d('autoFetchFirstGroup called but no longer implemented');
  }

  void setTripTextType(TripTextType type) {
    final previousType = currentType.value;
    currentType.value = type;

    // Debug: Check current state when type changes
    _d('setTripTextType called: $type');
    _d('currentGroupId: ${currentGroupId.value}');

    // ✅ Always refresh data when changing type to ensure real-time updates
    if (currentGroupId.value.isNotEmpty) {
      _d(
        '🚀 [TRIP_TEXT_CONTROLLER] Scheduling refresh for type change: $previousType -> $type',
      );

      // For status type, immediately initialize SliceUpController
      if (type == TripTextType.status) {
        _d('Initializing SliceUpController for status type');
        _initializeSliceUpController();
      }

      _scheduleRefreshAfterBuild();
    } else {
      _d('Cannot refresh: no group ID set');
    }
  }

  // Initialize SliceUpController when needed
  void _initializeSliceUpController() {
    final tag = currentGroupId.value;
    if (tag.isEmpty) {
      _d('Cannot initialize SliceUpController: empty group ID');
      return;
    }

    try {
      if (_sliceUpController == null ||
          !Get.isRegistered<SliceUpController>(tag: tag)) {
        _d('Creating new SliceUpController with tag: $tag');
        _sliceUpController = Get.put(
          SliceUpController(),
          tag:
              tag, // ✅ Use group ID as tag for unique SliceUpController per group
        );
        _sliceUpController!.setGroupId(currentGroupId.value);
      } else {
        _d('SliceUpController already exists for tag: $tag');
        _sliceUpController = Get.find<SliceUpController>(tag: tag);
      }

      // Always sync the mirror observables with current values
      if (_sliceUpController != null) {
        sliceupIsAllSettled.value = _sliceUpController!.isAllSettled.value;
        _d('Synced SliceUpController data for group: ${currentGroupId.value}');

        // Setup listener for settlement status changes only. Amount formatting
        // should be read from `summaryData` so TripText displays consistent
        // numeric -> formatted values derived from the summary.
        _sliceUpController!.isAllSettled.listen((val) {
          sliceupIsAllSettled.value = val;
        });

        // Sync summary data from SliceUp so TripText can read totalExpenses
        _syncSummaryDataFromSliceUp();
      }
    } catch (e) {
      _d('Error in _initializeSliceUpController: $e');
    }
  }

  // ✅ Helper to sync summary data from SliceUpController into this controller
  // so TripText widget can read totalExpenses and decide whether to show
  void _syncSummaryDataFromSliceUp() {
    if (_sliceUpController == null) return;
    try {
      final sliceSummary = _sliceUpController!.summaryData;
      if (sliceSummary.isNotEmpty) {
        summaryData.clear();
        summaryData.addAll({
          'youllPay': sliceSummary['youllPay'] ?? {'currency': '', 'amount': 0},
          'youllCollect':
              sliceSummary['youllCollect'] ?? {'currency': '', 'amount': 0},
          'totalExpenses': sliceSummary['totalExpenses'] ?? 0,
        });
        summaryData.refresh();
      }
    } catch (e) {
      // Silently ignore build errors during sync
    }
  }

  // Method to set group ID and auto-fetch data
  void setGroupId(String groupId) {
    _d('setGroupId called with: $groupId');

    if (currentGroupId.value != groupId) {
      currentGroupId.value = groupId;
      // Clear previous data when switching groups
      summaryData.clear();
      statusData.clear();
      error.value = '';
      sliceupIsAllSettled.value = false; // Reset settled state for new group
      // formatted mirrors removed; TripText reads from `summaryData`

      _d('Cleared previous group data');

      // Immediately fetch data for Expenses screen if that's the current type
      if (groupId.isNotEmpty && currentType.value == TripTextType.expenses) {
        fetchSliceUpData(groupId);
      }

      // Auto-fetch expense data for ALL screens to get summary
      if (groupId.isNotEmpty) {
        _d('Scheduling fetch for group: $groupId');
        _scheduleRefreshAfterBuild();
      }

      // Additionally initialize SliceUpController for sliceup/status screens
      if (currentType.value == TripTextType.sliceup && groupId.isNotEmpty) {
        _d('SLICEUP screen - Will also initialize SliceUpController');
      } else if (currentType.value == TripTextType.status &&
          groupId.isNotEmpty) {
        _d('STATUS screen - Will also initialize SliceUpController');
      }
      _d('GROUP CHANGE COMPLETE');
    } else {
      _d('Group ID unchanged: $groupId (no action needed)');
      // Even if group ID is same, schedule a refresh to ensure it's up to date
      _scheduleRefreshAfterBuild();
    }
  }

  // ✅ Method to refresh current data based on current type and group
  void refreshCurrentData() {
    if (currentGroupId.value.isEmpty) return;

    debugPrint(
      '🔄 [TRIP_TEXT_CTRL] Refreshing data for type: ${currentType.value}, group: ${currentGroupId.value}',
    );

    // For ALL screens, fetch slice-up data from settlements API
    // This provides the summary data needed for TripText
    fetchSliceUpData(currentGroupId.value);

    // Additionally, for slice-up and status screens, initialize SliceUpController
    // for additional slice-up specific data (settlements, balances, etc.)
    switch (currentType.value) {
      case TripTextType.expenses:
        // Already fetching slice-up data above
        break;
      case TripTextType.sliceup:
        _initializeSliceUpController();
        break;
      case TripTextType.status:
        _initializeSliceUpController();
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
      } finally {
        _refreshScheduled = false;
      }
    });
  }

  // TEMPORARY: Method to test API with hardcoded group ID
  void testApiCall() async {
    _d('Starting debug test');

    // First check if we have authentication
    final token = await AuthService.getApprovalToken();
    _d('Token available: ${token != null && token.isNotEmpty}');
    if (token != null) {
      _d('Token length: ${token.length}');
    }

    // Check current controller state before API call
    _d('Before API call');

    // Try to get the first available group ID dynamically
    String testGroupId = '';
    // Note: Group ID lookup removed - must be provided explicitly

    // If no group ID found, use current group ID if available
    if (testGroupId.isEmpty && currentGroupId.value.isNotEmpty) {
      testGroupId = currentGroupId.value;
      _d('Using current group ID: $testGroupId');
    }

    // If still no group ID, show error
    if (testGroupId.isEmpty) {
      _d('No group ID available for testing');
      _d('Make sure you have at least one group created');
      return;
    }

    _d('Testing with dynamic group ID: $testGroupId');

    // Set group ID and watch for changes
    setGroupId(testGroupId);

    // Wait a bit for the API call to complete
    await Future.delayed(Duration(seconds: 3));

    // Check state after API call
    _d('After API call');

    // Test manual URL construction - (no-op in production build)

    // Test if we can reach the endpoint manually
    _d('Testing manual API call');
    await testManualApiCall(testGroupId, token);
    _d('Debug test complete');
  }

  // Manual API test method
  Future<void> testManualApiCall(String groupId, String? token) async {
    if (token == null || token.isEmpty) {
      _d('No token for manual test');
      return;
    }

    try {
      _d('Manual API test start');

      // Use transactions endpoint for manual tests within TripTextController
      final url = Urls.getGroupTransactions(groupId);

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      _d('Manual test headers: $headers');

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      _d('Sending manual request...');
      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      _d('Manual response status: ${response.statusCode}');
      _d('Manual response headers: ${response.headers}');
      _d('Manual response body: $responseString');

      if (response.statusCode == 200) {
        try {
          final responseData =
              json.decode(responseString) as Map<String, dynamic>;
          _d('Manual parsed JSON: $responseData');

          // Check response structure
          _d('Response keys: ${responseData.keys}');
          _d('Status: ${responseData['status']}');
          _d('Has data: ${responseData['data'] != null}');

          if (responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            _d('Data keys: ${data.keys}');
            _d('Has summary: ${data['summary'] != null}');
            _d('Has transactions: ${data['transactions'] != null}');
            _d('Has totals: ${data['totals'] != null}');

            if (data['summary'] != null) {
              _d('Summary structure: ${data['summary']}');
            }
            if (data['transactions'] != null) {
              final transactions = data['transactions'] as List;
              _d('Transactions count: ${transactions.length}');
              if (transactions.isNotEmpty) {
                _d('First transaction: ${transactions[0]}');
              }
            }
            if (data['totals'] != null) {
              _d('Totals structure: ${data['totals']}');
            }
          }
        } catch (e) {
          _d('Error parsing manual response JSON: $e');
        }
      } else {
        _d('Manual API failed: ${response.statusCode}');
        if (response.statusCode == 401) {
          _d('Unauthorized - token might be invalid');
        } else if (response.statusCode == 404) {
          _d('Not found - group ID might be invalid');
        }
      }

      _d('Manual API test end');
    } catch (e) {
      _d('Manual API test exception: $e');
    }
  }

  // TEMPORARY: Method to manually set test data
  void setTestData() {
    _d('Setting manual test data');
    summaryData.clear();
    summaryData.addAll({
      'youllPay': {'currency': '', 'amount': 0},
      'youllCollect': {'currency': '', 'amount': 480},
    });
    _d('Test data set: $summaryData');
    summaryData.refresh();
    _d('UI refresh called');
  }

  // TEMPORARY: Method to force data fetch for testing
  void forceRefresh() {
    _d('Force refresh called');
    if (currentGroupId.value.isNotEmpty) {
      fetchExpenseData(currentGroupId.value);
    } else {
      autoFetchFirstGroup();
    }
  }

  // TEMPORARY: Quick debug method to check state
  void quickDebug() {
    _d(
      'Quick debug state: currentGroupId=${currentGroupId.value} currentType=${currentType.value} isLoading=${isLoading.value} error=${error.value} summaryData=$summaryData primaryAmount=$primaryAmount secondaryAmount=$secondaryAmount',
    );
  }

  // Debug method to check current state
  void debugCurrentState() {
    _d(
      'Debug state: summaryData=${summaryData.isEmpty ? 'empty' : summaryData} isLoading=${isLoading.value} error=${error.value} currentType=${currentType.value}',
    );
  }

  // Method to fetch slice-up data from settlements API
  Future<void> fetchSliceUpData(String groupId) async {
    try {
      isLoading.value = true;
      error.value = '';

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view data';
        return;
      }

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      final url = Urls.getSliceUp(groupId);
      debugPrint('🌐 [FETCH_SLICEUP] Calling: $url');
      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint('📊 [FETCH_SLICEUP] Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        debugPrint(
          '✅ [FETCH_SLICEUP] Response success: ${responseData['success']}',
        );
        debugPrint(
          '✅ [FETCH_SLICEUP] Has data: ${responseData['data'] != null}',
        );

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;

          debugPrint(
            '✅ [FETCH_SLICEUP] Has summary: ${data['summary'] != null}',
          );

          if (data['summary'] != null) {
            final summary = data['summary'] as Map<String, dynamic>;
            debugPrint('📥 [FETCH_SLICEUP] Summary data: $summary');

            summaryData.clear();
            summaryData.addAll({
              'youllPay': summary['youllPay'] ?? {'currency': '', 'amount': 0},
              'youllCollect':
                  summary['youllCollect'] ?? {'currency': '', 'amount': 0},
              'totalExpenses': summary['totalExpenses'] ?? 0,
            });
            summaryData.refresh();

            // Update isAllSettled from API response
            if (responseData['data']['isAllSettled'] != null) {
              sliceupIsAllSettled.value =
                  responseData['data']['isAllSettled'] as bool;
              debugPrint(
                '🔔 [FETCH_SLICEUP] isAllSettled: ${sliceupIsAllSettled.value}',
              );
            }

            debugPrint('✅ [FETCH_SLICEUP] Data stored: $summaryData');
          } else {
            debugPrint('❌ [FETCH_SLICEUP] No summary field in response');
          }
        }
      } else {
        debugPrint('❌ [FETCH_SLICEUP] HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      error.value = 'Error fetching data: $e';
      debugPrint('❌ [FETCH_SLICEUP] Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Method to fetch expense data from API (DEPRECATED - use fetchSliceUpData)
  Future<void> fetchExpenseData(String groupId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view expense data';
        _d('No token available');
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

      // Make API call to settlements endpoint (old transactions endpoint removed)
      final url = Urls.getSliceUp(groupId);

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      _d('Response status: ${response.statusCode}');
      _d('Raw Response: $responseString');

      if (response.statusCode == 200) {
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        _d('Parsed responseData keys: ${responseData.keys}');
        _d('Response status field: ${responseData['status']}');
        _d('Has data field: ${responseData['data'] != null}');

        if (responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          _d('Data keys: ${data.keys}');
          _d('Has summary: ${data['summary'] != null}');

          if (data['summary'] != null) {
            _d('Summary content: ${data['summary']}');
          }
        }

        if (responseData['status'] == 'success' &&
            responseData['data'] != null &&
            responseData['data']['summary'] != null) {
          final summary =
              responseData['data']['summary'] as Map<String, dynamic>;
          _d('Summary data found: $summary');

          // Update summary data with proper reactive updates
          // Normalize summary so callers can always read 'youllPay' and 'youllCollect'
          final normalized = _normalizeSummary(summary);
          summaryData.clear();
          summaryData.addAll(normalized);

          _d('summaryData after update: $summaryData');
          _d('summaryData.isEmpty: ${summaryData.isEmpty}');
          _d('youllPay in summaryData: ${summaryData['youllPay']}');
          _d('youllCollect in summaryData: ${summaryData['youllCollect']}');

          // Force UI update using refresh() instead of update()
          summaryData.refresh();
          _d('summaryData.refresh() called');
        } else {
          // Check if data exists but without summary - handle different response structures
          if (responseData['status'] == 'success' &&
              responseData['data'] != null) {
            final data = responseData['data'] as Map<String, dynamic>;
            _d('No summary field, checking for alternative structure');
            _d('Available data keys: ${data.keys}');

            // Try to extract summary data from alternative structures
            Map<String, dynamic> extractedSummary = {};

            // Check for transactions to calculate summary
            if (data['transactions'] != null) {
              extractedSummary = calculateSummaryFromTransactions(
                data['transactions'],
              );
              _d('Calculated summary from transactions: $extractedSummary');
            }

            // Check for totals field
            if (data['totals'] != null && extractedSummary.isEmpty) {
              extractedSummary = processTotalsData(data['totals']);
              _d('Extracted summary from totals: $extractedSummary');
            }

            if (extractedSummary.isNotEmpty) {
              summaryData.clear();
              summaryData.addAll(extractedSummary);
              summaryData.refresh();
              _d('Alternative summary data set: $extractedSummary');
            } else {
              error.value = 'No summary data found in response';
              _d('No summary data: $responseData');
            }
          } else {
            error.value = 'No summary data found in response';
            _d('No summary data: $responseData');
          }
        }
      } else {
        error.value = 'Failed to fetch expense data: ${response.statusCode}';
        _d('HTTP Error: ${response.statusCode}');
        _d('Response body: $responseString');
      }
    } catch (e) {
      error.value = 'Error fetching expense data: $e';
      _d('Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to format summary amount
  String _formatSummaryAmount(Map<String, dynamic> summaryItem) {
    final currency = summaryItem['currency'] ?? '';
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
          ? (src['youllPay']['currency'] ?? src['currency'] ?? '')
          : (src['currency'] ?? '');

      final currencyFromYoullCollect = (src['youllCollect'] is Map)
          ? (src['youllCollect']['currency'] ?? src['currency'] ?? '')
          : (src['currency'] ?? '');

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
      _d('Error normalizing summary: $e');
      return {
        'youllPay': {'currency': '', 'amount': 0},
        'youllCollect': {'currency': '', 'amount': 0},
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
      return '${_getCurrencySymbol(currency)}0';
    }
  }

  // ✅ Static method to clean up controller for a specific group
  static void cleanupControllerForGroup(String groupId) {
    final tag = groupId.isNotEmpty ? groupId : 'default';
    if (Get.isRegistered<TripTextController>(tag: tag)) {
      debugPrint('Cleaning up controller for group: $groupId');
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

      default:
        return currency;
    }
  }

  // Getters for different text formats
  String get primaryText {
    // If all settled AND there were expenses, show settled message
    final totalExpenses = summaryData['totalExpenses'] ?? 0;
    final totalExpensesAmount = totalExpenses is num
        ? totalExpenses.toDouble()
        : 0.0;

    if (sliceupIsAllSettled.value && totalExpensesAmount > 0) {
      return 'All sliced up and settled!'.tr;
    }

    // If no pay amount from API summary, no label
    final payAmt = _numericAmountFromSummaryEntry(summaryData['youllPay']);
    if (payAmt <= 0) return '';
    return '${'You\'ll pay'.tr} ';
  }

  String get primaryAmount {
    // If all settled AND there were expenses, don't show an amount (only the settled message)
    final totalExpenses = summaryData['totalExpenses'] ?? 0;
    final totalExpensesAmount = totalExpenses is num
        ? totalExpenses.toDouble()
        : 0.0;

    if (sliceupIsAllSettled.value && totalExpensesAmount > 0) return '';

    // Always use API summary for all three screens
    final payAmt = _numericAmountFromSummaryEntry(summaryData['youllPay']);
    if (payAmt <= 0) return '';
    if (summaryData.isNotEmpty &&
        summaryData['youllPay'] != null &&
        summaryData['youllPay'] is Map) {
      return _formatSummaryAmount(summaryData['youllPay']);
    }
    return _formatCurrency(payAmt, '');
  }

  // Check if secondary text should be shown
  bool get shouldShowSecondaryText {
    // Don't show secondary when all settled AND there were expenses
    final totalExpenses = summaryData['totalExpenses'] ?? 0;
    final totalExpensesAmount = totalExpenses is num
        ? totalExpenses.toDouble()
        : 0.0;

    if (sliceupIsAllSettled.value && totalExpensesAmount > 0) return false;

    double collectAmt = _numericAmountFromSummaryEntry(
      summaryData['youllCollect'],
    );
    return collectAmt > 0;
  }

  String get secondaryText {
    // Don't show secondary text when all settled AND there were expenses
    final totalExpenses = summaryData['totalExpenses'] ?? 0;
    final totalExpensesAmount = totalExpenses is num
        ? totalExpenses.toDouble()
        : 0.0;

    if (sliceupIsAllSettled.value && totalExpensesAmount > 0) return '';

    final collectAmt = _numericAmountFromSummaryEntry(
      summaryData['youllCollect'],
    );
    if (collectAmt <= 0) return '';
    return '${'You\'ll collect'.tr} ';
  }

  String get secondaryAmount {
    // Don't show secondary amount when all settled AND there were expenses
    final totalExpenses = summaryData['totalExpenses'] ?? 0;
    final totalExpensesAmount = totalExpenses is num
        ? totalExpenses.toDouble()
        : 0.0;

    if (sliceupIsAllSettled.value && totalExpensesAmount > 0) return '';

    final collectAmt = _numericAmountFromSummaryEntry(
      summaryData['youllCollect'],
    );
    if (collectAmt <= 0) return '';
    if (summaryData.isNotEmpty &&
        summaryData['youllCollect'] != null &&
        summaryData['youllCollect'] is Map) {
      return ' ${_formatSummaryAmount(summaryData['youllCollect'])}';
    }
    return ' ${_formatCurrency(collectAmt, '')}';
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
        'youllPay': {'currency': '', 'amount': youllPay},
        'youllCollect': {'currency': '', 'amount': youllCollect},
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
        'youllPay': {'currency': '', 'amount': youllPay},
        'youllCollect': {'currency': '', 'amount': youllCollect},
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

  // Helper to get a numeric amount from summary entry or formatted string
  double _numericAmountFromSummaryEntry(dynamic entry) {
    if (entry == null) return 0.0;
    if (entry is Map && entry['amount'] != null) {
      return _parseAmount(entry['amount']);
    }
    return _parseAmount(entry);
  }
}
