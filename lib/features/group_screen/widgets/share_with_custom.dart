import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_spent_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_friend_spent_amo.dart';

class ShareWithCustom extends StatelessWidget {
  const ShareWithCustom({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
        Get.find<
          GroupTripSpentController
        >(); // Use existing controller instead of creating new one
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load group members when the widget is built (same as PaidByMultiple)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🔍 Custom widget callback - groupMembers.length: ${controller.groupMembers.length}, isLoading: ${controller.isLoadingMembers.value}, currentGroupId: "${controller.currentGroupId.value}"',
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

      // Initialize calculations when screen loads (custom version)
      controller.updateMainTotalForCustom();
      controller.updateCustomFriendTotal();
    });

    return SafeArea(
      top: false,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.70,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 20),
                Obx(
                  () => Text(
                    'Total ${controller.customComparisonText.value}'.tr,
                    style: getTextStyle2(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                ),
                SizedBox(height: 4),
                Obx(
                  () => controller.doCustomAmountsMatch.value
                      ? SizedBox.shrink() // Hide the error message if amounts match
                      : Text(
                          'Total amounts don\'t match'.tr,
                          style: getTextStyle2(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.red,
                          ),
                        ),
                ),
                Container(
                  constraints: BoxConstraints(
                    // 👇 Limit height so it can scroll
                    maxHeight: MediaQuery.of(context).size.height * 0.25,
                  ),

                  child: SingleChildScrollView(
                    child: Obx(() {
                      // Show loading state if members are being loaded
                      if (controller.isLoadingMembers.value) {
                        return SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      // Show error state if there's an error
                      if (controller.error.value.isNotEmpty &&
                          controller.friendNames.isEmpty) {
                        return SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              'Failed to load members',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      // Show API data (always use this, no hardcoded fallback)
                      if (controller.friendNames.isEmpty) {
                        return SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              'No members available',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: [
                          SizedBox(height: 20),
                          ...controller.friendNames.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final friendName = entry.value;
                            // Limit name to 10 characters like in Individual (same as PaidByMultiple)
                            final displayName = friendName.length > 10
                                ? friendName.substring(0, 10)
                                : friendName;
                            final initials = friendName.isNotEmpty
                                ? friendName[0].toUpperCase()
                                : '?';
                            final avatarColor = _getAvatarColor(
                              friendName,
                              index,
                            );

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: GroupTripFriendSpentAmount(
                                controller: controller,
                                name: displayName,
                                initials: initials,
                                color: avatarColor,
                                showCheckbox: false,
                                fieldMap: controller.customFriendControllers,
                                initializeController: controller
                                    .initializeCustomFriendControllerIfAbsent, // Use custom initialization
                              ),
                            );
                            // ignore: unnecessary_to_list_in_spreads
                          }).toList(),
                          const SizedBox(height: 24),
                        ],
                      );
                    }),
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    // Pass the current group ID from the controller
                    Get.to(
                      () => GroupTripSpentScreen(
                        groupId: controller.currentGroupId.value,
                      ),
                    );
                  },
                  child: Container(
                    height: 52,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: AppColors.green,
                    ),
                    child: Center(
                      child: Text(
                        'Done'.tr,
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
              ],
            ).marginSymmetric(horizontal: 24),
          ),
        ),
      ),
    );
  }

  // Helper method to get avatar color based on index (consistent colors)
  Color _getAvatarColor(String name, int index) {
    final colors = [
      AppColors.green, // Owner (index 0) gets green
      AppColors.readishred, // Second person gets red
      AppColors.blueButton, // Third person gets blue
      Colors.orange, // Fourth person gets orange
      Colors.purple, // Fifth person gets purple
      Colors.teal, // Sixth person gets teal
    ];

    return colors[index % colors.length];
  }
}
