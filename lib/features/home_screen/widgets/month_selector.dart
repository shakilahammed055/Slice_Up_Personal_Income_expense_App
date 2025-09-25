import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Assuming these are defined in your project
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class MonthSelectorController extends GetxController {
  final Rx<DateTime> selectedDate = DateTime(
    DateTime.now().year,
    DateTime.now().month,
    1,
  ).obs;
  final RxList<DateTime> availableMonths = <DateTime>[].obs;
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _generateAvailableMonths();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedMonth(animate: false);
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _generateAvailableMonths() {
    final DateTime startDate = DateTime(2025, 1, 1);
    final DateTime endDate = DateTime(2050, 12, 1);

    DateTime currentDate = startDate;
    while (currentDate.isBefore(endDate) ||
        currentDate.isAtSameMomentAs(endDate)) {
      availableMonths.add(DateTime(currentDate.year, currentDate.month, 1));
      currentDate = DateTime(currentDate.year, currentDate.month + 1, 1);
    }
  }

  void setSelectedDate(DateTime date) {
    selectedDate.value = DateTime(
      date.year,
      date.month,
      1,
    ); // Normalize to first of the month
    debugPrint(
      'Selected date updated to: ${DateFormat('MMM yyyy').format(selectedDate.value)}',
    );
    _scrollToSelectedMonth(animate: true);
  }

  void _scrollToSelectedMonth({bool animate = true}) {
    final int index = availableMonths.indexWhere(
      (month) =>
          month.year == selectedDate.value.year &&
          month.month == selectedDate.value.month,
    );

    if (index != -1 && scrollController.hasClients) {
      double itemWidth = 100.0; // Adjusted for safety

      // Estimate item width. This might need fine-tuning.

      final double screenWidth = Get.width;
      final double centerOffset = (screenWidth / 2) - (itemWidth / 2);
      final double offset = (index * itemWidth) - centerOffset;

      debugPrint('Scrolling to index: $index, offset: $offset');
      if (animate) {
        scrollController.animateTo(
          offset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        scrollController.jumpTo(
          offset.clamp(0.0, scrollController.position.maxScrollExtent),
        );
      }
    } else {
      debugPrint(
        'Scroll failed: index=$index, hasClients=${scrollController.hasClients}',
      );
    }
  }
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final MonthSelectorController controller = Get.put(
      MonthSelectorController(),
    );

    return Container(
       color: isDark ? Color(0xFF262626) : AppColors.textWhite,
      child: Column(
        children: [
          
          SizedBox(
            height: 30,
            child: Obx(() {
              debugPrint(
                'ListView rebuilding, selectedDate: ${controller.selectedDate.value}',
              );
              return ListView.builder(
                controller: controller.scrollController,
                scrollDirection: Axis.horizontal,
                reverse: true,
                itemCount: controller.availableMonths.length,
                itemBuilder: (context, index) {
                  final DateTime month = controller.availableMonths[index];
                  final String formattedMonth = DateFormat(
                    'MMM yyyy',
                  ).format(month);
      
                  final bool isSelected =
                      controller.selectedDate.value.year == month.year &&
                      controller.selectedDate.value.month == month.month;
      
                  debugPrint(
                    'Index: $index, Month: $formattedMonth, isSelected: $isSelected',
                  );
      
                  return GestureDetector(
                    onTap: () {
                      controller.setSelectedDate(month);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formattedMonth,
                            style: getTextStyle2(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? (isDark
                                        ? AppColors.textWhite
                                        : AppColors.black)
                                  : AppColors.textGrey,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              height: 2,
                              width: 80,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                              //  AppColors.backgroundDark,
                            )
                          else
                            SizedBox(height: 6),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
