// ignore_for_file: unnecessary_to_list_in_spreads, curly_braces_in_flow_control_structures
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/home_screen/controller/home_screen_controller.dart';
import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';
import 'package:teddy_5618/features/home_screen/screen/bar_chart_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/filter_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/search_screen.dart';
import 'package:teddy_5618/features/home_screen/widgets/month_setting.dart';
import 'package:teddy_5618/features/home_screen/widgets/show_assistant.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/set_expense_income/screen/expense_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void showAssistantDialog(BuildContext context) {
    debugPrint('showAssistantDialog called');
    try {
      final HomeController controller = Get.find<HomeController>();
      Get.dialog(ShowAssistant(controller: controller));
    } catch (e) {
      debugPrint('Error in showAssistantDialog: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to open assistant dialog'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void showMonthSettingBottomSheet(BuildContext context) {
    debugPrint('showMonthSettingBottomSheet called');
    try {
      final HomeController controller = Get.find<HomeController>();
      debugPrint('HomeController found: $controller');
      Showmonthsetting(controller: controller).show(context);
    } catch (e) {
      debugPrint('Error in showMonthSettingBottomSheet: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to open month setting'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void handleFabAction(BuildContext context) {
    debugPrint('handleFabAction called');
    final HomeController controller = Get.find<HomeController>();
    if (controller.isDateRangeSet.value) {
      Get.to(() => const ExpenseScreen());
    } else {
      Showmonthsetting(controller: controller).show(context);
    }
  }

  String _formatDateRangeDisplay(HomeController controller) {
    if (controller.isApiDataLoaded.value &&
        controller.apiStartDate.value.isNotEmpty &&
        controller.apiEndDate.value.isNotEmpty) {
      try {
        final startDate = DateTime.parse(controller.apiStartDate.value);
        final endDate = DateTime.parse(controller.apiEndDate.value);
        final startMonth = DateFormat('MMMM').format(startDate);
        final endMonth = DateFormat('MMMM').format(endDate);
        final startDay = startDate.day;
        final endDay = endDate.day;
        return '$startMonth $startDay ~ $endMonth $endDay';
      } catch (e) {
        debugPrint('Error parsing API dates for display: $e');
      }
    }

    if (controller.selectedStartDate.value != -1 &&
        controller.selectedEndDate.value != -1) {
      return '${controller.currentMonth.value} ${controller.selectedStartDate.value} ~ ${controller.nextMonth.value} ${controller.selectedEndDate.value}';
    }

    return 'Continue setting'.tr;
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('HomeScreen build called');
    Get.put(HomeController());
    Get.put(ExpenseController());
    Get.put(FilterScreenController());
    final double screenHeight = MediaQuery.of(context).size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String currentDeviceMonth = DateFormat('MMMM').format(DateTime.now());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<HomeController>();
      controller.refreshIncomeAndExpenses();
    });

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : const Color(0xFFFAFAFA),
        automaticallyImplyLeading: false,
        actions: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => const SearchScreen()),
                child: Icon(
                  Icons.search,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 15.w),
              GestureDetector(
                onTap: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(34.r),
                    ),
                  ),
                  builder: (context) => const FilterScreen(),
                ),
                child: Icon(
                  Icons.filter_list,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 15.w),
              GestureDetector(
                onTap: () => Get.to(() => const BarChartScreen()),
                child: Icon(
                  Icons.bar_chart,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 15.w),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              clipBehavior: Clip.none,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Obx(() {
                final controller = Get.find<HomeController>();
                final expenseController = Get.find<ExpenseController>();
                final filterController = Get.find<FilterScreenController>();

                return Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => showMonthSettingBottomSheet(context),
                            child: Container(
                              color: Colors.transparent,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDateRangeDisplay(controller),
                                    style: getTextStyle2(
                                      color: const Color(0xFF828282),
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 6.h),
                                  Text(
                                    currentDeviceMonth,
                                    style: getTextStyle2(
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ✅ PERFECT INDEPENDENT LOGIC
                          Obx(() {
                            double displayAmount;
                            final DateTime? selectedMonth =
                                filterController.selectedMonthYearFilter.value;
                            final int typeFilter =
                                filterController.groupTwoSelected.value;
                            final int groupOne =
                                filterController.groupOneSelected.value;

                            if (controller.isApiDataLoaded.value) {
                              double inc = 0.0;
                              double exp = 0.0;
                              for (var group in controller.apiGroupedByDate) {
                                final String gDateStr = group['date'];
                                final DateTime gDate = DateTime.parse(gDateStr);
                                if (selectedMonth != null &&
                                    (gDate.year != selectedMonth.year ||
                                        gDate.month != selectedMonth.month))
                                  continue;
                                final List<Map<String, dynamic>> trans =
                                    (group['transactions'] as List)
                                        .cast<Map<String, dynamic>>();
                                for (var t in trans) {
                                  final double amt = (t['amount'] as num)
                                      .toDouble();
                                  if (t['transactionType'] == 'income') {
                                    inc += amt;
                                  } else {
                                    exp += amt;
                                  }
                                }
                              }

                              // ✅ EXACTLY INDEPENDENT LOGIC:
                              if (groupOne == 1) {
                                // Total Expense
                                displayAmount =
                                    inc - (inc - exp); // Income - Remaining ✅
                              } else if (groupOne == 0 && typeFilter == 0) {
                                // Total Remaining
                                displayAmount = inc - exp; // Income - Expense ✅
                              } else if (typeFilter == 1) {
                                // Expense Only
                                displayAmount = exp; // All Expenses ✅
                              } else if (typeFilter == 2) {
                                // Income Only
                                displayAmount = inc; // All Income ✅
                              } else {
                                displayAmount = inc - exp; // Default
                              }
                            } else {
                              if (expenseController.entries.isEmpty) {
                                displayAmount = 0.0;
                              } else {
                                double localInc = expenseController.entries
                                    .where((e) => e.isIncome)
                                    .fold<double>(
                                      0.0,
                                      (sum, e) => sum + e.amount,
                                    );
                                double localExp = expenseController.entries
                                    .where((e) => !e.isIncome)
                                    .fold<double>(
                                      0.0,
                                      (sum, e) => sum + e.amount,
                                    );

                                if (groupOne == 1) {
                                  // Total Expense
                                  displayAmount =
                                      localInc -
                                      (localInc -
                                          localExp); // Income - Remaining ✅
                                } else if (groupOne == 0 && typeFilter == 0) {
                                  // Total Remaining
                                  displayAmount = localInc - localExp;
                                } else if (typeFilter == 1) {
                                  // Expense Only
                                  displayAmount = localExp;
                                } else if (typeFilter == 2) {
                                  // Income Only
                                  displayAmount = localInc;
                                } else {
                                  displayAmount = localInc - localExp;
                                }
                              }
                            }
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Total S\$'.tr,
                                  style: getTextStyle2(
                                    color: const Color(0xFF828282),
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  displayAmount.toStringAsFixed(2),
                                  textAlign: TextAlign.right,
                                  style: getTextStyle2(
                                    color: isDark
                                        ? Color(0xFF406DFF)
                                        : Color(0xFF2A31EF),
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    // controller.selectedAssistant.value.isNotEmpty
                    //     ? Container(
                    //         constraints: BoxConstraints(
                    //           maxWidth: MediaQuery.of(context).size.width * 0.9,
                    //         ),
                    //         padding: EdgeInsets.symmetric(horizontal: 16.w),
                    //         decoration: ShapeDecoration(
                    //           color: isDark
                    //               ? Color(0xFF38383A)
                    //               : const Color(0xFFEDEDF0),
                    //           shape: RoundedRectangleBorder(
                    //             borderRadius: BorderRadius.circular(12.r),
                    //           ),
                    //         ),
                    //         child: Stack(
                    //           children: [
                    //             Container(
                    //               padding: EdgeInsets.symmetric(vertical: 16.h),
                    //               child: Column(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.center,
                    //                 children: [
                    //                   SizedBox(
                    //                     height: 60.h,
                    //                     width:
                    //                         MediaQuery.of(context).size.width *
                    //                         0.9,
                    //                     child: Text(
                    //                       'Ready to track your spending? Or just \nplanning to ignore it again'
                    //                           .tr,
                    //                       style: getTextStyle2(
                    //                         color: isDark
                    //                             ? AppColors.textWhite
                    //                             : AppColors.black,
                    //                         fontSize: 14.sp,
                    //                         fontWeight: FontWeight.w500,
                    //                         lineHeight: 22.sp,
                    //                       ),
                    //                       textAlign: TextAlign.left,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             Positioned(
                    //               right: 0,
                    //               top: 10.h,
                    //               child: Container(
                    //                 width: 60.w,
                    //                 height: 83.h,
                    //                 decoration: BoxDecoration(
                    //                   image: DecorationImage(
                    //                     image: AssetImage(
                    //                       controller.selectedAssistant.value ==
                    //                               'supportive'.tr
                    //                           ? IconPath.chiwawa1
                    //                           : IconPath.rabbit1,
                    //                     ),
                    //                     fit: BoxFit.fill,
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),

                    //             Positioned(
                    //               right: 5.w,
                    //               top: 5.h,
                    //               child: GestureDetector(
                    //                 onTap: () =>
                    //                     debugPrint('Share icon tapped'),
                    //                 child: Container(
                    //                   width: 30.w,
                    //                   height: 30.h,
                    //                   decoration: ShapeDecoration(
                    //                     color: isDark
                    //                         ? AppColors.textWhite
                    //                         : AppColors.textWhite,
                    //                     shape: RoundedRectangleBorder(
                    //                       borderRadius: BorderRadius.circular(
                    //                         20.r,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   child: Center(
                    //                     child: Icon(
                    //                       Icons.share,
                    //                       color: isDark
                    //                           ? AppColors.black
                    //                           : AppColors.black,
                    //                       size: 18.sp,
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),

                    //           ],
                    //         ),
                    //       )
                    //     : GestureDetector(
                    //         onTap: () => showAssistantDialog(context),
                    //         child: Container(
                    //           constraints: BoxConstraints(
                    //             maxWidth:
                    //                 MediaQuery.of(context).size.width * 0.9,
                    //           ),
                    //           height: 88.h,
                    //           padding: EdgeInsets.symmetric(horizontal: 24.w),
                    //           decoration: ShapeDecoration(
                    //             color: isDark
                    //                 ? Color(0xFF38383A)
                    //                 : const Color(0xFFEDEDF0),
                    //             shape: RoundedRectangleBorder(
                    //               borderRadius: BorderRadius.circular(16.r),
                    //             ),
                    //           ),
                    //           child: Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             crossAxisAlignment: CrossAxisAlignment.center,
                    //             children: [
                    //               Icon(
                    //                 Icons.add,
                    //                 color: isDark
                    //                     ? AppColors.textWhite
                    //                     : AppColors.black,
                    //                 size: 20.sp,
                    //               ),
                    //               SizedBox(width: 8.w),
                    //               Text(
                    //                 'Add assistant'.tr,
                    //                 textAlign: TextAlign.center,
                    //                 style: getTextStyle2(
                    //                   color: isDark
                    //                       ? AppColors.textWhite
                    //                       : AppColors.black,
                    //                   fontSize: 14.sp,
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //         ),
                    //       ),
                    controller.selectedAssistant.value.isNotEmpty
                        ? Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.9,
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? Color(0xFF38383A)
                                  : const Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 16.h),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 60.h,
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.9,
                                        child: Text(
                                          'Ready to track your spending? Or just \nplanning to ignore it again'
                                              .tr,
                                          style: getTextStyle2(
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w500,
                                            lineHeight: 22.sp,
                                          ),
                                          textAlign: TextAlign.left,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  top: 10.h,
                                  child: Container(
                                    width: 60.w,
                                    height: 83.h,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          controller.selectedAssistant.value ==
                                                  'Sarcastic Truth-Teller'.tr
                                              ? IconPath.rabbit1
                                              : IconPath.chiwawa1,
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                                // Positioned(
                                //   right: 5.w,
                                //   top: 5.h,
                                //   child: GestureDetector(
                                //     onTap: () =>
                                //         debugPrint('Share icon tapped'),
                                //     child: Container(
                                //       width: 30.w,
                                //       height: 30.h,
                                //       decoration: ShapeDecoration(
                                //         color: isDark
                                //             ? AppColors.textWhite
                                //             : AppColors.textWhite,
                                //         shape: RoundedRectangleBorder(
                                //           borderRadius: BorderRadius.circular(
                                //             20.r,
                                //           ),
                                //         ),
                                //       ),
                                //       child: Center(
                                //         child: Icon(
                                //           Icons.share,
                                //           color: isDark
                                //               ? AppColors.black
                                //               : AppColors.black,
                                //           size: 18.sp,
                                //         ),
                                //       ),
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        : GestureDetector(
                            onTap: () => showAssistantDialog(context),
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                              ),
                              height: 88.h,
                              padding: EdgeInsets.symmetric(horizontal: 24.w),
                              decoration: ShapeDecoration(
                                color: isDark
                                    ? Color(0xFF38383A)
                                    : const Color(0xFFEDEDF0),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    size: 20.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Add assistant'.tr,
                                    textAlign: TextAlign.center,
                                    style: getTextStyle2(
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    SizedBox(height: 16.h),
                    // ✅ Entries display (KEEP ALL YOUR EXISTING CODE HERE)
                    Obx(() {
                      final homeController = Get.find<HomeController>();
                      final filterController =
                          Get.find<FilterScreenController>();
                      final bool useApi =
                          homeController.isApiDataLoaded.value &&
                          homeController.apiGroupedByDate.isNotEmpty;

                      Widget noEntriesWidget = Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          children: [
                            Text(
                              'No entries available'.tr,
                              style: getTextStyle2(
                                color: const Color(0xFF828282),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.1),
                          ],
                        ),
                      );

                      if (useApi) {
                        return Obx(() {
                          final DateTime? selectedMonth =
                              filterController.selectedMonthYearFilter.value;
                          final int typeFilter =
                              filterController.groupTwoSelected.value;
                          List<Widget> filteredGroupWidgets = [];

                          for (var group in homeController.apiGroupedByDate) {
                            final String? dateStr = group['date'] as String?;
                            if (dateStr == null || dateStr.isEmpty) continue;
                            final DateTime dateTime;
                            try {
                              dateTime = DateTime.parse(dateStr);
                            } catch (e) {
                              debugPrint(
                                'Error parsing date: $dateStr, error: $e',
                              );
                              continue;
                            }
                            if (selectedMonth != null &&
                                (dateTime.year != selectedMonth.year ||
                                    dateTime.month != selectedMonth.month))
                              continue;
                            final String formattedDate = DateFormat(
                              'EEE d MMM yyyy',
                            ).format(dateTime);
                            final List<Map<String, dynamic>> allTransactions =
                                (group['transactions'] as List?)
                                    ?.cast<Map<String, dynamic>>() ??
                                [];

                            final List<Map<String, dynamic>>
                            filteredTransactions = allTransactions.where((t) {
                              if (typeFilter == 0) return true;
                              final bool isIncome =
                                  t['transactionType'] == 'income';
                              return typeFilter == 1 ? !isIncome : isIncome;
                            }).toList();

                            if (filteredTransactions.isEmpty) continue;

                            final double net = filteredTransactions
                                .fold<double>(0.0, (sum, t) {
                                  final double amount = (t['amount'] as num)
                                      .toDouble();
                                  return sum +
                                      (t['transactionType'] == 'income'
                                          ? amount
                                          : -amount);
                                });

                            filteredGroupWidgets.add(
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 24.w,
                                  vertical: 12.h,
                                ),
                                child: Container(
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? AppColors.backgroundDark
                                        : AppColors.textWhite,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    shadows: [
                                      BoxShadow(
                                        color: const Color(0x1E000000),
                                        blurRadius: 16.r,
                                        offset: Offset(0, 6.h),
                                        spreadRadius: 0,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 48.h,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 16.w,
                                          vertical: 12.h,
                                        ),
                                        decoration: ShapeDecoration(
                                          color: isDark
                                              ? Color(0xFF38383A)
                                              : const Color(0xFFEDEDF0),
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1.w,
                                              color: isDark
                                                  ? Color(0xFF38383A)
                                                  : const Color(0xFFEDEDF0),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              formattedDate,
                                              style: getTextStyle2(
                                                color: isDark
                                                    ? Color(0xFFAAAAAA)
                                                    : const Color(0xFF828282),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 100.w,
                                              height: 24.h,
                                              child: Text(
                                                '\$${net.toStringAsFixed(2)}',
                                                textAlign: TextAlign.right,
                                                style: getTextStyle2(
                                                  color: isDark
                                                      ? AppColors.textWhite
                                                      : AppColors.black,
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w500,
                                                  lineHeight: 22.sp,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        height: 1.h,
                                        color: isDark
                                            ? const Color(0xFF38383A)
                                            : const Color(0xFFEDEDF0),
                                      ),
                                      ...filteredTransactions.asMap().entries.map((
                                        indexedEntry,
                                      ) {
                                        final Map<String, dynamic> trans =
                                            indexedEntry.value;
                                        final String? typeName =
                                            trans['typeName'] as String?;
                                        final String iconStr =
                                            typeName?.split(' ').join(' ') ??
                                            '';
                                        final String title =
                                            trans['description'] as String? ??
                                            '';
                                        final double amount =
                                            (trans['amount'] as num).toDouble();
                                        final bool isIncome =
                                            trans['transactionType'] ==
                                            'income';
                                        final String transId =
                                            trans['_id'] as String;

                                        return Column(
                                          children: [
                                            if (indexedEntry.key > 0)
                                              Container(
                                                width: double.infinity,
                                                height: 1.h,
                                                color: isDark
                                                    ? const Color(0xFF38383A)
                                                    : const Color(0xFFEDEDF0),
                                              ),
                                            Dismissible(
                                              key: Key(transId),
                                              direction:
                                                  DismissDirection.endToStart,
                                              background: Container(
                                                width: double.infinity,
                                                height: 52.h,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16.w,
                                                  vertical: 12.h,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xFFE21818),
                                                ),
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Icon(
                                                  Icons.delete,
                                                  color: Colors.white,
                                                  size: 24.sp,
                                                ),
                                              ),
                                              confirmDismiss: (direction) async {
                                                try {
                                                  final String description =
                                                      trans['description']
                                                          as String? ??
                                                      'this transaction';
                                                  final success =
                                                      await homeController
                                                          .deleteTransaction(
                                                            transId,
                                                            description,
                                                          );
                                                  if (success) {
                                                    await homeController
                                                        .refreshIncomeAndExpenses();
                                                  }
                                                  return success;
                                                } catch (e) {
                                                  debugPrint(
                                                    'Error deleting transaction: $e',
                                                  );
                                                  return false;
                                                }
                                              },
                                              child: GestureDetector(
                                                onTap: () => Get.to(
                                                  () => const ExpenseScreen(),
                                                  arguments: trans,
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 48.h,
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 8.h,
                                                  ),
                                                  decoration: ShapeDecoration(
                                                    color: isDark
                                                        ? Color(0xFF262626)
                                                        : AppColors.textWhite,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          side: BorderSide(
                                                            width: 1.w,
                                                            color: isDark
                                                                ? Color(
                                                                    0xFF38383A,
                                                                  )
                                                                : AppColors
                                                                      .textWhite,
                                                          ),
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      SizedBox(
                                                        width: 100.w,
                                                        height: 20.h,
                                                        child: Text(
                                                          iconStr,
                                                          style: getTextStyle2(
                                                            color: const Color(
                                                              0xFF828282,
                                                            ),
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100.w,
                                                        child: Text(
                                                          title,
                                                          style: getTextStyle2(
                                                            color: isDark
                                                                ? AppColors
                                                                      .textWhite
                                                                : const Color(
                                                                    0xFF141414,
                                                                  ),
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 100.w,
                                                        child: Text(
                                                          '${isIncome ? '+' : '-'} \$${amount.toStringAsFixed(2)}',
                                                          textAlign:
                                                              TextAlign.right,
                                                          style: getTextStyle2(
                                                            color: isIncome
                                                                ? const Color(
                                                                    0xFF00D460,
                                                                  )
                                                                : const Color(
                                                                    0xFFEF5B00,
                                                                  ),
                                                            fontSize: 14.sp,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      }).toList(),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }

                          if (filteredGroupWidgets.isEmpty) {
                            return noEntriesWidget;
                          }

                          return Column(children: filteredGroupWidgets);
                        });
                      }
                      return noEntriesWidget;
                    }),

                    SizedBox(height: screenHeight * 0.6),
                  ],
                );
              }),
            ),
            Positioned(
              bottom: 120.h,
              left: MediaQuery.of(context).size.width / 2 - 28.w,
              child: FloatingActionButton(
                backgroundColor: isDark
                    ? Color(0xFF406DFF)
                    : const Color(0xFF2A31EF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.r),
                ),
                onPressed: () => handleFabAction(context),
                child: Icon(Icons.add, color: Colors.white, size: 32.sp),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
