import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_edit_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_filter_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_search_screen.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_add_new_friend.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_upper_navbar.dart';

class GroupTripHomeScreen extends StatelessWidget {
  final Trip trip;

  const GroupTripHomeScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripController = Get.find<TripController>();

    return DefaultTabController(
      // ✅ Moved here
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: isDark ? Color(0xFF262626) : AppColors.textWhite,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => Get.back(),
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
                    Get.to(GroupSearchScreen());
                  },
                  child: const Icon(Icons.search),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: () {
                    // showMaterialModalBottomSheet(
                    //   context: context,
                    //   shape: const RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.vertical(
                    //       top: Radius.circular(34),
                    //     ),
                    //   ),
                    //   builder: (context) => GroupEditScreen(),
                    // );
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      builder: (context) => GroupFilterScreen(),
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
              Text(
                trip.name,
                style: getTextStyle2(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.textWhite
                      : AppColors.backgroundDark,
                ),
              ).marginOnly(left: 24),
              const SizedBox(height: 15),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'You’ll pay ',
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF828282),
                      ), // or any color you want
                    ),
                    TextSpan(
                      text: 'US\$12,000 + S\$200',
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFFEF5C00),
                      ), // or any other color
                    ),
                  ],
                ),
              ).marginOnly(left: 24),
              const SizedBox(height: 2),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'You’ll collect',
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF828282),
                      ), // or any color you want
                    ),
                    TextSpan(
                      text: ' US\$120',
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF00D460),
                      ), // or any other color
                    ),
                  ],
                ),
              ).marginOnly(left: 24),
              const SizedBox(height: 12),
              GroupTripAddNewFriend(trip: trip),
              const SizedBox(height: 12),
              // ✅ Make tab bar and view take remaining space
              Expanded(child: GroupTripUpperNavbar()),
            ],
          ),
        ),
      ),
    );
  }
}
