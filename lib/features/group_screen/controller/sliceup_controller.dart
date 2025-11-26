import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/group_screen/widgets/individual_card.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart'
    as triptext;
import 'package:teddy_5618/features/group_screen/widgets/sliceup_balance_card.dart';
import 'package:teddy_5618/core/constants/currency_symbols.dart';

class SliceUpController extends GetxController {
  // API related observables
  var isLoading = false.obs;
  var error = ''.obs;
  var currentGroupId = ''.obs;

  // API response data observables
  final groupData = <String, dynamic>{}.obs;
  final summaryData = <String, dynamic>{}.obs;
  final settlements = <Map<String, dynamic>>[].obs;
  final totalBalances = <Map<String, dynamic>>[].obs;
  var isAllSettled = false.obs;

  // Formatted data for UI
  final youllPayAmount = ''.obs;
  final youllCollectAmount = ''.obs;
  final totalExpenses = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('🔄 [SLICEUP_CONTROLLER] onInit called');
  }

  // Method to set group ID and fetch slice-up data
  void setGroupId(String groupId) {
    debugPrint('🎯 [SLICEUP_CONTROLLER] setGroupId called with: $groupId');
    if (currentGroupId.value != groupId) {
      currentGroupId.value = groupId;
      if (groupId.isNotEmpty) {
        debugPrint(
          '🚀 [SLICEUP_CONTROLLER] Fetching slice-up data for group: $groupId',
        );
        fetchSliceUpData(groupId);
      }
    } else {
      debugPrint('🔄 [SLICEUP_CONTROLLER] Group ID unchanged: $groupId');
    }
  }

  // Method to fetch slice-up data from API
  Future<void> fetchSliceUpData(String groupId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        error.value = 'Please login to view slice-up data';
        debugPrint('❌ [SLICEUP_CONTROLLER] No token available');
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

      // Make API call to getSliceUp
      final url = Urls.getSliceUp(groupId);
      debugPrint('🌐 [SLICEUP_CONTROLLER] Fetching slice-up data from: $url');
      debugPrint('🔑 [SLICEUP_CONTROLLER] Headers: $headers');

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint(
        '📋 [SLICEUP_CONTROLLER] Response status: ${response.statusCode}',
      );
      debugPrint('📋 [SLICEUP_CONTROLLER] Raw Response: $responseString');

      if (response.statusCode == 200) {
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        debugPrint(
          '🔍 [SLICEUP_CONTROLLER] Parsed responseData keys: ${responseData.keys}',
        );

        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          debugPrint('✅ [SLICEUP_CONTROLLER] Slice-up data found');
          debugPrint('🔍 [SLICEUP_CONTROLLER] Data structure: ${data.keys}');

          // Update group data
          if (data['group'] != null) {
            // ✅ FIX: Use assignAll() for consistent observable updates
            groupData.assignAll(data['group']);

            debugPrint('📊 [SLICEUP_CONTROLLER] Group data: $groupData');
          }

          // Build summary data from available fields
          // (slice-up API doesn't provide a summary field directly)
          _buildSummaryFromSliceUpData(data);
          debugPrint('📊 [SLICEUP_CONTROLLER] Summary data: $summaryData');

          // Update settlements
          if (data['settlements'] != null) {
            // ✅ FIX: Use assignAll() instead of clear() + addAll()
            // This ensures Obx() widgets properly detect changes
            settlements.assignAll(
              List<Map<String, dynamic>>.from(data['settlements']),
            );
            debugPrint(
              '📊 [SLICEUP_CONTROLLER] Settlements (${settlements.length}): $settlements',
            );
          }

          // Update total balances
          if (data['totalBalances'] != null) {
            // ✅ FIX: Use assignAll() instead of clear() + addAll()
            totalBalances.assignAll(
              List<Map<String, dynamic>>.from(data['totalBalances']),
            );
            debugPrint(
              '📊 [SLICEUP_CONTROLLER] Total balances (${totalBalances.length}): $totalBalances',
            );
          }

          // Update settlement status
          isAllSettled.value = data['isAllSettled'] ?? false;
          debugPrint(
            '📊 [SLICEUP_CONTROLLER] Is all settled: ${isAllSettled.value}',
          );

          // Notify TripTextController (if registered) so TripText mirrors update
          try {
            final tag = groupId;
            if (tag.isNotEmpty &&
                Get.isRegistered<triptext.TripTextController>(tag: tag)) {
              final ttc = Get.find<triptext.TripTextController>(tag: tag);
              // Only sync settlement status and structured summary data.
              ttc.sliceupIsAllSettled.value = isAllSettled.value;
              // Also sync summary data so totalExpenses is available for TripText
              ttc.summaryData.clear();
              ttc.summaryData.addAll({
                'youllPay':
                    summaryData['youllPay'] ?? {'currency': '', 'amount': 0},
                'youllCollect':
                    summaryData['youllCollect'] ??
                    {'currency': '', 'amount': 0},
                'totalExpenses': summaryData['totalExpenses'] ?? 0,
              });
              ttc.summaryData.refresh();
              debugPrint(
                '🔔 [SLICEUP_CONTROLLER] Notified TripTextController for group: $tag',
              );
            }
          } catch (e) {
            debugPrint(
              '❌ [SLICEUP_CONTROLLER] Failed to notify TripTextController: $e',
            );
          }

          debugPrint(
            '✅ [SLICEUP_CONTROLLER] Slice-up data loaded successfully',
          );
        } else {
          error.value = 'No slice-up data found in response';
          debugPrint('❌ [SLICEUP_CONTROLLER] No slice-up data: $responseData');
        }
      } else {
        error.value = 'Failed to fetch slice-up data: ${response.statusCode}';
        debugPrint('❌ [SLICEUP_CONTROLLER] HTTP Error: ${response.statusCode}');
        debugPrint('❌ [SLICEUP_CONTROLLER] Response body: $responseString');
      }
    } catch (e) {
      error.value = 'Error fetching slice-up data: $e';
      debugPrint('❌ [SLICEUP_CONTROLLER] Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Helper method to build summary data from slice-up API response
  void _buildSummaryFromSliceUpData(Map<String, dynamic> data) {
    try {
      // IMPORTANT: Use the API's summary field directly if available.
      // The API already calculates the correct youllPay and youllCollect.
      if (data['summary'] != null) {
        final apiSummary = data['summary'] as Map<String, dynamic>;
        summaryData.assignAll({
          'youllPay': apiSummary['youllPay'] ?? {'currency': '', 'amount': 0},
          'youllCollect':
              apiSummary['youllCollect'] ?? {'currency': '', 'amount': 0},
          'totalExpenses': apiSummary['totalExpenses'] ?? 0,
        });
        debugPrint(
          '✅ [SLICEUP_CONTROLLER] Using API summary directly: $summaryData',
        );
      } else {
        // Fallback: Calculate from totalBalances if API summary is not available
        final totalExp = (groupData['totalExpenses'] ?? 0).toDouble();
        double youllPayAmt = 0.0;
        double youllCollectAmt = 0.0;

        if (data['totalBalances'] != null) {
          final balances = List<Map<String, dynamic>>.from(
            data['totalBalances'],
          );
          for (var balance in balances) {
            final netBalance = (balance['netBalance'] ?? 0).toDouble();
            if (netBalance < 0) {
              youllPayAmt += netBalance.abs();
            } else if (netBalance > 0) {
              youllCollectAmt += netBalance;
            }
          }
        }

        summaryData.assignAll({
          'youllPay': {'currency': '', 'amount': youllPayAmt},
          'youllCollect': {'currency': '', 'amount': youllCollectAmt},
          'totalExpenses': totalExp,
        });
        debugPrint(
          '⚠️ [SLICEUP_CONTROLLER] Calculated summary from balances (API summary not available)',
        );
      }

      // Format amounts for display
      _formatSummaryAmounts();

      debugPrint(
        '✅ [SLICEUP_CONTROLLER] Built summaryData from slice-up response',
      );
    } catch (e) {
      debugPrint('❌ [SLICEUP_CONTROLLER] Error building summary: $e');
    }
  }

  // Helper method to format summary amounts for UI display
  void _formatSummaryAmounts() {
    if (summaryData.isNotEmpty) {
      // Prefer normalized 'youllPay'/'youllCollect' map entries.
      if (summaryData['youllPay'] != null) {
        final payData = summaryData['youllPay'] as Map<String, dynamic>;
        final currency = payData['currency'] ?? '';
        final amount = payData['amount'] ?? 0;
        youllPayAmount.value = _formatCurrency(amount, currency);
      } else if (summaryData['totalUserBorrowed'] != null) {
        // Some API responses provide totals directly
        final amount = summaryData['totalUserBorrowed'] ?? 0;
        final currency = summaryData['currency'] ?? '';
        youllPayAmount.value = _formatCurrency(amount, currency);
      }

      if (summaryData['youllCollect'] != null) {
        final collectData = summaryData['youllCollect'] as Map<String, dynamic>;
        final currency = collectData['currency'] ?? '';
        final amount = collectData['amount'] ?? 0;
        youllCollectAmount.value = _formatCurrency(amount, currency);
      } else if (summaryData['totalUserLent'] != null) {
        final amount = summaryData['totalUserLent'] ?? 0;
        final currency = summaryData['currency'] ?? '';
        youllCollectAmount.value = _formatCurrency(amount, currency);
      }

      // Set total expenses
      totalExpenses.value = (summaryData['totalExpenses'] ?? 0).toDouble();

      debugPrint('💰 [SLICEUP_CONTROLLER] Formatted amounts:');
      debugPrint(
        '💰 [SLICEUP_CONTROLLER] You\'ll pay: ${youllPayAmount.value}',
      );
      debugPrint(
        '💰 [SLICEUP_CONTROLLER] You\'ll collect: ${youllCollectAmount.value}',
      );
      debugPrint(
        '💰 [SLICEUP_CONTROLLER] Total expenses: ${totalExpenses.value}',
      );
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

  // Helper method to get currency symbol. Uses centralized `currencySymbols` map.
  String _getCurrencySymbol(String currency) {
    final key = currency.toString().toUpperCase();
    // If the API already returned a symbol (e.g. 'HK$'), return it unchanged.
    if (currency.contains(RegExp(r'[^A-Za-z0-9]'))) {
      return currency;
    }
    return currencySymbols[key] ?? currency;
  }

  // Getter methods for accessing formatted data
  String get groupName => groupData['groupName'] ?? '';
  int get totalMembers => groupData['totalMembers'] ?? 0;
  List<String> get groupMembers =>
      List<String>.from(groupData['groupMembers'] ?? []);

  // Current currency used for display. Prefer API summary currency, then group currency.
  String get currency {
    try {
      if (summaryData.isNotEmpty && summaryData['youllPay'] != null) {
        final p = summaryData['youllPay'] as Map<String, dynamic>;
        if (p['currency'] != null && p['currency'].toString().isNotEmpty) {
          return p['currency'].toString();
        }
      }
      if (groupData.isNotEmpty &&
          groupData['currency'] != null &&
          groupData['currency'].toString().isNotEmpty) {
        return groupData['currency'].toString();
      }
    } catch (e) {
      // ignore and fall back
    }
    return '';
  }

  // Helper method to get balance for a specific member
  String getBalanceForMember(String memberEmail) {
    // Check settlements where this member is involved
    for (var settlement in settlements) {
      if (settlement['from'].toString() == memberEmail) {
        final amount = settlement['amount'] ?? 0;
        return 'Pay ${_formatCurrency(amount, currency)}';
      }
      if (settlement['to'].toString() == memberEmail) {
        final amount = settlement['amount'] ?? 0;
        return 'Collect ${_formatCurrency(amount, currency)}';
      }
    }

    // Check total balances for net balance
    for (var balance in totalBalances) {
      if (balance['memberEmail'].toString() == memberEmail) {
        final netBalance = (balance['netBalance'] ?? 0).toDouble();
        if (netBalance > 0) {
          return 'Collect ${_formatCurrency(netBalance, currency)}';
        } else if (netBalance < 0) {
          return 'Pay ${_formatCurrency(netBalance.abs(), currency)}';
        }
      }
    }

    return 'Settled';
  }

  // Get individual transactions for UI
  List<IndividualTransactionEntry> getIndividualTransactions() {
    try {
      if (settlements.isEmpty) {
        debugPrint('📊 [SLICEUP_CONTROLLER] No settlements data available');
        return [];
      }

      // Map all settlements (including historical) to UI entries so the
      // SliceUp page shows both active and historical settlements.
      return settlements.map<IndividualTransactionEntry>((settlement) {
        // API returns: {"from": "email", "to": "email", "amount": 300}
        final fromEmail = settlement['from'] ?? '';
        final toEmail = settlement['to'] ?? '';
        final amount = settlement['amount'] ?? 0;

        // Debug log the settlement structure
        debugPrint('🔍 [SLICEUP_CONTROLLER] Settlement: $settlement');

        // Prefer API-provided display names if available, fall back to email-derived name
        final rawFromName =
            settlement['fromName'] ?? settlement['formName'] ?? fromEmail;
        final rawToName = settlement['toName'] ?? toEmail;
        final fromName = _getDisplayName(
          rawFromName.toString(),
          fromEmail.toString(),
        );
        final toName = _getDisplayName(
          rawToName.toString(),
          toEmail.toString(),
        );

        final curr = currency;

        return IndividualTransactionEntry(
          fromAvatarColor: _getAvatarColor(fromName),
          fromAvatarText: _getInitials(fromName),
          fromName: fromName,
          toAvatarColor: _getAvatarColor(toName),
          toAvatarText: _getInitials(toName),
          toName: toName,
          amount: _formatCurrency(amount, curr),
        );
      }).toList();
    } catch (e) {
      debugPrint(
        '❌ [SLICEUP_CONTROLLER] Error getting individual transactions: $e',
      );
      return [];
    }
  }

  /// Return settlements that are not historical (i.e., still active / not settled)
  List<Map<String, dynamic>> getActiveSettlements() {
    try {
      return settlements
          .where(
            (s) => (s['isHistorical'] == null) || (s['isHistorical'] == false),
          )
          .toList();
    } catch (e) {
      debugPrint(
        '❌ [SLICEUP_CONTROLLER] Error filtering active settlements: $e',
      );
      return settlements.toList();
    }
  }

  /// Return settlements that are historical (i.e., already settled)
  List<Map<String, dynamic>> getHistoricalSettlements() {
    try {
      return settlements.where((s) => s['isHistorical'] == true).toList();
    } catch (e) {
      debugPrint(
        '❌ [SLICEUP_CONTROLLER] Error filtering historical settlements: $e',
      );
      return <Map<String, dynamic>>[];
    }
  }

  // Get balance entries for UI
  List<BalanceEntry> getBalanceEntries() {
    try {
      if (totalBalances.isEmpty) {
        debugPrint('📊 [SLICEUP_CONTROLLER] No balance data available');
        return [];
      }

      return totalBalances.map<BalanceEntry>((balance) {
        // API returns: {"memberEmail": "email", "netBalance": 900, "totalPaid": 1200, "totalOwes": 300}
        final memberEmail = balance['memberEmail'] ?? '';
        final netBalance = (balance['netBalance'] ?? 0).toDouble();
        final isPositive = netBalance >= 0;

        // Debug log the balance structure
        debugPrint('🔍 [SLICEUP_CONTROLLER] Balance: $balance');
        // Prefer API-provided `memberName` when present
        final rawMemberName = balance['memberName'] ?? memberEmail;
        final userName = _getDisplayName(
          rawMemberName.toString(),
          memberEmail.toString(),
        );

        final curr = currency;

        return BalanceEntry(
          circleavatarColor: _getAvatarColor(userName),
          circleavatartext: _getInitials(userName),
          name: userName,
          amount:
              '${isPositive ? '+' : ''}${_formatCurrency(netBalance.abs(), curr)}',
          amountcolor: isPositive ? Colors.green : Colors.red,
        );
      }).toList();
    } catch (e) {
      debugPrint('❌ [SLICEUP_CONTROLLER] Error getting balance entries: $e');
      return [];
    }
  }

  // Helper method to extract name from email
  String _getNameFromEmail(String email) {
    if (email.isEmpty) return 'Unknown';
    // Extract part before @ and capitalize first letter
    final namePart = email.split('@').first;
    if (namePart.isEmpty) return 'Unknown';

    // Limit name to 8 characters to prevent overflow
    String name = namePart[0].toUpperCase() + namePart.substring(1);
    if (name.length > 8) {
      name = name.substring(0, 8);
    }
    return name;
  }

  // Helper methods for UI formatting
  Color _getAvatarColor(String name) {
    final colors = [
      Colors.green,
      Colors.brown,
      Colors.purple,
      Colors.red,
      Colors.blue,
      Colors.orange,
    ];
    return colors[name.hashCode % colors.length];
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.split(' ');
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Normalize display name: prefer API-provided name, fall back to email-derived name
  String _getDisplayName(String? rawNameOrEmail, String? emailFallback) {
    try {
      final raw = (rawNameOrEmail ?? '').trim();
      if (raw.isEmpty) return _getNameFromEmail(emailFallback ?? '');

      // If the raw value looks like an email, extract name from it
      if (raw.contains('@')) {
        return _getNameFromEmail(raw);
      }

      // Otherwise assume it's a proper name (e.g. "person 1")
      String name = raw;
      name = name[0].toUpperCase() + (name.length > 1 ? name.substring(1) : '');
      if (name.length > 8) name = name.substring(0, 8);
      return name;
    } catch (e) {
      return _getNameFromEmail(emailFallback ?? '');
    }
  }

  // Helper method to get settlements where current user is involved
  List<Map<String, dynamic>> getSettlementsForCurrentUser() {
    // You can filter settlements based on current user's email
    // For now, returning all settlements
    return settlements.toList();
  }

  // Helper method to check if current user owes money
  Future<bool> getCurrentUserOwes() async {
    try {
      final currentUserEmail =
          await AuthService.getUserId(); // This should return the user's email
      if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
        final userBalance = getBalanceForMember(currentUserEmail);
        return userBalance.startsWith('Pay');
      }
    } catch (e) {
      debugPrint('❌ [SLICEUP_CONTROLLER] Error getting current user owes: $e');
    }
    return false;
  }

  // Helper method to check if current user is owed money
  Future<bool> getCurrentUserIsOwed() async {
    try {
      final currentUserEmail =
          await AuthService.getUserId(); // This should return the user's email
      if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
        final userBalance = getBalanceForMember(currentUserEmail);
        return userBalance.startsWith('Collect');
      }
    } catch (e) {
      debugPrint(
        '❌ [SLICEUP_CONTROLLER] Error getting current user is owed: $e',
      );
    }
    return false;
  }

  // Method to refresh slice-up data
  Future<void> refreshSliceUpData() async {
    if (currentGroupId.value.isNotEmpty) {
      await fetchSliceUpData(currentGroupId.value);
    }
  }

  // Debug method to check current state
  void debugCurrentState() {
    debugPrint('🔍 [SLICEUP_CONTROLLER] === DEBUG STATE ===');
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] currentGroupId: ${currentGroupId.value}',
    );
    debugPrint('🔍 [SLICEUP_CONTROLLER] isLoading: ${isLoading.value}');
    debugPrint('🔍 [SLICEUP_CONTROLLER] error: ${error.value}');

    debugPrint('🔍 [SLICEUP_CONTROLLER] groupData: $groupData');
    debugPrint('🔍 [SLICEUP_CONTROLLER] summaryData: $summaryData');
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] settlements count: ${settlements.length}',
    );
    debugPrint('🔍 [SLICEUP_CONTROLLER] settlements: $settlements');
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] totalBalances count: ${totalBalances.length}',
    );
    debugPrint('🔍 [SLICEUP_CONTROLLER] totalBalances: $totalBalances');
    debugPrint('🔍 [SLICEUP_CONTROLLER] isAllSettled: ${isAllSettled.value}');
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] youllPayAmount: ${youllPayAmount.value}',
    );
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] youllCollectAmount: ${youllCollectAmount.value}',
    );

    // Test the parsing methods
    final individualTransactions = getIndividualTransactions();
    final balanceEntries = getBalanceEntries();
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] individualTransactions count: ${individualTransactions.length}',
    );
    debugPrint(
      '🔍 [SLICEUP_CONTROLLER] balanceEntries count: ${balanceEntries.length}',
    );

    debugPrint('🔍 [SLICEUP_CONTROLLER] === END DEBUG ===');
  }
}
