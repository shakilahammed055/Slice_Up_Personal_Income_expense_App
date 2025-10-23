// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';
import 'package:teddy_5618/features/home_screen/widgets/year_selector.dart';
import 'package:teddy_5618/features/home_screen/controller/bar_chart_controller.dart';

class YearlyBarChartScreen extends StatelessWidget {
  const YearlyBarChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final barController = Get.put(BarChartController());

    // Set to yearly view when this screen loads
    barController.setYearlyView();

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 12,
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          ),
          YearlySelector(),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLightGrey,
                child: Column(
                  children: [
                    SizedBox(height: 24),
                    // Container(
                    //   width: r.size.width / 1.1,
                    //   decoration: BoxDecoration(
                    //     borderRadius: BorderRadiusDirectional.only(
                    //       topStart: Radius.circular(10),
                    //       topEnd: Radius.circular(10),
                    //     ),
                    //     color: isDark
                    //         ? AppColors.deepGrey
                    //         : AppColors.lightGreyContainer,

                    //     boxShadow: [
                    //       BoxShadow(
                    //         color: Color(0x1A000000),
                    //         spreadRadius: 1,
                    //         blurRadius: 1,
                    //         offset: Offset(0, 1),
                    //       ),
                    //     ],
                    //   ),
                    //   child: Row(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text(
                    //         AppText.morespendingontravel,
                    //         style: getTextStyle2(
                    //           fontSize: 16,
                    //           fontWeight: FontWeight.w500,
                    //           color: isDark
                    //               ? AppColors.textWhite
                    //               : AppColors.backgroundDark,
                    //           // color: AppColors.backgroundDark,
                    //           lineHeight: 18,
                    //         ),
                    //       ),

                    //       Spacer(),
                    //       Image.asset(
                    //         IconPath.rabbit1,
                    //         height: 92.h,
                    //         width: 73.h,
                    //       ),
                    //     ],
                    //   ).marginOnly(top: 16, left: 16, right: 10),
                    // ),
                    Container(
                      width: r.size.width / 1.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
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
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Text(
                                'Income'.tr,
                                style: getTextStyle2(
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
                                  style: getTextStyle2(
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
                                style: getTextStyle2(
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
                                  style: getTextStyle2(
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
                                  style: getTextStyle2(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Saving'.tr,
                                style: getTextStyle2(
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
                                  style: getTextStyle2(
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
                                  style: getTextStyle2(
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
                      ).marginOnly(left: 24, right: 24, bottom: 10),
                    ),

                    SizedBox(height: 32),
                    // Monthly breakdown first (for yearly view)
                    Obx(() {
                      final monthlyList = barController.monthlyBreakdown;
                      if (monthlyList.isNotEmpty) {
                        return Column(
                          children: monthlyList.map((monthly) {
                            // Calculate progress based on expenses vs total
                            final total = monthly.income + monthly.expenses;
                            final progress = total > 0
                                ? (monthly.expenses / total)
                                : 0.0;

                            // Show income if higher, otherwise show expenses
                            final double displayValue =
                                monthly.income > monthly.expenses
                                ? monthly.income
                                : monthly.expenses;
                            final Color displayColor =
                                monthly.income > monthly.expenses
                                ? AppColors.textOrange
                                : AppColors.textOrange;

                            return Column(
                              children: [
                                ExpenseBarChart(
                                  iconWidget: Text(
                                    monthly.month,
                                    style: getTextStyle2(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                    ),
                                  ),
                                  icontext: '',
                                  valueText:
                                      "${barController.currency.value}${displayValue.toInt()}",
                                  progressValue: progress,
                                  valueColor: displayColor,
                                ),
                                SizedBox(height: 32),
                              ],
                            );
                          }).toList(),
                        );
                      } else {
                        return SizedBox.shrink();
                      }
                    }),

                    // Category breakdown (expenses and income)
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
                            final Color displayColor =
                                type.income > type.expenses
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
                                SizedBox(height: 32),
                              ],
                            );
                          }).toList(),
                        );
                      } else if (barController.monthlyBreakdown.isEmpty) {
                        // Show loading or empty state only if no monthly data either
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
                      } else {
                        return SizedBox.shrink();
                      }
                    }),
                    SizedBox(height: 52),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
