import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

class PaidByIndividual extends StatelessWidget {
  const PaidByIndividual({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GroupTripSpentController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Obx(
        () => ListView.separated(
          shrinkWrap: true, // lets it size by content
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.friendNames.length,
          separatorBuilder: (_, __) => Divider(
            color: isDark ? AppColors.deepGrey : AppColors.borderGrey,
          ),
          itemBuilder: (context, index) {
            final friend = controller.friendNames[index];

            // Find the corresponding member data to check if they're the owner
            final memberData = controller.groupMembers.firstWhere(
              (member) => member['name'] == friend,
              orElse: () => <String, dynamic>{},
            );
            final isOwner = memberData['isOwner'] == true;

            // Limit name to 10 characters
            final displayName = friend.length > 10
                ? friend.substring(0, 10)
                : friend;

            return GestureDetector(
              onTap: () {
                controller.setSelectedPaidByFriend(friend);
                // Don't auto-close to allow users to see deselection
                // Get.back();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 24,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getAvatarColor(friend, index),
                      radius: 13,
                      child: Text(
                        friend.isNotEmpty ? friend[0] : '?',
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
                          if (isOwner) ...[
                            const SizedBox(width: 4),
                            Text(
                              '(Me)',
                              style: getTextStyle2(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.black,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Obx(
                      () => controller.selectedPaidByFriend.value == friend
                          ? const Icon(Icons.check)
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Helper method to get different avatar colors
  Color _getAvatarColor(String name, int index) {
    final colors = [
      AppColors.green, // Owner gets green
      AppColors.readishred, // Second person gets red
      AppColors.blueButton, // Third person gets blue
      Colors.orange, // Fourth person gets orange
      Colors.purple, // Fifth person gets purple
      Colors.teal, // Sixth person gets teal
    ];

    return colors[index % colors.length];
  }
}
