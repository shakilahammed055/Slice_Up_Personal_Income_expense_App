import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void showDeleteFriendBottomSheet(
  BuildContext context,
  SettingController controller,
  int index,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final double screenHeight = MediaQuery.of(context).size.height;
  final double screenWidth = MediaQuery.of(context).size.width;
  final friend = controller.friends[index];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
    ),
    builder: (context) {
      return Container(
        height: screenHeight * 0.85,
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isDark ? AppColors.black : AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 56,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(width: 48),
                  Expanded(
                    child: Text(
                      'Delete Friend'.tr,
                      textAlign: TextAlign.center,
                      style: getTextStyle2(
                        color: isDark ? AppColors.textWhite : AppColors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 24),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
              child: Text(
                'Are you sure you want to delete ${friend.name} from your friends list?',
                textAlign: TextAlign.center,
                style: getTextStyle2(
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  lineHeight: 22,
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: screenWidth * 0.4,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : Color(0xFFEDEDF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel'.tr,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    controller.friends.removeAt(index);
                    controller.friendCount.value = controller.friends.length;
                    Get.back();
                    Get.snackbar('Success'.tr, 'Friend deleted'.tr);
                  },
                  child: Container(
                    width: screenWidth * 0.4,
                    height: 48,
                    decoration: ShapeDecoration(
                      color: Color(0xFFCA6468),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x0C0C0C0D),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        'Delete'.tr,
                        style: getTextStyle2(
                          color: AppColors.textWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),
            Container(
              width: 134,
              height: 4,
              margin: EdgeInsets.only(bottom: 8),
              decoration: ShapeDecoration(
                color: isDark ? AppColors.textWhite : Color(0xFF2B2F38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
