import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:teddy_5618/core/utils/constants/colors.dart';

import 'package:teddy_5618/features/group_screen/widgets/group_search_card.dart';

import 'package:teddy_5618/features/home_screen/widgets/texxtfield.dart';

// Responsive Helper Class
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

class GroupSearchScreen extends StatelessWidget {
  const GroupSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.textWhite,
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
          SizedBox(
            height: responsive.fromSmallMediumLarge(
              small: 8,
              medium: 10,
              large: 16,
            ),
          ),
          TexxtField(),
          SizedBox(
            height: responsive.fromSmallMediumLarge(
              small: 24,
              medium: 12,
              large: 40,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  // Background grey container (added first)
                  Container(
                    height: MediaQuery.of(context).size.height / 1,
                    width: MediaQuery.of(context).size.width,
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLightGrey,
                    child: Column(
                      children: [
                        SizedBox(height: 20),
                        GroupSearchCard(foodtext: 'Lunch (Steak)',uppertext: 'Paid by Ted(me)', lowertext: 'US\$ 40',),
                        SizedBox(height: 24),
                        GroupSearchCard(foodtext: "Lunch in Outback", uppertext: "Paid by Jerrold", lowertext: 'US\$ 40',),
                        SizedBox(height: 24),
                        GroupSearchCard(foodtext: "Fancy Lunch", uppertext: 'Paid by Eric', lowertext: 'US\$ 40',),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
