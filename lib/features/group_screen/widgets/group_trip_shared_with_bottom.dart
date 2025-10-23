import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/share_with_custom.dart';
import 'package:teddy_5618/features/group_screen/widgets/share_with_equal.dart';

class GroupTripSharedWithBottom extends StatefulWidget {
  const GroupTripSharedWithBottom({super.key});

  @override
  State<GroupTripSharedWithBottom> createState() =>
      _GroupTripSharedWithBottomState();
}

class _GroupTripSharedWithBottomState extends State<GroupTripSharedWithBottom> {
  @override
  void initState() {
    super.initState();
    // Load group members when the bottom sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<GroupTripSpentController>();

      // Clear any previous Share-with selections when opening the bottom sheet
      // but preserve the Paid-by selection so users don't lose their choice.
      controller.clearSharedWithSelections();

      if (controller.friendNames.isEmpty) {
        controller.getGroupMembers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupTripSpentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // height: MediaQuery.of(context).size.height * 0.70,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),

          // Top row with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Text(
                'Share with'.tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: const Icon(Icons.close, size: 25),
              ),
            ],
          ).marginSymmetric(horizontal: 16),

          const SizedBox(height: 14),

          // --- START OF FIX ---
          // Tab bar (Equally / Custom)
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton(
                  title: 'Equally'.tr,
                  // 'Equally' is selected when isEquallySelected is true
                  selected: controller.isEquallySelected.value,
                  // Set isEquallySelected to true on tap
                  onTap: () => controller.isEquallySelected.value = true,
                  isDark: isDark,
                ),
                _buildTabButton(
                  title: 'Custom'.tr,
                  // 'Custom' is selected when isEquallySelected is false
                  selected: !controller.isEquallySelected.value,
                  // Set isEquallySelected to false on tap
                  onTap: () => controller.isEquallySelected.value = false,
                  isDark: isDark,
                ),
              ],
            ).marginSymmetric(horizontal: 10),
          ),

          // Dynamic content area
          Obx(() {
            // Show 'ShareWithEqual' when isEquallySelected is true
            if (controller.isEquallySelected.value) {
              return const ShareWithEqual();
            } else {
              // Show 'ShareWithCustom' when it's false
              return const ShareWithCustom();
            }
          }),
          // --- END OF FIX ---
        ],
      ),
    );
  }

  // Private helper to build each tab button (No changes needed here)
  Widget _buildTabButton({
    required String title,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 170,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected
                  ? (isDark ? AppColors.textWhite : AppColors.black)
                  : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: selected
                  ? (isDark ? AppColors.textWhite : AppColors.black)
                  : (isDark ? Colors.grey[500]! : Colors.grey),
            ),
          ),
        ),
      ),
    );
  }
}
