// ignore_for_file: use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class FinancialSummaryCard extends StatelessWidget {
  final bool isDark;
  final String congratsText;
  final String iconPath;
  final String incomeAmount;
  final String expensesAmount;
  final String expensesPercentage;
  final String savingAmount;
  final String savingPercentage;
  final double? cardWidth;
  final EdgeInsetsGeometry? padding;

  const FinancialSummaryCard({
    Key? key,
    required this.isDark,
    required this.congratsText,
    required this.iconPath,
    required this.incomeAmount,
    required this.expensesAmount,
    required this.expensesPercentage,
    required this.savingAmount,
    required this.savingPercentage,
    this.cardWidth,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Top section with congratulations text and icon
        Center(
          child: Container(
            width: cardWidth ?? MediaQuery.of(context).size.width / 1.1,
            height: 120.h, // Fixed height to accommodate longer text
            padding:
                padding ??
                EdgeInsets.only(
                  top: 16.h,
                  left: 16.w,
                  right: 16.w,
                  bottom: 16.h, // Added bottom padding
                ),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(10),
                topEnd: Radius.circular(10),
              ),
              color: isDark
                  ? AppColors.surfaceDark
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
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    congratsText,
                    style: getTextStyle3(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Image.asset(iconPath, height: 92.h, width: 73.h),
              ],
            ),
          ),
        ),

        // Bottom section with financial data
        Container(
          width: cardWidth ?? MediaQuery.of(context).size.width / 1.1,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(10),
              bottomStart: Radius.circular(10),
            ),
            color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
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

              // Income row
              _buildFinancialRow(
                label: 'Income'.tr,
                amount: incomeAmount,
                amountColor: AppColors.borderGrey,
              ),

              SizedBox(height: 16),

              // Expenses row
              _buildFinancialRowWithPercentage(
                label: 'Expenses'.tr,
                percentage: expensesPercentage,
                amount: expensesAmount,
                amountColor: AppColors.textOrange,
              ),

              SizedBox(height: 16.h),

              // Saving row
              _buildFinancialRowWithPercentage(
                label: 'Saving'.tr,
                percentage: savingPercentage,
                amount: savingAmount,
                amountColor: isDark ? AppColors.textWhite : AppColors.black,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRow({
    required String label,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: getTextStyle3(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textWhite : AppColors.black,
          ),
        ),
        Spacer(),
        Text(
          amount,
          style: getTextStyle3(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialRowWithPercentage({
    required String label,
    required String percentage,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: getTextStyle3(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textWhite : AppColors.black,
          ),
        ),
        SizedBox(width: 4),
        Text(
          percentage,
          style: getTextStyle3(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ),
        Spacer(),
        Text(
          amount,
          style: getTextStyle3(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: amountColor,
          ),
        ),
      ],
    );
  }
}
