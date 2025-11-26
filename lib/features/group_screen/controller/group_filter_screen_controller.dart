import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';

class GroupFilterScreenController extends GetxController {
  // For the "Expense View" section
  var groupOneSelected = 0.obs;

  // For the "Transaction Type" section
  // Default to 'All' (index 2) so the UI shows All selected by default
  var groupTwoSelected = 2.obs;

  // Used if you want to show a specific screen based on 'Invoice Me' or 'All Group'
  var showIndividual = false.obs;

  // Track filter state
  var isFilterApplied = false.obs;

  void selectGroupOne(int index) {
    groupOneSelected.value = index;

    // You can use this flag if you want to switch screens later based on selection
    showIndividual.value = index == 1;

    // Optional: Add logic if needed for side effects when switching selection
  }

  void selectGroupTwo(int index) {
    groupTwoSelected.value = index;

    // Optional: Add logic here based on borrow/lent choice
  }

  // Apply filters to expenses
  Future<void> applyFilters(String? groupId) async {
    try {
      debugPrint('🎯 [FILTER] Starting filter application...');
      debugPrint('🎯 [FILTER] GroupId: $groupId');
      debugPrint('🎯 [FILTER] Group One Selected: ${groupOneSelected.value}');
      debugPrint('🎯 [FILTER] Group Two Selected: ${groupTwoSelected.value}');

      // Get the expenses controller for the specific group
      String controllerTag = groupId ?? 'default';
      debugPrint('🎯 [FILTER] Looking for controller with tag: $controllerTag');

      // Debug: Check what controllers are registered
      debugPrint('🎯 [FILTER] Checking all registered controllers...');
      Get.printInfo();

      if (Get.isRegistered<ExpensesPageController>(tag: controllerTag)) {
        debugPrint('🎯 [FILTER] Found expenses controller with specific tag');
        final expensesController = Get.find<ExpensesPageController>(
          tag: controllerTag,
        );

        // Determine expense view filter
        String? expenseView;
        if (groupOneSelected.value == 0) {
          expenseView = null; // All group - no filter needed

          debugPrint('🎯 [FILTER] Expense view: All group');
        } else if (groupOneSelected.value == 1) {
          expenseView = 'involving_me'; // Involving me only
          debugPrint('🎯 [FILTER] Expense view: Involving me only');
        }

        // Determine transaction type filter
        String? transactionType;
        if (groupTwoSelected.value == 0) {
          transactionType = 'borrowed'; // I borrowed

          debugPrint('🎯 [FILTER] Transaction type: borrowed');
        } else if (groupTwoSelected.value == 1) {
          transactionType = 'lent'; // I lent
          debugPrint('🎯 [FILTER] Transaction type: lent');
        } else if (groupTwoSelected.value == 2) {
          transactionType = null; // All transaction types
          debugPrint('🎯 [FILTER] Transaction type: all');
        }

        debugPrint(
          '🎯 [FILTER] Applying filters - expenseView: $expenseView, transactionType: $transactionType',
        );

        // Apply the filters
        await expensesController.getGroupExpenses(
          expenseView: expenseView,
          transactionType: transactionType,
        );

        debugPrint('🎯 [FILTER] Filters applied successfully');
        isFilterApplied.value = true;
      } else {
        debugPrint(
          '❌ [FILTER] ExpensesPageController not found with tag: $controllerTag',
        );

        // Try to find without tag as fallback
        if (Get.isRegistered<ExpensesPageController>()) {
          debugPrint(
            '🎯 [FILTER] Found expenses controller without tag, using default',
          );
          final expensesController = Get.find<ExpensesPageController>();

          // Determine filters
          String? expenseView;
          if (groupOneSelected.value == 1) {
            expenseView = 'involving_me';
          }

          String? transactionType;
          if (groupTwoSelected.value == 0) {
            transactionType = 'borrowed';
          } else if (groupTwoSelected.value == 1) {
            transactionType = 'lent';
          } else if (groupTwoSelected.value == 2) {
            transactionType = null;
          }

          await expensesController.getGroupExpenses(
            expenseView: expenseView,
            transactionType: transactionType,
          );

          isFilterApplied.value = true;
        } else {
          debugPrint('❌ [FILTER] No ExpensesPageController found at all');
        }
      }
      // ignore: empty_catches
    } catch (e) {
      debugPrint('❌ [FILTER] Error applying filters: $e');
      debugPrint('❌ [FILTER] Stack trace: ${StackTrace.current}');
    }
  }

  // Reset filters to default
  void resetFilters() {
    groupOneSelected.value = 0;
    // Reset transaction type back to 'All' by default
    groupTwoSelected.value = 2;
    showIndividual.value = false;
    isFilterApplied.value = false;
  }

  // Get current filter description
  String getFilterDescription() {
    if (!isFilterApplied.value) return 'No filters applied';

    List<String> descriptions = [];

    // Add expense view description
    if (groupOneSelected.value == 0) {
      descriptions.add('All group expenses');
    } else if (groupOneSelected.value == 1) {
      descriptions.add('Involving me only');
    }

    // Add transaction type description
    if (groupTwoSelected.value == 0) {
      descriptions.add('I borrowed');
    } else if (groupTwoSelected.value == 1) {
      descriptions.add('I lent');
    } else if (groupTwoSelected.value == 2) {
      descriptions.add('All');
    }

    return descriptions.join(' • ');
  }
}
