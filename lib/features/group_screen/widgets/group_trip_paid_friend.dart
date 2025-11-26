import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/paid_by_individual.dart';
import 'package:teddy_5618/features/group_screen/widgets/paid_by_multiple.dart';

class GroupTripPaidFriendBottom extends StatelessWidget {
  final String controllerTag;

  const GroupTripPaidFriendBottom({
    super.key,
    this.controllerTag = 'groupTripSpent',
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupTripSpentController>(tag: controllerTag);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load group members when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🔍 Widget callback - groupMembers.length: ${controller.groupMembers.length}, isLoading: ${controller.isLoadingMembers.value}, currentGroupId: "${controller.currentGroupId.value}"',
      );

      if (controller.groupMembers.isEmpty &&
          !controller.isLoadingMembers.value) {
        if (controller.currentGroupId.value.isEmpty) {
          debugPrint(
            '🚀 No group ID, getting user groups first to set group ID...',
          );
          controller
              .getUserGroupsAndSetFirst(); // This will get groups and then call getGroupMembers
        } else {
          debugPrint('🚀 Have group ID, fetching members directly...');
          controller
              .getGroupMembers(); // This uses the getGroupMembers endpoint
        }
      }
    });

    return Container(
      // height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 16),

          // Top row with title and close button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(width: 32),
              Text(
                'Paid by'.tr,
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

          // Tab bar (Individual / Multiple)
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTabButton(
                  title: 'Individual'.tr,
                  selected: controller.isMultipleSelected.value == false,
                  onTap: () => controller.isMultipleSelected.value = false,
                  isDark: isDark,
                ),
                _buildTabButton(
                  title: 'Multiple'.tr,
                  selected: controller.isMultipleSelected.value == true,
                  onTap: () => controller.isMultipleSelected.value = true,
                  isDark: isDark,
                ),
              ],
            ).marginSymmetric(horizontal: 10),
          ),

          // Loading indicator for members
          Obx(() {
            if (controller.isLoadingMembers.value) {
              return Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              );
            }
            return SizedBox.shrink();
          }),

          // Error message
          Obx(() {
            if (controller.error.value.isNotEmpty &&
                !controller.isLoadingMembers.value) {
              return Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  controller.error.value,
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }
            return SizedBox.shrink();
          }),

          // Dynamic content area
          Obx(() {
            if (controller.isMultipleSelected.value) {
              return PaidByMultiple(controllerTag: controllerTag);
            } else {
              return PaidByIndividual(controllerTag: controllerTag);
            }
          }),
        ],
      ),
    );
  }

  // Private helper to build each tab button
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
