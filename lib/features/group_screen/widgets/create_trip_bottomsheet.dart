import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart'; // Adjust path if necessary

class CreateTripBottomsheet extends StatelessWidget {
  const CreateTripBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the instance of TripController
    // It's usually good practice to put the controller in GroupScreen and use Get.find() here.
    // However, for simplicity, if it's only created when this bottom sheet is shown, Get.put() works.
    // If GroupScreen already has a TripController, use Get.find<TripController>() here.
    final TripController tripController = Get.find<TripController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
         padding: MediaQuery.of(context).viewInsets, 
        child: Container(
          clipBehavior: Clip.antiAlias,
          // height: MediaQuery.of(context).size.height * 0.35, // 40% of screen
          // padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            // color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
               mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(height: 32, width: 32),
                    Text(
                      'Group title'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                          color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 25),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                // Dynamic margin for close icon
                const SizedBox(height: 32),
                Container(
                  height: 48.h,
                  width: MediaQuery.of(context).size.width, // Use full width
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
                    
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.backgroundDark,
                    
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: tripController
                          .tripNameController, // Link to the controller's text field
                     focusNode: tripController.createTripFocusNode,  
                      style: getTextStyle2(
                        // color: AppColors.backgroundDark,
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.transparent,
                        hintText: 'Create a trip'.tr,
                        hintStyle: getTextStyle2(
                          color: AppColors.textGrey,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ).marginOnly(left: 16),
                  ),
                ).marginSymmetric(horizontal: 24),
                const SizedBox(height: 40),
                // Create Button
                GestureDetector(
                  onTap: () {
                    tripController
                        .addTrip(); // Call the addTrip method in the controller
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    height: 52,
                    // padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Create'.tr,
                      style: getTextStyle2(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                    
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ).marginSymmetric(horizontal: 24),
                SizedBox(height: 12.h,)
              ],
            ),
          ),
        ),
      ),
    );
  }
}
