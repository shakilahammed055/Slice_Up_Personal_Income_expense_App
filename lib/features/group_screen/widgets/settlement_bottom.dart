import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/settlement_bottom_controller.dart';

class SettlementBottom extends StatelessWidget {
  const SettlementBottom({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettlementBottomController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.80,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Title row with Close button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const SizedBox(width: 32),
                Text(
                  'Settlement'.tr,
                  style: getTextStyle2(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                ),
              ],
            ),

            const SizedBox(height: 10),
            _sectionHeader('To pay'.tr, context),

            // Row 1
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleGroupOne(0),
                child: _buildSingleRow(
                  context: context,
                  title: 'Ted (Me) to Alice US\$ 40',
                  showCheck: controller.groupOneSelected[0],
                ),
              ),
            ),
            // Row 2
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleGroupOne(1),
                child: _buildSingleRow(
                  context: context,
                  title: 'Ted (Me) to Eric US\$ 40',
                  showCheck: controller.groupOneSelected[1],
                ),
              ),
            ),

            _sectionHeader('To Collect'.tr, context),

            // Row 1 in "To Collect"
            Obx(
              () => GestureDetector(
                onTap: () => controller.toggleGroupTwo(0),
                child: _buildSingleRow(
                  context: context,
                  title: 'Eric to Ted (Me) US\$ 40',
                  showCheck: controller.groupTwoSelected[0],
                ),
              ),
            ),

            const SizedBox(height: 40),
            const Spacer(),
            const Divider(),

            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: MediaQuery.of(context).size.width / 1.1,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(28),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Select'.tr,
                  style: getTextStyle2(
                    color: AppColors.black,
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
            color: isDark
                ? AppColors.deepGrey
                : AppColors.lightGreyContainer,
            width: 2,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: getTextStyle2(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textWhite : AppColors.black,
              ),
            ),
          ),
          // ✅ Custom checkbox
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: showCheck ? Colors.black : Colors.transparent,
              border: Border.all(color: AppColors.borderGrey, width: 2.0),
            ),
            child: Icon(
              Icons.done,
              size: 15,
              color: showCheck ? Colors.white : Colors.transparent,
              shadows: const [Shadow(blurRadius: 20, color: Colors.white)],
            ),
          ),
        ],
      ).marginSymmetric(horizontal: 8),
    );
  }

  Widget _sectionHeader(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      child: Container(
        height: 50,
        width: double.infinity,
        color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: getTextStyle2(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.textGrey,
          ),
        ).marginOnly(left: 15),
      ),
    );
  }
}
