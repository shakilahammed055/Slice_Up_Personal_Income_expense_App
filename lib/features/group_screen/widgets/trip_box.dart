import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/trip_text.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';

// Import your Trip model

class TripBox extends StatelessWidget {
  final Trip trip; // Now accepts a Trip object
  final String controllerTag;

  const TripBox({
    super.key,
    required this.trip, // Make trip a required parameter
    this.controllerTag = 'groupTripSpent',
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        Get.to(
          () => GroupTripHomeScreen(
            trip: trip,
          ), // Navigate to TripDetailsScreen with the trip object
          transition: Transition.rightToLeft,
        );
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 6.8,
        // width: MediaQuery.of(context).size.width / 1.2,
        decoration: BoxDecoration(
          borderRadius: BorderRadiusDirectional.all(Radius.circular(14)),
          color: isDark ? AppColors.surfaceDark : AppColors.textWhite,
          // color: AppColors.textWhite,
          boxShadow: [
            BoxShadow(
              color: Color(0x1A000000),
              spreadRadius: 3,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  trip.name, // Use the trip's name
                  style: getTextStyle2(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,

                    color: isDark ? AppColors.textWhite : AppColors.textPrimary,
                    // color: AppColors.textPrimary,
                  ),
                ).marginOnly(top: 16),

                // This SizedBox width might need adjustment based on the trip name length
                // SizedBox(width: MediaQuery.of(context).size.width / 2.7),
                Spacer(),
                // Render stacked avatars from group members
                Obx(() {
                  final String tag = trip.id ?? 'default';
                  final friendSelectionController =
                      Get.isRegistered<GroupTripAddNewFriendController>(
                        tag: tag,
                      )
                      ? Get.find<GroupTripAddNewFriendController>(tag: tag)
                      : Get.put(GroupTripAddNewFriendController(), tag: tag);

                  // Ensure controller knows current trip so it can fetch members
                  friendSelectionController.setCurrentTrip(
                    trip.name,
                    tripId: trip.id,
                  );

                  // Use groupMembers directly - already includes owner with isOwner: true
                  final groupMembers = friendSelectionController.groupMembers;

                  List<Widget> avatars = [];
                  double left = 0.0;
                  const double radius = 12.0;
                  const double step = 20.0;

                  // Display up to 5 group members
                  for (int i = 0; i < groupMembers.length && i < 5; i++) {
                    final member = groupMembers[i];
                    final String initial = member['initial'] ?? '?';
                    final Color bg = friendSelectionController.getAvatarColor(
                      i,
                    );

                    avatars.add(
                      Positioned(
                        left: left,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : AppColors.textWhite,
                              width: 2.0,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: radius,
                            backgroundColor: bg,
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
                    left += step;
                  }

                  final double stackWidth = left + radius; // approximate
                  return SizedBox(
                    width: stackWidth,
                    height: radius * 2,
                    child: Stack(clipBehavior: Clip.none, children: avatars),
                  ).marginOnly(top: 16);
                }),
              ],
            ).marginOnly(left: 20, right: 15),
            Text(
              trip.date, // Use the trip's date
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ).marginOnly(left: 20, top: 5),
            Align(
              alignment: Alignment.centerRight,
              child: TripText(
                type: TripTextType.expenses,
                groupId: trip.id,
              ).marginOnly(right: 20),
            ),
            SizedBox(height: 15),
          ],
        ),
      ),
    );
  }
}
