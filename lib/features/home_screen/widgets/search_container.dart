import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/core/utils/constants/responsive_helper.dart';

class SearchContainer extends StatelessWidget {
  const SearchContainer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final r = ResponsiveHelper(context);
    final double containerWidth = r.fromSmallMediumLarge(
      small: r.size.width / 1.1,
      medium: r.size.width / 1.1,
      large: r.size.width / 1.1,
    );
   
    final double containerHeightBottom = r.fromSmallMediumLarge(
      small: r.size.height / 17,
      medium: r.size.height / 20,
      large: r.size.height / 20,
    );
    final double fontSize = r.fromSmallMediumLarge(
      small: 12,
      medium: 13,
      large: 14,
    );
    final double iconScale = r.fromSmallMediumLarge(
      small: 4.5,
      medium: 4.2,
      large: 4,
    );

    return Column(
      children: [
        Container(
          // height: containerHeightTop,
          height: 45.h,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              topStart: Radius.circular(10),
              topEnd: Radius.circular(10),
            ),
            color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
            // color: AppColors.lightGreyContainer,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(
                AppText.searchDat1,
                style: getTextStyle2(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFAAAAAA),
                ),
              ),
              // SizedBox(width: r.size.width / 2.2),
              Spacer(),
              Text(
                AppText.value40,
                style: getTextStyle2(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ],
          ).marginSymmetric( horizontal: 16),
        ),

        // Simulating a "positioned" bottom container inside a column
        // SizedBox(height: 12), // Add space instead of Positioned
        Container(
          height: containerHeightBottom,
          width: containerWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              bottomStart: Radius.circular(15),
              bottomEnd: Radius.circular(15),
            ),
            color: isDark ?  Color(0xFF262626) : AppColors.textWhite,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Image.asset(IconPath.lipstickIcon, scale: iconScale),
              SizedBox(width: 15),
              Text(
                AppText.hair,
                style: getTextStyle2(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
              // SizedBox(width: r.size.width / 1.7),
              Spacer(),
              Text(
                AppText.value40,
                style: getTextStyle2(
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ],
          ).marginSymmetric(horizontal: 14, vertical: 8),
        ),
      ],
    );
  }
}
