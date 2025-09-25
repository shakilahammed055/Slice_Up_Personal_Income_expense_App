import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';
import 'package:teddy_5618/features/home_screen/widgets/expense_bar_chart.dart';

class IndividualStatusScreen extends StatelessWidget {
  const IndividualStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

   
  return SingleChildScrollView(
      child: SizedBox(
        child: Column(
          children: [
            const SizedBox(height: 24),
         
            Center(
              child: Container(
              
                width: r.size.width / 1.1,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadiusDirectional.only(
                    topStart: Radius.circular(10),
                    topEnd: Radius.circular(10),
                  ),
                  color: isDark
                      ? AppColors.deepGrey
                      : AppColors.lightGreyContainer,

                  boxShadow: const [
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
                      children: [
                        Text(
                          AppText.individualstatustitle,
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
                        Image.asset(
                          IconPath.chiwawa1,
                          width: 72.549.w,
                         height: 92.647.h
                        ),
                      ],
                    ).marginOnly(left: 16, right: 16,),
                  ],
                ),
              ),
            ),

            // Bottom container (was Positioned)
            // const SizedBox(height: 16),
            Container(
    
              width: r.size.width / 1.1,
              decoration: BoxDecoration(
                borderRadius: const BorderRadiusDirectional.only(
                  bottomEnd: Radius.circular(10),
                  bottomStart: Radius.circular(10),
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
                      Text(
                        'S\$ 20,000',
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 16, vertical: 8),
                  Row(
                    children: [
                      Text(
                       'My expenses'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '30%',
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'S\$ 6,000',
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.green,
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
                      Text(
                        ' ₩ 100,000',
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textGrey
                              : AppColors.textGrey,
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
                      Text(
                        '30%',
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'S\$ 6,000',
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.green,
                        ),
                      ),
                    ],
                  ).marginSymmetric(horizontal: 14, vertical: 8),
                ],
              ),
            ),
            SizedBox(height: 32),
            ExpenseBarChart(
              iconWidget: Text('🚗'),
              icontext: "Transport",
              valueText: "S\$ 120",
              valueText2: "/800",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.3,
            ),
            SizedBox(height: 24),
            ExpenseBarChart(
              iconWidget: Text('🚗'),
              icontext: "Transport",
              valueText: "₩ 1,000",
              valueText2: "/₩20,000",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.5,
            ),
            SizedBox(height: 24),
            ExpenseBarChart(
              iconWidget: Text('👕'),
              icontext: "Fashion",
              valueText: "S\$ 120",
              valueText2: "/800",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.8,
            ),
            SizedBox(height: 24),
            ExpenseBarChart(
              iconWidget: Text('✈️'),
              icontext: "Flight long trans",
              valueText: "S\$ 10,000,00",
              valueText2: "/15,000,00",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.6,
            ),
            SizedBox(height: 24),
            Divider(),

            SizedBox(height: 24),

            ExpenseBarChart(
              iconWidget: Container(
                height: 24, // desired height
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.readishred,
                ),

                child: Center(
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              icontext: "Ted (Me)",
              valueText: "S\$ 120",
              valueText2: "/800",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.2,
            ),

            SizedBox(height: 24),

            ExpenseBarChart(
              iconWidget: Container(
                height: 24, // desired height
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.readishred,
                ),

                child: Center(
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              icontext: "Ted (Me)",
              valueText: "S\$ 120",
              valueText2: "/800",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.2,
            ),
            SizedBox(height: 24),
            ExpenseBarChart(
              iconWidget: Container(
                height: 24, // desired height
                width: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.blueButton,
                ),

                child: Center(
                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
              icontext: "Shanon",
              valueText: "S\$ 120",
              valueText2: "/800",
              valueColor: AppColors.green,
              lightbarColor: AppColors.greylightbarcolor,
              progressValue: 0.2,
            ),
           
          ],
          
        ),
      ),
      
    );
  }
}
