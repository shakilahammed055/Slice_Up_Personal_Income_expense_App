import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';

import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/my_friend_bottom_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/add_friends_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';

class MyFriendsBottomsheet extends StatelessWidget {
  const MyFriendsBottomsheet({super.key});

  @override
  Widget build(BuildContext context) {
    final MyFriendBottomController controller = Get.put(
      MyFriendBottomController(),
    );
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Obx(() {
        double baseHeight = MediaQuery.of(context).size.height * 0.30;
        double extraHeight = controller.friends.isEmpty
            ? 0
            : (controller.friends.length * 56.0);
        double totalHeight = (baseHeight + extraHeight).clamp(
          0,
          MediaQuery.of(context).size.height * 0.85,
        );

        return Container(
          height: totalHeight,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF262626) : AppColors.textWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(),
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
                      'Add new'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFAAAAAA),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () async {
                        final result = await showMaterialModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(34),
                            ),
                          ),
                          builder: (context) => const AddFriendsBottomsheet(),
                        );
                        if (result != null) {
                          controller.fetchFriends();
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
                if (controller.isLoading.value) {
                  return const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final friendsList = controller.friends;
                if (friendsList.isEmpty) {
                  return Expanded(
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
                                      // overflow: TextOverflow.ellipsis,
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
                                      // overflow: TextOverflow.ellipsis,
                                      style: getTextStyle2(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textGrey,
                                      ),
                                    ),
                                  ),
                                  // const Spacer(),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: SvgPicture.asset(
                                'assets/icons/delete.svg',
                                height: 17.h,
                                width: 15.w,
                                // ignore: deprecated_member_use
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
