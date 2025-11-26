import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';

import 'package:teddy_5618/features/group_screen/widgets/group_edit_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_filter_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_search_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_add_new_friend.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_upper_navbar.dart';
import 'package:teddy_5618/features/group_screen/widgets/trip_text.dart';

class GroupTripHomeScreen extends StatelessWidget {
  final Trip trip;

  const GroupTripHomeScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use Get.put to ensure TripController is available, or make it optional
    final tripController = Get.put(TripController());

    // ✅ Get TripTextController with unique tag per group ID to avoid data mixing
    final String controllerTag = trip.id ?? 'default';
    final tripTextController =
        Get.isRegistered<TripTextController>(tag: controllerTag)
        ? Get.find<TripTextController>(tag: controllerTag)
        : Get.put(TripTextController(), tag: controllerTag);

    // ✅ Set the group ID immediately when the screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (trip.id != null && trip.id!.isNotEmpty) {
        // debugPrint(
        //   '🎯 [GROUP_TRIP_HOME] Setting TripTextController group ID: ${trip.id}',
        // );
        tripTextController.setGroupId(trip.id!);
        // ✅ Refresh data to ensure real-time updates
        tripTextController.refreshCurrentData();
      }
    });

    return DefaultTabController(
      // ✅ Moved here
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => Get.to(BottomNavbarView()),
            child: Icon(
              CupertinoIcons.back,
              size: MediaQuery.of(context).size.height / 25,
            ),
          ),
          actions: [
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.to(GroupSearchScreen(groupId: trip.id));
                  },
                  child: const Icon(Icons.search),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          // Set the current group for editing
                          tripController.setCurrentGroup(
                            trip.id ?? '',
                            trip.name,
                          );
                          tripController.focusEdit();
                        });
                        return const GroupEditScreen();
                      },
                    );
                  },
                  child: Image.asset(
                    IconPath.editIcon,
                    scale: 4,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.backgroundDark,
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      builder: (context) => GroupFilterScreen(groupId: trip.id),
                    );
                  },
                  // child: Image.asset(
                  //   IconPath.filter,
                  //   height: 18,
                  //   width: 18,
                  //   color: isDark
                  //       ? AppColors.textWhite
                  //       : AppColors.backgroundDark,
                  // ),
                  child: Icon(
                    Icons.filter_list,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    size: 28.sp,
                  ),
                ),
                const SizedBox(width: 15),
              ],
            ),
          ],
        ),

        body: Container(
          color: isDark ? Color(0xFF262626) : AppColors.textWhite,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Obx(() {
                // Find the current trip in the controller's trips list to get updated name
                final currentTrip = tripController.trips.firstWhere(
                  (t) => t.id == trip.id,
                  orElse: () => trip, // Fallback to original trip if not found
                );
                // Debug: show both the passed-in trip name and the controller-resolved name
                debugPrint(
                  '🔍 [GROUP_TRIP_HOME] Passed trip.name: "${trip.name}", controller currentTrip.name: "${currentTrip.name}"',
                );
                return Text(
                  currentTrip.name,
                  style: getTextStyle2(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textWhite
                        : AppColors.backgroundDark,
                  ),
                ).marginOnly(left: 24);
              }),
              const SizedBox(height: 15),

              TripText(groupId: trip.id).marginOnly(left: 24),
              const SizedBox(height: 12),
              GroupTripAddNewFriend(trip: trip, controllerTag: controllerTag),
              const SizedBox(height: 12),
              // ✅ Make tab bar and view take remaining space
              Expanded(child: GroupTripUpperNavbar(trip: trip)),
            ],
          ),
        ),
      ),
    );
  }
}
