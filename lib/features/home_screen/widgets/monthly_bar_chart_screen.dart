import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';
import 'package:teddy_5618/features/home_screen/widgets/month_selector.dart';
import 'package:teddy_5618/features/home_screen/controller/bar_chart_controller.dart';

class MonthlyBarChartScreen extends StatelessWidget {
  const MonthlyBarChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create instance of ResponsiveHelper to manage responsiveness
    final responsive = ResponsiveHelper(context);
    final barController = Get.put(BarChartController());

    // Ensure monthly view is set when this screen loads
    barController.setMonthlyView();

    // Debug: Print controller state

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : const Color(0xFFFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: responsive.fromSmallMediumLarge(
                small: 8,
                medium: 12,
                large: 12,
              ),
              color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            ),
            MonthSelector(),
            SizedBox(height: 24),
            Container(
              color: isDark
                  ? AppColors.backgroundDark
                  : AppColors.backgroundLightGrey,

              // color: AppColors.backgroundLightGrey, // Background grey color
              child: Column(
                children: [
                  Center(
                    // child: Container(
                    //   width: MediaQuery.of(context).size.width / 1.1,

                    //   padding: EdgeInsets.only(
                    //     top: 16.h,
                    //     left: 16.w,
                    //     right: 16.w,
                    //     // vertical: 16.h,
                    //   ),
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadiusDirectional.only(
                    //       topStart: Radius.circular(10),
                    //       topEnd: Radius.circular(10),
                    //     ),
                    //     color: isDark
                    //         ? AppColors.deepGrey
                    //         : AppColors.lightGreyContainer,

                    //     // color: AppColors.lightGreyContainer,
                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Color(0x1A000000),
                    //         spreadRadius: 1,
                    //         blurRadius: 1,
                    //         offset: Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       Row(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text(
                    //             AppText.congratsYouBought20,
                    //             style: getTextStyle3(
                    //               fontSize: 15,
                    //               fontWeight: FontWeight.w500,

                    //               color: isDark
                    //                   ? AppColors.textWhite
                    //                   : AppColors.black,
                    //             ),
                    //           ),
                    //           Spacer(),
                    //           Image.asset(
                    //             IconPath.chiwawa1,
                    //             height: 92.h,
                    //             width: 73.h,
                    //           ),
                    //         ],
                    //       ),
                    //     ],
                    //   ),
                    // ),
                  ),

                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      // vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
           Radius.circular(10)
                      ),
                      color: isDark ? Color(0xFF262626) : AppColors.textWhite,
                      // color: AppColors.textWhite,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1A000000),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),

                    child: Column(
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              'Income'.tr,
                              style: getTextStyle3(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                            ),

                            Spacer(),
                            Obx(
                              () => Text(
                                barController.summary.value != null
                                    ? '${barController.currency.value}${barController.summary.value!.totalIncome.toInt()}'
                                    : '${barController.currency.value}0',
                                style: getTextStyle3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.borderGrey,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text(
                              'Expenses'.tr,
                              style: getTextStyle3(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                            ),
                            SizedBox(width: 4),
                            Obx(
                              () => Text(
                                barController
                                            .summary
                                            .value
                                            ?.percentages['expense'] !=
                                        null
                                    ? '${barController.summary.value!.percentages['expense']}%'
                                    : '0%',
                                style: getTextStyle3(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),

                            Spacer(),
                            Obx(
                              () => Text(
                                barController.summary.value != null
                                    ? '${barController.currency.value}${barController.summary.value!.totalExpenses.toInt()}'
                                    : '${barController.currency.value}0',
                                style: getTextStyle3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          children: [
                            Text(
                              'Saving'.tr,
                              style: getTextStyle3(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                            ),
                            SizedBox(width: 4),
                            Obx(
                              () => Text(
                                barController
                                            .summary
                                            .value
                                            ?.percentages['saving'] !=
                                        null
                                    ? '${barController.summary.value!.percentages['saving']}%'
                                    : '0%',
                                style: getTextStyle3(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey,
                                ),
                              ),
                            ),
                            Spacer(),
                            Obx(
                              () => Text(
                                barController.summary.value != null
                                    ? '${barController.currency.value}${barController.summary.value!.savingAmount.toInt()}'
                                    : '${barController.currency.value}0',
                                style: getTextStyle3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).marginOnly(bottom: 10),
                  ),

                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 32,
                      large: 32,
                    ),
                  ),
                  // Types list from API only
                  Obx(() {
                    final typesList = barController.typesSummary;
                    if (typesList.isNotEmpty) {
                      return Column(
                        children: typesList.map((type) {
                          // Parse emoji and text from typeName (e.g., "✈️ plane")
                          String emoji = '🔖';
                          String text = type.typeName;
                          final parts = type.typeName.split(' ');
                          if (parts.length >= 2) {
                            emoji = parts[0];
                            text = parts.sublist(1).join(' ');
                          }

                          // Show income if it's higher than expenses (like salary), otherwise show expenses
                          final double displayValue =
                              type.income > type.expenses
                              ? type.income
                              : type.expenses;
                          final Color displayColor = type.income > type.expenses
                              ? AppColors.textOrange
                              : AppColors.textOrange;

                          return Column(
                            children: [
                              ExpenseBarChart(
                                iconWidget: Text(emoji),
                                icontext: text,
                                valueText:
                                    "${barController.currency.value}${displayValue.toInt()}",
                                progressValue: type.progress,
                                valueColor: displayColor,
                              ),
                              SizedBox(
                                height: responsive.fromSmallMediumLarge(
                                  small: 16,
                                  medium: 24,
                                  large: 24,
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      );
                    } else {
                      // Show loading or empty state instead of hardcoded data
                      return Center(
                        child: barController.isLoading.value
                            ? CircularProgressIndicator()
                            : Text(
                                'No data available',
                                style: getTextStyle2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
                              ),
                      );
                    }
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
