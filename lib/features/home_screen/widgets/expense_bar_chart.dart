// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // For .marginSymmetric

// Assuming these are defined in your project
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class ExpenseBarChart extends StatelessWidget {
  final String? iconPath;
  final String? icontext;

  final double? icontextfont;
  final Color? circlevatercolor;
  final String? valueText;
  final String? valueText2;
  final Color? valueColor;
  final Color? lightbarColor;
  final double? valuegap;
  final double? progressValue; // New parameter for progress (0.0 to 1.0)
  final Widget? iconWidget;

  const ExpenseBarChart({
    super.key,
    this.iconPath, // Can be null
    this.icontext,
    this.icontextfont,
    this.circlevatercolor,
    this.valueText,
    this.valueText2,
    this.valueColor,
    this.valuegap,
    this.progressValue,

    this.iconWidget,
    this.lightbarColor, // Initialize the new parameter // Initialize the new parameter
  });

  @override
  Widget build(BuildContext context) {
    final double gap = valuegap ?? 1.5;
    final double progress =
        progressValue ?? 0.5; // Progress value from 0.0 to 1.0
    final double percentage =
        progress * 100; // Convert to percentage for display

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Row(
          children: [
            // Show Image or fallback Text based on iconPath
            if (iconWidget != null)
              iconWidget!
            else if (iconPath != null)
              Image.asset(iconPath!, scale: 4)
            else
              SizedBox(
                height: 1, // desired height
                width: 1, // desired width
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle),

                  child: Text(
                    "A",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            // Fallback emoji/text
            SizedBox(width: 6.w),

            Text(
              icontext ?? '', // fallback to empty string
              style: getTextStyle2(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.black,
              ),
            ),

            Spacer(),

            Text(
              valueText ?? AppText.hundr1,
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: valueColor ?? AppColors.green,
              ),
            ),
            Text(
              valueText2 ?? '',
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ),
          ],
        ).marginSymmetric(horizontal: 24.w), // Responsive horizontal margin
        SizedBox(height: 10.h), // Responsive height
        Container(
          height: MediaQuery.of(context).size.height / 30, // Keep this dynamic
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              14.r,
            ), // Responsive border radius
            color:
                // AppColors.lightGreyContainer, // Background color of the bar
                isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: 0.9, // Target soft range (e.g., 60%)
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      14.r,
                    ), // Responsive border radius
                    color: isDark
                        ? AppColors.greylightbardeepcolor
                        : lightbarColor ?? AppColors.lightorange,
                    // lightbarColor, // Light layer
                  ),
                ),
              ),
              // The colored progress bar
              FractionallySizedBox(
                widthFactor: progress, // Width based on progress (0.0 to 1.0)
                child: AnimatedContainer(
                  duration: Duration(
                    milliseconds: 300,
                  ), // Smooth animation for progress changes
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      14.r,
                    ), // Responsive border radius
                    color:
                        valueColor ??
                        AppColors.textOrange, // Color of the progress
                  ),
                ),
              ),
              // Percentage text positioned at the right end of the progress
              // We use an AnimatedAlign to smoothly move the text with the progress,
              // and ensure it's always within the bounds or just at the edge.
              AnimatedAlign(
                alignment: Alignment.centerLeft, // Start alignment from left
                duration: Duration(
                  milliseconds: 300,
                ), // Match progress animation duration
                child: FractionallySizedBox(
                  widthFactor:
                      progress, // Text container width scales with progress
                  alignment: Alignment
                      .centerLeft, // Align content to left within its scaled width
                  child: Align(
                    alignment: Alignment
                        .centerRight, // Align text itself to the right of its container
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 8.w, // Responsive padding using ScreenUtil
                      ), // Small padding from the right edge
                      child: Text(
                        '${percentage.toStringAsFixed(0)}%', // Display percentage with no decimal places
                        style: TextStyle(
                          color: Colors.black, // Text color for contrast
                          fontSize:
                              11.sp, // Responsive font size using ScreenUtil
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).marginSymmetric(horizontal: 20.w), // Responsive horizontal margin
      ],
    );
  }
}
