import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/settings_screen/controller/add_friend_bottom_controller2.dart';

class AddFriendsBottomsheet2 extends StatelessWidget {
  const AddFriendsBottomsheet2({super.key});

  @override
  Widget build(BuildContext context) {
    final AddFriendsController2 controller = Get.put(AddFriendsController2());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
    padding: MediaQuery.of(context).viewInsets, 
        child: Container(
          // height: MediaQuery.of(context).size.height * 0.90,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
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
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Image.asset(IconPath.leftIcon, scale: 4),
                    ),
                    Text(
                       'Add friends'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(
                        Icons.close,
                        size: 24,
                        shadows: [Shadow(blurRadius: 2, color: Colors.black38)],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Obx(
                  () => Container(
                    height: controller.addedFriends.isEmpty
                        ? MediaQuery.of(context).size.height / 10
                        : null,
                    width: MediaQuery.of(context).size.width,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: isDark
                          ? AppColors.black
                          : AppColors.lightGreyContainer,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: controller.addedFriends.map((email) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: isDark
                                    ? AppColors.backgroundDark
                                    : AppColors.textWhite,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    email,
                                    style: getTextStyle2(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => controller.removeFriend(email),
                                    child: const Icon(
                                      Icons.close,
                                      size: 20,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 1.0,
                                          color: Colors.black,
                                          offset: Offset(0.5, 0.5),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller.emailTextController,
                                focusNode: controller.emailFocusNode,
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.backgroundDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: Colors.transparent,
                                  hintText: 'Add Friends Email...'.tr,
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
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width / 10),
                            GestureDetector(
                              onTap: () => controller.addFriend(),
                              child: Container(
                                height: MediaQuery.of(context).size.height / 30,
                                // width: MediaQuery.of(context).size.width / 7,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? AppColors.greylightbardeepcolor
                                      : AppColors.greylightbarcolor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.add, size: 20),
                                    Text(
                                      'Add'.tr,
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.backgroundDark,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ).marginSymmetric(horizontal: 5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).marginSymmetric(horizontal: 12),
                ),
                const SizedBox(height: 34),
                GestureDetector(
                  onTap: () {
                    final friendsToInvite = controller.getFriendsToInvite();
                    
                    if (friendsToInvite.isEmpty) {
                      Get.snackbar(
                        'No Emails Added'.tr,
                        'Please add at least one email to invite.'.tr,
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.blueAccent,
                        colorText: Colors.white,
                      );
                      return;
                    }
                    
                    // This is the key change: Close the current bottom sheet
                    // and pass the list of friends back as a result.
                    Get.back(result: friendsToInvite);
                  },
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.green,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Invite'.tr,
                      style: getTextStyle2(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ).marginSymmetric(horizontal: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
