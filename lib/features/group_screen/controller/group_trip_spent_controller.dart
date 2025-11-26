import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
// Navigation-related imports (needed when we optionally navigate after save)
import 'package:intl/intl.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/expense_event_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/sliceup_controller.dart';

class GroupTripSpentController extends GetxController {
  final TextEditingController totalAmountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();
  final isTotalAmountFocused = false.obs;
  final isNoteFocused = false.obs;
  final FocusNode totalAmountFocusNode = FocusNode();
  final RxString selectedCategoryName = ''.obs;
  final RxString selectedCategoryIcon = ''.obs;
  final RxBool isLoading = false.obs;

  // ----------------------------
  // ✅ API Integration Variables
  // ----------------------------
  final RxList<Map<String, dynamic>> groupMembers =
      <Map<String, dynamic>>[].obs;
  final RxBool isLoadingMembers = false.obs;
  final RxString error = ''.obs;
  final RxString groupOwnerEmail = ''.obs;
  final RxString currentGroupId = ''.obs;
  final RxBool isInitialized = false.obs; // Add initialization flag
  // Flag to ensure equal-share default selection runs only once per mount/group
  final RxBool equalShareInitialized = false.obs;
  // Flag indicating whether the entire group is settled (no further edits allowed)
  final RxBool isAllSettled = false.obs;
  // For editing existing expense
  final RxString editingExpenseId = ''.obs;

  // Constructor to accept group ID
  GroupTripSpentController({String? groupId}) {
    if (groupId != null && groupId.isNotEmpty) {
      currentGroupId.value = groupId;
      debugPrint(
        "🎯 GroupTripSpentController initialized with groupId: $groupId",
      );
    }
  }

  // ----------------------------
  // ✅ Group ID Management
  // ----------------------------

  // Method to set the group ID after controller initialization
  void setGroupId(String groupId) {
    if (groupId.isNotEmpty && currentGroupId.value != groupId) {
      // Only clear data if we're switching to a different group
      if (currentGroupId.value.isNotEmpty && currentGroupId.value != groupId) {
        clearAllTripData();
        debugPrint(
          "🔄 Switching from group ${currentGroupId.value} to $groupId - cleared data",
        );
      }

      currentGroupId.value = groupId;
      isInitialized.value = true;
      debugPrint("🔄 Updated groupId to: $groupId");

      // Fetch settlement status for this group so UI can disable edits if needed
      fetchSettlementStatus(groupId);

      // Also try to fetch and set the group's currency from the groups API
      // This will populate `selectedCurrency` with the API-provided symbol
      // (e.g. '₹') when available.
      fetchGroupCurrency(groupId);

      // Only reload group members if we don't have them or group changed
      if (groupMembers.isEmpty) {
        getGroupMembers();
      }
    } else if (groupId.isNotEmpty && currentGroupId.value == groupId) {
      debugPrint("✅ Group ID already set to $groupId - no action needed");
    }
  } // Method to clear all trip-specific data

  void clearAllTripData() {
    debugPrint("🧹 Clearing all trip data for clean state");
    debugPrint(
      '🧹 [TRACE] clearAllTripData() called - controllerHash=$hashCode',
    );
    debugPrint(
      '📅 [DATE_DEBUG] clearAllTripData - date BEFORE clear: ${selectedDate.value}',
    );

    // Clear member data
    groupMembers.clear();
    groupOwnerEmail.value = '';
    error.value = '';

    // Clear form data
    totalAmountController.clear();
    noteController.clear();
    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();
    debugPrint(
      '📅 [DATE_DEBUG] clearAllTripData - date AFTER clear: ${selectedDate.value}',
    );

    // Clear friend selections
    clearFriendSelections();

    // Dispose and clear all per-friend amount controllers/maps to avoid
    // carrying values across different groups/trips
    try {
      disposeFriendControllers();
    } catch (_) {}
    equalFriendControllers.clear();
    customFriendControllers.clear();
    multipleFriendControllers.clear();

    // Clear totals controllers and reset reactive totals/comparison state
    try {
      equalTotalController.clear();
      customTotalController.clear();
      multipleTotalController.clear();
    } catch (_) {}
    _multipleFriendTotal.value = 0.0;
    _mainTotal.value = 0.0;
    _comparisonText.value = '0 / 0';
    _amountsMatch.value = false;
    _customFriendTotal.value = 0.0;
    _customMainTotal.value = 0.0;
    _customComparisonText.value = '0 / 0';
    _customAmountsMatch.value = false;
    _equalTotalText.value = 'Total 0 / Per person 0';

    // Clear loading states
    isLoading.value = false;
    isLoadingMembers.value = false;

    // Clear currency selection
    selectedCurrency.value = '';

    // Reset focus states
    isTotalAmountFocused.value = false;
    isNoteFocused.value = false;

    // Reset initialization flag
    isInitialized.value = false;
    // Reset equal-share init guard so next mount/group can re-run initialization
    equalShareInitialized.value = false;

    debugPrint("✅ All trip data cleared successfully");
  }

  // Method to clear only user input (preserving group-specific data)
  void clearUserInput() {
    debugPrint("🧹 Clearing user input only");
    debugPrint('🧹 [TRACE] clearUserInput() called - controllerHash=$hashCode');

    // Clear form data
    totalAmountController.clear();
    noteController.clear();
    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();

    // Clear friend selections
    clearFriendSelections();

    // Reset focus states
    isTotalAmountFocused.value = false;
    isNoteFocused.value = false;

    debugPrint("✅ User input cleared successfully");
  }

  // Fetch complete expense details from API (includes paidBy with payment amounts)
  Future<Map<String, dynamic>?> fetchFullExpenseData(
    String expenseId,
    String groupId,
  ) async {
    try {
      debugPrint(
        '📥 [FETCH_EXPENSE] Fetching full expense details for $expenseId in group $groupId',
      );

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [FETCH_EXPENSE] No token found');
        return null;
      }

      final url = Urls.getGroupTransactions(groupId);
      debugPrint('📥 [FETCH_EXPENSE] Fetching from: $url');

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        final responseData =
            json.decode(responseString) as Map<String, dynamic>;

        // Extract transactions from the API response
        final data = responseData['data'] as Map<String, dynamic>? ?? {};
        List<dynamic> transactions = [];

        if (data['expenses'] != null && data['expenses']['list'] is List) {
          transactions = data['expenses']['list'] as List<dynamic>;
        } else if (data['transactions'] is List) {
          transactions = data['transactions'] as List<dynamic>;
        }

        // Find the specific expense by ID
        for (var tx in transactions) {
          final txId = tx['_id'] ?? tx['expenseId'] ?? tx['id'] ?? '';
          if (txId.toString() == expenseId) {
            debugPrint(
              '✅ [FETCH_EXPENSE] Found complete expense data with paidBy: ${tx['paidBy']}',
            );
            return tx as Map<String, dynamic>;
          }
        }

        debugPrint(
          '❌ [FETCH_EXPENSE] Expense $expenseId not found in API response',
        );
        return null;
      } else {
        debugPrint('❌ [FETCH_EXPENSE] API error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('❌ [FETCH_EXPENSE] Exception: $e');
      return null;
    }
  }

  // Load an existing transaction into the form for editing
  Future<void> loadExpenseForEditing(Map<String, dynamic> transaction) async {
    try {
      debugPrint('🔄 loadExpenseForEditing called');
      debugPrint('🔎 [TRACE] transaction keys: ${transaction.keys.toList()}');
      debugPrint(
        '🔎 [TRACE] transaction note field: "${transaction['note']}" notes field: "${transaction['notes']}" description field: "${transaction['description']}"',
      );
      if (transaction.isEmpty) return;

      // 🔑 CRITICAL FIX: Ensure group members are loaded before we try to look up names
      // This prevents member name lookup failures
      if (groupMembers.isEmpty && currentGroupId.value.isNotEmpty) {
        debugPrint(
          '📥 [LOAD_EXPENSE] Group members not yet loaded, loading now...',
        );
        await getGroupMembers();
        debugPrint(
          '📥 [LOAD_EXPENSE] Group members loaded: ${groupMembers.length}',
        );
      }

      final expenseId =
          transaction['_id'] ??
          transaction['expenseId'] ??
          transaction['id'] ??
          '';
      editingExpenseId.value = expenseId.toString();

      // 🔥 CRITICAL FIX: Clear ALL controllers before loading new data
      // This prevents old controller values from being mixed in with new ones
      debugPrint(
        '🔥 [FIX_DUPLICATE] Clearing all friend controllers before loading...',
      );
      try {
        multipleFriendControllers.forEach((_, controller) {
          try {
            controller.clear();
          } catch (e) {
            debugPrint('Error clearing multiple friend controller: $e');
          }
        });
        customFriendControllers.forEach((_, controller) {
          try {
            controller.clear();
          } catch (e) {
            debugPrint('Error clearing custom friend controller: $e');
          }
        });
        equalFriendControllers.forEach((_, controller) {
          try {
            controller.clear();
          } catch (e) {
            debugPrint('Error clearing equal friend controller: $e');
          }
        });
        debugPrint('✅ [FIX_DUPLICATE] All controllers cleared');
      } catch (e) {
        debugPrint('⚠️ [FIX_DUPLICATE] Error clearing controllers: $e');
      }

      // 🔑 CRITICAL: Fetch complete expense data from API if we don't have paidBy
      debugPrint(
        '📥 [LOAD_EXPENSE] Checking if we need to fetch complete data. Has paidBy: ${transaction.containsKey("paidBy")}',
      );
      if (!transaction.containsKey('paidBy') &&
          currentGroupId.value.isNotEmpty) {
        debugPrint(
          '📥 [LOAD_EXPENSE] No paidBy in transaction, fetching from API...',
        );
        final fullData = await fetchFullExpenseData(
          expenseId.toString(),
          currentGroupId.value,
        );
        if (fullData != null) {
          transaction = fullData;
          debugPrint(
            '✅ [LOAD_EXPENSE] Replaced transaction with full API data',
          );
        }
      }

      // Populate amount
      try {
        final rawTotal =
            transaction['totalExpenseAmount'] ?? transaction['amount'] ?? 0;

        // Normalize amount to a plain numeric string (no currency symbols)
        String normalized = rawTotal?.toString() ?? '';
        // Remove any non-digit, non-dot, non-minus characters (strip currency symbols and commas)
        normalized = normalized.replaceAll(',', '');
        normalized = normalized.replaceAll(RegExp(r'[^0-9.\-]'), '');
        double parsed = double.tryParse(normalized) ?? 0.0;
        // Show integer without decimal when possible, otherwise keep up to 2 decimals
        if (parsed % 1 == 0) {
          totalAmountController.text = parsed.toInt().toString();
        } else {
          // Keep up to 2 decimal places to preserve cents
          totalAmountController.text = parsed.toStringAsFixed(2);
        }
      } catch (e) {
        debugPrint('Error parsing total amount: $e');
      }

      // Ensure we know the settlement status for the current group before enabling edits
      if (currentGroupId.value.isNotEmpty) {
        await fetchSettlementStatus(currentGroupId.value);
      }

      // Switch the button label to Update while editing, or show All Settled Up when group is settled
      if (isAllSettled.value) {
        buttonTextKey.value = 'All Settled Up';
      } else {
        buttonTextKey.value = 'Update';
      }

      // Note - API uses 'notes' (plural)
      try {
        noteController.text =
            transaction['notes']?.toString() ??
            transaction['note']?.toString() ??
            '';
        debugPrint(
          '🔄 [TRACE] loadExpenseForEditing set note="${noteController.text}" editingExpenseId=${editingExpenseId.value} controllerHash=$hashCode',
        );
      } catch (e) {
        debugPrint('Error setting note: $e');
      }

      // Category - API may provide category object
      try {
        final category = transaction['category'];
        if (category is Map && category['name'] != null) {
          selectedCategoryName.value = category['name'].toString();
          // try to map to id if available
          final catId = category['_id'] ?? category['id'];
          if (catId != null) {
            categoryIdMap[selectedCategoryName.value] = catId.toString();
          }
        } else if (transaction['categoryName'] != null) {
          selectedCategoryName.value = transaction['categoryName'].toString();
        }
      } catch (e) {
        debugPrint('Error setting category: $e');
      }

      // Date
      try {
        final expenseDate =
            transaction['expenseDate'] ??
            transaction['createdAt'] ??
            transaction['date'];
        debugPrint(
          '📅 [DATE_DEBUG] Raw expenseDate from transaction: $expenseDate',
        );
        debugPrint(
          '📅 [DATE_DEBUG] Current selectedDate before parsing: ${selectedDate.value}',
        );

        if (expenseDate != null && expenseDate.toString().isNotEmpty) {
          try {
            final parsedDate = DateTime.parse(expenseDate.toString());
            selectedDate.value = parsedDate;
            debugPrint(
              '📅 [DATE_DEBUG] Successfully parsed and set date to: $parsedDate',
            );
            debugPrint(
              '📅 [DATE_DEBUG] selectedDate.value is now: ${selectedDate.value}',
            );
          } catch (e) {
            debugPrint('❌ [DATE_DEBUG] Failed to parse date: $e');
          }
        } else {
          debugPrint(
            '⚠️ [DATE_DEBUG] No valid expenseDate found in transaction',
          );
        }
      } catch (e) {
        debugPrint('Error processing date: $e');
      }

      // Paid by & shared with - try to populate names where possible
      // This part is best-effort; UI will still allow manual edits.
      try {
        final paidBy = transaction['paidBy'] ?? transaction['paid_by'];
        if (paidBy is Map && paidBy['memberEmail'] != null) {
          final email = paidBy['memberEmail'].toString();
          // 🔑 CRITICAL FIX: Look up actual member name by email from groupMembers
          String memberName = '';
          try {
            final matchedMember = groupMembers.firstWhere(
              (m) =>
                  (m['email']?.toString() ?? '').toLowerCase() ==
                  email.toLowerCase(),
            );
            memberName = matchedMember['name']?.toString() ?? '';
          } catch (_) {
            // Fallback: extract name from email if member not found
            memberName = _extractNameFromEmail(email);
          }
          selectedPaidByFriend.value = memberName;
          debugPrint(
            '🎯 [LOAD_EXPENSE] Set selectedPaidByFriend to: $memberName (from email: $email)',
          );
        }

        final shareWith = transaction['shareWith'] ?? transaction['share_with'];
        if (shareWith is Map && shareWith['members'] is List) {
          selectedSharedWithFriends.clear();
          for (var m in shareWith['members']) {
            if (m is String) {
              // 🔑 CRITICAL FIX: Look up actual member name by email from groupMembers
              String memberName = '';
              try {
                final matchedMember = groupMembers.firstWhere(
                  (member) =>
                      (member['email']?.toString() ?? '').toLowerCase() ==
                      m.toLowerCase(),
                );
                memberName = matchedMember['name']?.toString() ?? '';
              } catch (_) {
                // Fallback: extract name from email if member not found
                memberName = _extractNameFromEmail(m);
              }
              if (memberName.isNotEmpty) {
                selectedSharedWithFriends.add(memberName);
              }
            }
          }
          debugPrint(
            '🎯 [LOAD_EXPENSE] Loaded ${selectedSharedWithFriends.length} members into selectedSharedWithFriends',
          );
          // Sync checkbox states with the loaded selection so the UI
          // does not show stale/incorrect checked values.
          try {
            for (var name in friendNames) {
              friendCheckStates[name] = selectedSharedWithFriends.contains(
                name,
              );
            }
            debugPrint(
              '🎯 [LOAD_EXPENSE] friendCheckStates synced for ${friendNames.length} members',
            );
          } catch (e) {
            debugPrint(
              '⚠️ [LOAD_EXPENSE] Failed to sync friendCheckStates: $e',
            );
          }
        }
      } catch (e) {
        debugPrint(
          '⚠️ [LOAD_EXPENSE] Error populating paid by / shared with: $e',
        );
      }

      // Load payment amounts if this is a multiple payment expense
      try {
        debugPrint(
          '💾 [LOAD_EXPENSE] transaction has paidBy? ${transaction.containsKey('paidBy')}',
        );
        debugPrint('💾 [LOAD_EXPENSE] paidBy value: ${transaction['paidBy']}');
        debugPrint(
          '💾 [LOAD_EXPENSE] paidBy is Map? ${transaction['paidBy'] is Map}',
        );
        if (transaction['paidBy'] is Map) {
          final paidByMap = transaction['paidBy'] as Map;
          debugPrint('💾 [LOAD_EXPENSE] paidBy.type: ${paidByMap['type']}');
          debugPrint(
            '💾 [LOAD_EXPENSE] paidBy has payments? ${paidByMap.containsKey('payments')}',
          );
        }

        if (transaction['paidBy'] is Map &&
            transaction['paidBy']['type'] == 'multiple') {
          debugPrint(
            '💾 [LOAD_EXPENSE] ✅ Detected multiple payment expense, loading amounts',
          );
          isMultipleSelected.value = true;
          paidByWasMultiple.value =
              true; // 🔑 Mark that this expense was created with multiple payments
          debugPrint(
            '💾 [LOAD_EXPENSE] Set paidByWasMultiple = true so UI shows "Multiple"',
          );
          loadPaymentAmountsFromExpense(transaction);
          // ALSO load into custom controllers so custom tab shows amounts
          debugPrint(
            '💾 [LOAD_EXPENSE] Also loading into customFriendControllers for custom tab',
          );
          loadCustomAmountsFromExpense(transaction);
        } else if (transaction['paidBy'] is Map &&
            transaction['paidBy']['type'] == 'custom') {
          debugPrint(
            '💾 [LOAD_EXPENSE] ✅ Detected custom payment expense, loading amounts',
          );
          isEquallySelected.value = false; // Set to custom mode
          loadCustomAmountsFromExpense(transaction);
        } else {
          debugPrint(
            '💾 [LOAD_EXPENSE] ❌ NOT a multiple or custom payment expense (single or other type)',
          );
        }

        // Determine share type from shareWith field
        final shareWith = transaction['shareWith'] ?? transaction['share_with'];
        if (shareWith is Map && shareWith['type'] != null) {
          debugPrint('💾 [LOAD_EXPENSE] shareWith.type: ${shareWith['type']}');
          if (shareWith['type'] == 'equal') {
            debugPrint(
              '💾 [LOAD_EXPENSE] ✅ Detected equal share, setting isEquallySelected = true',
            );
            isEquallySelected.value = true;
          } else if (shareWith['type'] == 'custom') {
            debugPrint(
              '💾 [LOAD_EXPENSE] ✅ Detected custom share, setting isEquallySelected = false',
            );
            isEquallySelected.value = false;
          }
        } else {
          debugPrint(
            '💾 [LOAD_EXPENSE] shareWith not found or invalid, defaulting to equal',
          );
          isEquallySelected.value = true;
        }
      } catch (e) {
        debugPrint('⚠️ [LOAD_EXPENSE] Error loading payment amounts: $e');
      }

      debugPrint('✅ Loaded expense for editing: ${editingExpenseId.value}');
    } catch (e) {
      debugPrint('❌ Error in loadExpenseForEditing: $e');
    }
  }

  // Load payment amounts from an existing expense (for PaidByMultiple pre-population)
  void loadPaymentAmountsFromExpense(Map<String, dynamic> transaction) {
    try {
      debugPrint(
        '💾 [PAYMENT_AMOUNTS] ========== START loadPaymentAmountsFromExpense ==========',
      );
      debugPrint(
        '💾 [PAYMENT_AMOUNTS] Transaction keys: ${transaction.keys.toList()}',
      );
      debugPrint('💾 [PAYMENT_AMOUNTS] Transaction _id: ${transaction['_id']}');

      final paidBy = transaction['paidBy'] as Map<String, dynamic>? ?? {};
      debugPrint('💾 [PAYMENT_AMOUNTS] paidBy keys: ${paidBy.keys.toList()}');
      debugPrint('💾 [PAYMENT_AMOUNTS] paidBy type: ${paidBy['type']}');
      debugPrint(
        '💾 [PAYMENT_AMOUNTS] paidBy.payments is List? ${paidBy['payments'] is List}',
      );

      if (paidBy['type'] == 'multiple' && paidBy['payments'] is List) {
        final payments = paidBy['payments'] as List<dynamic>;
        debugPrint(
          '💾 [PAYMENT_AMOUNTS] ✅ Multiple payment detected! Found ${payments.length} payments to load',
        );

        debugPrint(
          '💾 [PAYMENT_AMOUNTS] groupMembers.length: ${groupMembers.length}',
        );
        debugPrint(
          '💾 [PAYMENT_AMOUNTS] groupMembers: ${groupMembers.map((m) => '${m['name']}(${m['email']})').toList()}',
        );

        for (var i = 0; i < payments.length; i++) {
          final payment = payments[i];
          debugPrint('💾 [PAYMENT_AMOUNTS] [Payment $i] Processing: $payment');

          if (payment is Map) {
            final memberEmail = payment['memberEmail']?.toString() ?? '';
            final amount = payment['amount'];

            debugPrint(
              '💾 [PAYMENT_AMOUNTS] [Payment $i] memberEmail: "$memberEmail", amount: $amount',
            );

            // Find the friend name for this email
            String friendName = '';
            for (var member in groupMembers) {
              final memberEmail_ = member['email']?.toString() ?? '';
              debugPrint(
                '💾 [PAYMENT_AMOUNTS] [Payment $i] Comparing "$memberEmail_" == "$memberEmail"? ${memberEmail_ == memberEmail}',
              );
              if (memberEmail_ == memberEmail) {
                friendName = member['name'] as String? ?? '';
                debugPrint(
                  '💾 [PAYMENT_AMOUNTS] [Payment $i] ✅ MATCH FOUND! friendName: "$friendName"',
                );
                break;
              }
            }

            if (friendName.isEmpty) {
              debugPrint(
                '⚠️ [PAYMENT_AMOUNTS] [Payment $i] ❌ NO MATCH FOUND for email: "$memberEmail"',
              );
              continue;
            }

            // IMPORTANT: Use FULL friendName (not truncated) as the key
            // The UI will truncate for display, but we use full name for controller key
            debugPrint(
              '💾 [PAYMENT_AMOUNTS] [Payment $i] friendName: "$friendName" (full name for key)',
            );

            // Pre-fill the amount field using full friendName as key
            if (friendName.isNotEmpty) {
              debugPrint(
                '💾 [PAYMENT_AMOUNTS] [Payment $i] Before init - multipleFriendControllers.keys: ${multipleFriendControllers.keys.toList()}',
              );

              if (!multipleFriendControllers.containsKey(friendName)) {
                debugPrint(
                  '💾 [PAYMENT_AMOUNTS] [Payment $i] Initializing controller for "$friendName"',
                );
                initializeFriendControllerIfAbsent(
                  friendName,
                  multipleFriendControllers,
                );
              } else {
                debugPrint(
                  '💾 [PAYMENT_AMOUNTS] [Payment $i] Controller for "$friendName" already exists',
                );
              }

              debugPrint(
                '💾 [PAYMENT_AMOUNTS] [Payment $i] After init - multipleFriendControllers.keys: ${multipleFriendControllers.keys.toList()}',
              );

              final currentValue =
                  multipleFriendControllers[friendName]?.text ?? 'NULL';
              debugPrint(
                '💾 [PAYMENT_AMOUNTS] [Payment $i] BEFORE SET: multipleFriendControllers["$friendName"].text = "$currentValue"',
              );

              multipleFriendControllers[friendName]!.text = amount.toString();

              final newValue =
                  multipleFriendControllers[friendName]?.text ?? 'NULL';
              debugPrint(
                '✅ [PAYMENT_AMOUNTS] [Payment $i] AFTER SET: multipleFriendControllers["$friendName"].text = "$newValue"',
              );
            } else {
              debugPrint(
                '⚠️ [PAYMENT_AMOUNTS] [Payment $i] displayName is empty! friendName was: "$friendName"',
              );
            }
          } else {
            debugPrint(
              '⚠️ [PAYMENT_AMOUNTS] [Payment $i] Payment is not a Map, it is: ${payment.runtimeType}',
            );
          }
        }

        debugPrint(
          '💾 [PAYMENT_AMOUNTS] FINAL STATE - multipleFriendControllers:',
        );
        multipleFriendControllers.forEach((key, controller) {
          debugPrint('💾 [PAYMENT_AMOUNTS]   "$key" → "${controller.text}"');
        });

        debugPrint('💾 [PAYMENT_AMOUNTS] Calling updateMultipleFriendTotal()');
        // Update calculations after loading all amounts
        updateMultipleFriendTotal();
        debugPrint('✅ [PAYMENT_AMOUNTS] updateMultipleFriendTotal() completed');
      } else {
        debugPrint(
          '⚠️ [PAYMENT_AMOUNTS] ❌ NOT A MULTIPLE PAYMENT - paidBy.type: "${paidBy['type']}", payments is List: ${paidBy['payments'] is List}',
        );
      }

      debugPrint(
        '💾 [PAYMENT_AMOUNTS] ========== END loadPaymentAmountsFromExpense ==========',
      );
    } catch (e) {
      debugPrint('❌ [PAYMENT_AMOUNTS] ERROR: $e');
      debugPrint('❌ [PAYMENT_AMOUNTS] Stack trace: ${StackTrace.current}');
    }
  }

  // Load custom payment amounts from an existing expense (for Custom sharing pre-population)
  void loadCustomAmountsFromExpense(Map<String, dynamic> transaction) {
    try {
      debugPrint(
        '💾 [CUSTOM_AMOUNTS] ========== START loadCustomAmountsFromExpense ==========',
      );
      debugPrint(
        '💾 [CUSTOM_AMOUNTS] Transaction keys: ${transaction.keys.toList()}',
      );

      // Check for shareWith (custom split) first, then fall back to paidBy
      final shareWith = transaction['shareWith'] as Map<String, dynamic>? ?? {};
      debugPrint('💾 [CUSTOM_AMOUNTS] shareWith type: ${shareWith['type']}');
      debugPrint(
        '💾 [CUSTOM_AMOUNTS] shareWith.shares is List? ${shareWith['shares'] is List}',
      );

      if (shareWith['type'] == 'custom' && shareWith['shares'] is List) {
        final shares = shareWith['shares'] as List<dynamic>;
        debugPrint(
          '💾 [CUSTOM_AMOUNTS] ✅ Custom sharing detected! Found ${shares.length} shares to load',
        );

        debugPrint(
          '💾 [CUSTOM_AMOUNTS] groupMembers.length: ${groupMembers.length}',
        );

        // Loop through each share and match to group member
        for (int i = 0; i < shares.length; i++) {
          final share = shares[i] as Map<String, dynamic>;
          final memberEmail = share['memberEmail']?.toString() ?? '';
          final amount = share['amount'] ?? 0;

          debugPrint(
            '💾 [CUSTOM_AMOUNTS] [Share $i] email: "$memberEmail", amount: $amount',
          );

          // Find matching group member
          String friendName = '';
          for (var member in groupMembers) {
            final memberEmail_ = member['email']?.toString() ?? '';
            debugPrint(
              '💾 [CUSTOM_AMOUNTS] [Share $i] Comparing "$memberEmail_" == "$memberEmail"? ${memberEmail_ == memberEmail}',
            );
            if (memberEmail_ == memberEmail) {
              friendName = member['name'] as String? ?? '';
              debugPrint(
                '💾 [CUSTOM_AMOUNTS] [Share $i] ✅ MATCH FOUND! friendName: "$friendName"',
              );
              break;
            }
          }

          if (friendName.isEmpty) {
            debugPrint(
              '⚠️ [CUSTOM_AMOUNTS] [Share $i] ❌ NO MATCH FOUND for email: "$memberEmail"',
            );
            continue;
          }

          // IMPORTANT: Use FULL friendName (not truncated) as the key
          // The UI will truncate for display, but we use full name for controller key
          debugPrint(
            '💾 [CUSTOM_AMOUNTS] [Share $i] friendName: "$friendName" (full name for key)',
          );

          // Pre-fill the amount field using full friendName
          if (friendName.isNotEmpty) {
            if (!customFriendControllers.containsKey(friendName)) {
              debugPrint(
                '💾 [CUSTOM_AMOUNTS] [Share $i] Initializing controller for "$friendName"',
              );
              initializeCustomFriendControllerIfAbsent(
                friendName,
                customFriendControllers,
              );
            }

            final currentValue =
                customFriendControllers[friendName]?.text ?? 'NULL';
            debugPrint(
              '💾 [CUSTOM_AMOUNTS] [Share $i] BEFORE SET: customFriendControllers["$friendName"].text = "$currentValue"',
            );

            customFriendControllers[friendName]!.text = amount.toString();

            debugPrint(
              '💾 [CUSTOM_AMOUNTS] [Share $i] AFTER SET: customFriendControllers["$friendName"].text = "${customFriendControllers[friendName]!.text}"',
            );
          }
        }

        debugPrint(
          '💾 [CUSTOM_AMOUNTS] FINAL STATE - customFriendControllers:',
        );
        customFriendControllers.forEach((key, controller) {
          debugPrint('💾 [CUSTOM_AMOUNTS]   "$key" → "${controller.text}"');
        });

        debugPrint('💾 [CUSTOM_AMOUNTS] Calling updateCustomFriendTotal()');
        updateCustomFriendTotal();
        debugPrint('✅ [CUSTOM_AMOUNTS] updateCustomFriendTotal() completed');
      } else {
        debugPrint(
          '⚠️ [CUSTOM_AMOUNTS] ❌ NOT A CUSTOM SHARE - shareWith.type: "${shareWith['type']}", shares is List: ${shareWith['shares'] is List}',
        );
      }

      debugPrint(
        '💾 [CUSTOM_AMOUNTS] ========== END loadCustomAmountsFromExpense ==========',
      );
    } catch (e) {
      debugPrint('❌ [CUSTOM_AMOUNTS] ERROR: $e');
      debugPrint('❌ [CUSTOM_AMOUNTS] Stack trace: ${StackTrace.current}');
    }
  }

  // Update an existing group expense using Urls.updateGroupExpense
  Future<bool> updateGroupExpense(String expenseId) async {
    try {
      debugPrint('🔄 [UPDATE] Starting updateGroupExpense for ID: $expenseId');
      debugPrint('🔄 [UPDATE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // If the group is fully settled, disallow updates for an existing expense only
      // (new expense creation should still be allowed elsewhere)
      if (isAllSettled.value && expenseId.isNotEmpty) {
        debugPrint('❌ [UPDATE] Group is fully settled - updates are disabled');
        Get.snackbar('Info', 'All Settled Up');
        return false;
      }

      if (expenseId.isEmpty) {
        debugPrint('❌ [UPDATE] Expense ID is empty');
        Get.snackbar('Error', 'Expense id missing');
        return false;
      }

      // Get approval token
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [UPDATE] No authentication token');
        Get.snackbar('Error', 'Authentication required');
        return false;
      }
      debugPrint('✅ [UPDATE] Token obtained successfully');

      // Store token in StorageService for other controllers (best-effort)
      try {
        await StorageService.saveToken(token, StorageService.userId ?? '');
      } catch (_) {}

      // Build request headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      debugPrint('📌 [UPDATE] Headers prepared with Authorization');

      // Build request body from current form state (same shape as add)
      double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
      if (totalAmount <= 0) {
        debugPrint('❌ [UPDATE] Invalid total amount: $totalAmount');
        Get.snackbar('Error', 'Please enter a valid amount greater than 0');
        return false;
      }
      debugPrint('💰 [UPDATE] Total amount validated: $totalAmount');

      // Get category id
      String? categoryId = categoryIdMap[selectedCategoryName.value];
      if (categoryId == null || categoryId.isEmpty) categoryId = '';
      debugPrint(
        '📂 [UPDATE] Category selected: "${selectedCategoryName.value}"',
      );
      debugPrint('📂 [UPDATE] Category ID: "$categoryId"');

      String currentUserEmail = groupOwnerEmail.value.isNotEmpty
          ? groupOwnerEmail.value
          : (groupMembers.isNotEmpty ? groupMembers.first['email'] : '');
      debugPrint('👤 [UPDATE] Current user email: "$currentUserEmail"');
      debugPrint('👤 [UPDATE] Group owner email: "${groupOwnerEmail.value}"');

      String? paidByMemberEmail;
      if (selectedPaidByFriend.value.isNotEmpty) {
        for (var member in groupMembers) {
          if (member['name'] == selectedPaidByFriend.value) {
            paidByMemberEmail = member['email'];
            break;
          }
        }
      }
      if (paidByMemberEmail == null || paidByMemberEmail.isEmpty) {
        paidByMemberEmail = currentUserEmail;
      }
      debugPrint(
        '💳 [UPDATE] Paid by selection: "${selectedPaidByFriend.value}"',
      );
      debugPrint('💳 [UPDATE] Paid by email resolved: "$paidByMemberEmail"');

      List<String> selectedMemberEmails = [];
      if (selectedSharedWithFriends.isNotEmpty) {
        for (String selectedFriendName in selectedSharedWithFriends) {
          for (var member in groupMembers) {
            if (member['name'] == selectedFriendName) {
              selectedMemberEmails.add(member['email']);
              break;
            }
          }
        }
      }

      // 🔑 CRITICAL FIX: If selectedMemberEmails is still empty but we're in equal share mode,
      // default to all group members (this can happen if member name lookups fail)
      if (selectedMemberEmails.isEmpty && isEquallySelected.value) {
        debugPrint(
          '⚠️ [UPDATE] selectedSharedWithFriends was empty, defaulting to all ${groupMembers.length} members',
        );
        selectedMemberEmails = groupMembers
            .map((m) => m['email'] as String)
            .toList();
      } else if (selectedMemberEmails.isEmpty) {
        // Fallback: use only current user
        selectedMemberEmails = [currentUserEmail];
      }

      // De-duplicate selected members by email to avoid API duplicate error
      selectedMemberEmails = selectedMemberEmails.toSet().toList();
      debugPrint(
        '👥 [UPDATE] Share with members count: ${selectedMemberEmails.length}',
      );
      debugPrint('👥 [UPDATE] Share with emails: $selectedMemberEmails');

      // Helper to map a display name back to an email
      String findEmailByDisplayName(String displayName) {
        for (var member in groupMembers) {
          final fullName = (member['name'] ?? '').toString();
          final candidate = fullName.length > 10
              ? fullName.substring(0, 10)
              : fullName;
          if (candidate == displayName) return member['email'];
        }
        return groupOwnerEmail.value.isNotEmpty
            ? groupOwnerEmail.value
            : (groupMembers.isNotEmpty ? groupMembers.first['email'] : '');
      }

      // Build paidBy structure (same as saveExpenseWithMembers)
      // Decide payment mode: respect explicit multiple flow flag or toggle
      final bool useMultiple =
          paidByWasMultiple.value || isMultipleSelected.value;

      debugPrint('🔄 [UPDATE] ─────────────────────────────────────────────');
      debugPrint('🔄 [UPDATE] Payment Mode Detection:');
      debugPrint('🔄 [UPDATE]   paidByWasMultiple: ${paidByWasMultiple.value}');
      debugPrint(
        '🔄 [UPDATE]   isMultipleSelected: ${isMultipleSelected.value}',
      );
      debugPrint('🔄 [UPDATE]   → Using Multiple: $useMultiple');
      debugPrint('🔄 [UPDATE] ─────────────────────────────────────────────');

      Map<String, dynamic> paidByStructure = {};
      if (!useMultiple) {
        debugPrint('🔄 [UPDATE] ✓ Building INDIVIDUAL payment structure');
        paidByStructure = {
          "type": "individual",
          "memberEmail": paidByMemberEmail,
        };
        debugPrint('🔄 [UPDATE]   → Type: individual');
        debugPrint('🔄 [UPDATE]   → Email: $paidByMemberEmail');
      } else {
        // Multiple payments
        debugPrint('🔄 [UPDATE] ✓ Building MULTIPLE payment structure');
        debugPrint(
          '🔄 [UPDATE] 🔥 DEBUG: multipleFriendControllers keys: ${multipleFriendControllers.keys.toList()}',
        );
        debugPrint('🔄 [UPDATE] 🔥 DEBUG: multipleFriendControllers values:');
        multipleFriendControllers.forEach((k, v) {
          debugPrint('🔄 [UPDATE]    → "$k" = "${v.text}"');
        });

        List<Map<String, dynamic>> payments = [];

        multipleFriendControllers.forEach((displayName, amtController) {
          if (amtController.text.isNotEmpty) {
            final amt = double.tryParse(amtController.text) ?? 0.0;
            if (amt > 0) {
              final email = findEmailByDisplayName(displayName);
              debugPrint(
                '🔄 [UPDATE]   → Payment: $displayName ($email) = $amt',
              );
              payments.add({"memberEmail": email, "amount": amt});
            }
          }
        });

        // De-duplicate payments by memberEmail
        final Map<String, double> deduped = {};
        for (var payment in payments) {
          final email = payment['memberEmail'];
          final amount = (payment['amount'] as num).toDouble();
          if (deduped.containsKey(email)) {
            deduped[email] = deduped[email]! + amount;
          } else {
            deduped[email] = amount;
          }
        }

        payments = deduped.entries
            .map((e) => {"memberEmail": e.key, "amount": e.value})
            .toList();

        paidByStructure = {
          "type": "multiple",
          "amount": totalAmount,
          "payments": payments,
        };
        debugPrint('🔄 [UPDATE]   → Type: multiple');
        debugPrint('🔄 [UPDATE]   → Total: $totalAmount');
        debugPrint('🔄 [UPDATE]   → Payments count: ${payments.length}');
      }

      // Build shareWith structure (handle custom vs equal)
      Map<String, dynamic> shareWithStructure = {};
      if (isEquallySelected.value) {
        debugPrint('🔄 [UPDATE] ✓ Building EQUAL sharing structure');
        shareWithStructure = {"type": "equal", "members": selectedMemberEmails};
        debugPrint('🔄 [UPDATE]   → Type: equal');
        debugPrint(
          '🔄 [UPDATE]   → Members count: ${selectedMemberEmails.length}',
        );
      } else {
        // Custom sharing
        debugPrint('🔄 [UPDATE] ✓ Building CUSTOM sharing structure');
        debugPrint(
          '🔄 [UPDATE] 🔥 DEBUG: customFriendControllers keys: ${customFriendControllers.keys.toList()}',
        );
        debugPrint('🔄 [UPDATE] 🔥 DEBUG: customFriendControllers values:');
        customFriendControllers.forEach((k, v) {
          debugPrint('🔄 [UPDATE]    → "$k" = "${v.text}"');
        });

        List<Map<String, dynamic>> customShares = [];

        customFriendControllers.forEach((displayName, amtController) {
          if (amtController.text.isNotEmpty) {
            final amt = double.tryParse(amtController.text) ?? 0.0;
            if (amt > 0) {
              final email = findEmailByDisplayName(displayName);
              debugPrint('🔄 [UPDATE]   → Share: $displayName ($email) = $amt');
              customShares.add({"memberEmail": email, "amount": amt});
            }
          }
        });

        shareWithStructure = {"type": "custom", "shares": customShares};
        debugPrint('🔄 [UPDATE]   → Type: custom');
        debugPrint('🔄 [UPDATE]   → Shares count: ${customShares.length}');
      }

      final requestBody = {
        "expenseDate":
            selectedDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "totalExpenseAmount": totalAmount,
        "currency": selectedCurrency.value.replaceAll('US\$', 'USD'),
        "category": categoryId,
        "note": noteController.text.isEmpty ? '' : noteController.text,
        "paidBy": paidByStructure,
        "shareWith": shareWithStructure,
      };

      debugPrint('📋 [UPDATE] ─────────────────────────────────────────────');
      debugPrint('📋 [UPDATE] Complete Request Body:');
      debugPrint('📋 [UPDATE] ${json.encode(requestBody)}');
      debugPrint('📋 [UPDATE] ─────────────────────────────────────────────');

      // Make PUT request
      final groupId = currentGroupId.value;
      if (groupId.isEmpty) {
        debugPrint('❌ [UPDATE] No group ID set');
        Get.snackbar('Error', 'No group selected');
        return false;
      }
      debugPrint('🏢 [UPDATE] Group ID: "$groupId"');
      debugPrint('📝 [UPDATE] Expense ID: "$expenseId"');

      final url = Urls.updateGroupExpense(groupId, expenseId);
      debugPrint('🌐 [UPDATE] ─────────────────────────────────────────────');
      debugPrint('🌐 [UPDATE] Making PUT request');
      debugPrint('🌐 [UPDATE] URL: $url');
      debugPrint(
        '🌐 [UPDATE] ⚠️ CRITICAL CHECK: expenseId="$expenseId" (length: ${expenseId.length}, isEmpty: ${expenseId.isEmpty})',
      );
      debugPrint('🌐 [UPDATE] ─────────────────────────────────────────────');

      var request = http.Request('PUT', Uri.parse(url));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      debugPrint('📤 [UPDATE] Sending request...');
      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('📥 [UPDATE] ─────────────────────────────────────────────');
      debugPrint('📥 [UPDATE] Response Status: ${response.statusCode}');
      debugPrint('📥 [UPDATE] Response Body:');
      debugPrint('📥 [UPDATE] $respStr');
      debugPrint('📥 [UPDATE] ─────────────────────────────────────────────');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        debugPrint('✅ [UPDATE] API update successful (${response.statusCode})');
        try {
          final data = json.decode(respStr);
          Get.snackbar('Success', data['message'] ?? 'Expense updated');
          debugPrint('✅ [UPDATE] Response decoded successfully');
          debugPrint('✅ [UPDATE] Message: ${data['message']}');
        } catch (_) {
          Get.snackbar('Success', 'Expense updated');
          debugPrint('✅ [UPDATE] Response parsed as success (no JSON)');
        }

        // Notify other controllers
        debugPrint('🔔 [UPDATE] ─────────────────────────────────────────────');
        debugPrint('🔔 [UPDATE] Notifying other controllers to refresh...');
        try {
          final eventController = Get.find<ExpenseEventController>();
          eventController.notifyExpenseUpdated(groupId);
          debugPrint('🔔 [UPDATE] ✓ Event controller notified');
        } catch (e) {
          debugPrint('⚠️ [UPDATE] ✗ Could not notify event controller: $e');
        }

        try {
          final expensesController = Get.find<ExpensesPageController>(
            tag: groupId,
          );
          debugPrint(
            '� [UPDATE] ✓ Found ExpensesPageController with tag: $groupId',
          );
          debugPrint('🔔 [UPDATE] Calling refreshExpenses...');
          await expensesController.refreshExpenses();
          debugPrint(
            '✅ [UPDATE] ✓ ExpensesPageController refreshed successfully',
          );
        } catch (e) {
          debugPrint(
            '⚠️ [UPDATE] ✗ Could not refresh ExpensesPageController: $e',
          );
        }
        debugPrint('🔔 [UPDATE] ─────────────────────────────────────────────');

        return true;
      } else {
        debugPrint(
          '❌ [UPDATE] API update failed with status ${response.statusCode}',
        );
        try {
          final err = json.decode(respStr);
          Get.snackbar('Error', err['message'] ?? 'Update failed');
          debugPrint('❌ [UPDATE] Error message: ${err['message']}');
        } catch (_) {
          Get.snackbar(
            'Error',
            'Failed to update expense. Status: ${response.statusCode}',
          );
          debugPrint('❌ [UPDATE] Could not parse error response');
        }
        return false;
      }
    } catch (e) {
      debugPrint('❌ [UPDATE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      debugPrint('❌ [UPDATE] Exception occurred: $e');
      debugPrint('❌ [UPDATE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Get.snackbar('Error', 'An error occurred: $e');
      return false;
    }
  }

  // Delete a single expense from the group
  // Returns true on success (any 2xx), false otherwise
  Future<bool> deleteExpense(String expenseId) async {
    try {
      if (expenseId.isEmpty) {
        debugPrint('❌ deleteExpense called with empty expenseId');
        error.value = 'Expense id missing';
        return false;
      }

      final groupId = currentGroupId.value;
      if (groupId.isEmpty) {
        debugPrint('❌ deleteExpense: no group selected');
        error.value = 'No group selected';
        return false;
      }

      // Get approval token (try storage first)
      String? token = StorageService.token;
      if (token == null || token.isEmpty) {
        token = await AuthService.getApprovalToken();
      }
      if (token == null || token.isEmpty) {
        debugPrint('🔐 deleteExpense: no token available');
        error.value = 'Authentication required';
        return false;
      }

      // Best-effort save token
      try {
        await StorageService.saveToken(token, StorageService.userId ?? '');
      } catch (_) {}

      final url = Urls.updateGroupExpense(groupId, expenseId);
      debugPrint('🌐 deleteExpense -> DELETE $url');

      var request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      // No body required for deletion
      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('📥 deleteExpense status: ${response.statusCode}');
      debugPrint('📋 deleteExpense body: $respStr');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = json.decode(respStr);
          Get.snackbar('Success', data['message'] ?? 'Expense deleted');
        } catch (_) {
          Get.snackbar('Success', 'Expense deleted');
        }

        // Notify other controllers to refresh
        try {
          final eventController = Get.find<ExpenseEventController>();
          eventController.notifyExpenseUpdated(groupId);
        } catch (_) {}

        try {
          final expensesController = Get.find<ExpensesPageController>(
            tag: groupId,
          );
          expensesController.refreshExpenses();
        } catch (_) {}

        return true;
      } else {
        try {
          final err = json.decode(respStr);
          Get.snackbar('Error', err['message'] ?? 'Failed to delete expense');
          error.value = err['message'] ?? 'Failed to delete expense';
        } catch (_) {
          Get.snackbar('Error', 'Failed to delete expense');
          error.value = 'Failed to delete expense';
        }
        return false;
      }
    } catch (e) {
      debugPrint('💥 deleteExpense exception: $e');
      Get.snackbar('Error', 'An error occurred: $e');
      error.value = 'Error deleting expense: $e';
      return false;
    }
  }

  // Delete the entire group (trip) using the backend API
  // Returns true on success (any 2xx), false otherwise
  Future<bool> deleteGroup(String groupId) async {
    try {
      if (groupId.isEmpty) {
        debugPrint('❌ deleteGroup called with empty groupId');
        error.value = 'Group id missing';
        return false;
      }

      // Get approval token
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('🔐 deleteGroup: no token available');
        error.value = 'Authentication required';
        return false;
      }

      // Best-effort save token
      try {
        await StorageService.saveToken(token, StorageService.userId ?? '');
      } catch (_) {}

      final url = Urls.deleteGroup(groupId);
      debugPrint('🌐 deleteGroup -> DELETE $url');

      var request = http.Request('DELETE', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      http.StreamedResponse response = await request.send();
      final respStr = await response.stream.bytesToString();

      debugPrint('📥 deleteGroup status: ${response.statusCode}');
      debugPrint('📋 deleteGroup body: $respStr');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Optionally parse message
        try {
          final data = json.decode(respStr) as Map<String, dynamic>;
          debugPrint('✅ deleteGroup success: ${data['message'] ?? data}');
        } catch (_) {
          debugPrint('✅ deleteGroup success (no json message)');
        }

        // Notify other controllers / UI to refresh or navigate away
        try {
          final eventController = Get.find<ExpenseEventController>();
          eventController.notifyGroupDeleted(groupId);
        } catch (_) {}

        try {
          // If an ExpensesPageController exists for this group, clear it
          if (Get.isRegistered<ExpensesPageController>(tag: groupId)) {
            final expensesController = Get.find<ExpensesPageController>(
              tag: groupId,
            );
            expensesController.clearTripData();
          }
        } catch (_) {}

        // Clear local state if this controller belonged to the deleted group
        if (currentGroupId.value == groupId) {
          clearAllTripData();
        }

        return true;
      } else {
        // Non-2xx - set error and log
        debugPrint('❌ deleteGroup failed: ${response.statusCode} - $respStr');
        try {
          final err = json.decode(respStr);
          error.value = err['message'] ?? 'Failed to delete group';
        } catch (_) {
          error.value = 'Failed to delete group';
        }
        return false;
      }
    } catch (e) {
      debugPrint('💥 deleteGroup exception: $e');
      error.value = 'Error deleting group: $e';
      return false;
    }
  }

  // ----------------------------
  // ✅ Checkbox logic for Share with (Equally)
  // ----------------------------

  final RxMap<String, bool> friendCheckStates = <String, bool>{}.obs;

  // Use this new list to track selected friends
  final RxList<String> selectedSharedWithFriends = <String>[].obs;

  void toggleFriendCheckbox(String friendName) {
    // Toggle the state of the tapped checkbox
    friendCheckStates[friendName] = !(friendCheckStates[friendName] ?? false);

    // Update the list of selected friends based on the map
    if (friendCheckStates[friendName] == true) {
      selectedSharedWithFriends.add(friendName);
    } else {
      selectedSharedWithFriends.remove(friendName);
    }

    // Update equal share calculation when friend selection changes
    updateEqualShareCalculation();
  }

  bool isFriendChecked(String friendName) {
    return friendCheckStates[friendName] == true;
  }

  // ----------------------------
  // ✅ Equally / Custom toggle
  // ----------------------------
  final RxBool isEquallySelected = true.obs;

  String get currentPeriodUnit =>
      isEquallySelected.value ? 'Equally'.tr : 'Custom'.tr;

  void toggleEquallyCustom() {
    isEquallySelected.value = !isEquallySelected.value;
  }

  // ----------------------------
  // ✅ Individual / Minimize toggle
  // ----------------------------
  final RxBool isIndividualSelected = true.obs;

  String get currentSelectionUnit =>
      isIndividualSelected.value ? 'Individual'.tr : 'Minimize'.tr;

  void toggleIndividualMinimize() {
    isIndividualSelected.value = !isIndividualSelected.value;
  }

  // ----------------------------
  // ✅ Individual / Multiple toggle (reinstated for SlidingButtonIndivMul)
  // ----------------------------
  final RxBool isMultipleSelected = false.obs;

  String get currentSelectionUnitMultiple =>
      isMultipleSelected.value ? 'Individual'.tr : 'Multiple'.tr;

  void toggleIndividualMultiple() {
    isMultipleSelected.value = !isMultipleSelected.value;
  }

  // ----------------------------
  // ✅ Date selection
  // ----------------------------
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(DateTime.now());

  void selectDate(DateTime? date) {
    selectedDate.value = date;
  }

  // ----------------------------
  // ✅ Currency
  // ----------------------------
  // No hardcoded currency default; will be set from API or user selection.
  final RxString selectedCurrency = ''.obs;
  final List<String> currencyOptions = ['US\$', 'EUR€', 'JPY¥', 'KRW₩'];

  void setSelectedCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  // ----------------------------
  // ✅ Friend Selection
  // ----------------------------
  // For "Paid by" (single selection)
  final RxString selectedPaidByFriend = ''.obs;
  // Flag to indicate the last paid-by action came from the "Multiple" flow
  // This allows the UI to show "Multiple" on the main form after the
  // PaidByMultiple bottomsheet's Update button is used.
  final RxBool paidByWasMultiple = false.obs;

  // For "Share with (Equally)" (single selection to match original UI)
  final RxString selectedSharedWithFriend = ''.obs;

  final RxList<String> friendNames = <String>[].obs;

  void setSelectedPaidByFriend(String friend) {
    // Allow toggling - if already selected, deselect it
    if (selectedPaidByFriend.value == friend) {
      selectedPaidByFriend.value = '';
      selectedSharedWithFriend.value = '';
      // User explicitly selected/deselected an individual, clear the multiple flag
      paidByWasMultiple.value = false;
    } else {
      selectedPaidByFriend.value = friend;
      selectedSharedWithFriend.value = friend;
      // Selecting an individual clears the multiple marker
      paidByWasMultiple.value = false;
    }
  }

  void setSelectedSharedWithFriend(String friend) {
    // Allow toggling - if already selected, deselect it
    if (selectedSharedWithFriend.value == friend) {
      selectedSharedWithFriend.value = '';
      friendCheckStates[friend] = false;
    } else {
      selectedSharedWithFriend.value = friend;
      // Update checkbox states to reflect single selection
      friendCheckStates.forEach((key, _) {
        friendCheckStates[key] = key == friend;
      });
    }
  }

  // ----------------------------
  // ✅ Amount Controllers (separated by page)
  // ----------------------------
  final RxMap<String, TextEditingController> equalFriendControllers =
      <String, TextEditingController>{}.obs;

  final RxMap<String, TextEditingController> customFriendControllers =
      <String, TextEditingController>{}.obs;

  final RxMap<String, TextEditingController> multipleFriendControllers =
      <String, TextEditingController>{}.obs;

  // Total per page
  final TextEditingController equalTotalController = TextEditingController();
  final TextEditingController customTotalController = TextEditingController();
  final TextEditingController multipleTotalController = TextEditingController();

  // Observable variables for live calculations (PaidByMultiple)
  final RxDouble _multipleFriendTotal = 0.0.obs;
  final RxDouble _mainTotal = 0.0.obs;
  final RxString _comparisonText = '0 / 0'.obs;
  final RxBool _amountsMatch = false.obs;

  // Observable variables for live calculations (ShareWithCustom)
  final RxDouble _customFriendTotal = 0.0.obs;
  final RxDouble _customMainTotal = 0.0.obs; // Separate main total for custom
  final RxString _customComparisonText = '0 / 0'.obs;
  final RxBool _customAmountsMatch = false.obs;

  // Calculate total of multiple friend amounts
  void updateMultipleFriendTotal() {
    double total = 0.0;
    for (var controller in multipleFriendControllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        total += double.tryParse(text) ?? 0.0;
      }
    }
    _multipleFriendTotal.value = total;
    _updateComparison();
  }

  // Update main total amount (original PaidByMultiple functionality)
  void updateMainTotal() {
    final text = totalAmountController.text.trim();
    _mainTotal.value = double.tryParse(text) ?? 0.0;
    _updateComparison();
  }

  // Update main total for custom calculations (separate method for ShareWithCustom)
  void updateMainTotalForCustom() {
    final text = totalAmountController.text.trim();
    _customMainTotal.value =
        double.tryParse(text) ?? 0.0; // Use separate custom main total
    _updateCustomComparison(); // Only update custom comparison, not the original
  }

  // Update comparison and match status
  void _updateComparison() {
    final friendTotal = _multipleFriendTotal.value;
    final mainTotal = _mainTotal.value;

    _comparisonText.value =
        '${friendTotal.toStringAsFixed(0)} / ${mainTotal.toStringAsFixed(0)}';
    _amountsMatch.value = (friendTotal == mainTotal && mainTotal > 0);
  }

  // Getters for reactive access (PaidByMultiple)
  RxDouble get multipleFriendAmountsTotal => _multipleFriendTotal;
  RxDouble get mainTotalAmount => _mainTotal;
  RxBool get doAmountsMatch => _amountsMatch;
  RxString get totalComparisonText => _comparisonText;

  // Calculate total of custom friend amounts
  void updateCustomFriendTotal() {
    double total = 0.0;
    for (var controller in customFriendControllers.values) {
      final text = controller.text.trim();
      if (text.isNotEmpty) {
        total += double.tryParse(text) ?? 0.0;
      }
    }
    _customFriendTotal.value = total;
    _updateCustomComparison();
  }

  // Update custom comparison and match status
  void _updateCustomComparison() {
    final customTotal = _customFriendTotal.value;
    final mainTotal =
        _customMainTotal.value; // Use custom main total instead of shared one

    _customComparisonText.value =
        '${customTotal.toStringAsFixed(0)} / ${mainTotal.toStringAsFixed(0)}';
    _customAmountsMatch.value = (customTotal == mainTotal && mainTotal > 0);
  }

  // Getters for reactive access (ShareWithCustom)
  RxDouble get customFriendAmountsTotal => _customFriendTotal;
  RxDouble get customMainTotal => _customMainTotal;
  RxBool get doCustomAmountsMatch => _customAmountsMatch;
  RxString get customComparisonText => _customComparisonText;

  // Observable variables for ShareWithEqual live calculations
  // Store an initially translated placeholder for equal-share summary.
  final RxString _equalTotalText = "${'Total'.tr} 0 / ${'Per person'.tr} 0".obs;

  // Calculate equal share amounts
  void updateEqualShareCalculation() {
    final totalAmount =
        double.tryParse(totalAmountController.text.trim()) ?? 0.0;
    final selectedCount = selectedSharedWithFriends.length;

    if (selectedCount > 0 && totalAmount > 0) {
      final perPersonAmount = totalAmount / selectedCount;
      _equalTotalText.value =
          "${'Total'.tr} ${totalAmount.toStringAsFixed(0)} / ${'Per person'.tr} ${perPersonAmount.toStringAsFixed(0)}";
    } else if (totalAmount > 0) {
      _equalTotalText.value =
          "${'Total'.tr} ${totalAmount.toStringAsFixed(0)} / ${'Per person'.tr} 0";
    } else {
      _equalTotalText.value = "${'Total'.tr} 0 / ${'Per person'.tr} 0";
    }
  }

  /// Initialize equal-share selection when friend names become available.
  /// This runs only once per controller lifecycle (guarded by [equalShareInitialized]).
  void initializeEqualShareIfNeeded() {
    try {
      if (equalShareInitialized.value) return;

      if (friendNames.isNotEmpty &&
          selectedSharedWithFriends.isEmpty &&
          editingExpenseId.value.isEmpty) {
        selectedSharedWithFriends.assignAll(friendNames.cast<String>());
        for (final f in friendNames) {
          friendCheckStates[f] = true;
        }

        updateEqualShareCalculation();
        equalShareInitialized.value = true;
        debugPrint(
          '✅ [INIT] Equal-share default selection applied for ${friendNames.length} members',
        );
      }
    } catch (e) {
      debugPrint('⚠️ [INIT] initializeEqualShareIfNeeded error: $e');
    }
  }

  // Getter for reactive access (ShareWithEqual)
  RxString get equalTotalText => _equalTotalText;

  void onTotalAmountFocusChange(bool hasFocus) {
    isTotalAmountFocused.value = hasFocus;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("🚀 GroupTripSpentController onInit called");

    // Ensure Individual is selected by default
    isMultipleSelected.value = false;

    // Add focus listener - wrap in try-catch
    try {
      totalAmountFocusNode.addListener(() {
        try {
          isTotalAmountFocused.value = totalAmountFocusNode.hasFocus;
        } catch (e) {
          debugPrint('Focus listener error: $e');
        }
      });
    } catch (e) {
      debugPrint('Error adding focus listener: $e');
    }

    // Add listener to totalAmountController to trigger updates when amount changes
    try {
      totalAmountController.addListener(() {
        try {
          updateMainTotal(); // Update live calculations for PaidByMultiple
          updateMainTotalForCustom(); // Update live calculations for ShareWithCustom
          updateEqualShareCalculation(); // Update live calculations for ShareWithEqual
        } catch (e) {
          debugPrint('Text controller listener error: $e');
        }
      });
    } catch (e) {
      debugPrint('Error adding text controller listener: $e');
    }

    // Auto-focus after a delay (check if not disposed)
    Future.delayed(const Duration(milliseconds: 10), () {
      try {
        if (!totalAmountFocusNode.hasFocus &&
            totalAmountController.text.isEmpty) {
          totalAmountFocusNode.requestFocus();
        }
      } catch (e) {
        debugPrint('FocusNode error (already disposed): $e');
      }
    });

    // Load group members ONLY if we have a valid group ID
    if (currentGroupId.value.isNotEmpty) {
      debugPrint(
        "🎯 Loading group members for groupId: ${currentGroupId.value}",
      );
      getGroupMembers();
    } else {
      debugPrint("⚠️ No group ID set - waiting for setGroupId() call");
      // Don't auto-fetch groups, wait for explicit group selection
    }

    // Fetch categories from API
    fetchGroupCategories();

    // Watch for friend list changes and initialize equal-share selection once
    try {
      ever(friendNames, (_) => initializeEqualShareIfNeeded());
    } catch (e) {
      debugPrint('Error attaching friendNames watcher: $e');
    }

    // Debug category state after initialization
    Future.delayed(const Duration(seconds: 2), () {
      debugCategoryState();
    });
  }

  void onNoteFocusChange(bool hasFocus) {
    isNoteFocused.value = hasFocus;
  }

  // Button text key (store the translation key; translate at render time)
  final RxString buttonTextKey = 'Save'.obs;

  // ----------------------------
  // ✅ Helpers
  // ----------------------------
  void initializeFriendControllerIfAbsent(
    String friendName,
    Map<String, TextEditingController> map,
  ) {
    if (!map.containsKey(friendName)) {
      final controller = TextEditingController();
      // Add listener to update calculations when amount changes
      controller.addListener(() {
        updateMultipleFriendTotal(); // Update live calculations for PaidByMultiple
      });
      map[friendName] = controller;
    }
  }

  // Separate method for custom controllers to avoid changing PaidByMultiple functionality
  void initializeCustomFriendControllerIfAbsent(
    String friendName,
    Map<String, TextEditingController> map,
  ) {
    if (!map.containsKey(friendName)) {
      final controller = TextEditingController();
      // Add listener to update calculations when amount changes
      controller.addListener(() {
        updateCustomFriendTotal(); // Update live calculations for ShareWithCustom
      });
      map[friendName] = controller;
    }
  }

  void disposeFriendControllers() {
    try {
      equalFriendControllers.forEach((_, c) {
        try {
          c.dispose();
        } catch (e) {
          debugPrint('Error disposing equal friend controller: $e');
        }
      });
    } catch (e) {
      debugPrint('Error disposing equalFriendControllers: $e');
    }

    try {
      customFriendControllers.forEach((_, c) {
        try {
          c.dispose();
        } catch (e) {
          debugPrint('Error disposing custom friend controller: $e');
        }
      });
    } catch (e) {
      debugPrint('Error disposing customFriendControllers: $e');
    }

    try {
      multipleFriendControllers.forEach((_, c) {
        try {
          c.dispose();
        } catch (e) {
          debugPrint('Error disposing multiple friend controller: $e');
        }
      });
    } catch (e) {
      debugPrint('Error disposing multipleFriendControllers: $e');
    }

    try {
      equalTotalController.dispose();
    } catch (e) {
      debugPrint('Error disposing equalTotalController: $e');
    }

    try {
      customTotalController.dispose();
    } catch (e) {
      debugPrint('Error disposing customTotalController: $e');
    }

    try {
      multipleTotalController.dispose();
    } catch (e) {
      debugPrint('Error disposing multipleTotalController: $e');
    }
  }

  void calculateAndSetTotalAmount(
    Map<String, TextEditingController> map,
    TextEditingController totalController,
  ) {
    int total = 0;
    map.forEach((name, controller) {
      if (isFriendChecked(name)) {
        final value = int.tryParse(controller.text) ?? 0;
        total += value;
      }
    });
    totalController.text = total.toString();
    buttonTextKey.value = 'Next';
  }

  //category bottomsheet

  var selectedType = ''.obs;

  // Categories loaded from API - starts empty until API call completes
  final expenseTypes = <String>[].obs;

  // API-related variables for categories
  final RxBool isLoadingCategories = false.obs;
  final RxString categoryError = ''.obs;

  // Dynamic category mapping from API - replaces static categoryIdMap
  final RxMap<String, String> categoryIdMap = <String, String>{}.obs;

  void setType(String type) {
    selectedType.value = type;
  }

  // ----------------------------
  // ✅ API Methods for Categories
  // ----------------------------

  // Fetch whether the current group has all settlements completed.
  // If the group is fully settled, editing/updating of expenses should be disabled.
  Future<void> fetchSettlementStatus(String groupId) async {
    try {
      if (groupId.isEmpty) return;

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) return;

      final url = Urls.getSliceUp(groupId);
      debugPrint('🔎 [SETTLEMENT] Checking settlement status at: $url');

      var request = http.Request('GET', Uri.parse(url));
      request.headers.addAll({
        'Authorization': token,
        'Content-Type': 'application/json',
      });

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final decoded = json.decode(respStr);
          bool settled = false;

          if (decoded is Map<String, dynamic>) {
            if (decoded.containsKey('isAllSettled')) {
              settled = decoded['isAllSettled'] == true;
            } else if (decoded['data'] is Map &&
                decoded['data'].containsKey('isAllSettled')) {
              settled = decoded['data']['isAllSettled'] == true;
            }
          }

          isAllSettled.value = settled;
          debugPrint('🔎 [SETTLEMENT] isAllSettled = ${isAllSettled.value}');
        } catch (e) {
          debugPrint('❌ [SETTLEMENT] Failed to parse settlement response: $e');
          isAllSettled.value = false;
        }
      } else {
        debugPrint(
          '❌ [SETTLEMENT] Settlement API returned ${response.statusCode}',
        );
        isAllSettled.value = false;
      }
    } catch (e) {
      debugPrint(
        '❌ [SETTLEMENT] Exception while fetching settlement status: $e',
      );
      isAllSettled.value = false;
    }
  }

  // Fetch all group categories from API
  Future<void> fetchGroupCategories() async {
    try {
      debugPrint('🔄 fetchGroupCategories called');
      isLoadingCategories.value = true;
      categoryError.value = '';

      // Clear categories first to show loading state
      expenseTypes.clear();
      categoryIdMap.clear();
      debugPrint('🧹 Cleared existing categories and mapping');

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for fetchGroupCategories');
        categoryError.value = 'Authentication required';
        // Don't initialize default categories immediately - let user see the issue
        return;
      }

      debugPrint(
        '✅ Token found for fetchGroupCategories: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      var request = http.Request('GET', Uri.parse(Urls.getallgroupcategory));
      request.headers.addAll(headers);

      debugPrint(
        '🌐 Making request to getallgroupcategory: ${Urls.getallgroupcategory}',
      );

      http.StreamedResponse response = await request.send();

      debugPrint(
        '📊 GetGroupCategories Response Status: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 GetGroupCategories Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 GetGroupCategories Parsed Response: $responseData');

        // Check for both possible response formats
        bool isSuccess =
            responseData['status'] == 'success' ||
            responseData['success'] == true;
        var categoriesData = responseData['data'];

        if (isSuccess && categoriesData != null) {
          List<dynamic> categories = [];

          // Handle different response structures
          if (categoriesData is List) {
            categories = categoriesData;
          } else if (categoriesData is Map &&
              categoriesData['categories'] != null) {
            categories = categoriesData['categories'] as List<dynamic>;
          } else {
            debugPrint('⚠️ Unexpected data structure: $categoriesData');
            categories = [];
          }

          debugPrint('📂 Found ${categories.length} categories');

          // Clear existing categories and mapping
          expenseTypes.clear();
          categoryIdMap.clear();

          for (var category in categories) {
            if (category is Map<String, dynamic>) {
              final categoryName = category['name']?.toString() ?? '';
              final categoryId =
                  category['_id']?.toString() ??
                  category['id']?.toString() ??
                  '';

              if (categoryName.isNotEmpty && categoryId.isNotEmpty) {
                debugPrint('🔍 Debug - categoryName: "$categoryName"');
                debugPrint('🔍 Debug - categoryId: "$categoryId"');

                // Use the category name directly since emoji is already included
                String displayName = categoryName;

                debugPrint('🔍 Debug - final displayName: "$displayName"');

                expenseTypes.add(displayName);
                categoryIdMap[displayName] = categoryId;

                debugPrint('📂 Added category: $displayName (ID: $categoryId)');
              }
            }
          }

          debugPrint(
            '✅ Successfully loaded ${expenseTypes.length} categories from API',
          );
          debugPrint('🗂️ Category ID mapping: $categoryIdMap');
        } else {
          debugPrint('❌ API returned error or no data');
          categoryError.value =
              responseData['message'] ?? 'Failed to load categories';
          // Don't fall back to default categories - let user know there's an issue
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint(
          '❌ GetGroupCategories failed with status: ${response.statusCode}',
        );
        debugPrint('❌ GetGroupCategories error response: $responseBody');
        categoryError.value = 'Failed to fetch categories';
        // Don't fall back to default categories - let user know there's an issue
      }
    } catch (e) {
      debugPrint('❌ Exception in fetchGroupCategories: $e');
      categoryError.value = 'Error fetching categories: $e';
      // Only initialize default categories if it's a critical error
      debugPrint('⚠️ Initializing fallback categories due to exception');
      _initializeDefaultCategories();
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Initialize default categories as fallback
  void _initializeDefaultCategories() {
    debugPrint('🔄 Initializing default categories as fallback');

    // Clear existing data
    expenseTypes.clear();
    categoryIdMap.clear();

    // Add default categories (these will work locally but won't have valid IDs for API calls)
    final defaultCategories = [
      '🚗 Transport',
      '🍽️ Food',
      '🏠 Housing',
      '🛍️ Shopping',
      '🎉 Entertainment',
      '👕 Fashion',
      '💊 Clinic',
      '💄 Beauty',
    ];

    for (String category in defaultCategories) {
      expenseTypes.add(category);
      categoryIdMap[category] = 'default_category_id'; // Placeholder ID
    }

    debugPrint('⚠️ Initialized ${expenseTypes.length} default categories');
  }

  // Manual refresh method for debugging
  void refreshCategories() {
    debugPrint('🔄 Manual refresh categories called');
    fetchGroupCategories();
  }

  // Debug method to check current state
  void debugCategoryState() {
    debugPrint('📊 Category Debug State:');
    debugPrint('📦 expenseTypes count: ${expenseTypes.length}');
    debugPrint('📦 expenseTypes content: $expenseTypes');
    debugPrint('🗂️ categoryIdMap count: ${categoryIdMap.length}');
    debugPrint('🗂️ categoryIdMap content: $categoryIdMap');
    debugPrint('⏳ isLoadingCategories: ${isLoadingCategories.value}');
    debugPrint('❌ categoryError: ${categoryError.value}');
  }

  // Add new category to API
  Future<bool> addCategoryToAPI(String categoryName, {String icon = ''}) async {
    try {
      debugPrint('🔄 addCategoryToAPI called with: $categoryName');
      isLoadingCategories.value = true;
      categoryError.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for addCategoryToAPI');
        categoryError.value = 'Authentication required';
        return false;
      }

      debugPrint(
        '✅ Token found for addCategoryToAPI: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Prepare request body - send the full category name (with emoji) as the name
      final requestBody = {
        'name': categoryName, // This now contains the full string with emoji
        'icon': icon.isNotEmpty
            ? icon
            : '', // Empty icon since emoji is in the name
      };

      debugPrint('📤 Request body: $requestBody');
      debugPrint('🔍 Sending full categoryName: "$categoryName"');

      var request = http.Request('POST', Uri.parse(Urls.postallgroupcategory));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      debugPrint(
        '🌐 Making request to postallgroupcategory: ${Urls.postallgroupcategory}',
      );

      http.StreamedResponse response = await request.send();

      debugPrint('📊 AddGroupCategory Response Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        debugPrint('📋 AddGroupCategory Raw Response: $responseBody');

        final responseData = json.decode(responseBody);
        debugPrint('🔍 AddGroupCategory Parsed Response: $responseData');

        // Fix: Check for 'success' instead of 'status'
        if (responseData['success'] == true) {
          debugPrint('✅ Category added successfully to API');

          // Extract the new category data from response
          final categoryData = responseData['data']?['category'];
          if (categoryData != null) {
            final categoryName = categoryData['name']?.toString() ?? '';
            final categoryId = categoryData['_id']?.toString() ?? '';

            debugPrint('📂 New category: $categoryName (ID: $categoryId)');

            // Add to local lists immediately for better UX
            if (categoryName.isNotEmpty && categoryId.isNotEmpty) {
              expenseTypes.add(categoryName);
              categoryIdMap[categoryName] = categoryId;
              debugPrint('✅ Added new category to local lists');
            }
          }

          // Refresh the categories list and mapping from API
          await fetchGroupCategories();

          return true;
        } else {
          debugPrint('❌ API returned error for addCategory');
          categoryError.value =
              responseData['message'] ?? 'Failed to add category';
          return false;
        }
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint(
          '❌ AddGroupCategory failed with status: ${response.statusCode}',
        );
        debugPrint('❌ AddGroupCategory error response: $responseBody');
        categoryError.value = 'Failed to add category';
        return false;
      }
    } catch (e) {
      debugPrint('❌ Exception in addCategoryToAPI: $e');
      categoryError.value = 'Error adding category: $e';
      return false;
    } finally {
      isLoadingCategories.value = false;
    }
  }

  // Local methods for backward compatibility
  void addCategory(String category) async {
    debugPrint('🔍 addCategory called with: "$category"');

    if (category.isNotEmpty && !expenseTypes.contains(category)) {
      // Instead of separating emoji and name, send the full category string
      // This ensures the emoji is preserved as part of the category name

      // Try to add to API first with the full category string
      bool apiSuccess = await addCategoryToAPI(category, icon: '');

      if (!apiSuccess) {
        // If API fails, add locally as fallback
        expenseTypes.add(category);
        debugPrint('⚠️ Added category locally as API fallback');
      }
    }
  }

  void editCategory(String oldCategory, String newCategory) {
    final index = expenseTypes.indexOf(oldCategory);
    if (index != -1 &&
        newCategory.isNotEmpty &&
        !expenseTypes.contains(newCategory)) {
      expenseTypes[index] = newCategory;
      if (selectedType.value == oldCategory) {
        selectedType.value = newCategory;
      }

      debugPrint('📝 Category edited locally: $oldCategory -> $newCategory');
    }
  }

  void deleteCategory(String category) {
    expenseTypes.remove(category);
    if (selectedType.value == category) {
      selectedType.value = '';
    }

    debugPrint('🗑️ Category deleted locally: $category');
  }

  // ----------------------------
  // ✅ API Integration for Adding Group Expense
  // ----------------------------

  Future<void> addGroupExpense() async {
    try {
      // Helper to map a display name (possibly truncated) back to an email
      String findEmailByDisplayName(String displayName) {
        for (var member in groupMembers) {
          final fullName = (member['name'] ?? '').toString();
          final candidate = fullName.length > 10
              ? fullName.substring(0, 10)
              : fullName;
          if (candidate == displayName) return member['email'];
        }
        // fallback to current user or empty
        return groupOwnerEmail.value.isNotEmpty
            ? groupOwnerEmail.value
            : (groupMembers.isNotEmpty ? groupMembers.first['email'] : '');
      }

      // Build paidBy structure: supports individual and multiple payments
      Map<String, dynamic> buildPaidBy(
        double totalAmount,
        String paidByMemberEmail,
      ) {
        if (isIndividualSelected.value) {
          return {"type": "individual", "memberEmail": paidByMemberEmail};
        }

        List<Map<String, dynamic>> payments = [];
        multipleFriendControllers.forEach((displayName, amtController) {
          if (amtController.text.isNotEmpty) {
            final amt = double.tryParse(amtController.text) ?? 0.0;
            if (amt > 0) {
              final email = findEmailByDisplayName(displayName);
              payments.add({"memberEmail": email, "amount": amt});
            }
          }
        });

        if (payments.isEmpty) {
          payments.add({
            "memberEmail": paidByMemberEmail,
            "amount": totalAmount,
          });
        }

        return {
          "type": "multiple",
          "amount": totalAmount,
          "payments": payments,
        };
      }

      // If we're editing an existing expense, delegate to update endpoint
      if (editingExpenseId.value.isNotEmpty) {
        debugPrint('✏️ [SAVE_EXPENSE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        debugPrint(
          '✏️ [SAVE_EXPENSE] Edit mode detected for expense: ${editingExpenseId.value}',
        );
        debugPrint('✏️ [SAVE_EXPENSE] Delegating to updateGroupExpense()');
        debugPrint('✏️ [SAVE_EXPENSE] ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        final updated = await updateGroupExpense(editingExpenseId.value);
        if (updated) {
          debugPrint('✅ [SAVE_EXPENSE] Update successful, clearing state...');
          // clear editing state and form
          editingExpenseId.value = '';
          clearForm();
          // Close the edit screen and return to the previous page (expenses list)
          try {
            Get.back();
            debugPrint('✅ [SAVE_EXPENSE] Screen closed successfully');
          } catch (_) {
            debugPrint('⚠️ [SAVE_EXPENSE] Could not close screen');
          }
        } else {
          debugPrint('❌ [SAVE_EXPENSE] Update failed');
        }
        return;
      }
      isLoading.value = true;

      // Enhanced validation
      if (totalAmountController.text.isEmpty) {
        Get.snackbar('Error', 'Please enter total amount');
        return;
      }

      double totalAmount = double.tryParse(totalAmountController.text) ?? 0.0;
      if (totalAmount <= 0) {
        Get.snackbar('Error', 'Please enter a valid amount greater than 0');
        return;
      }

      if (selectedCategoryName.value.isEmpty) {
        Get.snackbar('Error', 'Please select a category');
        return;
      }

      // Ensure we have group ID
      if (currentGroupId.value.isEmpty) {
        await getGroupMembers();
        if (currentGroupId.value.isEmpty) {
          Get.snackbar(
            'Error',
            'Group information not available. Please try again.',
          );
          return;
        }
      }

      // Debug sharing type detection

      // Check if we should force equal sharing (if custom has no amounts)
      bool hasCustomAmounts = false;
      customFriendControllers.forEach((name, controller) {
        if (controller.text.isNotEmpty &&
            (double.tryParse(controller.text) ?? 0) > 0) {
          hasCustomAmounts = true;
        }
      });

      // If user selected custom but has no custom amounts, force to equal
      if (!isEquallySelected.value && !hasCustomAmounts) {
        isEquallySelected.value = true;
      }

      // For custom sharing, validate that amounts are entered
      if (!isEquallySelected.value) {
        if (!hasCustomAmounts) {
          Get.snackbar('Error', 'Please enter amounts for custom sharing');
          return;
        }
        customFriendControllers.forEach((name, controller) {
          if (controller.text.isNotEmpty &&
              (double.tryParse(controller.text) ?? 0) > 0) {}
        });
      } else {
        // For equal sharing, ensure we have selected friends
        if (selectedSharedWithFriends.isEmpty) {
          // Auto-select all members if none selected
          selectedSharedWithFriends.clear();
          selectedSharedWithFriends.addAll(friendNames);
        }
      }

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null) {
        Get.snackbar('Error', 'Authentication token not found');
        return;
      }

      // Debug log

      // Prepare request headers - based on your original API example
      var headers = {
        'Authorization': token, // Direct token without Bearer prefix
        'Content-Type': 'application/json',
      };

      // Convert currency symbol to API format
      String currencyCode =
          ''; // No hardcoded default; prefer explicit selection
      if (selectedCurrency.value.contains('EUR') ||
          selectedCurrency.value.contains('€')) {
        currencyCode = 'EUR';
      } else if (selectedCurrency.value.contains('S\$')) {
        currencyCode = '';
      } else if (selectedCurrency.value.contains('GBP') ||
          selectedCurrency.value.contains('£')) {
        currencyCode = 'GBP';
      } else if (selectedCurrency.value.contains('AUD') ||
          selectedCurrency.value.contains('A\$')) {
        currencyCode = 'AUD';
      } else if (selectedCurrency.value.contains('USD') ||
          selectedCurrency.value.contains('US\$') ||
          selectedCurrency.value.contains('\$')) {
        currencyCode = 'USD';
      }

      // Get category ID from dynamic mapping
      String? categoryId = categoryIdMap[selectedCategoryName.value];

      // If category ID not found in mapping, try to use selectedType as fallback
      if (categoryId == null || categoryId.isEmpty) {
        categoryId = categoryIdMap[selectedType.value];
      }

      // If still no category ID found, show error
      if (categoryId == null || categoryId.isEmpty) {
        Get.snackbar(
          'Error',
          'Category ID not found. Please select a valid category.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint(
        '📂 Using category ID: $categoryId for category: ${selectedCategoryName.value}',
      );

      // Get current user email for paidBy - use the group owner or first member
      String currentUserEmail = groupOwnerEmail.value.isNotEmpty
          ? groupOwnerEmail.value
          : (groupMembers.isNotEmpty
                ? groupMembers.first['email']
                : "unknown@email.com");

      // Determine paid by member email - prefer the user selected in Paid-by (if any)
      String? paidByMemberEmail;
      if (selectedPaidByFriend.value.isNotEmpty) {
        for (var member in groupMembers) {
          if (member['name'] == selectedPaidByFriend.value) {
            paidByMemberEmail = member['email'];
            break;
          }
        }
      }

      // Fall back to currentUserEmail (owner or first member) if no selection/found
      if (paidByMemberEmail == null || paidByMemberEmail.isEmpty) {
        paidByMemberEmail = currentUserEmail;
      }

      // Prepare request body based on sharing type
      Map<String, dynamic> requestBody;

      if (isEquallySelected.value) {
        // Equal sharing format - use actual member emails
        List<String> selectedMemberEmails = [];

        if (selectedSharedWithFriends.isNotEmpty) {
          // Convert selected friend names back to emails
          for (String selectedFriendName in selectedSharedWithFriends) {
            // Find the member with this name and get their email
            for (var member in groupMembers) {
              if (member['name'] == selectedFriendName) {
                String memberEmail = member['email'];
                if (!selectedMemberEmails.contains(memberEmail)) {
                  selectedMemberEmails.add(memberEmail);
                }
                break;
              }
            }
          }
        } else {
          // If no friends selected, include all members
          selectedMemberEmails = [currentUserEmail];
        }

        // Ensure current user is included
        if (!selectedMemberEmails.contains(currentUserEmail)) {
          selectedMemberEmails.insert(0, currentUserEmail);
        }

        // Helper to map a display name (possibly truncated) back to an email
        String findEmailByDisplayName(String displayName) {
          for (var member in groupMembers) {
            final fullName = (member['name'] ?? '').toString();
            final candidate = fullName.length > 10
                ? fullName.substring(0, 10)
                : fullName;
            if (candidate == displayName) return member['email'];
          }
          // fallback to currentUserEmail
          return currentUserEmail;
        }

        // Build paidBy for multiple-payments if needed
        Map<String, dynamic> buildPaidBy(double totalAmount) {
          if (isIndividualSelected.value) {
            return {"type": "individual", "memberEmail": paidByMemberEmail};
          }

          // multiple payments
          List<Map<String, dynamic>> payments = [];
          multipleFriendControllers.forEach((displayName, amtController) {
            if (amtController.text.isNotEmpty) {
              final amt = double.tryParse(amtController.text) ?? 0.0;
              if (amt > 0) {
                final email = findEmailByDisplayName(displayName);
                payments.add({"memberEmail": email, "amount": amt});
              }
            }
          });

          // If no payments were provided, fallback to single payer
          if (payments.isEmpty) {
            payments.add({
              "memberEmail": paidByMemberEmail,
              "amount": totalAmount,
            });
          }

          return {
            "type": "multiple",
            "amount": totalAmount,
            "payments": payments,
          };
        }

        requestBody = {
          "expenseDate":
              selectedDate.value?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          "totalExpenseAmount":
              double.tryParse(totalAmountController.text) ?? 0.0,
          "currency": currencyCode,
          "category": categoryId,
          "note": noteController.text.isEmpty ? "" : noteController.text,
          "paidBy": buildPaidBy(
            double.tryParse(totalAmountController.text) ?? 0.0,
          ),
          "shareWith": {"type": "equal", "members": selectedMemberEmails},
        };
      } else {
        // Custom sharing format - requires shares array with actual emails
        debugPrint(
          '💾 [CUSTOM_POST] ========== START CUSTOM SHARE BUILDING ==========',
        );
        debugPrint(
          '💾 [CUSTOM_POST] customFriendControllers.length: ${customFriendControllers.length}',
        );
        debugPrint(
          '💾 [CUSTOM_POST] customFriendControllers.keys: ${customFriendControllers.keys.toList()}',
        );

        List<Map<String, dynamic>> shares = [];
        customFriendControllers.forEach((friendName, amountController) {
          debugPrint(
            '💾 [CUSTOM_POST] Processing friend: "$friendName" (${friendName.length} chars)',
          );
          debugPrint(
            '💾 [CUSTOM_POST]   Input text value: "${amountController.text}"',
          );

          if (amountController.text.isNotEmpty) {
            double amount = double.tryParse(amountController.text) ?? 0.0;
            debugPrint('💾 [CUSTOM_POST]   Parsed amount: $amount');

            if (amount > 0) {
              // Find the member email for this friend name
              String memberEmail = currentUserEmail; // default fallback
              debugPrint(
                '💾 [CUSTOM_POST]   Looking for email match for: "$friendName"',
              );
              debugPrint(
                '💾 [CUSTOM_POST]   groupMembers to search: ${groupMembers.map((m) => '${m['name']}(${m['email']})').toList()}',
              );

              for (var member in groupMembers) {
                final memberName = member['name'] ?? '';
                debugPrint(
                  '💾 [CUSTOM_POST]     Comparing: "$memberName" == "$friendName"? ${memberName == friendName}',
                );
                if (memberName == friendName) {
                  memberEmail = member['email'];
                  debugPrint(
                    '💾 [CUSTOM_POST]     ✅ FOUND! email: $memberEmail',
                  );
                  break;
                }
              }

              debugPrint(
                '💾 [CUSTOM_POST]   Final share: memberEmail="$memberEmail", amount=$amount',
              );
              shares.add({"memberEmail": memberEmail, "amount": amount});
            }
          }
        });

        debugPrint(
          '💾 [CUSTOM_POST] Final shares array (before empty check): $shares',
        );

        // Ensure we have at least one share
        if (shares.isEmpty) {
          debugPrint(
            '💾 [CUSTOM_POST] ⚠️ No shares found, adding currentUserEmail as fallback',
          );
          shares.add({
            "memberEmail": currentUserEmail,
            "amount": double.tryParse(totalAmountController.text) ?? 0.0,
          });
        }

        debugPrint(
          '💾 [CUSTOM_POST] Final shares array (after empty check): $shares',
        );

        // Build paidBy structure for custom share branch using helper
        requestBody = {
          "expenseDate":
              selectedDate.value?.toIso8601String() ??
              DateTime.now().toIso8601String(),
          "totalExpenseAmount":
              double.tryParse(totalAmountController.text) ?? 0.0,
          "currency": currencyCode,
          "category": categoryId,
          "note": noteController.text.isEmpty ? "" : noteController.text,
          "paidBy": buildPaidBy(
            double.tryParse(totalAmountController.text) ?? 0.0,
            paidByMemberEmail,
          ),
          "shareWith": {"type": "custom", "shares": shares},
        };
        debugPrint(
          '💾 [CUSTOM_POST] ========== END CUSTOM SHARE BUILDING ==========',
        );
      }

      // Validate that we have valid member emails and de-duplicate share arrays
      if (isEquallySelected.value) {
        final selectedMemberEmails =
            requestBody['shareWith']['members'] as List<String>;

        // Ensure all emails are valid (not duplicates or placeholders)
        final uniqueEmails = selectedMemberEmails.toSet().toList();
        // Assign back to remove duplicates (preserves insertion order)
        requestBody['shareWith']['members'] = uniqueEmails;
      } else {
        debugPrint('💾 [CUSTOM_DEDUP] Starting deduplication of shares...');
        // De-duplicate shares by memberEmail (sum amounts for duplicates)
        final List<dynamic> rawShares = List<dynamic>.from(
          requestBody['shareWith']['shares'] ?? [],
        );
        debugPrint('💾 [CUSTOM_DEDUP] Raw shares before dedup: $rawShares');

        final Map<String, double> byEmail = {};
        for (final s in rawShares) {
          if (s is Map && s['memberEmail'] != null) {
            final email = s['memberEmail'].toString();
            final amt = (s['amount'] is num)
                ? (s['amount'] as num).toDouble()
                : double.tryParse(s['amount'].toString()) ?? 0.0;
            debugPrint(
              '💾 [CUSTOM_DEDUP]   Processing: email="$email", amount=$amt',
            );
            byEmail[email] = (byEmail[email] ?? 0.0) + amt;
            debugPrint(
              '💾 [CUSTOM_DEDUP]   Accumulated for "$email": ${byEmail[email]}',
            );
          }
        }
        final deduped = byEmail.entries
            .map((e) => {'memberEmail': e.key, 'amount': e.value})
            .toList();
        debugPrint('💾 [CUSTOM_DEDUP] Deduplicated shares: $deduped');
        requestBody['shareWith']['shares'] = deduped;
      }

      // Optional: log request body for debugging
      debugPrint('addGroupExpense requestBody: ${json.encode(requestBody)}');

      // Make API request
      var request = http.Request(
        'POST',
        Uri.parse(Urls.addGroupExpense(currentGroupId.value)),
      );
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      // Debug response
      String responseString = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        var responseData = json.decode(responseString);
        debugPrint(
          'addGroupExpense success: ${responseData['message']?.toString() ?? 'Group expense added successfully'}',
        );

        // Clear form after successful submission
        clearForm();

        // Notify other controllers that expenses have been updated using event system
        try {
          final eventController = Get.find<ExpenseEventController>();
          eventController.notifyExpenseUpdated(currentGroupId.value);
        } catch (e) {
          debugPrint(
            "⚠️ [EXPENSE_SAVED] Event controller not found, using direct refresh: $e",
          );
        }

        // Also try direct controller refresh as backup
        try {
          final expensesController = Get.find<ExpensesPageController>(
            tag: currentGroupId.value,
          );
          debugPrint(
            "🔄 [EXPENSE_SAVED] Refreshing expenses for group: ${currentGroupId.value}",
          );
          expensesController.refreshExpenses();
        } catch (e) {
          debugPrint("⚠️ [EXPENSE_SAVED] Expenses controller not found: $e");
          // This is normal if the expenses page isn't currently visible
        }

        // After successful save, clear form and notify other controllers.
        // Maintain legacy behavior: navigate to GroupTripHomeScreen.
        debugPrint(
          '🔔 [SAVE_EXPENSE] Saved - navigating to GroupTripHomeScreen',
        );
        try {
          Trip tripToPass;
          try {
            final tripCtrl = Get.find<TripController>();
            tripToPass = tripCtrl.trips.firstWhere(
              (t) => t.id == currentGroupId.value,
              orElse: () => Trip(
                id: currentGroupId.value,
                name: tripCtrl.trips.isNotEmpty
                    ? tripCtrl.trips.first.name
                    : 'Group Trip',
                date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
              ),
            );
          } catch (_) {
            tripToPass = Trip(
              id: currentGroupId.value,
              name: 'Group Trip',
              date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
            );
          }
          Get.off(() => GroupTripHomeScreen(trip: tripToPass));
        } catch (e) {
          debugPrint('⚠️ [SAVE_EXPENSE] Navigation failed: $e');
        }
      } else {
        // Log detailed error message
        try {
          var errorData = json.decode(responseString);
          debugPrint(
            'addGroupExpense error: Failed to add expense: ${errorData['message'] ?? response.reasonPhrase}',
          );
        } catch (e) {
          debugPrint(
            'addGroupExpense error: Failed to add expense. Status: ${response.statusCode}, Error: $responseString',
          );
        }
      }
    } catch (e) {
      // Debug log
      debugPrint('addGroupExpense exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ----------------------------
  // ✅ API Methods for Group Members
  // ----------------------------

  // Get user's groups and set the first one as current group if none is set
  Future<void> getUserGroupsAndSetFirst() async {
    try {
      debugPrint('🔄 getUserGroupsAndSetFirst called');

      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No token found for getUserGroupsAndSetFirst');
        error.value = 'Authentication required';
        return;
      }

      debugPrint(
        '✅ Token found for getUserGroupsAndSetFirst: ${token.substring(0, 20)}...',
      );

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Urls.getGroups));
      request.headers.addAll(headers);

      debugPrint('🌐 Making request to getGroups: ${Urls.getGroups}');
      debugPrint('🔑 Request headers: $headers');

      http.StreamedResponse response = await request.send();

      debugPrint('📊 GetGroups Response Status: ${response.statusCode}');

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
            // Use the first group as the current group
            final firstGroup = groups.first;
            debugPrint('📦 First group data: $firstGroup');

            final groupId =
                firstGroup['groupId'] ?? firstGroup['id'] ?? firstGroup['_id'];
            debugPrint('🆔 Extracted groupId: $groupId');

            if (groupId != null) {
              currentGroupId.value = groupId.toString();
              debugPrint('✅ Set currentGroupId to: ${currentGroupId.value}');
              debugPrint('🔍 GroupId type: ${groupId.runtimeType}');
              debugPrint('🔍 GroupId toString(): ${groupId.toString()}');

              // Also set selectedCurrency from API if provided on the group
              try {
                final apiCurrency = firstGroup['currency'] ?? '';
                if (apiCurrency != null && apiCurrency.toString().isNotEmpty) {
                  selectedCurrency.value = apiCurrency.toString();
                  debugPrint(
                    '🔔 Set selectedCurrency from API: ${selectedCurrency.value}',
                  );
                }
              } catch (e) {
                // ignore: avoid_print
                debugPrint('🔍 Could not set currency from firstGroup: $e');
              }

              // Now fetch group members for this group
              await getGroupMembers();
              return;
            } else {
              debugPrint('❌ No valid groupId found in first group');
            }
          } else {
            debugPrint('❌ Groups array is empty');
          }
        } else {
          debugPrint('❌ No data.groups found in response');
          debugPrint('🔍 Response structure: ${responseData.keys.toList()}');

          // Try alternative structure in case API format is different
          if (responseData['data'] is List) {
            final List<dynamic> groups = responseData['data'] as List<dynamic>;
            debugPrint(
              '👥 Found ${groups.length} groups in alternative structure',
            );

            if (groups.isNotEmpty) {
              final firstGroup = groups.first;
              final groupId =
                  firstGroup['_id'] ??
                  firstGroup['id'] ??
                  firstGroup['groupId'];

              if (groupId != null) {
                currentGroupId.value = groupId.toString();
                debugPrint('✅ Set currentGroupId to: ${currentGroupId.value}');
                await getGroupMembers();
                return;
              }
            }
          }
        }

        error.value = 'No groups found. Please create a group first.';
      } else {
        final responseBody = await response.stream.bytesToString();
        debugPrint('❌ GetGroups failed with status: ${response.statusCode}');
        debugPrint('❌ GetGroups error response: $responseBody');
        error.value = 'Failed to fetch user groups';
      }
    } catch (e) {
      debugPrint('❌ Exception in getUserGroupsAndSetFirst: $e');
      debugPrint('❌ Exception stack trace: ${StackTrace.current}');
      error.value = 'Error fetching user groups: $e';
    }
  }

  /// Fetches the list of user's groups and sets `selectedCurrency` from the
  /// group that matches [groupId], if present. This is a lightweight helper
  /// used when the controller receives a groupId and needs the group's
  /// display currency symbol from the API.
  Future<void> fetchGroupCurrency(String groupId) async {
    try {
      if (groupId.isEmpty) return;
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) return;

      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };
      var request = http.Request('GET', Uri.parse(Urls.getGroups));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);
        if (responseData['data'] != null &&
            responseData['data']['groups'] != null) {
          final List<dynamic> groups = responseData['data']['groups'];
          for (var g in groups) {
            final gid = g['groupId'] ?? g['id'] ?? g['_id'];
            if (gid != null && gid.toString() == groupId.toString()) {
              final currency = (g['currency'] ?? '').toString();
              if (currency.isNotEmpty) {
                selectedCurrency.value = currency;
                debugPrint(
                  '🔔 fetchGroupCurrency set selectedCurrency: ${selectedCurrency.value}',
                );
              }
              return;
            }
          }
        }
      }
    } catch (e) {
      debugPrint('❌ fetchGroupCurrency error: $e');
    }
  }

  // Get group members using the POST API
  Future<void> getGroupMembers() async {
    try {
      debugPrint(
        '🎯 getGroupMembers called - currentGroupId: "${currentGroupId.value}"',
      );
      debugPrint(
        '🔍 currentGroupId.value type: ${currentGroupId.value.runtimeType}',
      );
      debugPrint(
        '🔍 currentGroupId.value length: ${currentGroupId.value.length}',
      );

      isLoadingMembers.value = true;
      error.value = '';

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ No authentication token found');
        error.value = 'Authentication required';
        return;
      }

      debugPrint('✅ Token found: ${token.substring(0, 20)}...');

      // Check if we have a valid group ID
      if (currentGroupId.value.isEmpty) {
        debugPrint('❌ Empty group ID, cannot fetch members without a group');
        error.value = 'No group selected. Please select a group first.';
        return;
      }

      String groupId = currentGroupId.value;
      debugPrint('📍 Using groupId: $groupId');

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Make API request to getGroupMembers with dynamic group ID
      String finalUrl = Urls.getGroupMembers(groupId);
      debugPrint('🌐 Final URL being used: $finalUrl');
      debugPrint('🔍 Raw groupId parameter: "$groupId"');
      debugPrint('🔍 currentGroupId.value: "${currentGroupId.value}"');

      var request = http.Request('GET', Uri.parse(finalUrl));

      request.headers.addAll(headers);

      debugPrint('🌐 Making request to: ${Urls.getGroupMembers(groupId)}');
      debugPrint('🔑 Headers: $headers');

      http.StreamedResponse response = await request.send();

      debugPrint('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        debugPrint('📋 Raw Response Data: $responseString');

        final responseData =
            json.decode(responseString) as Map<String, dynamic>;
        debugPrint('🔍 Parsed Response Data: $responseData');
        debugPrint('🔍 Response Data keys: ${responseData.keys.toList()}');

        if (responseData['status'] == 'success') {
          final data = responseData['data'] as Map<String, dynamic>? ?? {};
          debugPrint('📦 Data section: $data');
          debugPrint('📦 Data keys: ${data.keys.toList()}');

          // Extract group information from the actual API structure
          final groupId = data['groupId']?.toString() ?? '';
          final groupName = data['groupName']?.toString() ?? '';
          final totalMembers = data['totalMembers'] ?? 0;

          // Extract owner information from the actual API structure
          final ownerData = data['owner'] as Map<String, dynamic>? ?? {};
          final ownerEmail = ownerData['email']?.toString() ?? '';

          debugPrint('🆔 Group ID: $groupId');
          debugPrint('📛 Group name: $groupName');
          debugPrint('👥 Total members: $totalMembers');
          debugPrint('👤 Owner email: $ownerEmail');

          // Store group information
          if (groupId.isNotEmpty) {
            currentGroupId.value = groupId;
          }
          groupOwnerEmail.value = ownerEmail;

          // Handle members safely - it should be a list
          List<dynamic> members = [];
          if (data['members'] != null) {
            if (data['members'] is List) {
              members = data['members'] as List<dynamic>;
            } else {
              debugPrint(
                '⚠️ Warning: members is not a List, it is: ${data['members'].runtimeType}',
              );
              debugPrint('⚠️ Members data: ${data['members']}');
            }
          } else {
            debugPrint('⚠️ Warning: members is null in API response');
          }

          debugPrint('👥 Members: $members');

          // Extract member information from the actual API response structure
          Set<String> memberEmails = {};
          List<Map<String, dynamic>> processedMembers = [];

          debugPrint('🔄 Processing members from API response...');

          // Process members from the API response
          for (var member in members) {
            if (member is Map) {
              final memberMap = Map<String, dynamic>.from(member);
              final email = memberMap['email']?.toString() ?? '';
              final apiName = memberMap['name']?.toString().trim() ?? '';
              final isOwner = memberMap['isOwner'] ?? false;

              if (email.isNotEmpty) {
                memberEmails.add(email);

                // Prefer API-provided name when available; otherwise fall back to extracting from email
                final displayName = apiName.isNotEmpty
                    ? apiName
                    : _extractNameFromEmail(email);

                processedMembers.add({
                  'email': email,
                  'name': displayName,
                  'id': email, // Using email as ID for now
                  'isOwner': isOwner,
                  'role': isOwner ? 'owner' : 'member',
                  'balance': {}, // Not provided in this API response
                });

                debugPrint(
                  '👤 Processed member: $email ($displayName) - Owner: $isOwner',
                );
              }
            }
          }

          // Sort so owner appears first
          processedMembers.sort((a, b) {
            if (a['isOwner'] == true) return -1;
            if (b['isOwner'] == true) return 1;
            return (a['email'] as String).compareTo(b['email'] as String);
          });

          debugPrint(
            '📊 Total unique member emails found: ${memberEmails.length}',
          );
          debugPrint('👥 Processed members: ${processedMembers.length}');

          groupMembers.value = processedMembers;
          debugPrint(
            '✅ Loaded ${processedMembers.length} group members: ${processedMembers.map((m) => m['name']).join(', ')}',
          );
          // ignore: unnecessary_brace_in_string_interps
          debugPrint('🏆 Group owner: ${ownerEmail}');

          // Update friend names list for backward compatibility (owner first)
          friendNames.clear();
          friendNames.addAll(processedMembers.map((m) => m['name'] as String));

          // Initialize all checkboxes as unchecked (deselected by default)
          friendCheckStates.clear();
          for (String friendName in friendNames) {
            friendCheckStates[friendName] = false;
          }

          // If no shared-with selections exist yet, default to selecting all members
          // This ensures the main screen shows the default "X people" without opening the bottom sheet.
          if (selectedSharedWithFriends.isEmpty && friendNames.isNotEmpty) {
            selectedSharedWithFriends.assignAll(friendNames);
            for (final f in friendNames) {
              friendCheckStates[f] = true;
            }
            debugPrint('🎯 Defaulted selectedSharedWithFriends to all members');
          }

          // Debug trace to help reproduce race/overwrite issues when editing
          debugPrint(
            '🌐 [TRACE] getGroupMembers finished - controllerHash=$hashCode editingExpenseId=${editingExpenseId.value} selectedSharedWithFriends.length=${selectedSharedWithFriends.length} selectedPaidByFriend=${selectedPaidByFriend.value}',
          );

          // Start with no selections, but default Paid-by to the current user if present
          final currentUserEmail = await getCurrentUserEmail();
          String defaultPaidByName = '';
          if (currentUserEmail != null && currentUserEmail.isNotEmpty) {
            try {
              final matched = processedMembers.firstWhere(
                (m) =>
                    (m['email']?.toString() ?? '').toLowerCase() ==
                    currentUserEmail.toLowerCase(),
              );
              defaultPaidByName = matched['name'] as String? ?? '';
            } catch (_) {
              // no match found
            }
          }

          if (defaultPaidByName.isNotEmpty) {
            selectedPaidByFriend.value = defaultPaidByName;
            // Keep selectedSharedWithFriend aligned with paid-by for individual flows
            selectedSharedWithFriend.value = defaultPaidByName;
            debugPrint(
              '🎯 Default paid-by set to current user: $defaultPaidByName',
            );
          } else {
            selectedPaidByFriend.value = '';
            selectedSharedWithFriend.value = '';
            debugPrint('🎯 All members initialized as deselected');
          }

          // Initialize text controllers for each member
          for (var member in processedMembers) {
            final memberName = member['name'] as String;
            initializeFriendControllerIfAbsent(
              memberName,
              multipleFriendControllers,
            );
            initializeFriendControllerIfAbsent(
              memberName,
              equalFriendControllers,
            );
            initializeFriendControllerIfAbsent(
              memberName,
              customFriendControllers,
            );
          }

          // If selectedCurrency is empty, try to use the group's currency from
          // the members/group API response when available (backwards-compatible).
          try {
            final groupCurrency =
                data['currency'] ?? data['groupCurrency'] ?? '';
            if (groupCurrency != null && groupCurrency.toString().isNotEmpty) {
              if (selectedCurrency.value.isEmpty) {
                selectedCurrency.value = groupCurrency.toString();
                debugPrint(
                  '🔔 Set selectedCurrency from getGroupMembers: ${selectedCurrency.value}',
                );
              }
            }
          } catch (e) {
            debugPrint(
              '🔍 Could not extract currency from group members response: $e',
            );
          }
        } else {
          error.value =
              responseData['message'] ?? 'Failed to load group members';
          debugPrint('❌ API returned success: false');
          debugPrint('❌ Error message: ${error.value}');
        }
      } else {
        error.value =
            'Failed to load group members. Status: ${response.statusCode}';
        debugPrint('❌ Request failed with status: ${response.statusCode}');
        final responseString = await response.stream.bytesToString();
        debugPrint('❌ Response body: $responseString');
      }
    } catch (e) {
      error.value = 'Error loading group members: $e';
      debugPrint('❌ Exception in getGroupMembers: $e');
      debugPrint('❌ Exception stack trace: ${StackTrace.current}');
    } finally {
      isLoadingMembers.value = false;
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
          // ignore: unnecessary_brace_in_string_interps
          return '${letters.substring(0, 6)}${numbers}';
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

  // Helper method to get current logged-in user ID
  Future<String?> getCurrentUserId() async {
    try {
      return await AuthService.getUserId();
    } catch (e) {
      debugPrint('❌ Error getting current user ID: $e');
      return null;
    }
  }

  // Helper method to get current logged-in user email
  Future<String?> getCurrentUserEmail() async {
    try {
      return await AuthService.getUserEmail();
    } catch (e) {
      debugPrint('❌ Error getting current user email: $e');
      return null;
    }
  }

  // Post API to save expense with selected members
  Future<void> saveExpenseWithMembers({bool navigateAfterSave = false}) async {
    try {
      debugPrint(
        '💾 [SAVE_EXPENSE] ========== START saveExpenseWithMembers ==========',
      );

      // CHECK IF WE'RE IN EDIT MODE - Route to update instead of create
      if (editingExpenseId.value.isNotEmpty) {
        debugPrint(
          '✏️ [SAVE_EXPENSE] Edit mode detected, calling updateGroupExpense with ID: ${editingExpenseId.value}',
        );
        final success = await updateGroupExpense(editingExpenseId.value);

        if (success) {
          // Clear form and navigate back
          clearForm();

          if (navigateAfterSave) {
            debugPrint('🔔 [UPDATE] Navigating to GroupTripHomeScreen');
            try {
              Trip tripToPass;
              try {
                final tripCtrl = Get.find<TripController>();
                tripToPass = tripCtrl.trips.firstWhere(
                  (t) => t.id == currentGroupId.value,
                  orElse: () => Trip(
                    id: currentGroupId.value,
                    name: tripCtrl.trips.isNotEmpty
                        ? tripCtrl.trips.first.name
                        : 'Group Trip',
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                );
              } catch (_) {
                tripToPass = Trip(
                  id: currentGroupId.value,
                  name: 'Group Trip',
                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                );
              }
              Get.off(() => GroupTripHomeScreen(trip: tripToPass));
            } catch (e) {
              debugPrint('⚠️ [UPDATE] Navigation failed: $e');
            }
          } else {
            debugPrint('🔔 [UPDATE] Closing expense screen');
            try {
              Get.back();
            } catch (_) {}
          }
        }
        return;
      }
      debugPrint(
        '➕ [SAVE_EXPENSE] Create mode - proceeding with new expense creation',
      );

      isLoading.value = true;
      error.value = '';

      // Validate inputs
      if (totalAmountController.text.isEmpty) {
        debugPrint('❌ [SAVE_EXPENSE] Total amount is empty');
        Get.snackbar('Error', 'Please enter total amount');
        return;
      }

      debugPrint(
        '💾 [SAVE_EXPENSE] Total amount: ${totalAmountController.text}',
      );

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [SAVE_EXPENSE] No token available');
        Get.snackbar('Error', 'Authentication required');
        return;
      }

      debugPrint('💾 [SAVE_EXPENSE] Token retrieved successfully');

      // Get total amount
      final double totalAmount =
          double.tryParse(totalAmountController.text) ?? 0.0;
      debugPrint('💾 [SAVE_EXPENSE] Parsed total amount: $totalAmount');

      // Helper function to find email by display name or full name
      String findEmailByDisplayName(String nameInput) {
        // First try matching as full name (since we now use full names as keys)
        for (var member in groupMembers) {
          final fullName = (member['name'] ?? '').toString();
          if (fullName == nameInput) {
            return member['email'] ?? '';
          }
        }

        // Fallback: try matching truncated name (for backward compatibility)
        for (var member in groupMembers) {
          final fullName = (member['name'] ?? '').toString();
          final candidate = fullName.length > 10
              ? fullName.substring(0, 10)
              : fullName;
          if (candidate == nameInput) return member['email'] ?? '';
        }

        // Last resort fallback
        return groupOwnerEmail.value.isNotEmpty
            ? groupOwnerEmail.value
            : (groupMembers.isNotEmpty ? groupMembers.first['email'] : '');
      }

      // Decide payment mode: respect explicit multiple flow flag or toggle
      final bool useMultiple =
          paidByWasMultiple.value || isMultipleSelected.value;

      debugPrint(
        '💾 [SAVE_EXPENSE] paidByWasMultiple: ${paidByWasMultiple.value}',
      );
      debugPrint(
        '💾 [SAVE_EXPENSE] isMultipleSelected: ${isMultipleSelected.value}',
      );
      debugPrint('💾 [SAVE_EXPENSE] useMultiple: $useMultiple');

      // Build paidBy structure based on selection
      Map<String, dynamic> paidByStructure;

      if (!useMultiple) {
        // Individual payment
        if (selectedPaidByFriend.value.isEmpty) {
          Get.snackbar('Error', 'Please select who paid');
          return;
        }

        String? paidByEmail;
        for (var member in groupMembers) {
          if (member['name'] == selectedPaidByFriend.value) {
            paidByEmail = member['email'];
            break;
          }
        }

        if (paidByEmail == null) {
          Get.snackbar('Error', 'Selected payer not found');
          return;
        }

        paidByStructure = {"type": "individual", "memberEmail": paidByEmail};
      } else {
        // Multiple payments - collect from multipleFriendControllers
        debugPrint('💾 [SAVE_EXPENSE] Building MULTIPLE payment structure');
        debugPrint(
          '💾 [SAVE_EXPENSE] multipleFriendControllers has ${multipleFriendControllers.length} entries',
        );

        List<Map<String, dynamic>> payments = [];

        multipleFriendControllers.forEach((displayName, amtController) {
          debugPrint(
            '💾 [SAVE_EXPENSE] Checking $displayName: "${amtController.text}"',
          );
          if (amtController.text.isNotEmpty) {
            final amt = double.tryParse(amtController.text) ?? 0.0;
            if (amt > 0) {
              final email = findEmailByDisplayName(displayName);
              debugPrint(
                '💾 [SAVE_EXPENSE] Adding payment: $displayName ($email) = $amt',
              );
              payments.add({"memberEmail": email, "amount": amt});
            }
          }
        });

        debugPrint(
          '💾 [SAVE_EXPENSE] Total payments collected: ${payments.length}',
        );

        // De-duplicate payments by memberEmail (sum amounts for duplicates)
        final Map<String, double> deduped = {};
        for (var payment in payments) {
          final email = payment['memberEmail'];
          final amount = (payment['amount'] as num).toDouble();
          if (deduped.containsKey(email)) {
            deduped[email] = deduped[email]! + amount;
            debugPrint(
              '💾 [SAVE_EXPENSE] Duplicate email "$email" found, summing amounts: ${deduped[email]}',
            );
          } else {
            deduped[email] = amount;
          }
        }

        payments = deduped.entries
            .map((e) => {"memberEmail": e.key, "amount": e.value})
            .toList();

        debugPrint(
          '💾 [SAVE_EXPENSE] After deduplication: ${payments.length} unique payments',
        );

        // Validate that we have payments
        if (payments.isEmpty) {
          debugPrint('❌ [SAVE_EXPENSE] No payments entered');
          Get.snackbar(
            'Error',
            'Please enter payment amounts for multiple payers',
          );
          return;
        }

        // Extra guard: amounts should match the total
        final sumPayments = payments.fold<double>(
          0.0,
          (s, p) => s + ((p['amount'] as num).toDouble()),
        );
        debugPrint(
          '💾 [SAVE_EXPENSE] Sum of payments: $sumPayments, Total: $totalAmount',
        );

        if ((sumPayments - totalAmount).abs() > 0.001) {
          debugPrint('❌ [SAVE_EXPENSE] Payment sum mismatch!');
          Get.snackbar(
            'Error',
            'Sum of payments (${sumPayments.toStringAsFixed(2)}) must equal total (${totalAmount.toStringAsFixed(2)}).',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }

        paidByStructure = {
          "type": "multiple",
          "amount": totalAmount,
          "payments": payments,
        };

        debugPrint(
          '💾 [SAVE_EXPENSE] paidByStructure built: ${json.encode(paidByStructure)}',
        );
      }

      // Prepare share with members
      List<String> shareWithEmails = [];
      List<Map<String, dynamic>> customShares = [];

      if (isEquallySelected.value) {
        // Equal sharing - collect member emails
        // ✅ FIX: Use selectedSharedWithFriends (plural) instead of selectedSharedWithFriend (singular)
        if (selectedSharedWithFriends.isNotEmpty) {
          // Use all selected friends from the list
          debugPrint(
            '💾 [SAVE_EXPENSE] Using selectedSharedWithFriends with ${selectedSharedWithFriends.length} friends',
          );
          for (String friendName in selectedSharedWithFriends) {
            for (var member in groupMembers) {
              if (member['name'] == friendName) {
                final email = member['email'];
                if (!shareWithEmails.contains(email)) {
                  shareWithEmails.add(email);
                }
                break;
              }
            }
          }
        } else if (isMultipleSelected.value &&
            selectedPaidByFriend.value.isNotEmpty) {
          // Fallback: If using individual mode without selected friends, at least include paid-by person
          debugPrint(
            '💾 [SAVE_EXPENSE] selectedSharedWithFriends empty but isMultipleSelected=true, using selectedPaidByFriend',
          );
          for (var member in groupMembers) {
            if (member['name'] == selectedPaidByFriend.value) {
              final email = member['email'];
              if (!shareWithEmails.contains(email)) {
                shareWithEmails.add(email);
              }
              break;
            }
          }
        }

        // If still no selection, default to all group members
        if (shareWithEmails.isEmpty) {
          debugPrint(
            '💾 [SAVE_EXPENSE] No share-with selection; defaulting to all members equally',
          );
          for (var member in groupMembers) {
            final email = (member['email'] ?? '').toString();
            if (email.isNotEmpty && !shareWithEmails.contains(email)) {
              shareWithEmails.add(email);
            }
          }
        }

        debugPrint('💾 [SAVE_EXPENSE] Final shareWithEmails: $shareWithEmails');

        // De-duplicate any duplicates just in case
        shareWithEmails = shareWithEmails.toSet().toList();
      } else {
        // Custom sharing - collect from customFriendControllers
        customFriendControllers.forEach((friendName, amountController) {
          if (amountController.text.isNotEmpty) {
            double amount = double.tryParse(amountController.text) ?? 0.0;
            if (amount > 0) {
              // Find the member email for this friend name
              String memberEmail = groupOwnerEmail.value.isNotEmpty
                  ? groupOwnerEmail.value
                  : (groupMembers.isNotEmpty
                        ? groupMembers.first['email']
                        : '');

              for (var member in groupMembers) {
                if (member['name'] == friendName) {
                  memberEmail = member['email'];
                  break;
                }
              }

              customShares.add({"memberEmail": memberEmail, "amount": amount});
            }
          }
        });

        if (customShares.isEmpty) {
          Get.snackbar('Error', 'Please enter amounts for custom sharing');
          return;
        }
      }

      // Get category ID from dynamic mapping
      debugPrint(
        '💾 [SAVE_EXPENSE] Looking for category. selectedCategoryName: "${selectedCategoryName.value}", selectedType: "${selectedType.value}"',
      );
      debugPrint(
        '💾 [SAVE_EXPENSE] categoryIdMap has ${categoryIdMap.length} entries',
      );
      debugPrint(
        '💾 [SAVE_EXPENSE] categoryIdMap keys: ${categoryIdMap.keys.join(", ")}',
      );

      // Prefer the explicit selectedCategoryName (UI label). Fall back to selectedType for compatibility.
      String? categoryId =
          categoryIdMap[selectedCategoryName.value] ??
          categoryIdMap[selectedType.value];

      // If category ID not found, show error and guide the user
      if (categoryId == null || categoryId.isEmpty) {
        debugPrint(
          '❌ [SAVE_EXPENSE] Category ID not found. selectedCategoryName="${selectedCategoryName.value}", selectedType="${selectedType.value}", categoryId=$categoryId',
        );
        Get.snackbar(
          'Error',
          'Please select a category before saving',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      debugPrint(
        '💾 [SAVE_EXPENSE] Category ID found: $categoryId (from ${categoryIdMap.containsKey(selectedCategoryName.value) ? 'selectedCategoryName' : 'selectedType'})',
      );

      // Prepare request body
      final requestBody = {
        "expenseDate":
            selectedDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "totalExpenseAmount": totalAmount,
        "currency": selectedCurrency.value
            .replaceAll('US\$', 'USD')
            .replaceAll('€', 'EUR')
            .replaceAll('¥', 'JPY')
            .replaceAll('₩', 'KRW'),
        "category": categoryId,
        "note": noteController.text.isEmpty
            ? "Expense note"
            : noteController.text,
        "paidBy": paidByStructure,
        "shareWith": isEquallySelected.value
            ? {"type": "equal", "members": shareWithEmails}
            : {"type": "custom", "shares": customShares},
      };

      // Ensure custom shares are de-duplicated by memberEmail (sum amounts)
      try {
        final shareWith = requestBody['shareWith'] as Map<String, dynamic>?;
        if (shareWith != null && shareWith['type'] == 'custom') {
          final List<dynamic> rawShares = List<dynamic>.from(
            shareWith['shares'] ?? [],
          );
          final Map<String, double> byEmail = {};
          for (final s in rawShares) {
            if (s is Map && s['memberEmail'] != null) {
              final email = s['memberEmail'].toString();
              final amt = (s['amount'] is num)
                  ? (s['amount'] as num).toDouble()
                  : double.tryParse(s['amount'].toString()) ?? 0.0;
              byEmail[email] = (byEmail[email] ?? 0.0) + amt;
            }
          }
          final deduped = byEmail.entries
              .map((e) => {'memberEmail': e.key, 'amount': e.value})
              .toList();
          shareWith['shares'] = deduped;
        }
      } catch (e) {
        debugPrint('❌ [SAVE_EXPENSE] Error de-duplicating shares: $e');
      }

      debugPrint(
        'saveExpenseWithMembers requestBody: ${json.encode(requestBody)}',
      );

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Build dynamic endpoint URL with current group ID
      String addGroupExpenseUrl;
      if (currentGroupId.value.isNotEmpty) {
        addGroupExpenseUrl = Urls.addGroupExpense(currentGroupId.value);
      } else {
        // Cannot proceed without a valid group ID
        debugPrint(
          'saveExpenseWithMembers: No group selected. Please select a group first.',
        );
        return;
      }

      // Make API request
      var request = http.Request('POST', Uri.parse(addGroupExpenseUrl));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(responseString);

        if (responseData['status'] == 'success' ||
            responseData['success'] == true) {
          debugPrint('saveExpenseWithMembers: Expense saved successfully!');
          debugPrint('Response: ${responseData['message']}');

          // Clear form after success
          clearForm();

          // Notify other controllers that expenses have been updated
          try {
            final eventController = Get.find<ExpenseEventController>();
            eventController.notifyExpenseUpdated(currentGroupId.value);
          } catch (e) {
            debugPrint("⚠️ [EXPENSE_SAVED] Event controller not found: $e");
          }

          // Try direct controller refresh as backup
          try {
            final expensesController = Get.find<ExpensesPageController>(
              tag: currentGroupId.value,
            );
            debugPrint(
              "🔄 [EXPENSE_SAVED] Refreshing expenses for group: ${currentGroupId.value}",
            );
            expensesController.refreshExpenses();
          } catch (e) {
            debugPrint("⚠️ [EXPENSE_SAVED] Expenses controller not found: $e");
          }

          // Also refresh SliceUpController (balances / settlements) so the
          // Sliceup page updates immediately after a new expense is added.
          try {
            final sliceCtrl = Get.find<SliceUpController>(
              tag: currentGroupId.value,
            );
            debugPrint(
              "🔄 [EXPENSE_SAVED] Refreshing slice-up data for group: ${currentGroupId.value}",
            );
            await sliceCtrl.refreshSliceUpData();
            debugPrint('✅ [EXPENSE_SAVED] SliceUpController refreshed');
          } catch (e) {
            debugPrint(
              '⚠️ [EXPENSE_SAVED] Could not refresh SliceUpController: $e',
            );
          }

          // Show success message
          Get.snackbar(
            'Success',
            responseData['message']?.toString() ??
                'Group expense added successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          // Reset paidByWasMultiple flag after successful submission
          paidByWasMultiple.value = false;

          // Navigate to GroupTripHomeScreen if requested
          if (navigateAfterSave) {
            debugPrint('🔔 [SAVE_EXPENSE] Navigating to GroupTripHomeScreen');
            try {
              Trip tripToPass;
              try {
                final tripCtrl = Get.find<TripController>();
                tripToPass = tripCtrl.trips.firstWhere(
                  (t) => t.id == currentGroupId.value,
                  orElse: () => Trip(
                    id: currentGroupId.value,
                    name: tripCtrl.trips.isNotEmpty
                        ? tripCtrl.trips.first.name
                        : 'Group Trip',
                    date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  ),
                );
              } catch (_) {
                tripToPass = Trip(
                  id: currentGroupId.value,
                  name: 'Group Trip',
                  date: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                );
              }
              Get.off(() => GroupTripHomeScreen(trip: tripToPass));
            } catch (e) {
              debugPrint('⚠️ [SAVE_EXPENSE] Navigation failed: $e');
            }
          } else {
            debugPrint('🔔 [SAVE_EXPENSE] Staying on expense screen');
            // Close any open bottomsheets
            try {
              Get.back();
            } catch (_) {}
          }
        } else {
          debugPrint(
            'saveExpenseWithMembers error: ${responseData['message'] ?? 'Failed to save expense'}',
          );
          Get.snackbar(
            'Error',
            responseData['message']?.toString() ?? 'Failed to save expense',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } else {
        debugPrint(
          'saveExpenseWithMembers error: Failed to save expense. Status: ${response.statusCode}',
        );
        debugPrint('Response body: $responseString');

        try {
          final errorData = json.decode(responseString);
          Get.snackbar(
            'Error',
            errorData['message']?.toString() ?? 'Failed to save expense',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (_) {
          Get.snackbar(
            'Error',
            'Failed to save expense. Status: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      debugPrint('saveExpenseWithMembers exception: $e');
    } finally {
      // Always reset guard flag to avoid sticky state
      paidByWasMultiple.value = false;
      isLoading.value = false;
    }
  }

  // ----------------------------
  // ✅ Delete Group Expense API
  // ----------------------------
  Future<bool> deleteGroupExpense(String expenseId) async {
    try {
      debugPrint(
        '🗑️ [DELETE_EXPENSE] ========== START deleteGroupExpense ==========',
      );
      debugPrint('🗑️ [DELETE_EXPENSE] Expense ID: $expenseId');
      debugPrint('🗑️ [DELETE_EXPENSE] Group ID: ${currentGroupId.value}');

      isLoading.value = true;

      // Get token from AuthService
      final token = await AuthService.getApprovalToken();
      if (token == null || token.isEmpty) {
        debugPrint('❌ [DELETE_EXPENSE] No token available');
        Get.snackbar(
          'Error',
          'Authentication required',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Validate group ID
      if (currentGroupId.value.isEmpty) {
        debugPrint('❌ [DELETE_EXPENSE] No group ID');
        Get.snackbar(
          'Error',
          'Group information not available',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }

      // Build delete URL
      final url = Urls.deleteGroupExpense(currentGroupId.value, expenseId);
      debugPrint('🗑️ [DELETE_EXPENSE] URL: $url');

      // Prepare request body (same structure as the expense being deleted)
      final requestBody = {
        "expenseDate":
            selectedDate.value?.toIso8601String() ??
            DateTime.now().toIso8601String(),
        "totalExpenseAmount":
            double.tryParse(totalAmountController.text) ?? 0.0,
        "currency": selectedCurrency.value
            .replaceAll('US\$', 'USD')
            .replaceAll('€', 'EUR')
            .replaceAll('¥', 'JPY')
            .replaceAll('₩', 'KRW'),
        "category": categoryIdMap[selectedType.value] ?? "",
        "note": noteController.text.isEmpty ? "" : noteController.text,
        "paidBy": {
          "type": "individual",
          "memberEmail": groupOwnerEmail.value.isNotEmpty
              ? groupOwnerEmail.value
              : (groupMembers.isNotEmpty ? groupMembers.first['email'] : ""),
        },
        "shareWith": {
          "type": "equal",
          "members": [
            groupOwnerEmail.value.isNotEmpty
                ? groupOwnerEmail.value
                : (groupMembers.isNotEmpty ? groupMembers.first['email'] : ""),
          ],
        },
      };

      debugPrint(
        '🗑️ [DELETE_EXPENSE] Request body: ${json.encode(requestBody)}',
      );

      // Prepare headers
      var headers = {
        'Authorization': token,
        'Content-Type': 'application/json',
      };

      // Make DELETE request
      var request = http.Request('DELETE', Uri.parse(url));
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      final responseString = await response.stream.bytesToString();

      debugPrint(
        '🗑️ [DELETE_EXPENSE] Response status: ${response.statusCode}',
      );
      debugPrint('🗑️ [DELETE_EXPENSE] Response body: $responseString');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = json.decode(responseString);

        if (responseData['status'] == 'success' ||
            responseData['success'] == true) {
          debugPrint('✅ [DELETE_EXPENSE] Expense deleted successfully');

          // Clear form after successful deletion
          clearForm();

          // Notify other controllers that expenses have been updated
          try {
            final eventController = Get.find<ExpenseEventController>();
            eventController.notifyExpenseUpdated(currentGroupId.value);
          } catch (e) {
            debugPrint("⚠️ [DELETE_EXPENSE] Event controller not found: $e");
          }

          // Try direct controller refresh as backup
          try {
            final expensesController = Get.find<ExpensesPageController>(
              tag: currentGroupId.value,
            );
            debugPrint(
              "🔄 [DELETE_EXPENSE] Refreshing expenses for group: ${currentGroupId.value}",
            );
            expensesController.refreshExpenses();
          } catch (e) {
            debugPrint("⚠️ [DELETE_EXPENSE] Expenses controller not found: $e");
          }

          Get.snackbar(
            'Success',
            responseData['message']?.toString() ??
                'Expense deleted successfully',
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          return true;
        } else {
          debugPrint(
            '❌ [DELETE_EXPENSE] Delete failed: ${responseData['message']}',
          );
          Get.snackbar(
            'Error',
            responseData['message']?.toString() ?? 'Failed to delete expense',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return false;
        }
      } else {
        debugPrint('❌ [DELETE_EXPENSE] HTTP error: ${response.statusCode}');

        try {
          final errorData = json.decode(responseString);
          Get.snackbar(
            'Error',
            errorData['message']?.toString() ?? 'Failed to delete expense',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        } catch (_) {
          Get.snackbar(
            'Error',
            'Failed to delete expense. Status: ${response.statusCode}',
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        return false;
      }
    } catch (e) {
      debugPrint('🗑️ [DELETE_EXPENSE] Exception: $e');
      Get.snackbar(
        'Error',
        'An error occurred while deleting the expense',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    debugPrint(
      '🧹 [TRACE] clearForm() called - clearing inputs - controllerHash=$hashCode',
    );
    debugPrint(
      '📅 [DATE_DEBUG] clearForm - date BEFORE clear: ${selectedDate.value}',
    );

    try {
      totalAmountController.clear();
    } catch (e) {
      debugPrint('Error clearing totalAmountController: $e');
    }

    try {
      noteController.clear();
    } catch (e) {
      debugPrint('Error clearing noteController: $e');
    }

    selectedCategoryName.value = '';
    selectedCategoryIcon.value = '';
    selectedType.value = '';
    selectedDate.value = DateTime.now();

    debugPrint(
      '📅 [DATE_DEBUG] clearForm - date AFTER clear: ${selectedDate.value}',
    );

    // Clear friend selection states
    clearFriendSelections();

    // Clear all amount input fields for PaidByMultiple and ShareWithCustom
    try {
      multipleFriendControllers.forEach((_, c) {
        try {
          c.clear();
        } catch (e) {
          debugPrint('Error clearing multiple friend controller: $e');
        }
      });
      customFriendControllers.forEach((_, c) {
        try {
          c.clear();
        } catch (e) {
          debugPrint('Error clearing custom friend controller: $e');
        }
      });
      equalFriendControllers.forEach((_, c) {
        try {
          c.clear();
        } catch (e) {
          debugPrint('Error clearing equal friend controller: $e');
        }
      });
      try {
        multipleTotalController.clear();
      } catch (e) {
        debugPrint('Error clearing multipleTotalController: $e');
      }
      try {
        customTotalController.clear();
      } catch (e) {
        debugPrint('Error clearing customTotalController: $e');
      }
      try {
        equalTotalController.clear();
      } catch (e) {
        debugPrint('Error clearing equalTotalController: $e');
      }
    } catch (e) {
      debugPrint('Error clearing friend controllers: $e');
    }

    // Reset computed totals/comparison flags so UI starts fresh
    _multipleFriendTotal.value = 0.0;
    _mainTotal.value = 0.0;
    _comparisonText.value = '0 / 0';
    _amountsMatch.value = false;
    _customFriendTotal.value = 0.0;
    _customMainTotal.value = 0.0;
    _customComparisonText.value = '0 / 0';
    _customAmountsMatch.value = false;
    _equalTotalText.value = 'Total 0 / Per person 0';

    // Reset toggles to defaults
    isEquallySelected.value = true;
    isIndividualSelected.value = true;
    isMultipleSelected.value = false;

    // Reset button label key to default (translate in UI)
    buttonTextKey.value = 'Save';
  }

  // Separate method to clear only friend selections
  void clearFriendSelections() {
    friendCheckStates.clear();
    selectedSharedWithFriends.clear();
    selectedPaidByFriend.value = '';
    selectedSharedWithFriend.value = '';
    debugPrint('🧹 Cleared all friend selection states');
  }

  // Clear only the "Share with" related selections (leave PaidBy selection intact)
  void clearSharedWithSelections() {
    friendCheckStates.clear();
    selectedSharedWithFriends.clear();
    selectedSharedWithFriend.value = '';
    debugPrint('🧹 Cleared shared-with selection states (paid-by preserved)');
  }

  @override
  void onClose() {
    try {
      totalAmountController.dispose();
    } catch (e) {
      debugPrint('Error disposing totalAmountController: $e');
    }
    try {
      noteController.dispose();
    } catch (e) {
      debugPrint('Error disposing noteController: $e');
    }
    try {
      totalAmountFocusNode.dispose();
    } catch (e) {
      debugPrint('Error disposing totalAmountFocusNode: $e');
    }
    try {
      disposeFriendControllers();
    } catch (e) {
      debugPrint('Error disposing friend controllers: $e');
    }
    super.onClose();
  }
}
