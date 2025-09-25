import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:numberpicker/numberpicker.dart';


import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart'; // Assuming this path is correct

// Controller for MonthYearBar
class MonthYearController extends GetxController {
  // Define the start and end dates for the scrollable range
  static final DateTime _startDate = DateTime(2000, 1, 1); // Jan 2000
  static final DateTime _endDate = DateTime(2040, 12, 1); // Dec 2040

  // Calculate total number of months in the range
  static final int _totalMonths =
      (_endDate.year - _startDate.year) * 12 + (_endDate.month - _startDate.month) + 1;

  // RxInt to hold the current selected index in the scrollable list
  RxInt selectedIndex = 0.obs;

  @override
  // ignore: unnecessary_overrides
  void onInit() {
    super.onInit();
  }

  // Set the initial index based on a given DateTime
  void setInitialIndex(DateTime initialDate) {
    int yearDiff = initialDate.year - _startDate.year;
    int monthDiff = initialDate.month - _startDate.month;
    selectedIndex.value = yearDiff * 12 + monthDiff;
    // Ensure the initial index is within bounds
    if (selectedIndex.value < 0) selectedIndex.value = 0;
    if (selectedIndex.value >= _totalMonths) selectedIndex.value = _totalMonths - 1;
  }

  // Converts an index to a DateTime object (first day of the month)
  DateTime _indexToDateTime(int index) {
    final int totalMonthsFromStart = index;
    final int targetYear = _startDate.year + (totalMonthsFromStart + _startDate.month - 1) ~/ 12;
    final int targetMonth = (totalMonthsFromStart + _startDate.month - 1) % 12 + 1;
    
    return DateTime(targetYear, targetMonth, 1);
  }

  // Update the selected index
  void updateIndex(int index) {
    selectedIndex.value = index;
  }

  // Get the currently selected DateTime
  DateTime get selectedDate => _indexToDateTime(selectedIndex.value);

  // Helper to get month name from month number (1-12)
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return ''; // Should not happen
    }
  }

  // Get the formatted string for a given index
  String getFormattedDateForIndex(int index) {
    final DateTime date = _indexToDateTime(index);
    return '${_getMonthName(date.month)} ${date.year}';
  }
}

class MonthYearBar extends StatelessWidget {
  final Function(DateTime) onDateSelected;
  final DateTime initialDate;

  // REMOVED 'const' from the constructor and from the default DateTime value
  MonthYearBar({
    super.key,
    required this.onDateSelected,
    DateTime? initialDate,
  })  : initialDate = initialDate ?? DateTime(2025, 4, 1);

  @override
  Widget build(BuildContext context) {
    final MonthYearController controller = Get.put(MonthYearController());
    // Explicitly set the initial index based on the provided initialDate
     final isDark = Theme.of(context).brightness == Brightness.dark;
    controller.setInitialIndex(initialDate);

    // Removed Container height, decoration and rounded corners typical for bottom sheets
    // Now it's a regular widget that can be placed in any Column/Row/etc.
    return Column(
      mainAxisSize: MainAxisSize.min, // Takes minimum space
      children: [
        // Removed the top drag handle
        // Removed 'SELECT MONTH & YEAR' title if it's part of a larger filter screen


        Expanded( // Use Expanded to give the picker available vertical space
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Single NumberPicker for Month and Year
              Obx(
                () => NumberPicker(
                  value: controller.selectedIndex.value,
                  minValue: 0,
                  maxValue: MonthYearController._totalMonths - 1,
                  itemHeight: 40,
                  itemCount: 5, // Show 5 items (2 before, 1 selected, 2 after)
                  axis: Axis.vertical,
                  textMapper: (numberText) {
                    final int index = int.parse(numberText);
                    
                    return controller.getFormattedDateForIndex(index);
                  },
                  textStyle: getTextStyle2( // Use getTextStyle21
                   color: isDark ? AppColors.textWhite : AppColors.textPrimary,
                    // color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                  ),
                  selectedTextStyle: getTextStyle2( // Use getTextStyle21
                    color: Colors.transparent, // Make selected text transparent
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  onChanged: (value) {
                    controller.updateIndex(value);
                    onDateSelected(controller.selectedDate); // Callback immediately on change
                  },
                ),
              ),







              // Overlay container - only cover the middle section for the selected value
              Positioned(
                child: IgnorePointer(
                  child: Obx(
                   

                    () => Container(
                      height: 37,
                      width: MediaQuery.of(context).size.width / 1.1, // Adjust width as needed
                      decoration: BoxDecoration(
                         color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
                        // color: AppColors.lightGreyContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        controller.getFormattedDateForIndex(controller.selectedIndex.value),
                        style: getTextStyle2( 
                          
                          // Use getTextStyle21

                        color: isDark ? AppColors.textWhite : AppColors.textPrimary,
                          // color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Removed the "Done" button as selection is now immediate
      ],
    );
  }
}

// Removed the showMonthYearBar helper function as it's no longer a modal bottom sheet.

// RestTimerController and RestTimerBottomSheet (original code, kept for completeness)
// You can remove these if they are not needed elsewhere
class RestTimerController extends GetxController {
  RxInt selectedTime = 15.obs;

  void updateTime(int time) {
    selectedTime.value = time;
  }
}

class RestTimerBottomSheet extends StatelessWidget {
  final Function(int) onTimeSelected;
  final int initialTime;

  const RestTimerBottomSheet({
    super.key,
    required this.onTimeSelected,
    this.initialTime = 15,
  });

  @override
  Widget build(BuildContext context) {
    final RestTimerController controller = Get.put(RestTimerController());
    controller.selectedTime.value = initialTime;

    return Container(
      height: MediaQuery.of(context).size.height / 2,
      decoration: BoxDecoration(
        color: AppColors.lightContainer,
        borderRadius:  BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 12),
          Container(
            width: MediaQuery.of(context).size.width / 5,
            height: MediaQuery.of(context).size.height / 150,
            decoration: BoxDecoration(
              color: AppColors.textWhite,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),

          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            ],
          ),
          SizedBox(height: 10),

          // Number Picker with Stack
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // NumberPicker - make selected text transparent
                Obx(() => NumberPicker(
                      value: controller.selectedTime.value,
                      minValue: 5,
                      maxValue: 60,
                      step: 5,
                      itemHeight: 40,
                      itemCount: 7, // Show 7 items total (3 before + 1 selected + 3 after)
                      axis: Axis.vertical,
                      textStyle: getTextStyle2(
                        color: AppColors.textWhite,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      selectedTextStyle: getTextStyle2(
                        color: Colors.transparent, // Make selected text transparent
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      onChanged: (value) => controller.updateTime(value),
                    )),

                // Overlay container - only cover the middle section
                Positioned(
                  child: IgnorePointer(
                    child: Obx(
                      () => Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width / 1, // Full width
                        color: AppColors.secondary,
                        alignment: Alignment.center,
                        child: Text(
                          '${controller.selectedTime.value}',
                          style: getTextStyle2(
                            color: AppColors.backgroundLightGrey,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(top: 20, bottom: 20),
            child: GestureDetector(
              onTap: () {
                onTimeSelected(controller.selectedTime.value);
                Get.back();
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 2.5,
                padding: EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(25),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Done',
                  style: getTextStyle2(
                    color: AppColors.backgroundLightGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper function to show the bottom sheet
void showRestTimerBottomSheet({
  required BuildContext context,
  required Function(int) onTimeSelected,
  int initialTime = 5,
}) {

}