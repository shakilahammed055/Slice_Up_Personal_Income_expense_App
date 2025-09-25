import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Assuming these are defined in your project
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

// GetX Controller to manage the state and logic for year selection
class YearlySelectorController extends GetxController {
  // Observable to hold the currently selected year
  final Rx<DateTime> selectedYear = DateTime.now().obs;

  // List to store all possible years (2025 to 2050)
  final RxList<DateTime> _allAvailableYears = <DateTime>[].obs;

  final ScrollController yearlyScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    _generateAllAvailableYears();

    // Set initial selected year to 2025, or current year if within range
    final DateTime now = DateTime.now();
    int initialYear = 2025;
    if (now.year >= 2025 && now.year <= 2050) {
      initialYear = now.year;
    }
    selectedYear.value = DateTime(initialYear);
    debugPrint(
      'Initial selected year: ${DateFormat('yyyy').format(selectedYear.value)}',
    );

    // Scroll to the initial selected year after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear(animate: false);
    });
  }

  @override
  void onClose() {
    yearlyScrollController.dispose();
    super.onClose();
  }

  void _generateAllAvailableYears() {
    for (int year = 2000; year <= 2050; year++) {
      _allAvailableYears.add(DateTime(year));
    }
  }

  List<DateTime> getYearlyDates() {
    return _allAvailableYears;
  }

  void setSelectedYearAndScroll(DateTime date) {
    selectedYear.value = date;
    final String debugFormattedDate = DateFormat('yyyy').format(date);
    debugPrint('Selected year updated to: $debugFormattedDate');
    _scrollToSelectedYear(animate: true);
  }

  void _scrollToSelectedYear({bool animate = true}) {
    if (!yearlyScrollController.hasClients) {
      debugPrint('ScrollController has no clients yet, cannot scroll.');
      return;
    }

    int index = _allAvailableYears.indexWhere(
      (d) => d.year == selectedYear.value.year,
    );

    if (index != -1) {
      const double itemWidth = 80.0; // Aligned with itemExtent
      // final double offset = index * itemWidth;
      final double screenWidth =
          Get.width; // or MediaQuery.of(context).size.width
      final double centerOffset = (screenWidth / 2) - (itemWidth / 2);
      final double offset = (index * itemWidth) - centerOffset;

      debugPrint('Scrolling to index: $index, offset: $offset');
      if (animate) {
        yearlyScrollController.animateTo(
          offset.clamp(0.0, yearlyScrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        yearlyScrollController.jumpTo(
          offset.clamp(0.0, yearlyScrollController.position.maxScrollExtent),
        );
      }
    } else {
      debugPrint('Selected year not found in list for scrolling.');
    }
  }
}

// The main widget for selecting a year
class YearlySelector extends StatelessWidget {
  const YearlySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final YearlySelectorController controller = Get.put(
      YearlySelectorController(),
    );

    return Container(
      color: isDark ? Color(0xFF262626) : AppColors.textWhite,
      child: Column(
        children: [
          SizedBox(
            height: 30,
            child: Obx(() {
              debugPrint(
                'ListView rebuilding, selectedYear: ${DateFormat('yyyy').format(controller.selectedYear.value)}',
              );
              final List<DateTime> years = controller.getYearlyDates();

              return SizedBox(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  controller: controller.yearlyScrollController,
                  scrollDirection: Axis.horizontal,
                  reverse: true,
                  itemCount: years.length,
                  itemExtent: 80.0, // Fixed width per year item
                  itemBuilder: (context, index) {
                    final DateTime year = years[index];
                    final String formattedYear = DateFormat(
                      'yyyy',
                    ).format(year);
                    final bool isSelected =
                        controller.selectedYear.value.year == year.year;

                    debugPrint(
                      'Index: $index, Year: $formattedYear, isSelected: $isSelected',
                    );

                    return GestureDetector(
                      onTap: () {
                        debugPrint('Tapped year: $formattedYear');
                        controller.setSelectedYearAndScroll(year);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              formattedYear,
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
                                margin: const EdgeInsets.only(top: 4),
                                height: 2,
                                width: MediaQuery.of(context).size.width / 1.6,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              )
                            else
                              const SizedBox(height: 6),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
