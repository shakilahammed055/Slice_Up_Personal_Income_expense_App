import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_add_new_friend_bottom_controller.dart';

class GroupTripAddNewFriendBottom extends StatelessWidget {
  final String groupId;
  const GroupTripAddNewFriendBottom({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    // Try to find existing controller, otherwise create new one
    late final GroupTripAddNewFriendBottomController controller;
    try {
      controller = Get.find<GroupTripAddNewFriendBottomController>(
        tag: groupId,
      );
    } catch (e) {
      // Controller doesn't exist, create it
      controller = Get.put(
        GroupTripAddNewFriendBottomController(groupId: groupId),
        tag: groupId,
      );
    }

    // Ensure friends are fetched/refreshed when this bottom sheet is displayed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.friends.isEmpty) {
        debugPrint('🔄 [GroupTripAddNewFriendBottom] Refreshing friends list');
        controller.fetchFriendsFromAPI();
      }
    });

    // Get the context for dark mode detection
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      top: false,
      child: Obx(() {
        double baseHeight = MediaQuery.of(context).size.height * 0.30;
        double extraHeight = controller.friends.isEmpty
            ? 0
            : (controller.friends.length * 40);
        double totalHeight = (baseHeight + extraHeight).clamp(
          0,
          MediaQuery.of(context).size.height * 0.85,
        );
        return Container(
          height: totalHeight,
          // height: MediaQuery.of(context).size.height * 0.30,

          // padding: EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
            // color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SizedBox(width: 32),
                  IconButton(
                    icon: const Icon(CupertinoIcons.back, size: 30),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  Text(
                    'My friends'.tr,
                    style: getTextStyle2(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textWhite : AppColors.black,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.all(0),
                    icon: const Icon(Icons.close, size: 25),
                    onPressed: () => Get.back(),
                  ),
                ],
              ).marginSymmetric(vertical: 3),

              // Container(
              //   height: MediaQuery.of(context).size.height / 15,
              //   color: isDark
              //       ? AppColors.deepGrey
              //       : AppColors.lightGreyContainer,

              //   child: Row(
              //     children: [
              //       Text(
              //         'Add new'.tr,
              //         style: getTextStyle2(
              //           fontSize: 16,
              //           fontWeight: FontWeight.w500,
              //           color: Color(0xFFAAAAAA),
              //         ),
              //       ),
              //       Spacer(),
              //       GestureDetector(
              //         onTap: () {
              //           controller.addFriend();
              //         },
              //         child: const Icon(
              //           Icons.add,
              //           size: 24,
              //           shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
              //         ),
              //       ),
              //     ],
              //   ).marginSymmetric(horizontal: 24),
              // ),
              Expanded(
                child: Obx(() {
                  // Show loading indicator while fetching friends
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.green,
                        ),
                      ),
                    );
                  }

                  // Show message if no friends available
                  if (controller.friends.isEmpty) {
                    return Center(
                      child: Text(
                        'No friends available.\nTap + to add friends from your list.'
                            .tr,
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: isDark ? AppColors.textWhite : AppColors.black,
                        ),
                      ),
                    );
                  }

                  // Show friends list
                  return ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: controller.friends.length,
                    itemBuilder: (context, index) {
                      final friend = controller.friends[index];
                      final RxBool friendIsSelected = friend['isSelected'];

                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : AppColors.borderGrey,
                              width: 0.7,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? AppColors.textWhite.withValues(
                                            alpha: 0.2,
                                          )
                                        : Colors.black.withValues(alpha: 0.2),
                                    spreadRadius: 0.1,
                                    blurRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.readishred,
                                child: Center(
                                  child: Text(
                                    friend['name'][0].toUpperCase(),
                                    style: getTextStyle2(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 48,
                            ),
                            Text(
                              friend['name'],
                              style: getTextStyle2(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                            ),
                            Spacer(),
                            Obx(
                              () => GestureDetector(
                                onTap: () {
                                  controller.toggleFriendSelection(index);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    shape: BoxShape.rectangle,
                                    color: friendIsSelected.value
                                        ? Colors.black
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: AppColors.borderGrey,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.done,
                                    size: 15,
                                    color: friendIsSelected.value
                                        ? Colors.white
                                        : Colors.transparent,
                                    shadows: const [
                                      Shadow(
                                        blurRadius: 20,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).marginSymmetric(horizontal: 22, vertical: 10),
                      );
                    },
                  );
                }),
              ),
              //  const SizedBox(height: 27),
              //  const SizedBox(height: 27),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Material(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: () {
                      // Debug print
                      controller.confirmAddFriends(context);
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: 52,
                      alignment: Alignment.center,
                      child: Text(
                        'Add'.tr,
                        style: getTextStyle2(
                          color: isDark
                              ? AppColors.textWhite
                              : AppColors.backgroundDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }
}
