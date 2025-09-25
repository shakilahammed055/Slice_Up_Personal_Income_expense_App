import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';
import 'package:teddy_5618/features/home_screen/widgets/month_selector.dart';

class MonthlyBarChartScreen extends StatelessWidget {
  const MonthlyBarChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create instance of ResponsiveHelper to manage responsiveness
    final responsive = ResponsiveHelper(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : const Color(0xFFFAFAFA),
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
            
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLightGrey,

              // color: AppColors.backgroundLightGrey, // Background grey color
              child: Column(
                children: [
                  Center(
                    child: Container(
                    
                      width: MediaQuery.of(context).size.width / 1.1,

                      padding: EdgeInsets.only(
                        top: 16.h,
                        left: 16.w,
                        right: 16.w,
                        // vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                        ),
                        color: isDark
                            ? AppColors.deepGrey
                            : AppColors.lightGreyContainer,

                        // color: AppColors.lightGreyContainer,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppText.congratsYouBought20,
                                style: getTextStyle3(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,

                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
                              ),
                              Spacer(),
                              Image.asset(
                                IconPath.chiwawa1,
                                height: 92.h,
                                width: 73.h,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Container(
                 
                    width: MediaQuery.of(context).size.width / 1.1,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadiusDirectional.only(
                        bottomEnd: Radius.circular(10),
                        bottomStart: Radius.circular(10),
                      ),
                      color: isDark
                          ? Color(0xFF262626)
                          : AppColors.textWhite,
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
                            Text(
                              AppText.mil12,
                              style: getTextStyle3(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.borderGrey,
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
                            Text(
                              AppText.per65,
                              style: getTextStyle3(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                            ),

                            Spacer(),
                            Text(
                              AppText.thousmin2,
                              style: getTextStyle3(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textOrange,
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
                            Text(
                              AppText.per35,
                              style: getTextStyle3(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textGrey,
                              ),
                            ),
                            Spacer(),
                            Text(
                              AppText.thous8,
                              style: getTextStyle3(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 32,
                      large: 32,
                    ),
                  ),
                  ExpenseBarChart(
                    iconWidget: Text('✈️'),
                    icontext: "Travel",
                    valueText: "\$2,250",
                    progressValue: 0.3,
                    valueColor: AppColors.textOrange,
                  ),

                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 24,
                      large: 24,
                    ),
                  ),

                  ExpenseBarChart(
                    iconWidget: Text('🛒'),
                    icontext: "Grocery",
                    valueText: "\$1,500",
                    valueColor: AppColors.textOrange,
                    valuegap: 1.6,
                    progressValue: 0.2,
                  ),
                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 24,
                      large: 24,
                    ),
                  ),

                  ExpenseBarChart(
                    iconWidget: Text('🚗'),
                    icontext: "Transport",

                    valueText: "\$750",
                    valueColor: AppColors.textOrange,
                    valuegap: 1.6,
                    progressValue: 0.15,
                  ),
                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 24,
                      large: 24,
                    ),
                  ),

                  ExpenseBarChart(
                    iconWidget: Text('🚗'),
                    icontext: "Transport",
                    valueText: "\$750",
                    valueColor: AppColors.textOrange,
                    valuegap: 1.6,
                    progressValue: 0.15,
                  ),
                  SizedBox(
                    height: responsive.fromSmallMediumLarge(
                      small: 16,
                      medium: 24,
                      large: 24,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
