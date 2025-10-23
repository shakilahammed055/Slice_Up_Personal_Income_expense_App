// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/home_screen/controller/home_screen_controller.dart';

class Showmonthsetting extends StatelessWidget {
  final HomeController controller;

  const Showmonthsetting({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    debugPrint('Showmonthsetting build called');
    return const SizedBox(); // Placeholder; actual UI in show method
  }

  void show(BuildContext context) {
    debugPrint('Showmonthsetting show method called with context: $context');
    try {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.r),
            topRight: Radius.circular(24.r),
          ),
        ),
        builder: (BuildContext context) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return Theme(
            data: Theme.of(context).copyWith(
              highlightColor: Colors.transparent,
              splashColor: Colors.transparent,
            ),
            child: Container(
              width: double.infinity,
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    topRight: Radius.circular(24.r),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // HEADER
                  Container(
                    height: 56.h,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 24),
                        Text(
                          'Month setting'.tr,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            controller.clearMonthSettings();
                            Navigator.of(context).pop();
                          },
                          child: Icon(
                            Icons.close,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            size: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // CONTENT (no outer scroll; each list scrolls itself at fixed 300 height)
                  Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // START column
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'Start'.tr,
                                style: getTextStyle2(
                                  color: const Color(0xFF828282),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                height: 220.h,
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: controller.getDaysInMonth(
                                        controller.currentMonth.value,
                                      ),
                                      itemBuilder: (_, i) {
                                        final date = i + 1;
                                        return Obx(() {
                                          final selected =
                                              controller
                                                  .selectedStartDate
                                                  .value ==
                                              date;
                                          return GestureDetector(
                                            onTap: () =>
                                                controller.setStartDate(date),
                                            child: Container(
                                              height: 36.h,
                                              margin: EdgeInsets.symmetric(
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? (isDark
                                                          ? AppColors.deepGrey
                                                          : const Color(
                                                              0xFFEDEDF0,
                                                            ))
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$date',
                                                  style: getTextStyle2(
                                                    color: isDark
                                                        ? AppColors.textWhite
                                                        : AppColors.black,
                                                    fontSize: 16.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(1),
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 60.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(1),
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),

                        // END column
                        Expanded(
                          child: Column(
                            children: [
                              Text(
                                'End'.tr,
                                style: getTextStyle2(
                                  color: const Color(0xFF828282),
                                  fontSize: 14.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              SizedBox(
                                height: 220.h,
                                child: Stack(
                                  children: [
                                    ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      itemCount: controller.getDaysInMonth(
                                        controller.nextMonth.value,
                                      ),
                                      itemBuilder: (_, i) {
                                        final date = i + 1;
                                        return Obx(() {
                                          final selected =
                                              controller
                                                  .selectedEndDate
                                                  .value ==
                                              date;
                                          return GestureDetector(
                                            onTap: () {
                                              if (controller
                                                          .selectedStartDate
                                                          .value ==
                                                      -1 ||
                                                  date >=
                                                      controller
                                                          .selectedStartDate
                                                          .value ||
                                                  controller.nextMonth.value !=
                                                      controller
                                                          .currentMonth
                                                          .value) {
                                                controller.setEndDate(date);
                                              } else {
                                                Get.snackbar(
                                                  'Invalid Selection'.tr,
                                                  'End date cannot be before Start date in the same month'
                                                      .tr,
                                                  snackPosition:
                                                      SnackPosition.BOTTOM,
                                                  backgroundColor: Colors.red,
                                                  colorText: isDark
                                                      ? AppColors.black
                                                      : AppColors.textWhite,
                                                );
                                              }
                                            },
                                            child: Container(
                                              height: 40.h,
                                              margin: EdgeInsets.symmetric(
                                                vertical: 2.h,
                                              ),
                                              decoration: BoxDecoration(
                                                color: selected
                                                    ? (isDark
                                                          ? AppColors.deepGrey
                                                          : const Color(
                                                              0xFFEDEDF0,
                                                            ))
                                                    : Colors.transparent,
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '$date',
                                                  style: getTextStyle2(
                                                    color: isDark
                                                        ? AppColors.textWhite
                                                        : AppColors.black,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        });
                                      },
                                    ),
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(1),
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        height: 40.h,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(1),
                                              (isDark
                                                      ? AppColors.backgroundDark
                                                      : Colors.white)
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider + spacing
                  Padding(
                    padding: EdgeInsets.only(top: 16.h),
                    child: Divider(
                      height: 1.h,
                      color: isDark ? AppColors.black : const Color(0xFFD0D3D9),
                    ),
                  ),

                  // FIXED FOOTER BUTTON
                  SafeArea(
                    top: false,
                    minimum: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 8.h),
                    child: SizedBox(
                      height: 48.h,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: isDark
                              ? AppColors.textWhite
                              : AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          minimumSize: Size(double.infinity, 52.h),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        onPressed: () async {
                          if (controller.selectedStartDate.value != -1 &&
                              controller.selectedEndDate.value != -1) {
                            if (controller.currentMonth.value ==
                                    controller.nextMonth.value &&
                                controller.selectedStartDate.value >
                                    controller.selectedEndDate.value) {
                              Get.snackbar(
                                'Invalid Range'.tr,
                                'Start date must be before or equal to End date in the same month'
                                    .tr,
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red,
                                colorText: Colors.white,
                              );
                            } else {
                              await controller.saveDateRange();
                              Navigator.of(context).pop();
                            }
                          } else {
                            Get.snackbar(
                              'Selection Required'.tr,
                              'Please select both Start and End dates'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                        child: Text(
                          'Confirm'.tr,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.black
                                : AppColors.textWhite,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ).copyWith(height: 1.2),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ).catchError((Object e) {
        debugPrint('Error showing bottom sheet: $e');
      });
    } catch (e) {
      debugPrint('Error in show method: $e');
      Get.snackbar(
        'Error'.tr,
        'Failed to open month setting'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }
}
