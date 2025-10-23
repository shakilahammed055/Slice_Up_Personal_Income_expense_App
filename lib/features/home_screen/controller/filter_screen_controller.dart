
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';


class FilterScreenController extends GetxController {
  // ✅ 0=Total Remaining, 1=Total Expense - INDEPENDENT
  RxInt groupOneSelected = 0.obs;
  void selectGroupOne(int index) {
    groupOneSelected.value = index;

    // ✅ NO AUTO-SELECTION - All independent
    debugPrint('Group One selected: $index (Total View)');
  }

  // ✅ 0=All, 1=Expense Only, 2=Income Only - INDEPENDENT
  RxInt groupTwoSelected = 0.obs;
  void selectGroupTwo(int index) {
    groupTwoSelected.value = index;
    // ✅ Reset groupOne when selecting type filter
    if (index != 0) {
      groupOneSelected.value = 0;
    }
    debugPrint('Group Two selected: $index (Type Filter)');
  }

  // Month/Year Filter
  Rx<DateTime?> selectedMonthYearFilter = Rx<DateTime?>(null);
  
  @override
  void onInit() {
    super.onInit();
    selectedMonthYearFilter.value = null;
  }

  
  void updateMonthYearFilter(DateTime newDate) {
    final updatedDate = DateTime(newDate.year, newDate.month, 1);
    selectedMonthYearFilter.value = updatedDate;
    debugPrint("Month/Year filter updated to: ${updatedDate.month}/${updatedDate.year}");
  }

  void clearMonthFilter() {
    selectedMonthYearFilter.value = null;
    debugPrint("Month filter cleared");
  }


  RxBool isMonthlySelected = true.obs;
  void toggleMonthlyYearly() => isMonthlySelected.value = !isMonthlySelected.value;
  String get currentPeriodUnit => isMonthlySelected.value ? "Monthly".tr : "Yearly".tr;
}

