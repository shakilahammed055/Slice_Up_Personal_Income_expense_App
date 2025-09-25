// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/app_texts.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/core/utils/constants/icon_path.dart';
// import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';

// class GroupSearchCard extends StatelessWidget {
//   final String foodtext;
//   final String uppertext;
//   final String lowertext;
//   const GroupSearchCard({
//     super.key,
//     required this.foodtext,
//     required this.uppertext,
//     required this.lowertext,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final r = ResponsiveHelper(context);
//     final double containerWidth = r.fromSmallMediumLarge(
//       small: r.size.width / 1.1,
//       medium: r.size.width / 1.1,
//       large: r.size.width / 1.1,
//     );
    

//     final double fontSize = r.fromSmallMediumLarge(
//       small: 12,
//       medium: 13,
//       large: 14,
//     );
//     // final double iconScale = r.fromSmallMediumLarge(
//     //   small: 4.5,
//     //   medium: 4.2,
//     //   large: 4,
//     // );

//     return Column(
//       children: [
//         Center(
//           child: Container(
//             // height: containerHeightTop,
//             width: containerWidth,
//             decoration: BoxDecoration(
//               borderRadius: const BorderRadiusDirectional.only(
//                 topStart: Radius.circular(10),
//                 topEnd: Radius.circular(10),
//               ),
//               color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
//               // color: AppColors.lightGreyContainer,
//               boxShadow: const [
//                 BoxShadow(
//                   color: Color(0x1A000000),
//                   spreadRadius: 1,
//                   blurRadius: 1,
//                   offset: Offset(0, 1),
//                 ),
//               ],
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       AppText.searchDat1,
//                       style: getTextStyle2(
//                         fontSize: fontSize,
//                         fontWeight: FontWeight.w500,
//                         color: Color(0xFFAAAAAA),
//                       ),
//                     ),
//                   ],
//                 ).marginSymmetric(vertical: 10, horizontal: 16),
//               ],
//             ),
//           ),
//         ),

//         // Simulating a "positioned" bottom container inside a column
//         // SizedBox(height: 12), // Add space instead of Positioned
//         Container(
//           // height: containerHeightBottom,
//           width: containerWidth,
//           decoration: BoxDecoration(
//             borderRadius: const BorderRadiusDirectional.only(
//               bottomStart: Radius.circular(10),
//               bottomEnd: Radius.circular(10),
//             ),
//             color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//             boxShadow: const [
//               BoxShadow(
//                 color: Color(0x1A000000),
//                 spreadRadius: 2,
//                 blurRadius: 5,
//                 offset: Offset(0, 3),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               Image.asset(IconPath.burger, 
//               // scale: iconScale
//               ),
//               const SizedBox(width: 15),
//               Text(
//                 foodtext,
//                 style: getTextStyle2(
//                   fontSize: fontSize,
//                   fontWeight: FontWeight.w500,
//                   color: isDark ? AppColors.textWhite : AppColors.black,
//                 ),
//               ),
//               // SizedBox(width: r.size.width / 2),
//               Spacer(),
//               Column(
//                 children: [
//                   Text(
//                     uppertext,
//                     style: getTextStyle2(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w400,
//                       color: AppColors.textGrey,
//                     ),
//                   ),
//                   Text(
//                     lowertext,
//                     style: getTextStyle2(
//                       fontSize: fontSize,
//                       fontWeight: FontWeight.w500,
//                       color: isDark ? AppColors.textWhite : AppColors.black,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ).marginSymmetric(horizontal: 14),
//         ),
//       ],
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';

class GroupSearchCard extends StatelessWidget {
  final String foodtext;
  final String uppertext;
  final String lowertext;

  const GroupSearchCard({
    super.key,
    required this.foodtext,
    required this.uppertext,
    required this.lowertext,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = ResponsiveHelper(context);

    // final double containerWidth = r.fromSmallMediumLarge(
    //   small: r.size.width / 1.1,
    //   medium: r.size.width / 1.2,
    //   large: r.size.width / 1.1,
    // );

    final double fontSize = r.fromSmallMediumLarge(
      small: 12,
      medium: 13,
      large: 14,
    );

    return Column(
      children: [
        // Top (date/header)
        Center(
          child: Container(
            // width: containerWidth,
            decoration: BoxDecoration(
              borderRadius: const BorderRadiusDirectional.only(
                topStart: Radius.circular(10),
                topEnd: Radius.circular(10),
              ),
              color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppText.searchDat1,
                      style: getTextStyle2(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA), // ✅ kept your color
                      ),
                    ),
                  ],
                ).marginSymmetric(vertical: 10, horizontal: 16),
              ],
            ),
          ).marginSymmetric(horizontal: 24),
        ),

        // Bottom row
        Container(
          // width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: const BorderRadiusDirectional.only(
              bottomStart: Radius.circular(10),
              bottomEnd: Radius.circular(10),
            ),
            color: isDark
                ? const Color(0xFF262626)
                : AppColors.textWhite, // ✅ kept your color
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 48, // ✅ new fixed height
            child: Padding(
              padding: const EdgeInsets.only(
                left: 8,
                right: 16,
              ), // ✅ new padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ✅ icon wrapped in fixed box
                  SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Image.asset(
                        IconPath.burger,
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // ✅ Expanded + ellipsis
                  Expanded(
                    child: Text(
                      foodtext,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: getTextStyle2(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // ✅ aligned column for right block
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        uppertext,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle2(
                          fontSize: 12, // ✅ kept your font size
                          fontWeight: FontWeight.w400, // ✅ kept your weight
                          color: AppColors.textGrey,
                        ),
                      ),
                      Text(
                        lowertext,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: getTextStyle2(
                          fontSize: fontSize, // ✅ kept responsive
                          fontWeight: FontWeight.w500, // ✅ kept your weight
                          color: isDark ? AppColors.textWhite : AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).marginSymmetric(horizontal: 24),
      ],
    );
  }
}
