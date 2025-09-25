// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

// void showThemeDialog(BuildContext context, SettingController controller) {
//   final isDark = Theme.of(context).brightness == Brightness.dark;
//   final screenWidth = MediaQuery.of(context).size.width;
//   final screenHeight = MediaQuery.of(context).size.height;

//   // Define theme modes
//   final themes = ['Light'.tr, 'Dark'.tr];

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
//       return ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: 184,
//           maxHeight: screenHeight * 0.22,
//         ),
//         child: Container(
//           width: screenWidth,
//           clipBehavior: Clip.antiAlias,
//           decoration: ShapeDecoration(
//             color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24),
//                 topRight: Radius.circular(24),
//               ),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: screenWidth,
//                 height: 56,
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     SizedBox(width: 48), // Placeholder for alignment
//                     Expanded(
//                       child: Text(
//                         'Mode'.tr,
//                         textAlign: TextAlign.center,
//                         style: getTextStyle2(
//                           color: isDark
//                               ? AppColors.textWhite
//                               : Color(0xFF141414),
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.close, size: 24),
//                       color: isDark ? AppColors.textWhite : Color(0xFF141414),
//                       onPressed: () => Get.back(),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: Container(
//                   width: double.infinity,
//                   color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
//                   child: ListView.builder(
//                     itemCount: themes.length,
//                     itemBuilder: (context, index) {
//                       final theme = themes[index];
//                       return Obx(
//                         () => GestureDetector(
//                           onTap: () {
//                             controller.updateThemeMode(theme);
//                             // Update the app's theme
//                             Get.changeThemeMode(
//                               theme == 'Dark'.tr
//                                   ? ThemeMode.dark
//                                   : ThemeMode.light,
//                             );
//                             Get.back();
//                             Get.snackbar('Success'.tr, 'Theme updated to $theme');
//                           },
//                           child: Container(
//                             width: screenWidth,
//                             height: 54,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 16,
//                             ),
//                             decoration: ShapeDecoration(
//                               color: isDark
//                                   ? Color(0xFF262626)
//                                   : AppColors.textWhite,
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   width: 1,
//                                   color: isDark
//                                       ? AppColors.deepGrey
//                                       : Color(0xFFEDEDF0),
//                                 ),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     theme,
//                                     style: getTextStyle2(
//                                       color: controller.themeMode.value == theme
//                                           ? (isDark
//                                                 ? AppColors.textWhite
//                                                 : Color(0xFF141414))
//                                           : Color(0xFF828282),
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 if (controller.themeMode.value == theme)
//                                   Icon(
//                                     Icons.check,
//                                     color: isDark
//                                         ? AppColors.textWhite
//                                         : Color(0xFF141414),
//                                     size: 24,
//                                   ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ),
//               Container(
//                 width: double.infinity,
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                 child: Center(
//                   child: Container(
//                     width: 134,
//                     height: 4,
//                     decoration: ShapeDecoration(
//                       color: isDark ? AppColors.textWhite : Color(0xFF2B2F38),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(100),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
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

void showThemeDialog(BuildContext context, SettingController controller) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final screenWidth = MediaQuery.of(context).size.width;
  final screenHeight = MediaQuery.of(context).size.height;

  // Define theme modes
  final themes = ['Light'.tr, 'Dark'.tr];

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
      return ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: 184,
          maxHeight: screenHeight * 0.22,
        ),
        child: Container(
          width: screenWidth,
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: screenWidth,
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: 48), // Placeholder for alignment
                    Expanded(
                      child: Text(
                        'Mode'.tr,
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark
                              ? AppColors.textWhite
                              : Color(0xFF141414),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 24),
                      color: isDark ? AppColors.textWhite : Color(0xFF141414),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
                  child: ListView.builder(
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      return Obx(
                        () => GestureDetector(
                          onTap: () {
                            controller.updateThemeMode(theme); // This handles saving and theme change
                            Get.back();
                            Get.snackbar('Success'.tr, 'Theme updated to $theme');
                          },
                          child: Container(
                            width: screenWidth,
                            height: 54,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? Color(0xFF262626)
                                  : AppColors.textWhite,
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    theme,
                                    style: getTextStyle2(
                                      color: controller.themeMode.value == theme
                                          ? (isDark
                                              ? AppColors.textWhite
                                              : Color(0xFF141414))
                                          : Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (controller.themeMode.value == theme)
                                  Icon(
                                    Icons.check,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : Color(0xFF141414),
                                    size: 24,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Center(
                  child: Container(
                    width: 134,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: isDark ? AppColors.textWhite : Color(0xFF2B2F38),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}