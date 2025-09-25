// teddy_5618/features/home_screen/controller/filter_screen_controller.dart

import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class FilterScreenController extends GetxController {
  // Existing state for group 1
  RxInt groupOneSelected = 0.obs; // 0 for Total Remaining, 1 for Total Expense
  void selectGroupOne(int index) => groupOneSelected.value = index;

  // Existing state for group 2
  RxInt groupTwoSelected = 0.obs; // 0 for All, 1 for Expense Only, 2 for Income Only
  void selectGroupTwo(int index) => groupTwoSelected.value = index;

  // State for Month/Year Filter
  Rx<DateTime> selectedMonthYearFilter = DateTime(2025, 4, 1).obs;
  void updateMonthYearFilter(DateTime newDate) {
    selectedMonthYearFilter.value = newDate;

    debugPrint("Month/Year filter updated to: ${selectedMonthYearFilter.value.month}/${selectedMonthYearFilter.value.year}");

    // You would typically trigger your data filtering logic here
  }

  // --- NEW: State for Monthly/Yearly Toggle ---
  RxBool isMonthlySelected = true.obs; // true for Monthly, false for Yearly

  void toggleMonthlyYearly() {
    isMonthlySelected.value = !isMonthlySelected.value;

    debugPrint("Toggle unit to: ${isMonthlySelected.value ? 'Monthly' : 'Yearly'}");

    // You might trigger a re-filter or UI update based on this selection
  }

  String get currentPeriodUnit => isMonthlySelected.value ? "Monthly".tr : "Yearly".tr;
  // ---------------------------------------
}