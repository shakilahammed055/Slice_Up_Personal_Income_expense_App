import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalendarController extends GetxController {
  // Selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  // Current month being displayed
  final Rx<DateTime> currentMonth = DateTime.now().obs;

  // Days in the current month view
  final RxList<DateTime> daysInMonth = <DateTime>[].obs;

  // Weekday headers
  final List<String> weekdays = ['SUN', 'MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT'];

  // Tab selection (0 = One time, 1 = Repeat)
  final RxInt selectedTab = 0.obs;

  // Selected repeat option
  final RxString selectedRepeatOption = 'Every Sunday'.obs;

  @override
  void onInit() {
    super.onInit();
    generateDaysInMonth();
  }

  /// Generate all days to display in the calendar
  void generateDaysInMonth() {
    final year = currentMonth.value.year;
    final month = currentMonth.value.month;

    // First and last day of the month
    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    // Days from previous month to show
    final firstWeekday = firstDay.weekday % 7;
    final previousMonthDays = firstWeekday;

    // Days from next month to show
    final lastWeekday = lastDay.weekday % 7;
    final nextMonthDays = 6 - lastWeekday;

    final days = <DateTime>[];

    // Add previous month's days
    if (previousMonthDays > 0) {
      final previousMonthLastDay = DateTime(year, month, 0);
      for (var i = previousMonthDays - 1; i >= 0; i--) {
        days.add(previousMonthLastDay.subtract(Duration(days: i)));
      }
    }

    // Add current month's days
    for (var i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(year, month, i));
    }

    // Add next month's days
    if (nextMonthDays > 0) {
      for (var i = 1; i <= nextMonthDays; i++) {
        days.add(DateTime(year, month + 1, i));
      }
    }

    daysInMonth.value = days;
  }

  /// Navigate to previous month
  void previousMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month - 1,
      1,
    );
    generateDaysInMonth();
  }

  /// Navigate to next month
  void nextMonth() {
    currentMonth.value = DateTime(
      currentMonth.value.year,
      currentMonth.value.month + 1,
      1,
    );
    generateDaysInMonth();
  }

  /// Select a date
  void selectDate(DateTime date) {
    selectedDate.value = DateTime(date.year, date.month, date.day);
  }

  /// Check if a date is selected
  bool isSelected(DateTime date) {
    return selectedDate.value.year == date.year &&
        selectedDate.value.month == date.month &&
        selectedDate.value.day == date.day;
  }

  /// Check if a date belongs to current month
  bool isCurrentMonth(DateTime date) {
    return currentMonth.value.month == date.month && 
           currentMonth.value.year == date.year;
  }

  /// Get formatted month and year (e.g. "June 2023")
  String getMonthYear() {
    return DateFormat('MMMM yyyy').format(currentMonth.value);
  }

  /// Switch between tabs (One time/Repeat)
  void switchTab(int index) {
    selectedTab.value = index;
  }

  /// Select a repeat option
  void selectRepeatOption(String option) {
    selectedRepeatOption.value = option;
  }
}