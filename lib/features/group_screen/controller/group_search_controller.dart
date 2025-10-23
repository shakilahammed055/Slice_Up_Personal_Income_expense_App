import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';

class GroupSearchController extends GetxController {
  // Observable variables
  var searchQuery = ''.obs;
  var searchResults = <Map<String, dynamic>>[].obs;
  var isSearching = false.obs;
  var groupId = ''.obs;

  // Text editing controller for the search field
  final TextEditingController searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();

    // Listen to text changes in the search field
    searchTextController.addListener(() {
      searchQuery.value = searchTextController.text;
      if (searchQuery.value.isNotEmpty) {
        performSearch();
      } else {
        clearSearch();
      }
    });
  }

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }

  // Set the group ID to search within
  void setGroupId(String id) {
    groupId.value = id;

    debugPrint('🔍 [SEARCH] Group ID set to: $id');

  }

  // Perform search through expenses
  void performSearch() {
    if (searchQuery.value.isEmpty || groupId.value.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;

    debugPrint(
      '🔍 [SEARCH] Searching for: "${searchQuery.value}" in group: ${groupId.value}',
    );


    try {
      // Get the expenses controller for the specific group
      String controllerTag = groupId.value;

      if (Get.isRegistered<ExpensesPageController>(tag: controllerTag)) {
        final expensesController = Get.find<ExpensesPageController>(
          tag: controllerTag,
        );

        // Get the expenses data directly from the controller (same as expenses page)
        List<Map<String, dynamic>> allExpensesData =
            expensesController.expenses;

        // Filter the day data based on search query
        String query = searchQuery.value.toLowerCase();
        List<Map<String, dynamic>> filteredDayData = [];

        for (var dayData in allExpensesData) {
          List<dynamic> dayExpenses = dayData['expenses'] ?? [];
          List<dynamic> filteredExpenses = [];

          for (var expense in dayExpenses) {
            if (expense is Map<String, dynamic>) {
              String title = (expense['title'] ?? '').toString().toLowerCase();
              String status = (expense['status'] ?? '')
                  .toString()
                  .toLowerCase();
              String amount = (expense['formattedAmount'] ?? '')
                  .toString()
                  .toLowerCase();

              if (title.contains(query) ||
                  status.contains(query) ||
                  amount.contains(query)) {
                filteredExpenses.add(expense);
              }
            }
          }

          // Only include days that have matching expenses
          if (filteredExpenses.isNotEmpty) {
            filteredDayData.add({
              'date': dayData['date'],
              'expenses': filteredExpenses,
            });
          }
        }

        searchResults.value = filteredDayData;

        debugPrint(
          '🔍 [SEARCH] Found ${filteredDayData.length} days with matching expenses',
        );
      } else {
        debugPrint(
          '❌ [SEARCH] ExpensesPageController not found for group: $controllerTag',
        );
        searchResults.clear();
      }
    } catch (e) {
      debugPrint('❌ [SEARCH] Error performing search: $e');
      searchResults.clear();
    } finally {
      isSearching.value = false;
    }
  }

  // Clear search results
  void clearSearch() {
    searchResults.clear();
    isSearching.value = false;

    debugPrint('🔍 [SEARCH] Search cleared');

  }

  // Clear search text and results
  void clearSearchText() {
    searchTextController.clear();
    clearSearch();
  }

  // Format expense data for display (same format as expenses page)
  Map<String, dynamic> formatExpenseForDisplay(Map<String, dynamic> expense) {
    return expense; // Return the expense data as-is, same as expenses page
  }

  // Get search results (same structure as expenses page)
  List<Map<String, dynamic>> get groupedSearchResults {
    return searchResults;
  }
}
