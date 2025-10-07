import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';

enum TripTextType { expenses, sliceup, status }

class TripTextController extends GetxController {
  final currentType = TripTextType.expenses.obs;

  // API related observables
  var isLoading = false.obs;
  final summaryData = <String, dynamic>{}.obs;
  var currentGroupId = ''.obs;
  var error = ''.obs;

  // SliceUp controller reference
  SliceUpController? _sliceUpController;

  // Mock data for status (until their APIs are integrated)
  final statusData = {}.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 [TRIP_TEXT_CONTROLLER] onInit called');
    // Auto-load data if we're on expenses tab and don't have a group ID
    if (currentType.value == TripTextType.expenses &&
        currentGroupId.value.isEmpty) {
      autoFetchFirstGroup();
    }
  }

  // Auto-fetch first group if no group ID is set
  Future<void> autoFetchFirstGroup() async {
    try {
      debugPrint('🔍 [TRIP_TEXT_CONTROLLER] Auto-fetching first group...');
      final token = await AuthService.getApprovalToken();
      if (token != null && token.isNotEmpty) {
        final firstGroupId = await getUserGroupsAndGetFirst(token);
        if (firstGroupId.isNotEmpty) {
          debugPrint(
            '✅ [TRIP_TEXT_CONTROLLER] Auto-setting groupId: $firstGroupId',
          );
          setGroupId(firstGroupId);
        }
      }
    } catch (e) {
      debugPrint('❌ [TRIP_TEXT_CONTROLLER] Error auto-fetching group: $e');
    }
  }

  void setTripTextType(TripTextType type) {
    currentType.value = type;

    // Debug: Check current state when type changes
    debugPrint('🔄 [TRIP_TEXT_CONTROLLER] setTripTextType called: $type');
    debugPrint(
      '🔄 [TRIP_TEXT_CONTROLLER] currentGroupId: ${currentGroupId.value}',
    );

    // Auto-fetch data when switching to expenses and we have a group ID
    if (type == TripTextType.expenses && currentGroupId.value.isNotEmpty) {
      debugPrint(
        '🚀 [TRIP_TEXT_CONTROLLER] Auto-fetching data for group: ${currentGroupId.value}',
      );
      fetchExpenseData(currentGroupId.value);
    } else if (type == TripTextType.sliceup &&
        currentGroupId.value.isNotEmpty) {
      debugPrint(
        '🚀 [TRIP_TEXT_CONTROLLER] Auto-fetching slice-up data for group: ${currentGroupId.value}',
      );
      _initializeSliceUpController();
    } else if (type == TripTextType.expenses) {
      debugPrint(
        '⚠️ [TRIP_TEXT_CONTROLLER] Cannot auto-fetch: no group ID set',
      );
    }
  }

  // Initialize SliceUpController when needed
  void _initializeSliceUpController() {
    if (_sliceUpController == null) {
      _sliceUpController = Get.put(
        SliceUpController(),
        tag: currentGroupId.value,
      );
      _sliceUpController!.setGroupId(currentGroupId.value);
    }
  }

  // Method to set group ID and auto-fetch data
  void setGroupId(String groupId) {
    debugPrint('🎯 [TRIP_TEXT_CONTROLLER] setGroupId called with: $groupId');
    if (currentGroupId.value != groupId) {
      currentGroupId.value = groupId;
      // Auto-fetch expense data when group changes and we're on expenses tab
      if (currentType.value == TripTextType.expenses && groupId.isNotEmpty) {
        debugPrint(
          '🚀 [TRIP_TEXT_CONTROLLER] Fetching data for new group: $groupId',
        );
        fetchExpenseData(groupId);
      } else if (currentType.value == TripTextType.sliceup &&
          groupId.isNotEmpty) {
        debugPrint(
          '🚀 [TRIP_TEXT_CONTROLLER] Fetching slice-up data for new group: $groupId',
        );
        _initializeSliceUpController();
      }
    } else {
      debugPrint('🔄 [TRIP_TEXT_CONTROLLER] Group ID unchanged: $groupId');
    }
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
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] primaryAmount: ${primaryAmount}');
    debugPrint('⚡ [TRIP_TEXT_CONTROLLER] secondaryAmount: ${secondaryAmount}');
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
          summaryData.clear();
          summaryData.addAll(summary);

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
        return 'You\'ll pay ';
      case TripTextType.sliceup:
        return 'You\'ll pay ';
      case TripTextType.status:
        return 'All sliced up and settled!';
    }
  }

  String get primaryAmount {
    debugPrint(
      '🎯 [TRIP_TEXT_CONTROLLER] primaryAmount getter called for type: ${currentType.value}',
    );
    switch (currentType.value) {
      case TripTextType.expenses:
        // Use API summary data only
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] Checking summaryData: isEmpty=${summaryData.isEmpty}',
        );
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] summaryData content: $summaryData',
        );
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] summaryData keys: ${summaryData.keys}',
        );

        if (summaryData.isNotEmpty && summaryData['youllPay'] != null) {
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] youllPay exists: ${summaryData['youllPay']}',
          );
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] youllPay type: ${summaryData['youllPay'].runtimeType}',
          );

          if (summaryData['youllPay'] is Map) {
            final amount = _formatSummaryAmount(summaryData['youllPay']);
            debugPrint(
              '✅ [TRIP_TEXT_CONTROLLER] primaryAmount (youllPay): $amount',
            );
            return amount;
          } else {
            debugPrint(
              '⚠️ [TRIP_TEXT_CONTROLLER] youllPay is not a Map: ${summaryData['youllPay']}',
            );
          }
        } else {
          debugPrint(
            '⚠️ [TRIP_TEXT_CONTROLLER] summaryData is empty or youllPay is null',
          );
          debugPrint(
            '⚠️ [TRIP_TEXT_CONTROLLER] isEmpty: ${summaryData.isEmpty}',
          );
          debugPrint(
            '⚠️ [TRIP_TEXT_CONTROLLER] youllPay exists: ${summaryData.containsKey('youllPay')}',
          );
        }
        debugPrint(
          '⚠️ [TRIP_TEXT_CONTROLLER] No summaryData for youllPay, showing default US\$0',
        );
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
        return 'You\'ll collect';
      case TripTextType.sliceup:
        return 'You’ll collect ';
      case TripTextType.status:
        return 'Pending';
    }
  }

  String get secondaryAmount {
    debugPrint(
      '🎯 [TRIP_TEXT_CONTROLLER] secondaryAmount getter called for type: ${currentType.value}',
    );
    switch (currentType.value) {
      case TripTextType.expenses:
        // Use API summary data only
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] Checking summaryData for youllCollect: isEmpty=${summaryData.isEmpty}',
        );
        debugPrint(
          '🔍 [TRIP_TEXT_CONTROLLER] youllCollect exists: ${summaryData.containsKey('youllCollect')}',
        );

        if (summaryData.isNotEmpty && summaryData['youllCollect'] != null) {
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] youllCollect content: ${summaryData['youllCollect']}',
          );
          debugPrint(
            '🔍 [TRIP_TEXT_CONTROLLER] youllCollect type: ${summaryData['youllCollect'].runtimeType}',
          );

          if (summaryData['youllCollect'] is Map) {
            final amount =
                ' ${_formatSummaryAmount(summaryData['youllCollect'])}';
            debugPrint(
              '✅ [TRIP_TEXT_CONTROLLER] secondaryAmount (youllCollect): $amount',
            );
            return amount;
          } else {
            debugPrint(
              '⚠️ [TRIP_TEXT_CONTROLLER] youllCollect is not a Map: ${summaryData['youllCollect']}',
            );
          }
        } else {
          debugPrint(
            '⚠️ [TRIP_TEXT_CONTROLLER] summaryData is empty or youllCollect is null',
          );
        }
        debugPrint(
          '⚠️ [TRIP_TEXT_CONTROLLER] No summaryData for youllCollect, showing default US\$0',
        );
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
