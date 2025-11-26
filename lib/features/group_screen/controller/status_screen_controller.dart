import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

class StatusScreenController extends GetxController {
  // Observable variables for API data
  final RxBool isLoading = false.obs;
  final RxString groupName = ''.obs;
  final RxInt totalMembers = 0.obs;
  final RxDouble totalExpenses = 0.0.obs;
  final RxString groupId = ''.obs;
  final RxString ownerEmail =
      ''.obs; // Add owner email to identify current user
  // Current logged-in user's email (cached from AuthService)
  final RxString currentUserEmail = ''.obs;

  // Summary data
  final RxString involvedCurrency = ''.obs;
  final RxDouble involvedAmount = 0.0.obs;
  final RxDouble myExpensesPercentage = 0.0.obs;
  final RxString myExpensesCurrency = ''.obs;
  final RxDouble myExpensesAmount = 0.0.obs;

  // Net balance
  final RxDouble netBalanceAmount = 0.0.obs;
  final RxString netBalanceStatus = ''.obs;
  final RxString netBalanceCurrency = ''.obs;

  // Category wise data
  final RxList<CategoryWiseStatus> categoryWiseData =
      <CategoryWiseStatus>[].obs;

  // Person wise data
  final RxList<PersonWiseStatus> personWiseData = <PersonWiseStatus>[].obs;

  // Available currencies
  final RxList<String> currencies = <String>[].obs;

  // Filter parameters
  final RxString expenseView = 'involving_me_only'.obs; // involving_me_only
  final RxString transactionType = 'i_borrowed'.obs; // i_borrowed | i_lent
  final RxString searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint("--- StatusScreenController Initialized ---");
    // Set some default values to prevent empty UI
    _setDefaultValues();
  }

  /// Sets default values for better UX
  void _setDefaultValues() {
    totalExpenses.value = 0.0;
    involvedAmount.value = 0.0;
    myExpensesAmount.value = 0.0;
    myExpensesPercentage.value = 0.0;
  }

  /// Fetches group status from API
  Future<void> fetchGroupStatus(String groupId) async {
    if (groupId.isEmpty) {
      debugPrint("⚠️ [STATUS] Warning: Group ID is empty");
      return;
    }

    this.groupId.value = groupId;
    isLoading.value = true;
    EasyLoading.show(status: 'Loading Status...');

    try {
      final String? token = await AuthService.getApprovalToken();
      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      debugPrint("🔑 [STATUS] Token found for group: $groupId");

      // Cache current logged-in user's email so we can mark "Me" in lists
      try {
        final String? userEmail = await AuthService.getUserEmail();
        currentUserEmail.value = userEmail ?? '';
        debugPrint("🔑 [STATUS] Current user email: ${currentUserEmail.value}");
      } catch (e) {
        debugPrint("⚠️ [STATUS] Could not read current user email: $e");
      }

      // Build query parameters
      final Map<String, String> queryParams = {
        'expenseView': expenseView.value,
        'transactionType': transactionType.value,
      };

      if (searchQuery.value.isNotEmpty) {
        queryParams['search'] = searchQuery.value;
      }

      final Uri url = Uri.parse(
        Urls.getGroupStatus(groupId),
      ).replace(queryParameters: queryParams);

      final headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      debugPrint("📡 [STATUS] API URL: $url");
      debugPrint("📋 [STATUS] Query Params: $queryParams");

      final http.Response response = await http.get(url, headers: headers);

      debugPrint("📊 [STATUS] Response Status: ${response.statusCode}");
      debugPrint("📄 [STATUS] Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          _parseApiResponse(responseData['data']);
          debugPrint("✅ [STATUS] Group status loaded successfully");
        } else {
          throw Exception(
            responseData['message'] ?? 'Failed to fetch group status',
          );
        }
      } else if (response.statusCode == 404 || response.statusCode == 500) {
        // Group not found or server error - silently skip status data
        // This is optional data, not critical to the app
        debugPrint(
          "ℹ️ [STATUS] Status data unavailable (${response.statusCode}): Continuing without status details",
        );
        return; // Exit early - don't throw exception
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch group status');
      }
    } catch (e) {
      // Silently handle errors - status screen is optional
      debugPrint("ℹ️ [STATUS] Status data unavailable, continuing without it");
    } finally {
      isLoading.value = false;
      EasyLoading.dismiss();
    }
  }

  /// Parses API response and updates observable variables
  void _parseApiResponse(Map<String, dynamic> data) {
    try {
      // Group data
      final groupData = data['group'] as Map<String, dynamic>? ?? {};
      groupName.value = groupData['groupName'] ?? '';
      totalMembers.value = groupData['totalMembers'] ?? 0;
      totalExpenses.value = (groupData['totalExpenses'] ?? 0).toDouble();
      ownerEmail.value = groupData['ownerEmail'] ?? '';

      // Summary data
      final summaryData = data['summary'] as Map<String, dynamic>? ?? {};

      // Prefer the API-provided currency when present; otherwise fall back
      // to user-selected currency from SettingController. No hardcoded
      // fallback is used — prefer empty string when nothing is available.
      String preferredCurrency = '';
      final String apiInvolvedCurrency = (summaryData['involvedCurrency'] ?? '')
          .toString();
      try {
        if (apiInvolvedCurrency.isNotEmpty) {
          preferredCurrency = apiInvolvedCurrency;
        } else {
          final setting = Get.find<SettingController>();
          final sel = setting.currency.value; // e.g. 'S\$' or 'US\$'
          if (sel.isNotEmpty) {
            preferredCurrency = sel;
          }
        }
      } catch (e) {
        // No SettingController available; prefer API value if present
        if (apiInvolvedCurrency.isNotEmpty) {
          preferredCurrency = apiInvolvedCurrency;
        }
      }

      involvedCurrency.value = preferredCurrency;
      involvedAmount.value = (summaryData['involvedAmount'] ?? 0).toDouble();
      myExpensesPercentage.value = (summaryData['myExpensesPercentage'] ?? 0)
          .toDouble();

      // Use API-provided myExpensesCurrency if present, otherwise prefer
      // the previously determined preferredCurrency (may be empty).
      myExpensesCurrency.value =
          (summaryData['myExpensesCurrency'] ?? preferredCurrency).toString();
      myExpensesAmount.value = (summaryData['myExpensesAmount'] ?? 0)
          .toDouble();

      // Net balance
      final netBalance = summaryData['netBalance'];
      if (netBalance != null && netBalance is Map) {
        netBalanceAmount.value = (netBalance['amount'] ?? 0).toDouble();
        netBalanceStatus.value = netBalance['status'] ?? '';
        // Use netBalance.currency from API if present; otherwise keep empty
        netBalanceCurrency.value = (netBalance['currency'] ?? preferredCurrency)
            .toString();
      }

      // Category wise data: parse then ensure displayed currency matches preferredCurrency
      final categoryWiseList = data['categoryWise'] as List? ?? [];
      final parsedCategories = categoryWiseList
          .map((item) => CategoryWiseStatus.fromJson(item))
          .map(
            (c) => CategoryWiseStatus(
              categoryName: c.categoryName,
              involved: AmountInfo(
                currency: (c.involved.currency.isNotEmpty)
                    ? c.involved.currency
                    : preferredCurrency,
                amount: c.involved.amount,
                percentage: c.involved.percentage,
              ),
              myExpense: AmountInfo(
                currency: (c.myExpense.currency.isNotEmpty)
                    ? c.myExpense.currency
                    : preferredCurrency,
                amount: c.myExpense.amount,
                percentage: c.myExpense.percentage,
              ),
            ),
          )
          .toList();
      categoryWiseData.assignAll(parsedCategories);

      // Person wise data: parse then override currency to preferredCurrency
      final personWiseList = data['personWise'] as List? ?? [];
      final parsedPersons = personWiseList
          .map((item) => PersonWiseStatus.fromJson(item))
          .map(
            (p) => PersonWiseStatus(
              memberEmail: p.memberEmail,
              memberName: p.memberName,
              involved: AmountInfo(
                currency: (p.involved.currency.isNotEmpty)
                    ? p.involved.currency
                    : preferredCurrency,
                amount: p.involved.amount,
                percentage: p.involved.percentage,
              ),
              myExpense: AmountInfo(
                currency: (p.myExpense.currency.isNotEmpty)
                    ? p.myExpense.currency
                    : preferredCurrency,
                amount: p.myExpense.amount,
                percentage: p.myExpense.percentage,
              ),
            ),
          )
          .toList();
      personWiseData.assignAll(parsedPersons);

      // Currencies
      final currencyList = data['currencies'] as List? ?? [];
      currencies.assignAll(currencyList.cast<String>());

      debugPrint("🔍 [STATUS] Parsed data:");
      debugPrint(
        "   - Group: ${groupName.value} (${totalMembers.value} members)",
      );
      debugPrint("   - Total Expenses: ${totalExpenses.value}");
      debugPrint(
        "   - My Expenses: ${myExpensesAmount.value} ${myExpensesCurrency.value}",
      );
      debugPrint(
        "   - Involved Amount: ${involvedAmount.value} ${involvedCurrency.value}",
      );
      debugPrint("   - Categories: ${categoryWiseData.length}");
      debugPrint("   - Members: ${personWiseData.length}");
      debugPrint("   - Owner Email: ${ownerEmail.value}");

      // Debug: log personWise members and whether they are identified as current user
      try {
        for (var p in personWiseData) {
          debugPrint(
            "🔎 [STATUS] Member: ${p.memberEmail} / ${p.memberName} -> isMe: ${isCurrentUser(p.memberEmail)}",
          );
        }
        debugPrint(
          "🔎 [STATUS] Current user cached email: ${currentUserEmail.value}",
        );
      } catch (e) {
        debugPrint("⚠️ [STATUS] Failed to debug-log members: $e");
      }
    } catch (e) {
      debugPrint("❌ [STATUS] Error parsing API response: $e");
      throw Exception('Failed to parse status data');
    }
  }

  /// Updates filter parameters and refetches data
  void updateFilters({
    String? expenseView,
    String? transactionType,
    String? search,
  }) {
    if (expenseView != null) this.expenseView.value = expenseView;
    if (transactionType != null) this.transactionType.value = transactionType;
    // ignore: unnecessary_this
    if (search != null) this.searchQuery.value = search;

    // Refetch data with new filters if group ID is available
    if (groupId.value.isNotEmpty) {
      fetchGroupStatus(groupId.value);
    }
  }

  /// Helper methods for UI formatting
  String getFormattedAmount(double amount, String currency) {
    if (amount >= 1000000) {
      // ignore: unnecessary_brace_in_string_interps
      return '${currency} ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      // ignore: unnecessary_brace_in_string_interps
      return '${currency} ${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      // ignore: unnecessary_brace_in_string_interps
      return '${currency} ${amount.toStringAsFixed(0)}';
    }
  }

  String getFormattedPercentage(double percentage) {
    return '${percentage.toStringAsFixed(1)}%';
  }

  // Helper method to get relative progress for categories (highest amount = 100%)
  double getRelativeProgress(double amount) {
    if (categoryWiseData.isEmpty) return 0.0;

    final maxAmount = categoryWiseData
        .map((category) => category.myExpense.amount)
        .reduce((max, current) => current > max ? current : max);

    if (maxAmount == 0) return 0.0;
    return amount / maxAmount;
  }

  // Helper method to get relative progress for group view (based on involved amounts)
  double getRelativeProgressForGroup(double amount) {
    // Prefer category-wise involved amounts if present; otherwise use person-wise involved
    if (categoryWiseData.isNotEmpty) {
      final maxAmount = categoryWiseData
          .map((category) => category.involved.amount)
          .fold<double>(0.0, (prev, curr) => curr > prev ? curr : prev);
      if (maxAmount == 0) return 0.0;
      return amount / maxAmount;
    }

    if (personWiseData.isNotEmpty) {
      final maxAmount = personWiseData
          .map((p) => p.involved.amount)
          .fold<double>(0.0, (prev, curr) => curr > prev ? curr : prev);
      if (maxAmount == 0) return 0.0;
      return amount / maxAmount;
    }

    return 0.0;
  }

  bool isCurrentUser(String memberEmail) {
    final normalizedMember = memberEmail.trim().toLowerCase();
    final normalizedCurrent = currentUserEmail.value.trim().toLowerCase();

    // Only mark a member as the current user when the member's email
    // exactly matches the logged-in user's email. Do NOT treat the
    // group owner as 'Me' unless the owner is the logged-in user.
    final isCurrent =
        normalizedMember.isNotEmpty && normalizedMember == normalizedCurrent;

    debugPrint("🔍 [USER_CHECK] Checking if $memberEmail is current user");
    debugPrint("   - Current user email: ${currentUserEmail.value}");
    debugPrint("   - Owner email: ${ownerEmail.value}");
    debugPrint("   - Is current: $isCurrent");

    return isCurrent;
  }

  // Get net balance display text
  String getNetBalanceDisplayText() {
    switch (netBalanceStatus.value) {
      case 'you_are_owed':
        return 'You\'ll collect';
      case 'you_owe':
        return 'You\'ll pay';
      default:
        return 'Balance';
    }
  }

  // Get net balance color
  Color getNetBalanceColor() {
    switch (netBalanceStatus.value) {
      case 'you_are_owed':
        return const Color(0xFF00D460); // Green
      case 'you_owe':
        return const Color(0xFFEF5C00); // Orange/Red
      default:
        return const Color(0xFF828282); // Grey
    }
  }
}

// Model classes for API response
class CategoryWiseStatus {
  final String categoryName;
  final AmountInfo involved;
  final AmountInfo myExpense;

  CategoryWiseStatus({
    required this.categoryName,
    required this.involved,
    required this.myExpense,
  });

  factory CategoryWiseStatus.fromJson(Map<String, dynamic> json) {
    return CategoryWiseStatus(
      categoryName: json['categoryName'] ?? '',
      involved: AmountInfo.fromJson(json['involved'] ?? {}),
      myExpense: AmountInfo.fromJson(json['myExpense'] ?? {}),
    );
  }
}

class PersonWiseStatus {
  final String memberEmail;
  final String memberName;
  final AmountInfo involved;
  final AmountInfo myExpense;

  PersonWiseStatus({
    required this.memberEmail,
    required this.memberName,
    required this.involved,
    required this.myExpense,
  });

  factory PersonWiseStatus.fromJson(Map<String, dynamic> json) {
    return PersonWiseStatus(
      memberEmail: json['memberEmail'] ?? '',
      memberName: (json['memberName'] ?? json['memberEmail'] ?? '').toString(),
      involved: AmountInfo.fromJson(json['involved'] ?? {}),
      myExpense: AmountInfo.fromJson(json['myExpense'] ?? {}),
    );
  }
}

class AmountInfo {
  final String currency;
  final double
  amount; // normalized amount used across the UI (prefer currentAmount)
  final double percentage;

  // Optional raw values from API (kept for future use / debugging)
  final double? originalAmount;
  final double? settledAmount;
  final double? currentAmountRaw;

  AmountInfo({
    required this.currency,
    required this.amount,
    required this.percentage,
    this.originalAmount,
    this.settledAmount,
    this.currentAmountRaw,
  });

  factory AmountInfo.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse various numeric shapes (int, double, string)
    double toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0.0;
    }

    // API may provide 'currentAmount' (preferred), or 'amount' in older responses.
    final double parsedOriginal = toDouble(
      json['originalAmount'] ?? json['original_amount'],
    );
    final double parsedSettled = toDouble(
      json['settledAmount'] ?? json['settled_amount'],
    );
    final double parsedCurrent = toDouble(
      json['currentAmount'] ?? json['current_amount'] ?? json['amount'],
    );
    final double parsedPercentage = toDouble(json['percentage']);

    final String parsedCurrency = (json['currency'] ?? '').toString();

    return AmountInfo(
      currency: parsedCurrency,
      amount: parsedCurrent,
      percentage: parsedPercentage,
      originalAmount: parsedOriginal != 0.0 ? parsedOriginal : null,
      settledAmount: parsedSettled != 0.0 ? parsedSettled : null,
      currentAmountRaw: parsedCurrent != 0.0 ? parsedCurrent : null,
    );
  }
}
