import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_add_new_friend_bottom.dart';

class GroupTripAddNewFriend extends StatelessWidget {
  const GroupTripAddNewFriend({super.key, required this.trip});

  final Trip trip;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final GroupTripAddNewFriendController friendSelectionController = Get.put(
      GroupTripAddNewFriendController(),
    );

    // Set the current trip for persistence
    friendSelectionController.setCurrentTrip(trip.name, tripId: trip.id);

    // Define the maximum number of friend avatars to display before the '+' icon
    const int maxVisibleFriendsAvatars = 99; // Adjust this number as needed

    return Row(
      children: [
        Obx(() {
          final selectedFriends = friendSelectionController.selectedFriendNames;
          List<Widget> avatars = [];

          // 1. Add the Trip's CircleAvatar first
          if (trip.name.isNotEmpty) {
            avatars.add(
              Positioned(
                left: 0, // It's the first avatar, so its position is 0
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.textWhite,
                      // color: AppColors.textWhite,
                      width: 2.0,
                    ),
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
                    backgroundColor: AppColors.green,
                    child: Center(
                      child: Text(
                        trip.name[0].toUpperCase(),
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
          }

          // Determine how many *friend* avatars to actually render based on the limit
          final int numFriendAvatarsToRender =
              selectedFriends.length > maxVisibleFriendsAvatars
              ? maxVisibleFriendsAvatars
              : selectedFriends.length;

          // Offset for friend avatars, starting after the trip avatar
          // If trip.name is empty, the offset for friends starts from 0 (no trip avatar)
          // Otherwise, it starts after the trip avatar's width (2*radius + overlap)
          double currentLeftPosition = (trip.name.isNotEmpty ? 27.0 : 0.0);

          // 2. Add CircleAvatars for each selected friend up to the determined limit
          for (int i = 0; i < numFriendAvatarsToRender; i++) {
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
                        selectedFriends[i][0]
                            .toUpperCase(), // First letter of friend's name
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
                        GroupTripAddNewFriendBottom(groupId: trip.id!),
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
