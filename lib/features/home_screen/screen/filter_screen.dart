import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/features/home_screen/controller/filter_screen_controller.dart';
import 'package:teddy_5618/features/home_screen/widgets/month_year_bar.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FilterScreenController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Fixed header
            SizedBox(
              height: 56,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 32),
                  Text(
                    'Filter'.tr,
                    style: getTextStyle2(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                  IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/crossicon.svg',
                      height: 14.h,
                      width: 14.w,
                      // ignore: deprecated_member_use
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _sectionHeader('Balance overview'.tr, context),
                    // ✅ Total Remaining - Independent
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectGroupOne(0),
                        child: _buildGroupRow(
                          context: context,
                          title1: 'Total Remaining'.tr,
                          title2: AppText.incomeExpense.tr,
                          showCheck: controller.groupOneSelected.value == 0,
                        ),
                      ),
                    ),
                    // ✅ Total Expense - Independent
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectGroupOne(1),
                        child: _buildGroupRow(
                          context: context,
                          title1: AppText.totalExpense.tr,
                          title2: AppText.incomeRemain.tr,
                          showCheck: controller.groupOneSelected.value == 1,
                        ),
                      ),
                    ),
                    _sectionHeader('Filter by type'.tr, context),
                    // ✅ ALL OPTION - FIRST
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectGroupTwo(0),
                        child: _buildSingleRow(
                          context: context,
                          title: 'All'.tr, // ✅ ADDED ALL
                          showCheck: controller.groupTwoSelected.value == 0,
                        ),
                      ),
                    ),
                    // ✅ Expense Only
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectGroupTwo(1),
                        child: _buildSingleRow(
                          context: context,
                          title: 'Expense only'.tr,
                          showCheck: controller.groupTwoSelected.value == 1,
                        ),
                      ),
                    ),
                    // ✅ Income Only
                    Obx(
                      () => GestureDetector(
                        onTap: () => controller.selectGroupTwo(2),
                        child: _buildSingleRow(
                          context: context,
                          title: 'Income only'.tr,
                          showCheck: controller.groupTwoSelected.value == 2,
                        ),
                      ),
                    ),
                    _sectionHeader('Filter by month'.tr, context),
                    SizedBox(
                      height: 210,
                      child: Obx(
                        () => MonthYearBar(
                          onDateSelected: (DateTime date) {
                            controller.updateMonthYearFilter(date);
                          },
                          initialDate:
                              controller.selectedMonthYearFilter.value ??
                              DateTime.now(),
                        ),
                      ),
                    ),
                    // Clear filter button for month
                    Obx(() {
                      if (controller.selectedMonthYearFilter.value != null) {
                        return GestureDetector(
                          onTap: () => controller.clearMonthFilter(),
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 20.w,
                              vertical: 10.h,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              'Clear Month Filter'.tr,
                              style: getTextStyle2(
                                color: Colors.red,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    }),
                    const SizedBox(height: 5),
                  ],
                ),
              ),
            ),
            Divider(
              thickness: 1,
              color: isDark ? AppColors.deepGrey : AppColors.borderGrey,
            ),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                height: 52,
                width: MediaQuery.of(context).size.width / 1.1,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark ? Color(0xFF406DFF) : const Color(0xFF2A31EF),
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm'.tr,
                  style: getTextStyle2(
                    color: AppColors.backgroundLightGrey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupRow({
    required BuildContext context,
    required String title1,
    required String title2,
    required bool showCheck,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title1,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            title2,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.textGrey,
            ),
          ),
          const Spacer(),
          if (showCheck)
            Icon(
              Icons.check,
              color: isDark ? AppColors.textWhite : AppColors.black,
              shadows: const [
                Shadow(
                  blurRadius: 0.5,
                  color: Colors.black,
                  offset: Offset(1, 0),
                ),
              ],
            ),
        ],
      ).marginSymmetric(horizontal: 20),
    );
  }

  Widget _buildSingleRow({
    required BuildContext context,
    required String title,
    required bool showCheck,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 55,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
          ),
          const Spacer(),
          if (showCheck)
            Icon(
              Icons.check,
              color: isDark ? AppColors.textWhite : AppColors.black,
              shadows: const [
                Shadow(
                  blurRadius: 0.5,
                  color: Colors.black,
                  offset: Offset(1, 0),
                ),
              ],
            ),
        ],
      ).marginSymmetric(horizontal: 20),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 55,
      width: double.infinity,
      color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: getTextStyle2(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFFAAAAAA),
        ),
      ).marginOnly(left: 20),
    );
  }
}
