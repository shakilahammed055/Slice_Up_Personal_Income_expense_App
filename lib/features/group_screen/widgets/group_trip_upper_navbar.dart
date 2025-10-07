// import 'package:flutter/material.dart';
// import 'package:get/get_utils/src/extensions/internacionalization.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/group_screen/screen/expenses_page_screen.dart';
// import 'package:teddy_5618/features/group_screen/screen/sliceup_page_screen.dart';
// import 'package:teddy_5618/features/group_screen/screen/status_page_screen.dart';
// import 'package:teddy_5618/features/group_screen/model/trip_model.dart';

// class GroupTripUpperNavbar extends StatelessWidget {
//   final Trip trip; // Add trip parameter

//   const GroupTripUpperNavbar({super.key, required this.trip});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Column(
//       children: [
//         TabBar(
//           dividerColor: Colors.transparent,
//           indicatorColor: isDark ? AppColors.textWhite : AppColors.black,
//           unselectedLabelColor: Colors.transparent,
//           indicatorWeight: 2,
//           indicator: UnderlineTabIndicator(
//             borderSide: BorderSide(
//               color: isDark ? AppColors.textWhite : AppColors.black,
//               width: 2.0,
//             ),
//             insets: const EdgeInsets.symmetric(horizontal: 80.0),
//           ),
//           tabs: [
//             Tab(
//               child: Text(
//                 "Expenses".tr,
//                 style: getTextStyle2(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                   color: isDark ? AppColors.textWhite : AppColors.black,
//                 ),
//               ),
//             ),
//             Tab(
//               child: Text(
//                 "Slice up".tr,
//                 style: getTextStyle2(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                   color: isDark ? AppColors.textWhite : AppColors.black,
//                 ),
//               ),
//             ),
//             Tab(
//               child: Text(
//                 "Status".tr,
//                 style: getTextStyle2(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w400,
//                   color: isDark ? AppColors.textWhite : AppColors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         // ✅ Expand TabBarView inside parent Expanded
//         Expanded(
//           child: TabBarView(
//             children: [
//               ExpensesPageScreen(trip: trip), // Pass trip to ExpensesPageScreen
//               SliceupPageScreen(trip: trip), // Pass trip to SliceupPageScreen
//               StatusPageScreen(trip: trip), // Pass trip to StatusPageScreen
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/screen/expenses_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/sliceup_page_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/status_page_screen.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/controller/trip_text_controller.dart';

class GroupTripUpperNavbar extends StatelessWidget {
  final Trip trip; // Add trip parameter

  const GroupTripUpperNavbar({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        TabBar(
          dividerColor: Colors.transparent,
          indicatorColor: isDark ? AppColors.textWhite : AppColors.black,
          unselectedLabelColor: Colors.transparent,
          indicatorWeight: 2,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(
              color: isDark ? AppColors.textWhite : AppColors.black,
              width: 2.0,
            ),
            insets: const EdgeInsets.symmetric(horizontal: 80.0),
          ),
          onTap: (index) {
            // Update trip text type based on selected tab
            final controller = Get.find<TripTextController>();
            switch (index) {
              case 0:
                controller.setTripTextType(TripTextType.expenses);
                break;
              case 1:
                controller.setTripTextType(TripTextType.sliceup);
                break;
              case 2:
                controller.setTripTextType(TripTextType.status);
                break;
            }
          },
          tabs: [
            Tab(
              child: Text(
                "Expenses".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Slice up".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
            Tab(
              child: Text(
                "Status".tr,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
              ),
            ),
          ],
        ),
        // ✅ Expand TabBarView inside parent Expanded
        Expanded(
          child: TabBarView(
            children: [
              ExpensesPageScreen(trip: trip), // Pass trip to ExpensesPageScreen
              SliceupPageScreen(
                trip: trip,
                groupId: trip.id,
              ), // Pass both trip and groupId
              StatusPageScreen(trip: trip), // Pass trip to StatusPageScreen
            ],
          ),
        ),
      ],
    );
  }
}
