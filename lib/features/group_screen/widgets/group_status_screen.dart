import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';
import 'package:teddy_5618/features/group_screen/controller/status_screen_controller.dart';

class GroupStatusScreen extends StatelessWidget {
  const GroupStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Use Get.put to ensure controller is available, fallback to Get.find
    StatusScreenController statusController;
    try {
      statusController = Get.find<StatusScreenController>();
    } catch (e) {
      statusController = Get.put(StatusScreenController());
    }

    return SingleChildScrollView(
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Top container
            // Center(
            //   child: Container(
            //     width: r.size.width / 1.1,
            //     decoration: BoxDecoration(
            //       borderRadius: const BorderRadiusDirectional.only(
            //         topStart: Radius.circular(10),
            //         topEnd: Radius.circular(10),
            //       ),
            //       color: isDark
            //           ? AppColors.deepGrey
            //           : AppColors.lightGreyContainer,

            //       boxShadow: const [
            //         BoxShadow(
            //           color: Color(0x1A000000),
            //           spreadRadius: 1,
            //           blurRadius: 1,
            //           offset: Offset(0, 1),
            //         ),
            //       ],
            //     ),
            //     child: Column(
            //       children: [
            //         Row(
            //           children: [
            //             Text(
            //               AppText.groupstatustitle,
            //               style: getTextStyle2(
            //                 fontSize: 16,
            //                 fontWeight: FontWeight.w600,
            //                 color: isDark
            //                     ? AppColors.textWhite
            //                     : AppColors.backgroundDark,
            //                 // color: AppColors.backgroundDark,
            //                 lineHeight: 18,
            //               ),
            //             ),
            //             Spacer(),
            //             Image.asset(
            //               IconPath.rabbit1,
            //               width: 72.549.w,
            //               height: 92.647.h,
            //             ),
            //           ],
            //         ).marginOnly(left: 16, right: 10),
            //       ],
            //     ),
            //   ),
            // ),

            // Bottom container (was Positioned)
            // const SizedBox(height: 16),
            Container(
              width: r.size.width / 1.1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(
                Radius.circular(10)
                ),
                color: isDark ? Color(0xFF262626) : AppColors.textWhite,

                boxShadow: const [
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
                  Row(
                    children: [
                      Text(
                        'Entire group'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ).marginOnly(bottom: 20),
                      Spacer(),
                      Obx(
                        () => Column(
                          children: [
                            SizedBox(height: 10),
                            Text(
                              statusController.getFormattedAmount(
                                statusController.totalExpenses.value,
                                statusController.involvedCurrency.value,
                              ),
                              style: getTextStyle2(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              '+ ${statusController.getFormattedAmount(statusController.involvedAmount.value, statusController.involvedCurrency.value)}',
                              style: getTextStyle2(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).marginOnly(left: 16, right: 16),

                  Divider(),

                  Row(
                    children: [
                      Text(
                        'Involved'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ),
                      Spacer(),
                      Obx(
                        () => Text(
                          statusController.getFormattedAmount(
                            statusController.involvedAmount.value,
                            statusController.involvedCurrency.value,
                          ),
                          style: getTextStyle2(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 16, vertical: 8),
                  Row(
                    children: [
                      Text(
                        'My expenses',
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          statusController.getFormattedPercentage(
                            statusController.myExpensesPercentage.value,
                          ),
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
                          statusController.getFormattedAmount(
                            statusController.myExpensesAmount.value,
                            statusController.myExpensesCurrency.value,
                          ),
                          style: getTextStyle2(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 14, vertical: 8),
                  Row(
                    children: [
                      Text(
                        AppText.involved,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ),

                      Spacer(),
                      Obx(
                        () => Text(
                          statusController.getFormattedAmount(
                            statusController.involvedAmount.value,
                            statusController.involvedCurrency.value,
                          ),
                          style: getTextStyle2(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textGrey
                                : AppColors.textGrey,
                          ),
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 14, vertical: 8),
                  Row(
                    children: [
                      Text(
                        AppText.myExpense,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Obx(
                        () => Text(
                          statusController.getFormattedPercentage(
                            statusController.myExpensesPercentage.value,
                          ),
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
                          statusController.getFormattedAmount(
                            statusController.myExpensesAmount.value,
                            statusController.myExpensesCurrency.value,
                          ),
                          style: getTextStyle2(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.green,
                          ),
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 14, vertical: 8),
                ],
              ),
            ),

            SizedBox(height: 32),

            // Person wise data from API
            Obx(
              () => statusController.personWiseData.isEmpty
                  ? statusController.isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: Text(
                              'No member data available',
                              style: getTextStyle2(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.backgroundDark,
                              ),
                            ),
                          )
                  : Column(
                      children: statusController.personWiseData.map((person) {
                        final isMe = statusController.isCurrentUser(
                          person.memberEmail,
                        );

                        // Extract name from email
                        String displayName = person.memberEmail.split('@')[0];
                        if (isMe) {
                          displayName = "$displayName (Me)";
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: ExpenseBarChart(
                            iconWidget: Container(
                              height: 24,
                              width: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isMe
                                    ? AppColors.readishred
                                    : AppColors.blueButton,
                              ),
                              child: Center(
                                child: Text(
                                  person.memberEmail.isNotEmpty
                                      ? person.memberEmail[0].toUpperCase()
                                      : "U",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            icontext: displayName,
                            valueText: statusController.getFormattedAmount(
                              person.involved.amount,
                              statusController.involvedCurrency.value,
                            ),
                            valueText2:
                                "/${statusController.getFormattedAmount(statusController.totalExpenses.value, statusController.involvedCurrency.value)}",
                            valueColor: AppColors.green,
                            lightbarColor: AppColors.greylightbarcolor,
                            progressValue: person.involved.percentage / 100,
                          ),
                        );
                      }).toList(),
                    ),
            ),

            Divider(),
            SizedBox(height: 24),

            // Category wise data from API
            Obx(
              () => statusController.categoryWiseData.isEmpty
                  ? statusController.isLoading.value
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: Text(
                              'No category data available',
                              style: getTextStyle2(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.backgroundDark,
                              ),
                            ),
                          )
                  : Column(
                      children: statusController.categoryWiseData
                          .where(
                            (category) =>
                                category.categoryName.isNotEmpty &&
                                category.categoryName.toLowerCase() !=
                                    'unknown',
                          )
                          .map((category) {
                            // Extract emoji and name from category name like "🤖 robot"
                            final categoryParts = category.categoryName
                                .trim()
                                .split(' ');
                            final emoji = categoryParts.isNotEmpty
                                ? categoryParts[0]
                                : '📦';
                            final categoryDisplayName = categoryParts.length > 1
                                ? categoryParts.skip(1).join(' ')
                                : category.categoryName;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24),
                              child: ExpenseBarChart(
                                iconWidget: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                                icontext: categoryDisplayName,
                                valueText: statusController.getFormattedAmount(
                                  category.involved.amount,
                                  statusController.involvedCurrency.value,
                                ),
                                valueText2:
                                    "/${statusController.getFormattedAmount(statusController.totalExpenses.value, statusController.involvedCurrency.value)}",
                                valueColor: AppColors.green,
                                lightbarColor: AppColors.greylightbarcolor,
                                progressValue: statusController
                                    .getRelativeProgressForGroup(
                                      category.involved.amount,
                                    ), // Use group-specific relative progress
                              ),
                            );
                          })
                          .toList(),
                    ),
            ),

            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }
}
