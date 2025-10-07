import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class IndividualTransactionEntry {
  final Color fromAvatarColor;
  final String fromAvatarText;
  final String fromName;
  final Color toAvatarColor;
  final String toAvatarText;
  final String toName;
  final String amount;
  // final Color amountColor;

  IndividualTransactionEntry({
    required this.fromAvatarColor,
    required this.fromAvatarText,
    required this.fromName,
    required this.toAvatarColor,
    required this.toAvatarText,
    required this.toName,
    required this.amount,
    // required this.amountColor,
  });
}

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

class IndividualCard extends StatelessWidget {
  final List<IndividualTransactionEntry> entries;
  final String? title2;

  const IndividualCard({super.key, required this.entries, this.title2});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget buildIndividualRowContent(IndividualTransactionEntry entry) {
      String _shorten(String s, [int len = 10]) {
        if (s.length <= len) return s;
        return '${s.substring(0, len)}...';
      }

      return Row(
        children: [
          // FROM
          CircleAvatar(
            backgroundColor: entry.fromAvatarColor,
            radius: 14,
            child: Text(
              entry.fromAvatarText,
              style: getTextStyle2(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textWhite,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _shorten(entry.fromName),
              style: getTextStyle2(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Color(0xFFAAAAAA),
          ),
          const SizedBox(width: 6),

          // TO
          CircleAvatar(
            backgroundColor: entry.toAvatarColor,
            radius: 14,
            child: Text(
              entry.toAvatarText,
              style: getTextStyle2(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textWhite,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              _shorten(entry.toName),
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.black,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          const Spacer(),

          // Amount
          Text(
            entry.amount,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
          ),
        ],
      );
    }

    return Center(
      child: Column(
        children: [
          // Top Container
          Container(
            height: responsive.fromSmallMediumLarge(
              small: 40,
              medium: 45,
              large: 48,
            ),
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
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
            child: Row(
              children: [
                Text(
                  'Settlement'.tr,
                  style: getTextStyle2(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFAAAAAA),
                  ),
                ),
                const Spacer(),
                Text(
                  title2 ?? '',
                  style: getTextStyle2(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.black,

                    //  AppColors.black,
                  ),
                ),
              ],
            ).marginSymmetric(horizontal: 16),
          ),

          // Bottom Container with dynamic entries
          Container(
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
              color: isDark ? Color(0xFF262626) : AppColors.textWhite,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              itemCount: entries.length,
              itemBuilder: (_, index) =>
                  buildIndividualRowContent(entries[index]),
              separatorBuilder: (_, __) => Divider(
                thickness: 1,
                color: isDark
                    ? AppColors.deepGrey
                    : AppColors.lightGreyContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
