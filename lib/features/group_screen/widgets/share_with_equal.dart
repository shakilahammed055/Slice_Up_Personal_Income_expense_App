import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

class ShareWithEqual extends StatelessWidget {
  const ShareWithEqual({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupTripSpentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(() {
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

            // Show API data
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

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 20),
              itemCount: controller.friendNames.length + 1, // header + friends
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Center(
                    child: Text(
                      "Total 90 / Per person 30",
                      style: getTextStyle3(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                  );
                }
                final friendName = controller.friendNames[index - 1];
                // Limit name to 10 characters
                final displayName = friendName.length > 10
                    ? '${friendName.substring(0, 8)}..'
                    : friendName;
                final initials = friendName.isNotEmpty
                    ? friendName[0].toUpperCase()
                    : '?';
                final avatarColor = _getAvatarColor(friendName, index - 1);

                return Column(
                  children: [
                    if (index > 1)
                      Divider(
                        color: isDark
                            ? AppColors.deepGrey
                            : AppColors.borderGrey,
                        height: 1,
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: avatarColor,
                            radius: 13,
                            child: Text(
                              initials,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  displayName,
                                  style: getTextStyle2(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                  ),
                                ),
                                // Show "(me)" if this is the first friend (group owner)
                                if (index - 1 == 0)
                                  Text(
                                    ' (me)',
                                    style: getTextStyle2(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.black,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Obx(
                            () => Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: controller.selectedSharedWithFriends
                                    .contains(friendName),
                                onChanged: (checked) {
                                  controller.toggleFriendCheckbox(friendName);
                                },
                                activeColor: Colors.black,
                                checkColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }),

          // ✅ FIX 2: Add the divider here, outside the ListView.
          const Divider(color: AppColors.borderGrey, height: 1),

          Padding(
            // Combined padding for above and below the button
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
            child: GestureDetector(
              onTap: () {
                Get.back();
              },
              child: Container(
                height: 52,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: AppColors.green,
                ),
                child: Center(
                  child: Text(
                    'Update'.tr,
                    style: getTextStyle2(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // I removed the SizedBox(height: 72) and managed the bottom spacing inside the Padding above.
        ],
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
