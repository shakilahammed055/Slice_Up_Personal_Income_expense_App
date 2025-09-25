import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';

class SlidingButton extends StatelessWidget {
  final FilterScreenController controller;

  const SlidingButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      return GestureDetector(
        onTap: controller.toggleMonthlyYearly,
        child: Container(
          height: 42.h,
          width: width / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            color: isDark ? Color(0xFF38383A) : AppColors.lightGreyContainer,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                left: controller.isMonthlySelected.value ? 5 : width / 5,
                top: 5,
                bottom: 5,
                width: width / 5.3,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.textWhite,
                  ),
                  child: Center(
                    child: Text(
                      controller.currentPeriodUnit,
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: controller.isMonthlySelected.value ? 0 : 1,
                        child: Text(
                          'Monthly'.tr,
                          style: getTextStyle2(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Opacity(
                        opacity: controller.isMonthlySelected.value ? 1 : 0,
                        child: Text(
                          'Yearly'.tr,
                          style: getTextStyle2(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
