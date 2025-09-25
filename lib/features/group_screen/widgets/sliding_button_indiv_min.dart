import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

class SlidingButtonIndivMin extends StatelessWidget {
  final GroupTripSpentController controller;

  const SlidingButtonIndivMin({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      return GestureDetector(
        onTap: controller.toggleIndividualMinimize,
        child: Container(
          height: height / 20,
          width: width / 2.2,
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
                left: controller.isIndividualSelected.value ? 5 : width / 4.24,
                top: 5,
                bottom: 5,
                width: width / 4.8,
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
                        'Individual'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: controller.isIndividualSelected.value
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
                        'Minimize'.tr,
                        style: getTextStyle2(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: !controller.isIndividualSelected.value
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
