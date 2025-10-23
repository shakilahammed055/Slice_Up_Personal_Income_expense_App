import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';

// Import your controllers and models
import 'package:teddy_5618/features/group_screen/controller/group_screen_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/create_trip_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/hire_assistant_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/my_friends_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/show_assistan1.dart';
import 'package:teddy_5618/features/group_screen/widgets/trip_box.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groupScreenController = Get.put(GroupScreenController());
    final tripController = Get.put(TripController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.textWhite,
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            CupertinoIcons.back,
            size: MediaQuery.of(context).size.height / 25,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showMaterialModalBottomSheet(
                context: context,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
                ),
                builder: (context) => MyFriendsBottomsheet(),
              );
            },
            child: Icon(
              Icons.group_outlined,
              color: isDark ? AppColors.textWhite : const Color(0xff141414),
              size: MediaQuery.of(context).size.height / 30,
            ).marginOnly(right: 20),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    'Our'.tr,
                    style: getTextStyle2(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Spending'.tr,
                    style: getTextStyle2(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.textPrimary,
                    ),
                  ),
                ],
              ).marginSymmetric(horizontal: 24),
              const SizedBox(height: 38),

              /// Assistant Box or Add Button
              Obx(() {
                return groupScreenController.selectedAssistant.value.isNotEmpty
                    ? Container(
                        width: MediaQuery.of(context).size.width,
                        // height: 88.h,
                        decoration: ShapeDecoration(
                          color: isDark
                              ? AppColors.deepGrey
                              : AppColors
                                    .lightGreyContainer, // ✅ kept your color
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          // center children vertically
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Text area (allow wrapping)
                            Expanded(
                              child: Obx(
                                () => Text(
                                  tripController.currentAiSummary,
                                  softWrap: true,
                                  overflow: TextOverflow.visible,
                                  style: getTextStyle2(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ).marginOnly(bottom: 10),
                              ),
                            ),

                            // const SizedBox(width: 8),

                            // const SizedBox(width: 8),

                            // Assistant image with overlayed share icon
                          
                            Container(
                               width: 60,
                               height: 60,
                               decoration: BoxDecoration(
                                 borderRadius: BorderRadius.circular(8),
                               ),
                               child: Image.asset(
                                 groupScreenController
                                             .selectedAssistant
                                             .value ==
                                         'supportive'.tr
                                     ? IconPath.chiwawa1
                                     : IconPath.rabbit1,
                                 fit: BoxFit.contain,
                               ),
                             )
                          ],
                        ).marginOnly(left: 16, right: 16, top: 10),
                      )
                    : GestureDetector(
                        onTap: () {
                          if (!Get.isDialogOpen!) {
                            Get.dialog(const ShowAssistant1());
                          }
                        },
                        child: Container(
                          height: 88.h,
                          decoration: ShapeDecoration(
                            color: isDark
                                ? AppColors.deepGrey
                                : AppColors
                                      .lightGreyContainer, // ✅ kept your color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Add assistant'.tr,
                                style: getTextStyle2(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
              }).marginSymmetric(horizontal: 24),

              const SizedBox(height: 16),

              /// Conditional "Invite Friends" Container
              Obx(
                () => tripController.trips.isEmpty
                    ? GestureDetector(
                        onTap: () {
                          showMaterialModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(34),
                              ),
                            ),
                            builder: (context) => MyFriendsBottomsheet(),
                          );
                        },
                        child: Container(
                          height: 88.h,
                          decoration: ShapeDecoration(
                            color: isDark
                                ? AppColors.deepGrey
                                : AppColors
                                      .lightGreyContainer, // ✅ kept your color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.person_add_alt,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.textPrimary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Invite friends'.tr,
                                style: getTextStyle2(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ).marginSymmetric(horizontal: 24),

              Obx(
                () => tripController.trips.isEmpty
                    ? const SizedBox(height: 16)
                    : const SizedBox.shrink(),
              ),

              /// Trip list
              Obx(
                () => tripController.trips.isEmpty
                    ? const Spacer()
                    : Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: tripController.trips.length,
                          itemBuilder: (context, index) {
                            final trip = tripController.trips[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                                left: 24,
                                right: 24,
                              ),
                              child: TripBox(trip: trip),
                            );
                          },
                        ),
                      ),
              ),
              const SizedBox(height: 80),
            ],
          ),

          /// Floating Action Button
          Positioned(
            bottom: 120.h,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: AppColors.green, // ✅ kept your green logic
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                ),
                onPressed: () {
                  if (tripController.trips.length >= 2) {
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      builder: (context) => HireAssistantBottomsheet(),
                    );
                  } else {
                    showMaterialModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(34),
                        ),
                      ),
                      builder: (context) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          tripController.focusCreate();
                        });
                        return const CreateTripBottomsheet();
                      },
                    );
                  }
                },
                child: Icon(
                  Icons.add,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  size: 32,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
