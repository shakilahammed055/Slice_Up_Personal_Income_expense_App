import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/controller/group_screen_controller.dart';

class ShowAssistant1 extends StatelessWidget {
  const ShowAssistant1({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupScreenController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // return Dialog(
    //   backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
    //   // Colors.white,
    //   child: SizedBox(
    //     height: MediaQuery.of(context).size.height * 0.323, // 40% of screen
    //     width: double.infinity,
    //     child: Padding(
    //       padding: EdgeInsets.all(16),
    //       child: Column(
    //         children: [
    //           Row(
    //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //             children: [
    //               SizedBox(height: 20.h, width: 20.w),
    //               Text(
    //                 'Assistant'.tr,
    //                 style: getTextStyle2(
    //                   color: isDark ? AppColors.textWhite : AppColors.black,

    //                   fontSize: 16,
    //                   fontWeight: FontWeight.w500,
    //                 ),
    //               ),
    //               GestureDetector(
    //                 onTap: () => Get.back(),
    //                 child: Icon(
    //                   Icons.close,

    //                   color: isDark ? AppColors.textWhite : AppColors.black,
    //                   size: 20,
    //                 ),
    //               ),
    //             ],
    //           ),
    //           //  SizedBox(height: 30.h),
    //           Container(
    //             width: double.infinity,
    //             padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
    //             child: Row(
    //               mainAxisSize: MainAxisSize.min,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Expanded(
    //                   child: GestureDetector(
    //                     onTap: () {
    //                       controller.setAssistant('supportive'.tr);
    //                       Get.back();
    //                     },
    //                     child: Container(
    //                       height: 150.h,
    //                       width: double.infinity,
    //                       padding: const EdgeInsets.only(
    //                         top: 12,
    //                         left: 12,
    //                         right: 12,
    //                       ),
    //                       clipBehavior: Clip.antiAlias,
    //                       decoration: ShapeDecoration(
    //                         color: isDark
    //                             ? AppColors.deepGrey
    //                             : AppColors.lightGreyContainer,
    //                         // color: const Color(0xFFEDEDF0),
    //                         shape: RoundedRectangleBorder(
    //                           side: BorderSide(
    //                             width: 2.w,
    //                             color:
    //                                 controller.selectedAssistant.value ==
    //                                     'supportive'.tr
    //                                 ? Colors.black
    //                                 : Colors.transparent,
    //                           ),
    //                           borderRadius: BorderRadius.circular(24),
    //                         ),
    //                       ),
    //                       child: Column(
    //                         mainAxisSize: MainAxisSize.min,
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           SizedBox(
    //                             width: 139.w,
    //                             child: Text(
    //                               'Supportive & Friendly'.tr,
    //                               textAlign: TextAlign.center,
    //                               style: TextStyle(
    //                                 color: isDark
    //                                     ? AppColors.textWhite
    //                                     : AppColors.black,

    //                                 fontSize: 14,
    //                                 fontFamily: 'SF Pro Display',
    //                                 fontWeight: FontWeight.w500,
    //                                 height: 1.29.h,
    //                               ),
    //                             ),
    //                           ),
    //                           const Spacer(),
    //                           Container(
    //                             width: 73.50.w,
    //                             height: 80.h,
    //                             decoration: BoxDecoration(
    //                               image: DecorationImage(
    //                                 image: Image.asset(IconPath.chiwawa1).image,
    //                                 fit: BoxFit.fitHeight,
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //                 const SizedBox(width: 16),
    //                 Expanded(
    //                   child: GestureDetector(
    //                     onTap: () {
    //                       controller.setAssistant('sarcastic'.tr);
    //                       Get.back();
    //                     },
    //                     child: Container(
    //                       height: 150.h,
    //                       width: double.infinity,
    //                       padding: const EdgeInsets.only(
    //                         top: 12,
    //                         left: 12,
    //                         right: 12,
    //                       ),
    //                       clipBehavior: Clip.antiAlias,
    //                       decoration: ShapeDecoration(
    //                         color: isDark
    //                             ? AppColors.deepGrey
    //                             : AppColors.lightGreyContainer,
    //                         shape: RoundedRectangleBorder(
    //                           side: BorderSide(
    //                             width: 2.w,
    //                             color:
    //                                 controller.selectedAssistant.value ==
    //                                     'sarcastic'
    //                                 ? Colors.black
    //                                 : Colors.transparent,
    //                           ),
    //                           borderRadius: BorderRadius.circular(24),
    //                         ),
    //                       ),
    //                       child: Column(
    //                         mainAxisSize: MainAxisSize.min,
    //                         mainAxisAlignment: MainAxisAlignment.start,
    //                         crossAxisAlignment: CrossAxisAlignment.center,
    //                         children: [
    //                           SizedBox(
    //                             width: 139.w,
    //                             child: Text(
    //                               'Sarcastic Truth-Teller'.tr,
    //                               textAlign: TextAlign.center,
    //                               style: TextStyle(
    //                                 color: isDark
    //                                     ? AppColors.textWhite
    //                                     : AppColors.black,
    //                                 fontSize: 14,
    //                                 fontFamily: 'SF Pro Display',
    //                                 fontWeight: FontWeight.w500,
    //                                 height: 1.28.h,
    //                               ),
    //                             ),
    //                           ),
    //                           const Spacer(),
    //                           Container(
    //                             width: 73.50.w,
    //                             height: 80.w,
    //                             decoration: BoxDecoration(
    //                               image: DecorationImage(
    //                                 image: Image.asset(IconPath.rabbit1).image,
    //                                 fit: BoxFit.fitHeight,
    //                               ),
    //                             ),
    //                           ),
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   ),
    // );




     return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
      backgroundColor: isDark ? AppColors.deepGrey : AppColors.textWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24.r), // Responsive border radius
      ),
      child: Padding(
        padding: EdgeInsets.all(24.w), // only inside padding = 24
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content vertically
          children: [
            /// Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(height: 20.h, width: 20.w), // spacer
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

            /// Cards container
            Column(
              children: [
                // Supportive card
                GestureDetector(
                  onTap: () {
                    controller.setAssistant('supportive'.tr);
                    Get.back();
                  },
                  child: Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ), // ⬅️ side padding only
                    decoration: ShapeDecoration(
                      color: isDark
                          ? Color(0xFF262626)
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
                        // ⬇️ Wrap image with Container that adds top padding
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

                // Sarcastic card
                GestureDetector(
                  onTap: () {
                    controller.setAssistant('sarcastic'.tr);
                    Get.back();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                    ), // ⬅️ side padding only
                    decoration: ShapeDecoration(
                      color: isDark
                          ? Color(0xFF262626)
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
                        // ⬇️ Wrap image with Container that adds top padding
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
