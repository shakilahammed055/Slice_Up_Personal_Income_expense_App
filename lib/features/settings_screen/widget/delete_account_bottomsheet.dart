// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

// void showDeleteAccountBottomSheet(
//   BuildContext context,
//   SettingController controller,
// ) {
//   final double screenHeight = MediaQuery.of(context).size.height;
//   final double screenWidth = MediaQuery.of(context).size.width;
//   final bool isDark = Theme.of(context).brightness == Brightness.dark;

//   showModalBottomSheet(
//     context: context,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(screenWidth * 0.06),
//       ),
//     ),
//     backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
//     builder: (BuildContext context) {
//       return Container(
//         height: screenHeight * 0.28,
//         padding: EdgeInsets.symmetric(
//           horizontal: screenWidth * 0.06,
//           vertical: screenHeight * 0.03,
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.center,
//           children: [
//             Text(
//               'Delete Account'.tr,
//               style: getTextStyle2(
//                 color: isDark ? AppColors.textWhite : AppColors.black,
//                 fontSize: screenWidth * 0.05,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.02),
//             Text(
//               'Are you sure you want to delete your account? This action cannot be undone.'
//                   .tr,
//               textAlign: TextAlign.center,
//               style: getTextStyle2(
//                 color: isDark ? AppColors.textWhite : AppColors.black,
//                 fontSize: screenWidth * 0.04,
//                 fontWeight: FontWeight.w400,
//                 lineHeight: 22,
//               ),
//             ),
//             SizedBox(height: screenHeight * 0.03),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 Expanded(
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Implement account deletion logic
//                       controller.deleteAccount();
//                       Get.back();
//                       Get.snackbar(
//                         'Success'.tr,
//                         'Account deleted successfully'.tr,
//                       );
//                     },
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: Colors.red,
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.04),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         vertical: screenHeight * 0.02,
//                       ),
//                     ),
//                     child: Text(
//                       'Delete'.tr,
//                       style: getTextStyle2(
//                         color: AppColors.textWhite,
//                         fontSize: screenWidth * 0.04,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: screenWidth * 0.04),
//                 Expanded(
//                   child: OutlinedButton(
//                     onPressed: () => Get.back(),
//                     style: OutlinedButton.styleFrom(
//                       side: BorderSide(
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(screenWidth * 0.04),
//                       ),
//                       padding: EdgeInsets.symmetric(
//                         vertical: screenHeight * 0.02,
//                       ),
//                     ),
//                     child: Text(
//                       'Cancel'.tr,
//                       style: getTextStyle2(
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                         fontSize: screenWidth * 0.04,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       );
//     },
//   );
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showDeleteAccountBottomSheet(
  BuildContext context,
  SettingController controller,
) {
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  final bool isDark = Theme.of(context).brightness == Brightness.dark;

  showModalBottomSheet(
    context: context,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(screenWidth * 0.06),
      ),
    ),
    backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
    builder: (BuildContext context) {
      return Container(
        height: screenHeight * 0.28,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.06,
          vertical: screenHeight * 0.03,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Delete Account'.tr,
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Text(
              'Are you sure you want to delete your account? This action cannot be undone and will permanently delete all your data.'.tr,
              textAlign: TextAlign.center,
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w400,
                lineHeight: 22,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Close bottom sheet first
                      Get.back();
                      
                      // Show confirmation dialog
                      Get.defaultDialog(
                        title: 'Final Confirmation'.tr,
                        titleStyle: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w700,
                        ),
                        backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: screenWidth * 0.08,
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'This will permanently delete your account and all associated data. Are you absolutely sure?'.tr,
                              textAlign: TextAlign.center,
                              style: getTextStyle2(
                                color: isDark ? AppColors.textWhite : AppColors.black,
                                fontSize: screenWidth * 0.038,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        confirm: ElevatedButton(
                          onPressed: () {
                            Get.back(); // Close confirmation dialog
                            // Call the delete method
                            controller.deleteAccount();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            ),
                          ),
                          child: Text(
                            'Yes, Delete'.tr,
                            style: getTextStyle2(
                              color: AppColors.textWhite,
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        cancel: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: isDark ? AppColors.textWhite : AppColors.black,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(screenWidth * 0.04),
                            ),
                          ),
                          child: Text(
                            'Cancel'.tr,
                            style: getTextStyle2(
                              color: isDark ? AppColors.textWhite : AppColors.black,
                              fontSize: screenWidth * 0.038,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: Text(
                      'Delete'.tr,
                      style: getTextStyle2(
                        color: AppColors.textWhite,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.back(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.04),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.02,
                      ),
                    ),
                    child: Text(
                      'Cancel'.tr,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    },
  );
}