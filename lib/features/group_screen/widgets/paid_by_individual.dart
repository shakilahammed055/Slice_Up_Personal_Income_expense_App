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
          padding: const EdgeInsets.fromLTRB(
            0,
            16,
            0,
            52,
          ), // Added 36 to bottom padding (16 + 36 = 52)
          itemCount:
              controller.friendNames.length + 1, // +1 for the final divider
          separatorBuilder: (_, index) {
            // Don't show separator after the last member, since we'll add a divider as a separate item
            if (index == controller.friendNames.length - 1) {
              return const SizedBox.shrink();
            }
            return Divider(
              color: isDark ? AppColors.deepGrey : AppColors.borderGrey,
            );
          },
          itemBuilder: (context, index) {
            // If this is the last item, show just a divider
            if (index == controller.friendNames.length) {
              return Divider(
                color: isDark ? AppColors.deepGrey : AppColors.borderGrey,
              );
            }

            final friend = controller.friendNames[index];

            // Find the corresponding member data to get member info
            final memberData = controller.groupMembers.firstWhere(
              (member) => member['name'] == friend,
              orElse: () => <String, dynamic>{},
            );

            // Limit name to 10 characters
            final displayName = friend.length > 10
                ? friend.substring(0, 10)
                : friend;

            return FutureBuilder<String?>(
              future: controller.getCurrentUserEmail(),
              builder: (context, snapshot) {
                // Check if this member is the currently logged-in user
                final currentUserEmail = snapshot.data;
                final memberEmail = memberData['email']?.toString() ?? '';
                final memberId = memberData['id']?.toString() ?? '';

                // Debug logging
                debugPrint('🔍 Current User Email: $currentUserEmail');
                debugPrint('🔍 Member Email: $memberEmail');
                debugPrint('🔍 Member ID: $memberId');
                debugPrint('🔍 Friend Name: $friend');
                debugPrint('🔍 Member Data: $memberData');

                // Check if this member matches the logged-in user (by email)
                final isCurrentUser =
                    currentUserEmail != null &&
                    currentUserEmail.isNotEmpty &&
                    memberEmail.isNotEmpty &&
                    memberEmail.toLowerCase() == currentUserEmail.toLowerCase();

                debugPrint('🔍 Is Current User: $isCurrentUser');

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
                              if (isCurrentUser) ...[
                                const SizedBox(width: 4),
                                Text(
                                  '(Me)',
                                  style: getTextStyle2(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Obx(() {
                          final selected =
                              controller.selectedPaidByFriend.value;

                          // If nothing has been selected yet, default to current user
                          final shouldShowCheck = selected.isNotEmpty
                              ? selected == friend
                              : isCurrentUser;

                          return shouldShowCheck
                              ? const Icon(Icons.check)
                              : const SizedBox.shrink();
                        }),
                      ],
                    ),
                  ),
                );
              },
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
