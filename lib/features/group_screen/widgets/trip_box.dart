import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/trip_text.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';

// Import your Trip model

class TripBox extends StatelessWidget {
  final Trip trip; // Now accepts a Trip object

  const TripBox({
    super.key,
    required this.trip, // Make trip a required parameter
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
        // height: MediaQuery.of(context).size.height / 7.8,
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
                // Render stacked avatars (owner initial + friend avatars) without the add '+' avatar
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

                  String ownerInitial = '';
                  Color ownerBgColor = friendSelectionController.getAvatarColor(
                    0,
                  );
                  try {
                    if (Get.isRegistered<GroupTripSpentController>()) {
                      final spentCtrl = Get.find<GroupTripSpentController>();
                      final ownerEmail = spentCtrl.groupOwnerEmail.value;
                      if (ownerEmail.isNotEmpty) {
                        final localPart = ownerEmail.split('@')[0];
                        if (localPart.isNotEmpty) {
                          ownerInitial = localPart[0].toUpperCase();
                        }
                      }
                    }
                  } catch (_) {}

                  // pick deterministic color index based on trip id when available
                  try {
                    if (trip.id != null && trip.id!.isNotEmpty) {
                      final idx =
                          trip.id!.hashCode.abs() %
                          friendSelectionController.avatarColors.length;
                      ownerBgColor = friendSelectionController.getAvatarColor(
                        idx,
                      );
                    }
                  } catch (_) {}

                  final selectedFriends =
                      friendSelectionController.selectedFriendNames;

                  // Build combined list: owner (if exists) + friends
                  final List<String> members = [];
                  if (ownerInitial.isNotEmpty) members.add(ownerInitial);
                  for (var f in selectedFriends) {
                    if (f.isNotEmpty) members.add(f);
                  }

                  List<Widget> avatars = [];
                  double left = 0.0;
                  const double radius = 12.0;
                  const double step = 20.0;

                  for (int i = 0; i < members.length && i < 5; i++) {
                    final member = members[i];
                    final String initial = member.isNotEmpty
                        ? member[0].toUpperCase()
                        : '?';
                    final Color bg = (i == 0 && ownerInitial.isNotEmpty)
                        ? ownerBgColor
                        : friendSelectionController.getAvatarColor(i + 1);

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
            ).marginOnly(left: 20, right: 10),
            Text(
              trip.date, // Use the trip's date
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ).marginOnly(left: 20, top: 8),
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
