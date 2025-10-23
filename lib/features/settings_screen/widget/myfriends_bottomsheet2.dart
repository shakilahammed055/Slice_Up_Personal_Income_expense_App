// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/app_texts.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/widgets/add_friends_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';
import 'package:teddy_5618/features/settings_screen/controller/my_friend_bottom_controller2.dart';

// MyFriendsBottomsheet2 remains a StatelessWidget as its state is managed by the controller.
class MyFriendsBottomsheet2 extends StatelessWidget {
  const MyFriendsBottomsheet2({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the controller and make it available.
    final MyFriendBottomController2 controller = Get.put(
      MyFriendBottomController2(),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Obx(() {
        double baseHeight = MediaQuery.of(context).size.height * 0.30;
        double extraHeight = controller.myFriends.isEmpty
            ? 0
            : (controller.myFriends.length * 56.0);
        double totalHeight = (baseHeight + extraHeight).clamp(
          0,
          MediaQuery.of(context).size.height * 0.85,
        );
        return Container(
          height: totalHeight,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 32),
                    Text(
                      'My friends'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.close, size: 24),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 15,
                color: isDark
                    ? AppColors.deepGrey
                    : AppColors.lightGreyContainer,
                child: Row(
                  children: [
                    Text(
                      AppText.addNew,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        // Use `await` to get the result from the `AddFriendsBottomsheet`.
                        final result = await showMaterialModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                          ),
                          builder: (context) => const AddFriendsBottomsheet(),
                        );
                        // If a list of friends is returned, update the controller's list.
                        if (result != null && result is List<String>) {
                          await controller.addFriends(result);
                        }
                      },
                      child: const Icon(
                        Icons.add,
                        size: 24,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
                      ),
                    ),
                  ],
                ).marginSymmetric(horizontal: 24),
              ),
              Obx(() {
                final friendsList = controller.myFriends;
                if (friendsList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 48.0),
                    child: Center(
                      child: Text(
                        'You haven’t added any friends yet'.tr,
                        style: getTextStyle2(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: friendsList.length,
                    itemBuilder: (context, index) {
                      final friend = friendsList[index];
                      final String friendNameBase =
                          (friend.name.isNotEmpty
                                  ? friend.name
                                  : friend.email.split('@')[0])
                              .toString()
                              .capitalizeFirst ??
                          'Friend';
                      final String friendNameDisplay =
                          friendNameBase.length > 20
                          ? '${friendNameBase.substring(0, 20)}...'
                          : friendNameBase;
                      final String avatarLetter = friendNameBase.isNotEmpty
                          ? friendNameBase[0].toUpperCase()
                          : 'A';
                      final String emailDisplay = friend.email.length > 40
                          ? '${friend.email.substring(0, 40)}...'
                          : friend.email;

                      return Container(
                        height: MediaQuery.of(context).size.height / 15,
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
                            CircleAvatar(
                              radius: 15,
                              backgroundColor: AppColors.readishred,
                              child: Center(
                                child: Text(
                                  avatarLetter,
                                  style: getTextStyle2(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textWhite,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery.of(context).size.width / 40,
                            ),
                            Expanded(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Flexible(
                                    child: Text(
                                      friendNameDisplay,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: getTextStyle2(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      emailDisplay,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: getTextStyle2(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/delete.svg',
                                height: 17.h,
                                width: 15.w,
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                              ),
                              onPressed: () {
                                showCupertinoDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      ConfirmationDialog(
                                        title:
                                            'Are you sure you want to delete them?'
                                                .tr,
                                        content:
                                            'You won’t be able to undo this.'
                                                .tr,
                                        button1: 'No'.tr,
                                        button2: 'Yes'.tr,
                                        onConfirm: () {
                                          controller.removeFriend(friend.email);
                                        },
                                      ),
                                );
                              },
                            ),
                          ],
                        ).marginOnly(left: 24, right: 10),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
