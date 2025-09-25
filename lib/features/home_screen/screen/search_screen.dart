// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// // --- ASSUMED IMPORTS FROM YOUR PROJECT ---
// // Make sure you have these files in your project structure.
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/app_texts.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/core/utils/constants/icon_path.dart';
// import 'package:teddy_5618/features/home_screen/widgets/search_container.dart';
// import 'package:teddy_5618/features/home_screen/widgets/texxtfield.dart';

// // Responsive Helper Class
// class ResponsiveHelper {
//   final BuildContext context;
//   final Size size;

//   ResponsiveHelper(this.context) : size = MediaQuery.of(context).size;

//   bool get isSmallPhone => size.width <= 360;
//   bool get isMediumPhone => size.width > 362 && size.width < 414;
//   bool get isLargePhone => size.width >= 414;

//   T fromSmallMediumLarge<T>({
//     required T small,
//     required T medium,
//     required T large,
//   }) {
//     if (isSmallPhone) return small;
//     if (isMediumPhone) return medium;
//     return large;
//   }
// }

// class SearchScreen extends StatelessWidget {
//   const SearchScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final responsive = ResponsiveHelper(context);
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     // You might need to create this controller if it doesn't exist.
//     // final searchController = Get.put(SearchController());

//     return Scaffold(
//       backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
//       appBar: AppBar(
//         leading: GestureDetector(
//           onTap: () => Get.back(),
//           child: Icon(
//             CupertinoIcons.back,
//             size: MediaQuery.of(context).size.height / 25,
//           ),
//         ),
//         backgroundColor: isDark
//             ? AppColors.backgroundDark
//             : AppColors.textWhite,
//       ),
//       body: Column(
//         children: [
//           TexxtField(),
//           SizedBox(
//             height: responsive.fromSmallMediumLarge(
//               small: 24.0,
//               medium: 12.0,
//               large: 40.0,
//             ),
//           ),
//           Expanded(
//             child: SingleChildScrollView(
//               child: Container(
//                 constraints: BoxConstraints(
//                   minHeight: MediaQuery.of(context).size.height,
//                 ),
//                 width: MediaQuery.of(context).size.width,
//                 color: isDark
//                     ? AppColors.backgroundDark
//                     : AppColors.backgroundLightGrey,
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 21),
//                     Center(
//                       child: Container(
//                         width: responsive.fromSmallMediumLarge(
//                           small: MediaQuery.of(context).size.width / 1.1,
//                           medium: MediaQuery.of(context).size.width / 1.1,
//                           large: MediaQuery.of(context).size.width / 1.1,
//                         ),
//                         decoration: BoxDecoration(
//                           borderRadius: const BorderRadiusDirectional.only(
//                             topStart: Radius.circular(15),
//                             topEnd: Radius.circular(15),
//                           ),
//                           color: isDark
//                               ? AppColors.deepGrey
//                               : AppColors.lightGreyContainer,
//                           boxShadow: const [
//                             BoxShadow(
//                               color: Color(0x1A000000),
//                               spreadRadius: 1,
//                               blurRadius: 1,
//                               offset: Offset(0, 1),
//                             ),
//                           ],
//                         ),
//                         child:
//                             Row(
//                               children: [
//                                 Text(
//                                   AppText.searchDat1,
//                                   style: getTextStyle2(
//                                     fontSize: responsive.fromSmallMediumLarge(
//                                       small: 12.0,
//                                       medium: 14.0,
//                                       large: 14.0,
//                                     ),
//                                     fontWeight: FontWeight.w500,
//                                     color: const Color(0xFFAAAAAA),
//                                   ),
//                                 ),
//                                 const Spacer(),
//                                 Text(
//                                   AppText.value40,
//                                   style: getTextStyle2(
//                                     color: isDark
//                                         ? AppColors.textWhite
//                                         : AppColors.black,
//                                     fontSize: responsive.fromSmallMediumLarge(
//                                       small: 12.0,
//                                       medium: 14.0,
//                                       large: 14.0,
//                                     ),
//                                     fontWeight: FontWeight.w500,
//                                   ),
//                                 ),
//                               ],
//                             ).marginSymmetric(
//                               vertical: responsive.fromSmallMediumLarge(
//                                 small: 8.0,
//                                 medium: 12.0,
//                                 large: 16.0,
//                               ),
//                               horizontal: 16,
//                             ),
//                       ),
//                     ),

//                     // --- ✅ INDEPENDENTLY DISMISSIBLE ROWS ---
//                     Container(
//                       width: responsive.fromSmallMediumLarge(
//                         small: MediaQuery.of(context).size.width / 1.1,
//                         medium: MediaQuery.of(context).size.width / 1.1,
//                         large: MediaQuery.of(context).size.width / 1.1,
//                       ),
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.vertical(
//                           bottom: Radius.circular(15)
//                         ), // Apply radius to the main container
//                         color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Color(0x1A000000),
//                             spreadRadius: 2,
//                             blurRadius: 5,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       // Clip the children to respect the rounded corners
//                       clipBehavior: Clip.antiAlias,
//                       child: Column(
//                         children: [
//                           // --- First Dismissible Row ---
//                           Dismissible(
//                             key: UniqueKey(), // Must have a unique key
//                             direction: DismissDirection.endToStart,
//                             background: Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE21818), // Red color
//                                 borderRadius: BorderRadiusDirectional.only(

//                                 ),
//                               ),
//                               alignment: Alignment.centerRight,
//                               padding: EdgeInsets.symmetric(horizontal: 10.0),
//                               child: Image.asset(IconPath.deleteIcon, scale: 4),
//                             ), // Red background
//                             confirmDismiss: (direction) async {
//                               debugPrint('First item would be deleted');
//                               return true;
//                             },
//                             child: Container(
//                               // Add color and padding here to make it look right
//                               color: isDark
//                                   ? Color(0xFF262626)
//                                   : AppColors.textWhite,
//                               child:
//                                   Row(
//                                     children: [
//                                       Image.asset(
//                                         IconPath.lipstickIcon,
//                                         scale: responsive.fromSmallMediumLarge(
//                                           small: 4.0,
//                                           medium: 4.0,
//                                           large: 4.0,
//                                         ),
//                                       ),
//                                       SizedBox(width: 15),
//                                       Text(
//                                         AppText.hair,
//                                         style: getTextStyle2(
//                                           color: isDark
//                                               ? AppColors.textWhite
//                                               : AppColors.black,
//                                           fontSize: responsive
//                                               .fromSmallMediumLarge(
//                                                 small: 12.0,
//                                                 medium: 14.0,
//                                                 large: 14.0,
//                                               ),
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       Text(
//                                         AppText.value40,
//                                         style: getTextStyle2(
//                                           fontSize: responsive
//                                               .fromSmallMediumLarge(
//                                                 small: 12.0,
//                                                 medium: 14.0,
//                                                 large: 14.0,
//                                               ),
//                                           fontWeight: FontWeight.w500,
//                                           color: AppColors.success,
//                                         ),
//                                       ),
//                                     ],
//                                   ).marginOnly(
//                                     left: 16,
//                                     right: 16,
//                                     top: 8,
//                                     bottom: 8,
//                                   ),
//                             ),
//                           ),

//                           // --- Divider ---
//                           Container(
//                             height: 1.5,
//                             color: isDark
//                                 ? AppColors.deepGrey
//                                 : AppColors.lightGreyContainer,
//                           ),

//                           // --- Second Dismissible Row ---
//                           Dismissible(
//                             key: UniqueKey(), // Must have a unique key
//                             direction: DismissDirection.endToStart,
//                            background: Container(
//                               decoration: BoxDecoration(
//                                 color: const Color(0xFFE21818), // Red color
//                                 borderRadius: BorderRadiusDirectional.only(

//                                 ),
//                               ),
//                               alignment: Alignment.centerRight,
//                               padding: EdgeInsets.symmetric(horizontal: 10.0),
//                               child:  Image.asset(IconPath.deleteIcon, scale: 4),
//                             ), // Red background
//                             confirmDismiss: (direction) async {
//                               debugPrint('Second item would be deleted');
//                               return true;
//                             },
//                             child: Container(
//                               // Add color and padding here as well
//                               color: isDark
//                                   ? Color(0xFF262626)
//                                   : AppColors.textWhite,
//                               child:
//                                   Row(
//                                     children: [
//                                       Image.asset(
//                                         IconPath.lipstickIcon,
//                                         scale: responsive.fromSmallMediumLarge(
//                                           small: 4.0,
//                                           medium: 4.0,
//                                           large: 4.0,
//                                         ),
//                                       ),
//                                       SizedBox(width: 15),
//                                       Text(
//                                         AppText.hair,
//                                         style: getTextStyle2(
//                                           fontSize: responsive
//                                               .fromSmallMediumLarge(
//                                                 small: 12.0,
//                                                 medium: 14.0,
//                                                 large: 14.0,
//                                               ),
//                                           color: isDark
//                                               ? AppColors.textWhite
//                                               : AppColors.black,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       Text(
//                                         AppText.value40,
//                                         style: getTextStyle2(
//                                           fontSize: responsive
//                                               .fromSmallMediumLarge(
//                                                 small: 12.0,
//                                                 medium: 14.0,
//                                                 large: 14.0,
//                                               ),
//                                           fontWeight: FontWeight.w500,
//                                           color: AppColors.error,
//                                         ),
//                                       ),
//                                     ],
//                                   ).marginOnly(
//                                     left: 16,
//                                     right: 16,
//                                     top: 8,
//                                     bottom: 8,
//                                   ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     const SizedBox(height: 24),
//                     SearchContainer(),
//                     const SizedBox(height: 24),
//                     SearchContainer(),
//                     const SizedBox(height: 24),
//                     SearchContainer(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/features/home_screen/widgets/search_screen.dart
// lib/features/home_screen/widgets/search_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/home_screen/widgets/search_container.dart';
import 'package:teddy_5618/features/home_screen/widgets/texxtfield.dart';
import 'package:teddy_5618/features/home_screen/widgets/dismissable_row.dart';
import 'package:teddy_5618/features/home_screen/controller/search_controller.dart';


// --- RESPONSIVE HELPER ---
class ResponsiveHelper {
  final BuildContext context;
  final Size size;

  ResponsiveHelper(this.context) : size = MediaQuery.of(context).size;

  bool get isSmallPhone => size.width <= 360;
  bool get isMediumPhone => size.width > 362 && size.width < 414;
  bool get isLargePhone => size.width >= 414;

  T fromSmallMediumLarge<T>({
    required T small,
    required T medium,
    required T large,
  }) {
    if (isSmallPhone) return small;
    if (isMediumPhone) return medium;
    return large;
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = Get.put(SearchScreenController());

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            CupertinoIcons.back,
            size: MediaQuery.of(context).size.height / 25,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.textWhite,
      ),
      body: Column(
        children: [
          TexxtField(),
          SizedBox(
            height: responsive.fromSmallMediumLarge(
              small: 24.0,
              medium: 12.0,
              large: 40.0,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                width: MediaQuery.of(context).size.width,
                color: isDark
                    ? AppColors.backgroundDark
                    : AppColors.backgroundLightGrey,
                child: Column(
                  children: [
                    const SizedBox(height: 21),
                    Center(
                      child: Container(
                        width: responsive.fromSmallMediumLarge(
                          small: MediaQuery.of(context).size.width / 1.1,
                          medium: MediaQuery.of(context).size.width / 1.1,
                          large: MediaQuery.of(context).size.width / 1.1,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: const BorderRadiusDirectional.only(
                            topStart: Radius.circular(15),
                            topEnd: Radius.circular(15),
                          ),
                          color: isDark
                              ? AppColors.deepGrey
                              : AppColors.lightGreyContainer,
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x1A000000),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child:
                            Row(
                              children: [
                                Text(
                                  AppText.searchDat1,
                                  style: getTextStyle2(
                                    fontSize: responsive.fromSmallMediumLarge(
                                      small: 12.0,
                                      medium: 14.0,
                                      large: 14.0,
                                    ),
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFFAAAAAA),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  AppText.value40,
                                  style: getTextStyle2(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    fontSize: responsive.fromSmallMediumLarge(
                                      small: 12.0,
                                      medium: 14.0,
                                      large: 14.0,
                                    ),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ).marginSymmetric(
                              vertical: responsive.fromSmallMediumLarge(
                                small: 8.0,
                                medium: 12.0,
                                large: 16.0,
                              ),
                              horizontal: 16,
                            ),
                      ),
                    ),
                    Container(
                      width: responsive.fromSmallMediumLarge(
                        small: MediaQuery.of(context).size.width / 1.1,
                        medium: MediaQuery.of(context).size.width / 1.1,
                        large: MediaQuery.of(context).size.width / 1.1,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(15),
                        ),
                        color: isDark
                            ? const Color(0xFF262626)
                            : AppColors.textWhite,
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Obx(
                        () => Column(
                          children: List.generate(
                            searchController.searchResults.length,
                            (index) {
                              final item =
                                  searchController.searchResults[index];
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DismissibleRow(
                                    item: item,
                                    onDelete: () =>
                                        searchController.deleteItem(item.id),
                                  ),
                                  if (index <
                                      searchController.searchResults.length - 1)
                                    Container(
                                      height: 1.5,
                                      color: isDark
                                          ? AppColors.deepGrey
                                          : AppColors.lightGreyContainer,
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SearchContainer(),
                    const SizedBox(height: 24),
                    SearchContainer(),
                    const SizedBox(height: 24),
                    SearchContainer(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
