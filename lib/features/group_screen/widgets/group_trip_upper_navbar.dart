import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/screen/expenses_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/sliceup_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/status_page_screen.dart';

class GroupTripUpperNavbar extends StatelessWidget {
  const GroupTripUpperNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TabBar(
          dividerColor: Colors.transparent,
          indicatorColor: isDark ? AppColors.textWhite : AppColors.black,
          unselectedLabelColor: Colors.transparent,
          indicatorWeight: 2,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: isDark ? AppColors.textWhite : AppColors.black,
              width: 2.0,
            ),
            insets: const EdgeInsets.symmetric(horizontal: 80.0),
          ),
          tabs: [
            Tab(
              child: Text(
                "Expenses".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Slice up".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Status".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
          ],
        ),
        // ✅ Expand TabBarView inside parent Expanded
        Expanded(
          child: TabBarView(
            children: [
              const ExpensesPageScreen(),
              const SliceupPageScreen(),
              const StatusPageScreen(),
            ],
          ),
        ),
      ],
    );
  }
}
