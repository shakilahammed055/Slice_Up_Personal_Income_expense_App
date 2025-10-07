import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_filter_screen_controller.dart';

class GroupFilterScreen extends StatelessWidget {
  final String? groupId;

  const GroupFilterScreen({super.key, this.groupId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GroupFilterScreenController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.60,

        decoration: BoxDecoration(
          color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Title row with Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [
                Row(
                  children: [
                    Text(
                      'Filter'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ).marginOnly(left: 158),
                  ],
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

            const SizedBox(height: 10),
            _sectionHeader('Expense view'.tr, context),

            Obx(
              () => GestureDetector(
                onTap: () => controller.selectGroupOne(0),
                child: _buildSingleRow(
                  context: context,
                  title: 'All group'.tr,
                  showCheck: controller.groupOneSelected.value == 0,
                ),
              ),
            ),
            Obx(
              () => GestureDetector(
                onTap: () => controller.selectGroupOne(1),
                child: _buildSingleRow(
                  context: context,
                  title: 'Involving me only'.tr,
                  showCheck: controller.groupOneSelected.value == 1,
                ),
              ),
            ),

            _sectionHeader('Transaction Type'.tr, context),

            Obx(
              () => GestureDetector(
                onTap: () => controller.selectGroupTwo(0),
                child: _buildSingleRow(
                  context: context,
                  title: 'I borrowed'.tr,
                  showCheck: controller.groupTwoSelected.value == 0,
                ),
              ),
            ),
            Obx(
              () => GestureDetector(
                onTap: () => controller.selectGroupTwo(1),
                child: _buildSingleRow(
                  context: context,
                  title: 'I lent'.tr,
                  showCheck: controller.groupTwoSelected.value == 1,
                ),
              ),
            ),

            SizedBox(height: 40),

            const Spacer(),
            Divider(),
            GestureDetector(
              onTap: () async {
                // Apply filters before closing
                print('🎯 [FILTER_UI] Confirm button pressed');
                print(
                  '🎯 [FILTER_UI] Selected filters - View: ${controller.groupOneSelected.value}, Type: ${controller.groupTwoSelected.value}',
                );

                try {
                  await controller.applyFilters(groupId);
                  print('🎯 [FILTER_UI] Filters applied, closing modal');
                } catch (e) {
                  print('❌ [FILTER_UI] Error applying filters: $e');
                }

                Get.back();
              },
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                height: 52,
                // padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Confirm'.tr,
                  style: getTextStyle2(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
      ).marginSymmetric(horizontal: 8),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 50,
      width: double.infinity,
      color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: getTextStyle2(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFAAAAAA),
        ),
      ).marginOnly(left: 15),
    );
  }
}
