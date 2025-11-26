import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

void showCalendarBottomSheet(BuildContext context, {String? controllerTag}) {
  final tag = controllerTag ?? 'groupTripSpent';
  final controller = Get.find<GroupTripSpentController>(tag: tag);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.70,
        constraints: BoxConstraints(minHeight: 184),
        color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                return TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.selectedDate.value ?? DateTime.now(),
                  selectedDayPredicate: (day) =>
                      isSameDay(controller.selectedDate.value, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    controller.selectDate(selectedDay);
                    Navigator.pop(context, selectedDay);
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontSize: 17.0,
                    ), // Month/Year color
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ), // Chevron color
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ), // Chevron color
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: const BoxDecoration(
                      color: Colors.transparent,
                      shape: BoxShape.rectangle,
                    ),
                    todayTextStyle: TextStyle(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontWeight: FontWeight.normal,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                    selectedTextStyle: TextStyle(
                      color: isDark ? AppColors.black : AppColors.textWhite,
                    ),
                    defaultTextStyle: TextStyle(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                    weekendTextStyle: TextStyle(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                    outsideTextStyle: TextStyle(color: Colors.grey),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    },
  ).then((value) {
    if (value != null && value is DateTime) {
      controller.selectDate(value);
    }
  });
}
