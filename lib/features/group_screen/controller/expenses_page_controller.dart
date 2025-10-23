// ignore_for_file: avoid_function_literals_in_foreach_calls, curly_braces_in_flow_control_structures

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ExpensesPageController extends GetxController {
  // Observable variables
  var isLoading = false.obs;
  var expenses = <Map<String, dynamic>>[].obs;
  var error = ''.obs;
  var isRefreshing = false.obs;

  // Group-specific data
  var groupId = ''.obs;
  var groupName = ''.obs;
  var groupInfo = <String, dynamic>{}.obs;
  var groupMembers = <Map<String, dynamic>>[].obs;

  // Total amount observables for this specific group
  var totalAmount = 0.0.obs;
  var totalOwed = 0.0.obs;
  var totalLent = 0.0.obs;
  var netBalance = 0.0.obs;

  // Filter state
  var currentExpenseView = ''.obs;
  var currentTransactionType = ''.obs;
  var currentSearchQuery = ''.obs;

  // Constructor to accept group ID
  ExpensesPageController({String? groupId}) {
    if (groupId != null) {
      this.groupId.value = groupId;
      debugPrint("💰 [EXPENSES_CONTROLLER] Initialized with groupId: $groupId");
    }
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint(
      "🔄 [EXPENSES_CONTROLLER] onInit called for groupId: ${groupId.value}",
    );
    // Load group details when controller is initialized
    if (groupId.value.isNotEmpty) {
      loadGroupDetails();
    }
  }

  // Method to clear all data for this trip
  void clearTripData() {
    debugPrint(
      "🧹 [EXPENSES_CONTROLLER] Clearing trip data for groupId: ${groupId.value}",
    );
    expenses.clear();
    error.value = '';
    totalAmount.value = 0.0;
    totalOwed.value = 0.0;
    totalLent.value = 0.0;
    netBalance.value = 0.0;
    groupInfo.clear();
    groupMembers.clear();
    isLoading.value = false;
    isRefreshing.value = false;

    // Clear filter state
    currentExpenseView.value = '';
    currentTransactionType.value = '';
    currentSearchQuery.value = '';
  }

  // Method to set new group ID and clear previous data
  void setGroupId(String newGroupId) {
    if (groupId.value != newGroupId) {
      debugPrint(
        "🔄 [EXPENSES_CONTROLLER] Switching from groupId: ${groupId.value} to: $newGroupId",
      );
      clearTripData();
      groupId.value = newGroupId;
      loadGroupDetails();
    }
  }

  @override
  void onClose() {
    debugPrint(
      "🗑️ [EXPENSES_CONTROLLER] Disposing controller for groupId: ${groupId.value}",
    );
    super.onClose();
  }

  // Main method to load group details and expenses for this specific group
  Future<void> loadGroupDetails({
    String? expenseView,
    String? transactionType,
    String? search,
  }) async {
    try {
      debugPrint(
        "📊 [EXPENSES_CONTROLLER] loadGroupDetails called for groupId: ${groupId.value}",
      );

      if (!isRefreshing.value) {
        isLoading.value = true;
      }
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view expenses';
        Get.snackbar(
          'Authentication Required',
          'Please login to view your expenses',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Get the current group ID - if not set, get user's groups first
      String currentGroupId = groupId.value;

      if (currentGroupId.isEmpty) {
        debugPrint(
          '🔍 [EXPENSES_CONTROLLER] No group ID set, fetching user groups first...',
        );
        currentGroupId = await getUserGroupsAndGetFirst(token);
        if (currentGroupId.isEmpty) {
          // No groups found - show empty state instead of error
          expenses.clear();
          debugPrint('📋 [EXPENSES_CONTROLLER] No groups found for user');
          return;
        }
        groupId.value = currentGroupId;
        debugPrint('✅ [EXPENSES_CONTROLLER] Using group ID: $currentGroupId');
      } else {
        debugPrint(
          '🎯 [EXPENSES_CONTROLLER] Using provided group ID: $currentGroupId',
        );
      }

      await getGroupDetails(
        token,
        currentGroupId,
        expenseView,
        transactionType,
        search,
      );
    } catch (e) {
      // Clear expenses and error, log error without showing error snackbar to user
      expenses.clear();
      error.value = ''; // Clear error to show empty state instead
      debugPrint('❌ Error in loadGroupDetails: $e');

      // Only show error snackbar for critical errors (like network issues)
      if (e.toString().contains('SocketException') ||
          e.toString().contains('TimeoutException')) {
        Get.snackbar(
          'Connection Error',
          'Please check your internet connection',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  // Get group details with expenses for specific group

  // Main API method to get group transactions
  // Get group details and expenses
  Future<void> getGroupExpenses({
    String? expenseView,
    String? transactionType,
    String? search,
  }) async {
    try {
      if (!isRefreshing.value) {
        isLoading.value = true;
      }
      error.value = '';

      // Store filter parameters
      currentExpenseView.value = expenseView ?? '';
      currentTransactionType.value = transactionType ?? '';
      currentSearchQuery.value = search ?? '';

      debugPrint('💰 [EXPENSES] Filter parameters stored:');
      debugPrint('💰 [EXPENSES] - expenseView: ${currentExpenseView.value}');
      debugPrint(
        '💰 [EXPENSES] - transactionType: ${currentTransactionType.value}',
      );
      debugPrint('💰 [EXPENSES] - search: ${currentSearchQuery.value}');

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      debugPrint('token: $token');
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view expenses';
        Get.snackbar(
          'Authentication Required',
          'Please login to view your expenses',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
        );
        return;
      }

      // Get the current group ID - if not set, get user's groups first
      String currentGroupId = groupId.value;

      if (currentGroupId.isEmpty) {
        debugPrint('🔍 No group ID set, fetching user groups first...');
        currentGroupId = await getUserGroupsAndGetFirst(token);
        if (currentGroupId.isEmpty) {
          // No groups found - show empty state instead of error
          expenses.clear();
          debugPrint('📋 No groups found for user');
          return;
        }
        groupId.value = currentGroupId;
        debugPrint('✅ Using group ID: $currentGroupId');
      }

      // Call API to get group details
      await getGroupDetails(
        token,
        currentGroupId,
        expenseView,
        transactionType,
        search,
      );
    } catch (e) {
      // Handle HTTP exceptions
      error.value = 'An unexpected error occurred: $e';

      Get.snackbar(
        'Error',
        error.value,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Get group transactions using the getGroupTransactions endpoint
  // Note: Method name kept as getGroupDetails for compatibility with existing calls
  Future<void> getGroupDetails(
    String token,
    String groupId,
    String? expenseView,
    String? transactionType,
    String? search,
  ) async {
    try {
      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Use the getGroupTransactions endpoint instead
      final url = Urls.getGroupTransactions(groupId);
      // final url = '${Urls.getGroupDetails}$groupId';

      debugPrint('🌐 Making request to: $url');
      debugPrint('🔑 Headers: $headers');
      debugPrint('🆔 Group ID: $groupId');

      // Make API call using http package
      var request = http.Request('GET', Uri.parse(url));

      request.headers.addAll(headers);

      debugPrint('📝 Making GET request to getGroupTransactions endpoint');

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        debugPrint('📋 Raw Response: $responseString');

        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        debugPrint('🔍 Parsed Response: $responseData');

        if (responseData['status'] == 'success' ||
            responseData['success'] == true) {
          final data = responseData['data'] as Map<String, dynamic>? ?? {};

          // For getGroupTransactions, look for expenses in the correct location
          List<dynamic> transactions = [];

          // Based on your API response, expenses are in data.expenses.list
          if (data['expenses'] != null && data['expenses']['list'] is List) {
            transactions = data['expenses']['list'] as List<dynamic>;
            debugPrint(
              '📋 Found transactions in data.expenses.list: ${transactions.length}',
            );
          } else if (data['expenses'] != null &&
              data['expenses']['byDate'] is Map) {
            // Alternative: get from byDate structure
            final byDate = data['expenses']['byDate'] as Map<String, dynamic>;
            transactions = [];
            byDate.values.forEach((dateExpenses) {
              if (dateExpenses is List) {
                transactions.addAll(dateExpenses);
              }
            });
            debugPrint(
              '📋 Found transactions in data.expenses.byDate: ${transactions.length}',
            );
          } else if (data['transactions'] is List) {
            transactions = data['transactions'] as List<dynamic>;
            debugPrint(
              '📋 Found transactions in data.transactions: ${transactions.length}',
            );
          } else if (data is List) {
            transactions = data as List<dynamic>;
            debugPrint(
              '📋 Found transactions in data directly: ${transactions.length}',
            );
          }

          debugPrint('📋 Total transactions found: ${transactions.length}');

          // Extract group info from the response
          final group = data['group'] as Map<String, dynamic>? ?? {};
          final summary = data['summary'] as Map<String, dynamic>? ?? {};

          // Update group info observables
          if (group.isNotEmpty) {
            groupInfo.value = group;
            groupName.value = group['groupName']?.toString() ?? 'Unknown Group';

            // Convert groupMembers from list of emails to proper format
            final memberEmails = group['groupMembers'] as List<dynamic>? ?? [];
            groupMembers.value = memberEmails
                .map(
                  (email) => {
                    'email': email.toString(),
                    'name': _extractNameFromEmail(email.toString()),
                  },
                )
                .toList();
          }

          // Update summary/totals if available
          if (summary.isNotEmpty) {
            final youllPay = summary['youllPay'] as Map<String, dynamic>? ?? {};
            final youllCollect =
                summary['youllCollect'] as Map<String, dynamic>? ?? {};

            totalOwed.value = _parseAmount(youllPay['amount']);
            totalLent.value = _parseAmount(youllCollect['amount']);
            netBalance.value = totalLent.value - totalOwed.value;
            totalAmount.value = _parseAmount(summary['totalExpenses']);
          }

          debugPrint('🏢 Group: ${groupName.value}');
          debugPrint('👥 Members: ${groupMembers.length}');
          debugPrint('💰 Total Expenses: ${totalAmount.value}');
          debugPrint('📋 Transactions: ${transactions.length}');

          // Convert transactions to proper format for UI
          final properTransactions = transactions.map((transaction) {
            if (transaction is Map) {
              return Map<String, dynamic>.from(transaction);
            }
            return <String, dynamic>{};
          }).toList();

          // Process expenses for display
          await processExpenses(properTransactions);

          debugPrint(
            '✅ Group transactions loaded successfully: ${properTransactions.length} transactions for group ${groupName.value}',
          );
        } else {
          // Clear expenses instead of showing error
          expenses.clear();
          debugPrint('❌ API returned error, clearing expenses');
        }
      } else if (response.statusCode == 401) {
        // Clear data and show session expired
        expenses.clear();
        Get.snackbar(
          'Session Expired',
          'Please login again',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else {
        // Clear expenses and log error without showing snackbar
        expenses.clear();
        debugPrint(
          '❌ Failed to load group transactions. Status: ${response.statusCode}',
        );
        final responseBody = await response.stream.bytesToString();
        debugPrint('❌ Response body: $responseBody');
      }
    } catch (e) {
      debugPrint('Error in getGroupDetails: $e');

      rethrow;
    }
  }

  // Process total amounts from API response
  Future<void> processTotalAmounts(
    Map<String, dynamic> totals,
    Map<String, dynamic> data,
  ) async {
    try {
      // Reset totals
      totalAmount.value = 0.0;
      totalOwed.value = 0.0;
      totalLent.value = 0.0;
      netBalance.value = 0.0;

      // Try different possible field names for totals
      // Check if totals are provided directly in the response
      if (totals.isNotEmpty) {
        totalAmount.value = _parseAmount(
          totals['total_amount'] ??
              totals['totalAmount'] ??
              totals['total'] ??
              0,
        );
        totalOwed.value = _parseAmount(
          totals['total_owed'] ?? totals['totalOwed'] ?? totals['owed'] ?? 0,
        );
        totalLent.value = _parseAmount(
          totals['total_lent'] ?? totals['totalLent'] ?? totals['lent'] ?? 0,
        );
        netBalance.value = _parseAmount(
          totals['net_balance'] ??
              totals['netBalance'] ??
              totals['balance'] ??
              0,
        );
      }

      // If totals are not provided, check other possible locations
      if (totalAmount.value == 0.0) {
        totalAmount.value = _parseAmount(
          data['total_amount'] ?? data['totalAmount'] ?? 0,
        );
        totalOwed.value = _parseAmount(
          data['total_owed'] ?? data['totalOwed'] ?? 0,
        );
        totalLent.value = _parseAmount(
          data['total_lent'] ?? data['totalLent'] ?? 0,
        );
        netBalance.value = _parseAmount(
          data['net_balance'] ?? data['netBalance'] ?? 0,
        );
      }

      // If still no totals, calculate from transactions
      if (totalAmount.value == 0.0 && data['transactions'] != null) {
        await calculateTotalsFromTransactions(data['transactions']);
      }
    } catch (e) {
      // Set default values on error
      totalAmount.value = 0.0;
      totalOwed.value = 0.0;
      totalLent.value = 0.0;
      netBalance.value = 0.0;
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

  // Helper method to format currency for display
  String formatCurrency(dynamic amount, String currency) {
    try {
      double val = 0.0;
      if (amount is num) {
        val = amount.toDouble();
      } else if (amount is String) {
        val = double.tryParse(amount) ?? 0.0;
      }
      final currencySymbol = getCurrencySymbol(currency);
      if ((val % 1) == 0) {
        return '$currencySymbol ${val.toInt()}';
      }
      return '$currencySymbol ${val.toStringAsFixed(2)}';
    } catch (e) {
      return 'US\$0';
    }
  }

  // Helper to return currency symbol
  String getCurrencySymbol(String currency) {
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
        return currency.toUpperCase();
    }
  }

  // Calculate totals from transactions if not provided by API
  Future<void> calculateTotalsFromTransactions(
    List<dynamic> transactions,
  ) async {
    try {
      double totalAmountCalc = 0.0;
      double totalOwedCalc = 0.0;
      double totalLentCalc = 0.0;

      for (var transaction in transactions) {
        final amount = _parseAmount(transaction['amount'] ?? 0);
        final status = _getTransactionStatus(transaction);

        totalAmountCalc += amount.abs(); // Add absolute value to total

        switch (status.toLowerCase()) {
          case 'you borrowed':
            totalOwedCalc += amount.abs();
            break;
          case 'you lent':
            totalLentCalc += amount.abs();
            break;
        }
      }

      totalAmount.value = totalAmountCalc;
      totalOwed.value = totalOwedCalc;
      totalLent.value = totalLentCalc;
      netBalance.value =
          totalLentCalc -
          totalOwedCalc; // Positive if you're owed money, negative if you owe

      // ignore: empty_catches
    } catch (e) {}
  }

  // Process expenses and group by date
  Future<void> processExpenses(List<dynamic> transactions) async {
    try {
      debugPrint(
        '💰 [EXPENSES] Processing ${transactions.length} transactions with filters:',
      );
      debugPrint(
        '💰 [EXPENSES] - currentExpenseView: ${currentExpenseView.value}',
      );
      debugPrint(
        '💰 [EXPENSES] - currentTransactionType: ${currentTransactionType.value}',
      );

      // First, format all transactions
      List<Map<String, dynamic>> formattedList = [];
      for (var transaction in transactions) {
        final expense = await formatExpenseData(transaction);
        formattedList.add(expense);
      }

      // Deduplicate potential duplicates by date + category + total amount
      final Map<String, Map<String, dynamic>> dedupedMap = {};
      for (var expense in formattedList) {
        final date = (expense['date'] ?? '').toString();
        final categoryName = (expense['categoryName'] ?? '').toString();
        final rawTotal = expense['rawData'] != null
            ? (expense['rawData']['totalExpenseAmount'] ??
                      expense['rawData']['amount'] ??
                      expense['formattedTotalAmount'])
                  .toString()
            : expense['formattedTotalAmount'].toString();

        final key = '${date}_${categoryName}_$rawTotal';

        if (!dedupedMap.containsKey(key)) {
          dedupedMap[key] = expense;
        } else {
          final existing = dedupedMap[key]!;
          final existingNotes = (existing['notes'] ?? '').toString();
          final currentNotes = (expense['notes'] ?? '').toString();

          // Prefer the one with user notes
          if (existingNotes.isEmpty && currentNotes.isNotEmpty) {
            dedupedMap[key] = expense;
          } else if (existingNotes.isNotEmpty && currentNotes.isEmpty) {
            // keep existing
          } else if (existingNotes.isNotEmpty && currentNotes.isNotEmpty) {
            if (currentNotes.length > existingNotes.length)
              dedupedMap[key] = expense;
          }
        }
      }

      // Apply filters and group by date
      Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
      int filteredCount = 0;
      final dedupedList = dedupedMap.values.toList();
      for (var expense in dedupedList) {
        // Filter out General/uncategorized transactions
        final categoryName = expense['categoryName'] as String? ?? '';
        if (categoryName.toLowerCase() == 'general' ||
            categoryName.toLowerCase() == 'uncategorized' ||
            categoryName.isEmpty) {
          debugPrint(
            '💰 [EXPENSES] Filtering out general/uncategorized transaction: ${expense['title']}',
          );
          continue;
        }

        // Transaction type filter
        if (currentTransactionType.value.isNotEmpty) {
          final status = expense['status'] as String;
          bool shouldInclude = false;
          if (currentTransactionType.value == 'borrowed' &&
              status == 'You borrowed')
            shouldInclude = true;
          if (currentTransactionType.value == 'lent' && status == 'You lent')
            shouldInclude = true;
          if (!shouldInclude) {
            filteredCount++;
            continue;
          }
        }

        // Involving me filter
        if (currentExpenseView.value == 'involving_me') {
          final userInvolvement = expense['rawData']?['userInvolvement'] ?? {};
          final netAmount = userInvolvement['net'] ?? 0.0;
          if (netAmount == 0.0) continue;
        }

        // Search filter
        if (currentSearchQuery.value.isNotEmpty) {
          final title = expense['title'] as String;
          final notes = expense['notes'] as String;
          final searchLower = currentSearchQuery.value.toLowerCase();
          if (!title.toLowerCase().contains(searchLower) &&
              !notes.toLowerCase().contains(searchLower))
            continue;
        }

        final date = expense['date'] as String;
        if (groupedExpenses[date] == null) groupedExpenses[date] = [];
        groupedExpenses[date]!.add(expense);
      }

      // Convert to list format expected by UI
      List<Map<String, dynamic>> formattedExpenses = [];
      groupedExpenses.forEach((date, dayExpenses) {
        formattedExpenses.add({'date': date, 'expenses': dayExpenses});
      });

      // Sort by date (most recent first)
      formattedExpenses.sort((a, b) {
        try {
          DateTime dateA = DateFormat('EEE dd MMM yyyy').parse(a['date']);
          DateTime dateB = DateFormat('EEE dd MMM yyyy').parse(b['date']);
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      expenses.value = formattedExpenses;
      debugPrint(
        '💰 [EXPENSES] Final result: ${formattedExpenses.length} day groups, $filteredCount transactions filtered out',
      );
    } catch (e) {
      error.value = 'Error processing expense data';
      debugPrint('❌ [EXPENSES] Error in processExpenses: $e');
    }
  }

  // Format individual expense data
  Future<Map<String, dynamic>> formatExpenseData(
    Map<String, dynamic> transaction,
  ) async {
    try {
      // Extract basic info from your API structure
      final amount = transaction['totalExpenseAmount'] ?? 0;
      // Prefer the user's selected currency (if available) for display labels.
      String currency = transaction['currency'] ?? 'USD';
      try {
        final setting = Get.find<SettingController>();
        final sel = setting.currency.value;
        if (sel.isNotEmpty) {
          final mapped = _mapSelectedCurrencyToCode(sel);
          if (mapped != null && mapped.isNotEmpty) {
            currency = mapped;
          }
        }
      } catch (e) {
        // no settings controller available, fall back to transaction currency
      }
      final category = transaction['category'] ?? {};
      final createdAt = transaction['expenseDate'] ?? '';
      var notesRaw = transaction['note'] ?? '';
      String notes = notesRaw.toString().trim();
      // Treat common placeholders like 'no note' (case-insensitive) as empty
      final notesLower = notes.toLowerCase();
      if (notesLower == 'no note' ||
          notesLower == 'nonote' ||
          notesLower == 'expense note') {
        notes = '';
      }
      final userInvolvement = transaction['userInvolvement'] ?? {};

      // Format date
      String formattedDate = 'Today';
      if (createdAt.isNotEmpty) {
        try {
          final date = DateTime.parse(createdAt);
          formattedDate = DateFormat('EEE dd MMM yyyy').format(date);
          // ignore: empty_catches
        } catch (e) {}
      }

      // Format total amount and per-user amount
      final formattedTotalAmount = formatCurrency(amount, currency);
      // Prefer user-specific amount when available (userInvolvement.amount),
      // otherwise fall back to net or the total expense amount.
      final dynamic userAmountRaw =
          userInvolvement['amount'] ?? userInvolvement['net'] ?? 0;
      final double userAmount = (userAmountRaw is num)
          ? userAmountRaw.toDouble()
          : double.tryParse(userAmountRaw.toString()) ?? 0.0;
      final formattedUserAmount = formatCurrency(userAmount, currency);

      // Get category info from API data
      String categoryName = 'General';

      if (category is Map && category.isNotEmpty) {
        categoryName = category['name'] ?? 'General';
        // Keep the original category name as it comes from API (with emoji if present)
        // No processing needed since we want to show "🩸 blood" as is
      }

      // Determine transaction status from userInvolvement
      String status = 'Unknown';
      Color statusColor = Colors.grey;

      final userStatus = userInvolvement['status'] ?? '';
      final netAmount = userInvolvement['net'] ?? 0.0;

      if (userStatus == 'settled' || netAmount == 0) {
        status = 'Settled';
        statusColor = Colors.grey;
      } else if (userStatus == 'you_lent' || netAmount > 0) {
        status = 'You lent';
        statusColor = Colors.green;
      } else if (userStatus == 'you_borrowed' || netAmount < 0) {
        status = 'You borrowed';
        statusColor = Colors.red;
      }

      final expenseId =
          transaction['_id'] ??
          transaction['expenseId'] ??
          transaction['id'] ??
          '';

      return {
        // expose the API's primary id under expenseId and keep id for compatibility
        'expenseId': expenseId,
        'id': expenseId,
        'title': categoryName.isNotEmpty ? categoryName : 'Transport',
        // 'amount' kept for backward-compat but UI prefers 'formattedAmount' below
        'amount': formattedTotalAmount,
        'date': formattedDate,
        'status': status,
        'statusColor': statusColor,
        'notes': notes,
        'category': categoryName,
        'categoryName': categoryName, // Add this for filtering
        // Expose both total and per-user formatted amounts
        'formattedAmount': formattedUserAmount,
        'formattedTotalAmount': formattedTotalAmount,
        'rawUserAmount': userAmount,
        'rawData': transaction,
      };
    } catch (e) {
      return {
        'id': '',
        'title': 'Unknown',
        'amount': 'US\$ 0',
        'date': 'Today',
        'status': 'Unknown',
        'statusColor': Colors.grey,
        'notes': '',
        'category': 'General',
        'categoryName': 'General',
        'rawData': transaction,
      };
    }
  }

  String? _mapSelectedCurrencyToCode(String selected) {
    final s = selected.toUpperCase();
    if (s.contains('USD') ||
        s.contains('US\$') ||
        s.contains('\$') && !s.contains('SGD') && !s.contains('S\$'))
      return 'USD';
    if (s.contains('EUR') || s.contains('€')) return 'EUR';
    if (s.contains('JPY') || s.contains('¥')) return 'JPY';
    if (s.contains('KRW') || s.contains('₩')) return 'KRW';
    if (s.contains('SGD') || s.contains('S\$')) return 'SGD';
    // fallback: try to extract alphabetic code
    final letters = RegExp(r'[A-Z]{3}').firstMatch(s);
    if (letters != null) return letters.group(0);
    return null;
  }

  // Get category icon
  String getCategoryIcon(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'food':
      case 'restaurant':
      case 'lunch':
      case 'dinner':
      case 'breakfast':
      case 'snacks':
        return '🍔';
      case 'transport':
      case 'taxi':
      case 'uber':
      case 'bus':
      case 'train':
        return '🚕';
      case 'hotel':
      case 'accommodation':
      case 'lodging':
        return '🏨';
      case 'entertainment':
      case 'movie':
      case 'games':
        return '🎬';
      case 'shopping':
      case 'clothes':
      case 'fashion':
        return '🛍️';
      case 'fuel':
      case 'gas':
      case 'petrol':
        return '⛽';
      case 'coffee':
      case 'drinks':
      case 'beverages':
        return '☕';
      case 'flight':
      case 'airplane':
      case 'air travel':
        return '✈️';
      case 'groceries':
      case 'supermarket':
        return '🛒';
      case 'medical':
      case 'health':
      case 'hospital':
        return '🏥';
      case 'education':
      case 'books':
      case 'school':
        return '📚';
      case 'beauty':
      case 'cosmetics':
      case 'salon':
        return '💄';
      case 'sports':
      case 'gym':
      case 'fitness':
        return '⚽';
      case 'bills':
      case 'utilities':
        return '�';
      case 'rent':
      case 'housing':
        return '🏠';
      case 'gifts':
        return '🎁';
      case 'charity':
      case 'donation':
        return '❤️';
      default:
        return '�💰';
    }
  }

  // Get category name by ID
  String getCategoryNameById(String categoryId) {
    // Since we removed categories observable, return default
    return 'General';
  }

  // Get category icon by ID
  String getCategoryIconById(String categoryId) {
    // Since we removed categories observable, use getCategoryIcon with default
    return getCategoryIcon('General');
  }

  // Helper method to determine transaction status
  String _getTransactionStatus(Map<String, dynamic> expense) {
    try {
      // This logic depends on your API structure
      // You'll need to implement based on how your API indicates user involvement
      // final paidBy = expense['paidBy'] ?? {};
      // final shareWith = expense['shareWith'] ?? [];

      // Check if there's a specific status field in the API response
      if (expense.containsKey('user_status')) {
        return expense['user_status'] ?? 'Unknown';
      }

      if (expense.containsKey('transaction_status')) {
        return expense['transaction_status'] ?? 'Unknown';
      }

      // Check paid by and share with information
      final paidBy = expense['paid_by'] ?? expense['paidBy'] ?? {};
      final shareWith = expense['share_with'] ?? expense['shareWith'] ?? [];
      final currentUserId =
          expense['current_user_id']; // You'll need to get this from auth

      // If current user paid
      if (paidBy is Map &&
          paidBy['id'] != null &&
          paidBy['id'].toString() == currentUserId?.toString()) {
        return 'You lent';
      }

      // If current user is in share list but didn't pay
      if (shareWith is List &&
          shareWith.any(
            (user) => user['id']?.toString() == currentUserId?.toString(),
          )) {
        return 'You borrowed';
      }

      // Simplified logic based on amount for fallback
      final amount = double.tryParse(expense['amount'].toString()) ?? 0;

      if (amount > 0) {
        return 'You borrowed';
      } else if (amount < 0) {
        return 'You lent';
      } else {
        return 'Not yours';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  // Get formatted notes
  String getFormattedNotes(String notes) {
    if (notes.isEmpty) return '';
    // Truncate notes if too long
    if (notes.length > 100) {
      // ignore: prefer_interpolation_to_compose_strings
      return notes.substring(0, 97) + '...';
    }
    return notes;
  }

  // Check if expense has notes
  bool hasNotes(Map<String, dynamic> expense) {
    final notes = expense['notes'] ?? '';
    return notes.toString().isNotEmpty;
  }

  // Get status color
  // Refresh method for pull-to-refresh
  Future<void> refreshExpenses() async {
    isRefreshing.value = true;
    // Refresh group details and expenses
    await loadGroupDetails();
  }

  // Refresh categories only - simplified since we removed categories API
  Future<void> refreshCategories() async {
    // No longer needed since we removed categories API
  }

  // Search expenses
  Future<void> searchExpenses(String query) async {
    await getGroupExpenses(search: query);
  }

  // Filter by expense view
  Future<void> filterByView(String view) async {
    await getGroupExpenses(expenseView: view);
  }

  // Filter by transaction type
  Future<void> filterByType(String type) async {
    await getGroupExpenses(transactionType: type);
  }

  // Check if any filters are applied
  bool get hasActiveFilters {
    return currentExpenseView.value.isNotEmpty ||
        currentTransactionType.value.isNotEmpty ||
        currentSearchQuery.value.isNotEmpty;
  }

  // Clear all filters
  Future<void> clearFilters() async {
    currentExpenseView.value = '';
    currentTransactionType.value = '';
    currentSearchQuery.value = '';
    await loadGroupDetails(); // Reload data without filters
  }

  // Get current filter description
  String getActiveFiltersDescription() {
    List<String> descriptions = [];

    if (currentExpenseView.value == 'involving_me') {
      descriptions.add('Involving me only');
    }

    if (currentTransactionType.value == 'borrowed') {
      descriptions.add('I borrowed');
    } else if (currentTransactionType.value == 'lent') {
      descriptions.add('I lent');
    }

    if (currentSearchQuery.value.isNotEmpty) {
      descriptions.add('Search: "${currentSearchQuery.value}"');
    }

    return descriptions.isEmpty ? 'No filters' : descriptions.join(' • ');
  }

  // Formatted total amount getters
  String get formattedTotalAmount => formatCurrency(totalAmount.value, 'USD');
  String get formattedTotalOwed => formatCurrency(totalOwed.value, 'USD');
  String get formattedTotalLent => formatCurrency(totalLent.value, 'USD');
  String get formattedNetBalance => formatCurrency(netBalance.value, 'USD');

  // Check if user owes money
  bool get oweseMoney => netBalance.value < 0;

  // Check if user is owed money
  bool get isOwedMoney => netBalance.value > 0;

  // Get net balance status
  String get netBalanceStatus {
    if (netBalance.value > 0) {
      return 'You are owed';
    } else if (netBalance.value < 0) {
      return 'You owe';
    } else {
      return 'Settled up';
    }
  }

  // Get net balance color
  Color get netBalanceColor {
    if (netBalance.value > 0) {
      return Colors.green;
    } else if (netBalance.value < 0) {
      return Colors.red;
    } else {
      return Colors.grey;
    }
  }

  // Helper method to extract name from email
  String _extractNameFromEmail(String email) {
    if (email.contains('@')) {
      String username = email.split('@')[0];

      // Handle emails with dots (like rezwanrahim.rupak)
      if (username.contains('.')) {
        List<String> parts = username.split('.');
        // Take first name + last initial or first 2 parts
        if (parts.length >= 2) {
          String firstName = parts[0];
          String lastName = parts[1];
          // If names are too similar, include more of the last name
          if (firstName.length >= 8) {
            return '${firstName.substring(0, 7)}${lastName[0].toUpperCase()}';
          } else {
            return '${firstName[0].toUpperCase()}${firstName.substring(1)} ${lastName[0].toUpperCase()}';
          }
        }
      }

      // Handle emails with numbers (like rezwanrahim31)
      if (username.contains(RegExp(r'\d'))) {
        // Extract the numeric part to differentiate
        String numbers = username.replaceAll(RegExp(r'[^0-9]'), '');
        String letters = username.replaceAll(RegExp(r'[0-9]'), '');
        if (letters.length >= 6 && numbers.isNotEmpty) {
          return '${letters.substring(0, 6)}$numbers';
        }
      }

      // Default: capitalize first letter of each word
      return username
          .replaceAll('.', ' ')
          .split(' ')
          .map(
            (word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '',
          )
          .join(' ');
    }
    return email;
  }

  // Get user's groups and return the first group ID
  Future<String> getUserGroupsAndGetFirst(String token) async {
    try {
      debugPrint('🔄 Getting user groups...');

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Urls.getGroups));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 GetGroups Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 GetGroups Parsed Response: $responseData');

        if (responseData['data'] != null &&
            responseData['data']['groups'] != null) {
          final List<dynamic> groups = responseData['data']['groups'];
          debugPrint('👥 Found ${groups.length} groups');

          if (groups.isNotEmpty) {
            final firstGroup = groups.first;
            final groupId =
                firstGroup['_id'] ?? firstGroup['id'] ?? firstGroup['groupId'];
            if (groupId != null) {
              debugPrint('✅ Using first group ID: $groupId');
              return groupId.toString();
            }
          }
        }
      } else {
        debugPrint('❌ GetGroups failed with status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Exception in getUserGroupsAndGetFirst: $e');
    }

    return '';
  }
}
