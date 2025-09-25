// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';
import 'package:teddy_5618/features/home_screen/widgets/year_selector.dart';

class YearlyBarChartScreen extends StatelessWidget {
  const YearlyBarChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
  
    
    return Scaffold(
      body: Column(
        children: [
          Container(height: 12,
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
                    Container(
                    
                      width: r.size.width / 1.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          topStart: Radius.circular(10),
                          topEnd: Radius.circular(10),
                        ),
                        color: isDark
                            ? AppColors.deepGrey
                            : AppColors.lightGreyContainer,

                        boxShadow: [
                          BoxShadow(
                            color: Color(0x1A000000),
                            spreadRadius: 1,
                            blurRadius: 1,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppText.morespendingontravel,
                            style: getTextStyle2(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.backgroundDark,
                              // color: AppColors.backgroundDark,
                              lineHeight: 18,
                            ),
                          ),
                      
                          Spacer(),
                          Image.asset(IconPath.rabbit1,  height: 92.h,
                            width: 73.h,
                          ),
                        ],
                      ).marginOnly(top: 16, left: 16,right: 10 ),
                    ),
                    Container(
                  
                      width: r.size.width / 1.1,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadiusDirectional.only(
                          bottomEnd: Radius.circular(10),
                          bottomStart: Radius.circular(10),
                        ),
                        color: isDark
                            ? Color(0xFF262626)
                            : AppColors.textWhite,
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
                                style: getTextStyle2(
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
                                style: getTextStyle2(
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
                                style: getTextStyle2(
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
                                style: getTextStyle2(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey,
                                ),
                              ),

                              Spacer(),
                              Text(
                                AppText.thousmin2,
                                style: getTextStyle2(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textOrange,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                'Saving',
                                style: getTextStyle2(
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
                                style: getTextStyle2(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textGrey,
                                ),
                              ),
                              Spacer(),
                              Text(
                                AppText.thous8,
                                style: getTextStyle2(
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
                      ).marginOnly(left: 24, right: 24, bottom: 8),
                    ),

                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text(
                        "Jun",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textWhite : AppColors.black,
                        ),
                      ),
                      valueText: "\$10,100",
                      valueColor: AppColors.textOrange,
                    ),
                    SizedBox(height: 24),
                    ExpenseBarChart(
                      iconWidget: Text(
                        "May",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.textWhite : AppColors.black,
                        ),
                      ),
                      valueText: "\$10,100",
                      valueColor: AppColors.textOrange,
                    ),
                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text(
                        "April",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                         color: isDark ? AppColors.textWhite : AppColors.black,
                        ),
                      ),
                      valueText: "\$10,100",
                      valueColor: AppColors.textOrange,
                    ),
                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text('✈️'),
                      icontext: "Travel",
                      valueText: "\$2,250",
                      progressValue: 0.3,
                      valueColor: AppColors.textOrange,
                    ),
                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text('🛒'),
                      icontext: "Grocery",
                      valueText: "\$1,500",
                      valueColor: AppColors.textOrange,
                      valuegap: 1.6,
                      progressValue: 0.2,
                    ),
                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text('🚗'),
                      icontext: "Transport",
                      valueText: "\$750",
                      valueColor: AppColors.textOrange,
                      valuegap: 1.6,
                      progressValue: 0.15,
                    ),
                    SizedBox(height: 32),
                    ExpenseBarChart(
                      iconWidget: Text('🚗'),
                      icontext: "Transport",
                      valueText: "\$750",
                      valueColor: AppColors.textOrange,
                      valuegap: 1.6,
                      progressValue: 0.15,
                    ),
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
