import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_friend_spent_amo.dart';

class PaidByMultiple extends StatelessWidget {
  final String controllerTag;

  const PaidByMultiple({super.key, this.controllerTag = 'groupTripSpent'});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupTripSpentController>(tag: controllerTag);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Load group members when the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] ========== WIDGET CALLBACK START ==========',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] groupMembers.length: ${controller.groupMembers.length}',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] isLoadingMembers: ${controller.isLoadingMembers.value}',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] currentGroupId: "${controller.currentGroupId.value}"',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] editingExpenseId: "${controller.editingExpenseId.value}"',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] friendNames: ${controller.friendNames.toList()}',
      );
      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] multipleFriendControllers.keys: ${controller.multipleFriendControllers.keys.toList()}',
      );

      // Print all controller values
      debugPrint('🔍 [PAID_BY_MULTIPLE] Controller values:');
      controller.multipleFriendControllers.forEach((key, ctrl) {
        debugPrint('🔍 [PAID_BY_MULTIPLE]   "$key" → "${ctrl.text}"');
      });

      if (controller.groupMembers.isEmpty &&
          !controller.isLoadingMembers.value) {
        if (controller.currentGroupId.value.isEmpty) {
          debugPrint(
            '🚀 [PAID_BY_MULTIPLE] No group ID, getting user groups first...',
          );
          controller
              .getUserGroupsAndSetFirst(); // This will get groups and then call getGroupMembers
        } else {
          debugPrint(
            '🚀 [PAID_BY_MULTIPLE] Have group ID, fetching members directly...',
          );
          controller
              .getGroupMembers(); // This uses the getGroupMembers endpoint
        }
      }

      // Initialize calculations when screen loads
      debugPrint('🔍 [PAID_BY_MULTIPLE] Calling updateMainTotal()');
      controller.updateMainTotal();
      debugPrint('🔍 [PAID_BY_MULTIPLE] Calling updateMultipleFriendTotal()');
      controller.updateMultipleFriendTotal();

      debugPrint(
        '🔍 [PAID_BY_MULTIPLE] ========== WIDGET CALLBACK END ==========',
      );
    });

    return SafeArea(
      top: false,
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.60,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16),
              Obx(
                () => Text(
                  "${'Total'.tr} ${controller.totalComparisonText.value}",
                  style: getTextStyle2(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                ),
              ),
              Obx(
                () => controller.doAmountsMatch.value
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
                      // ignore: sized_box_for_whitespace
                      return Container(
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
                            'Failed to load members'.tr,
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
                            'No members available'.tr,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }

                    return Column(
                      children: [
                        SizedBox(height: 18),
                        ...controller.friendNames.asMap().entries.map((entry) {
                          final index = entry.key;
                          final friendName = entry.value;
                          // Limit name to 10 characters like in Individual
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

                          // Debug: Print state at render time
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            debugPrint(
                              '🎨 [PAID_BY_MULTIPLE_UI] Rendering item $index: friendName="$friendName" → displayName="$displayName"',
                            );
                            debugPrint(
                              '🎨 [PAID_BY_MULTIPLE_UI] multipleFriendControllers.keys: ${controller.multipleFriendControllers.keys.toList()}',
                            );
                            if (controller.multipleFriendControllers
                                .containsKey(friendName)) {
                              final amount = controller
                                  .multipleFriendControllers[friendName]
                                  ?.text;
                              debugPrint(
                                '🎨 [PAID_BY_MULTIPLE_UI] ✅ Found controller for "$friendName" with value: "$amount"',
                              );
                            } else {
                              debugPrint(
                                '🎨 [PAID_BY_MULTIPLE_UI] ❌ NO controller found for "$friendName"',
                              );
                            }
                          });

                          // Ensure the controller is initialized for this friend
                          controller.initializeFriendControllerIfAbsent(
                            friendName,
                            controller.multipleFriendControllers,
                          );

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: GroupTripFriendSpentAmount(
                              controller: controller,
                              name: friendName,
                              initials: initials,
                              color: avatarColor,
                              showCheckbox: false,
                              fieldMap: controller.multipleFriendControllers,
                            ),
                          );
                          // ignore: unnecessary_to_list_in_spreads
                        }).toList(),
                        const SizedBox(height: 21),
                      ],
                    );
                  }),
                ),
              ),

              // Show the Update button always; enable (green/clickable)
              // only when totals match. When disabled, it stays visible
              // but greyed out and non-clickable.
              Obx(() {
                final enabled = controller.doAmountsMatch.value;
                return GestureDetector(
                  onTap: enabled
                      ? () async {
                          debugPrint(
                            '🔘 [PAID_BY_MULTIPLE] Update button clicked',
                          );
                          debugPrint(
                            '🔘 [PAID_BY_MULTIPLE] doAmountsMatch: ${controller.doAmountsMatch.value}',
                          );
                          debugPrint(
                            '🔘 [PAID_BY_MULTIPLE] totalComparisonText: ${controller.totalComparisonText.value}',
                          );

                          // Mark that the paid-by selection came from Multiple flow
                          controller.paidByWasMultiple.value = true;
                          debugPrint(
                            '🔘 [PAID_BY_MULTIPLE] Set paidByWasMultiple = true',
                          );

                          // Close the bottom sheet (saving happens elsewhere)
                          debugPrint(
                            '🔘 [PAID_BY_MULTIPLE] Closing bottom sheet...',
                          );
                          Get.back();
                        }
                      : null,
                  child: Container(
                    height: 52,
                    width: MediaQuery.of(context).size.width / 1.1,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: enabled
                          ? AppColors.green
                          : (isDark ? Color(0xFF3A3A3A) : Color(0xFFE0E0E0)),
                    ),
                    child: Center(
                      child: Text(
                        'Update'.tr,
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: enabled ? Colors.black : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                );
              }),
              SizedBox(height: 12),
            ],
          ).marginSymmetric(horizontal: 24),
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
