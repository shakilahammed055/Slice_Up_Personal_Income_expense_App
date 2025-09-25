import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';

class ShowAssistant extends StatelessWidget {
  final dynamic controller; // Supports GroupScreenController or HomeController
  const ShowAssistant({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 20.h, width: 20.w),
                Text(
                  'Assistant'.tr,
                  style: getTextStyle2(
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Icon(
                    Icons.close,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    size: 20.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    controller.setAssistant('supportive'.tr);
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: ShapeDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.lightGreyContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        side: BorderSide(
                          width: 2.w,
                          color:
                              controller.selectedAssistant.value ==
                                  'supportive'.tr
                              ? (isDark ? AppColors.textWhite : AppColors.black)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Supportive & Friendly'.tr,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Container(
                            width: 73.5.w,
                            height: 90.h,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(IconPath.chiwawa1),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.setAssistant('sarcastic'.tr);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: ShapeDecoration(
                      color: isDark
                          ? AppColors.surfaceDark
                          : AppColors.lightGreyContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                        side: BorderSide(
                          width: 2.w,
                          color:
                              controller.selectedAssistant.value ==
                                  'sarcastic'.tr
                              ? (isDark ? AppColors.textWhite : AppColors.black)
                              : Colors.transparent,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sarcastic Truth-Teller'.tr,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Container(
                            width: 73.5.w,
                            height: 90.h,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(IconPath.rabbit1),
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
