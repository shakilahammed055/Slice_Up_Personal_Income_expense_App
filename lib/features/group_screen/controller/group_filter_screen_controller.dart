import 'package:get/get.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';

class GroupFilterScreenController extends GetxController {
  // For the "Expense View" section
  var groupOneSelected = 0.obs;

  // For the "Transaction Type" section
  var groupTwoSelected = 0.obs;

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
      print('🎯 [FILTER] Starting filter application...');
      print('🎯 [FILTER] GroupId: $groupId');
      print('🎯 [FILTER] Group One Selected: ${groupOneSelected.value}');
      print('🎯 [FILTER] Group Two Selected: ${groupTwoSelected.value}');

      // Get the expenses controller for the specific group
      String controllerTag = groupId ?? 'default';
      print('🎯 [FILTER] Looking for controller with tag: $controllerTag');

      // Debug: Check what controllers are registered
      print('🎯 [FILTER] Checking all registered controllers...');
      Get.printInfo();

      if (Get.isRegistered<ExpensesPageController>(tag: controllerTag)) {
        print('🎯 [FILTER] Found expenses controller with specific tag');
        final expensesController = Get.find<ExpensesPageController>(
          tag: controllerTag,
        );

        // Determine expense view filter
        String? expenseView;
        if (groupOneSelected.value == 0) {
          expenseView = null; // All group - no filter needed
          print('🎯 [FILTER] Expense view: All group');
        } else if (groupOneSelected.value == 1) {
          expenseView = 'involving_me'; // Involving me only
          print('🎯 [FILTER] Expense view: Involving me only');
        }

        // Determine transaction type filter
        String? transactionType;
        if (groupTwoSelected.value == 0) {
          transactionType = 'borrowed'; // I borrowed
          print('🎯 [FILTER] Transaction type: borrowed');
        } else if (groupTwoSelected.value == 1) {
          transactionType = 'lent'; // I lent
          print('🎯 [FILTER] Transaction type: lent');
        }

        print(
          '🎯 [FILTER] Applying filters - expenseView: $expenseView, transactionType: $transactionType',
        );

        // Apply the filters
        await expensesController.getGroupExpenses(
          expenseView: expenseView,
          transactionType: transactionType,
        );

        print('🎯 [FILTER] Filters applied successfully');
        isFilterApplied.value = true;
      } else {
        print(
          '❌ [FILTER] ExpensesPageController not found with tag: $controllerTag',
        );

        // Try to find without tag as fallback
        if (Get.isRegistered<ExpensesPageController>()) {
          print(
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
          }

          await expensesController.getGroupExpenses(
            expenseView: expenseView,
            transactionType: transactionType,
          );

          isFilterApplied.value = true;
        } else {
          print('❌ [FILTER] No ExpensesPageController found at all');
        }
      }
    } catch (e) {
      print('❌ [FILTER] Error applying filters: $e');
      print('❌ [FILTER] Stack trace: ${StackTrace.current}');
    }
  }

  // Reset filters to default
  void resetFilters() {
    groupOneSelected.value = 0;
    groupTwoSelected.value = 0;
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
    }

    return descriptions.join(' • ');
  }
}
