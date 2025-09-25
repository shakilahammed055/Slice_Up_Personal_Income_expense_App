// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/core/utils/constants/icon_path.dart';
// import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

// void showAssistantBottomSheet(
//   BuildContext context,
//   SettingController controller,
// ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24),
//         topRight: Radius.circular(24),
//       ),
//     ),
//     builder: (context) {
//       final isDark = Theme.of(context).brightness == Brightness.dark;
//       return Container(
//         height: MediaQuery.of(context).size.height * 0.40,
//         width: double.infinity,
//         clipBehavior: Clip.antiAlias,
//         decoration: ShapeDecoration(
//           color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.only(
//               topLeft: Radius.circular(24),
//               topRight: Radius.circular(24),
//             ),
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SizedBox(width: 48.w),
//                   Expanded(
//                     child: Text(
//                       'Assistant'.tr,
//                       textAlign: TextAlign.center,
//                       style: getTextStyle2(
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                   IconButton(
//                     icon: Icon(Icons.close, size: 24),
//                     onPressed: () => Get.back(),
//                   ),
//                 ],
//               ),
//             ),

//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
//               child: Column(
//                 children: [
//                   IntrinsicHeight(
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               controller.updateAssistantType(
//                                 'Supportive & Friendly'.tr,
//                               );
//                               Get.back();
//                             },
//                             child: _buildCommonView(
//                               title: 'Supportive & Friendly'.tr,
//                               imagePath: IconPath.chiwawa1,
//                               context: context,
//                               assistantType: 'Supportive & Friendly'.tr,
//                               controller: controller,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 16.w),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () {
//                               controller.updateAssistantType(
//                                 'Sarcastic Truth-Teller'.tr,
//                               );
//                               Get.back();
//                             },
//                             child: _buildCommonView(
//                               title: 'Sarcastic Truth-Teller'.tr,
//                               imagePath: IconPath.rabbit1,
//                               context: context,
//                               assistantType: 'Sarcastic Truth-Teller'.tr,
//                               controller: controller,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),

//                   SizedBox(height: 16),

//                   GestureDetector(
//                     onTap: () {
//                       controller.updateAssistantType('');
//                       Get.back();
//                     },
//                     child: Obx(
//                       () => Container(
//                         width: double.infinity,
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 12,
//                           vertical: 16,
//                         ),
//                         decoration: ShapeDecoration(
//                           color: isDark
//                               ? AppColors.deepGrey
//                               : Color(0xFFEDEDF0),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(24),
//                             side: BorderSide(
//                               width: controller.assistantType.value.isEmpty
//                                   ? 2
//                                   : 0,
//                               color: isDark
//                                   ? AppColors.textWhite
//                                   : AppColors.black,
//                             ),
//                           ),
//                         ),
//                         child: Text(
//                           "   'I don't want assistant'".tr,
//                           textAlign: TextAlign.center,
//                           style: getTextStyle2(
//                             color: isDark
//                                 ? AppColors.textWhite
//                                 : AppColors.black,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             Container(
//               width: double.infinity,
//               padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: Center(
//                 child: Container(
//                   width: 134,
//                   height: 4.h,
//                   decoration: ShapeDecoration(
//                     color: Color(0xFF2B2F38),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }

// Widget _buildCommonView({
//   required String title,
//   required String imagePath,
//   required BuildContext context,
//   required String assistantType,
//   required SettingController controller,
// }) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   return Obx(
//     () => Container(
//       // height: 150.h,
//       padding: EdgeInsets.only(top: 12.h, left: 12.w, right: 12.w),
//       decoration: ShapeDecoration(
//         color: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//           side: BorderSide(
//             width: controller.assistantType.value == assistantType ? 2 : 0,
//             color: isDark ? AppColors.textWhite : AppColors.black,
//           ),
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Text(
//             title,
//             textAlign: TextAlign.center,
//             style: getTextStyle2(
//               color: isDark ? AppColors.textWhite : AppColors.black,
//               fontSize: 14,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//           SizedBox(height: 10.h),

//           const Spacer(),

//           Container(
//             width: 72.549.h,
//             height: 92.647.h,
//             decoration: BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage(imagePath),
//                 fit: BoxFit.fill,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showAssistantBottomSheet(
  BuildContext context,
  SettingController controller,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        height: MediaQuery.of(context).size.height * 0.40,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 48.w),
                  Expanded(
                    child: Text(
                      'Assistant'.tr,
                      textAlign: TextAlign.center,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: Column(
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await controller.updateAssistantTypeViaAPI('Supportive & Friendly'.tr);
                              Get.back();
                            },
                            child: _buildCommonView(
                              title: 'Supportive & Friendly'.tr,
                              imagePath: IconPath.chiwawa1,
                              context: context,
                              assistantType: 'Supportive & Friendly'.tr,
                              controller: controller,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              await controller.updateAssistantTypeViaAPI('Sarcastic Truth-Teller'.tr);
                              Get.back();
                            },
                            child: _buildCommonView(
                              title: 'Sarcastic Truth-Teller'.tr,
                              imagePath: IconPath.rabbit1,
                              context: context,
                              assistantType: 'Sarcastic Truth-Teller'.tr,
                              controller: controller,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16),

                  GestureDetector(
                    onTap: () async {
                      await controller.updateAssistantTypeViaAPI(''.tr);
                      Get.back();
                    },
                    child: Obx(
                      () => Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 16,
                        ),
                        decoration: ShapeDecoration(
                          color: isDark
                              ? AppColors.deepGrey
                              : Color(0xFFEDEDF0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: BorderSide(
                              width: controller.assistantType.value.isEmpty
                                  ? 2
                                  : 0,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                            ),
                          ),
                        ),
                        child: Text(
                          "   'I don't want assistant'".tr,
                          textAlign: TextAlign.center,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Center(
                child: Container(
                  width: 134,
                  height: 4.h,
                  decoration: ShapeDecoration(
                    color: Color(0xFF2B2F38),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildCommonView({
  required String title,
  required String imagePath,
  required BuildContext context,
  required String assistantType,
  required SettingController controller,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return Obx(
    () => Container(
      // height: 150.h,
      padding: EdgeInsets.only(top: 12.h, left: 12.w, right: 12.w),
      decoration: ShapeDecoration(
        color: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            width: controller.assistantType.value == assistantType ? 2 : 0,
            color: isDark ? AppColors.textWhite : AppColors.black,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: getTextStyle2(
              color: isDark ? AppColors.textWhite : AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          Spacer(),
          Container(
            width: 72.549.h,
            height: 92.647.h,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}