import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';

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
        height: MediaQuery.of(context).size.height / 7.8,
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
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.green,
                  child: Center(
                    child: Text(
                      trip.name.isNotEmpty
                          ? trip.name[0].toUpperCase()
                          : '', // First letter of trip name
                      style: getTextStyle2(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textWhite,
                      ),
                    ),
                  ),
                ).marginOnly(top: 16),
              ],
            ).marginOnly(left: 20, right: 20),
            Text(
              trip.date, // Use the trip's date
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textGrey,
              ),
            ).marginOnly(left: 20, top: 8),
          ],
        ),
      )
    );
  }
}
