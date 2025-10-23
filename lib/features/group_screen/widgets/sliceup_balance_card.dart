// ignore_for_file: no_leading_underscores_for_local_identifiers

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

// Data model for a single balance entry row
class BalanceEntry {
  final Color circleavatarColor;
  final String circleavatartext;
  final String name;
  final String amount;
  final Color amountcolor;

  BalanceEntry({
    required this.circleavatarColor,
    required this.circleavatartext,
    required this.name,
    required this.amount,
    required this.amountcolor,
  });
}

// Responsive Helper Class (unchanged)
class ResponsiveHelper {
  final BuildContext context;
  final Size size;

  ResponsiveHelper(this.context) : size = MediaQuery.of(context).size;

  bool get isSmallPhone => size.width <= 360;
  bool get isMediumPhone => size.width > 362 && size.width < 414;
  bool get isLargePhone => size.width >= 414;

  double fromSmallMediumLarge({
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallPhone) return small;
    if (isMediumPhone) return medium;
    return large;
  }
}

class SliceupBalanceCard extends StatelessWidget {
  const SliceupBalanceCard({
    super.key,
    required this.entries, // Now accepts a list of BalanceEntry
  });

  final List<BalanceEntry> entries; // List to hold data for each row

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Helper widget to build a single balance row without specific vertical margins
    Widget buildBalanceRowContent(BalanceEntry entry) {
      String _shorten(String s, [int len = 10]) {
        if (s.length <= len) return s;
        return '${s.substring(0, len)}...';
      }

      return Row(
        children: [
          CircleAvatar(
            backgroundColor: entry.circleavatarColor,
            radius: 15,
            child: Text(
              entry.circleavatartext,
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textWhite,
              ),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              _shorten(entry.name),
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,
                fontSize: responsive.fromSmallMediumLarge(
                  small: 12,
                  medium: 14,
                  large: 14,
                ),
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Spacer(),
          Text(
            entry.amount,
            style: getTextStyle2(
              fontSize: responsive.fromSmallMediumLarge(
                small: 12,
                medium: 14,
                large: 14,
              ),
              fontWeight: FontWeight.w500,
              color: entry.amountcolor,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        // First foreground container with border radius
        Center(
          child: Container(
            width: responsive.fromSmallMediumLarge(
              small: MediaQuery.of(context).size.width / 1.1,
              medium: MediaQuery.of(context).size.width / 1.1,
              large: MediaQuery.of(context).size.width / 1.1,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadiusDirectional.only(
                topStart: Radius.circular(15),
                topEnd: Radius.circular(15),
              ),
              color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
              boxShadow: [
                BoxShadow(
                  color: Color(0x1A000000),
                  spreadRadius: 1,
                  blurRadius: 1,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child:
                Text(
                  'Total balance'.tr,
                  style: getTextStyle2(
                    fontSize: responsive.fromSmallMediumLarge(
                      small: 12,
                      medium: 14,
                      large: 14,
                    ),
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFAAAAAA),
                  ),
                ).marginSymmetric(
                  vertical: responsive.fromSmallMediumLarge(
                    small: 8,
                    medium: 12,
                    large: 16,
                  ),
                  horizontal: 16,
                ),
          ),
        ),

        // Positioned container on top
        Container(
          width: responsive.fromSmallMediumLarge(
            small: MediaQuery.of(context).size.width / 1.1,
            medium: MediaQuery.of(context).size.width / 1.1,
            large: MediaQuery.of(context).size.width / 1.1,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadiusDirectional.only(
              bottomEnd: Radius.circular(10),
              bottomStart: Radius.circular(10),
            ),
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Dynamically build rows based on the 'entries' list
              // Apply margins as per original code
              if (entries.isNotEmpty)
                buildBalanceRowContent(
                  entries[0],
                ).marginOnly(left: 16, right: 16, top: 8),
              if (entries.length > 1)
                Divider(
                  thickness: 1,
                  color: isDark
                      ? AppColors.deepGrey
                      : AppColors.lightGreyContainer,
                ),
              if (entries.length > 1)
                buildBalanceRowContent(
                  entries[1],
                ).marginOnly(left: 16, right: 16),
              if (entries.length > 2)
                Divider(
                  thickness: 1,
                  color: isDark
                      ? AppColors.deepGrey
                      : AppColors.lightGreyContainer,
                ),
              if (entries.length > 2)
                buildBalanceRowContent(
                  entries[2],
                ).marginOnly(left: 16, right: 16),
              if (entries.length > 3)
                Divider(
                  thickness: 1,
                  color: isDark
                      ? AppColors.deepGrey
                      : AppColors.lightGreyContainer,
                ),
              if (entries.length > 3)
                buildBalanceRowContent(
                  entries[3],
                ).marginOnly(left: 16, right: 16, bottom: 8),
            ],
          ),
        ),
      ],
    );
  }
}
