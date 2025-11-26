import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_add_new_friend_bottom.dart';

class GroupTripAddNewFriend extends StatelessWidget {
  const GroupTripAddNewFriend({
    super.key,
    required this.trip,
    this.controllerTag = 'groupTripSpent',
  });

  final Trip trip;
  final String controllerTag;

  @override
  Widget build(BuildContext context) {
    // Use the externally provided controllerTag so parent & bottom sheet
    // share the same GetX controller instance for this trip.
    final String tag = controllerTag.isNotEmpty
        ? controllerTag
        : (trip.id ?? 'default');
    final GroupTripAddNewFriendController friendSelectionController =
        Get.isRegistered<GroupTripAddNewFriendController>(tag: tag)
        ? Get.find<GroupTripAddNewFriendController>(tag: tag)
        : Get.put(GroupTripAddNewFriendController(), tag: tag);

    // Set the current trip for persistence
    friendSelectionController.setCurrentTrip(trip.name, tripId: trip.id);

    // Define the maximum number of friend avatars to display before the '+' icon
    const int maxVisibleFriendsAvatars = 50; // Adjust this number as needed

    return Row(
      children: [
        Obx(() {
          final groupMembers = friendSelectionController.groupMembers;
          List<Widget> avatars = [];

          // Determine how many member avatars to actually render based on the limit
          final int numMembersToRender =
              groupMembers.length > maxVisibleFriendsAvatars
              ? maxVisibleFriendsAvatars
              : groupMembers.length;

          // Start position for avatars
          double currentLeftPosition = 0.0;

          // 2. Add CircleAvatars for each group member up to the determined limit
          for (int i = 0; i < numMembersToRender; i++) {
            final member = groupMembers[i];
            final String initial = member['initial'] ?? '?';

            avatars.add(
              Positioned(
                left: currentLeftPosition,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textWhite, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 0.1,
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: friendSelectionController.getAvatarColor(
                      i,
                    ), // Dynamic color
                    child: Center(
                      child: Text(
                        initial,
                        style: getTextStyle2(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
            currentLeftPosition += 27.0; // Increment for the next avatar
          }

          // 3. Add the Plus Icon Circle
          avatars.add(
            Positioned(
              left:
                  currentLeftPosition, // Place after all rendered avatars (trip + friends)
              child: GestureDetector(
                onTap: () async {
                  // Validate trip ID before showing bottom sheet
                  if (trip.id == null || trip.id!.isEmpty) {
                    debugPrint(
                      "❌ Cannot add friends: Trip ID is null or empty for trip: '${trip.name}'",
                    );
                    Get.snackbar(
                      'Error',
                      'This trip is invalid. Please try recreating the trip or contact support.',
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                      duration: Duration(seconds: 4),
                    );

                    // Show additional help message
                    debugPrint(
                      "� Suggestion: Try refreshing the trips list or creating a new trip",
                    );

                    return;
                  }

                  debugPrint(
                    "🎯 Opening add friends for trip: '${trip.name}' with ID: '${trip.id}'",
                  );

                  // Show the bottom sheet and wait for result
                  await showMaterialModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(34),
                      ),
                    ),
                    builder: (context) =>
                        GroupTripAddNewFriendBottom(groupId: tag),
                  );
                  // Refresh the friends data after the bottom sheet is closed
                  friendSelectionController.refreshFriends();
                },
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.textWhite, width: 2.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        spreadRadius: 0.1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 13,
                    backgroundColor: Colors.grey[400], // Gray for "+"
                    child: const Center(
                      child: Icon(Icons.add, size: 16, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
          );

          // Calculate the total width needed for the Stack.
          // It's the final currentLeftPosition + the width of the last avatar (radius * 2)
          double stackWidth = currentLeftPosition + (13 * 2);

          return SizedBox(
            width: stackWidth,
            height: 26, // Height of the avatars (radius 13 * 2)
            child: Stack(clipBehavior: Clip.none, children: avatars),
          );
        }),
      ],
    ).marginOnly(left: 20); // This margin applies to the entire Row
  }
}
