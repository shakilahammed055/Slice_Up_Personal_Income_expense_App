import 'package:flutter/material.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

Widget buildSettingItem({
    required IconData icon,
    required String title,
    required BuildContext context,
    Widget? trailing,
    VoidCallback? onTap,
    bool isEditable = true,
    required double screenWidth,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: isEditable ? onTap : null,
      child: Container(
        width: double.infinity,
        height: screenWidth * 0.14,
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenWidth * 0.03,
        ),
        decoration: ShapeDecoration(
          color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              width: 1,
              color: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: screenWidth * 0.06),
            SizedBox(width: screenWidth * 0.02),
            Expanded(
              child: Text(
                title,
                style: getTextStyle2(
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontSize: screenWidth * 0.036,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }