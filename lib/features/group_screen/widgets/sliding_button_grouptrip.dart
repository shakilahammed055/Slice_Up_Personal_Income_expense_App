import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

class SlidingButtonGrouptrip extends StatelessWidget {
  final GroupTripSpentController controller;

  const SlidingButtonGrouptrip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
 
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return GestureDetector(
        onTap: controller.toggleEquallyCustom,
        child: Container(
          height: 34.h,
          width: width / 2.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(19),
            color: isDark
                ? AppColors.surfaceDark
                : AppColors.lightGreyContainer,
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,

                left: controller.isEquallySelected.value ? 5.5 : width / 5,
                top: 5,
                bottom: 5,
                width: width / 5.5,

                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(19),
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.textWhite,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        'Equally'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          lineHeight: 14,
                          color: controller.isEquallySelected.value
                              ? (isDark
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary)
                              : (isDark
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Custom'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          lineHeight: 14,
                          color: !controller.isEquallySelected.value
                              ? (isDark
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary)
                              : (isDark
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary),
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
