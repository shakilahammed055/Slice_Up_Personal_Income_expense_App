// File: lib/features/settings_screen/setting_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
import 'package:teddy_5618/features/settings_screen/widget/assistant_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/build_setting_item.dart';
import 'package:teddy_5618/features/settings_screen/widget/category_bttomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/currency_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/image_picker_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/language_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/mode_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/myfriends_bottomsheet2.dart';
import 'package:teddy_5618/features/settings_screen/widget/name_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/reset_password_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/setting_monthsetting.dart';
import 'package:teddy_5618/features/settings_screen/widget/delete_account_bottomsheet.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final SettingController controller = Get.put(SettingController());
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double containerWidth = screenWidth * 0.93;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : Color(0xffFAFAFA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: screenHeight * 0.08,
              color: isDark ? AppColors.backgroundDark : Color(0xffFAFAFA),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(
                        () => Container(
                          width: screenWidth * 0.2,
                          height: screenWidth * 0.2,
                          decoration: ShapeDecoration(
                            color: controller.profileImagePath.value.isEmpty
                                ? Color(0xFF2D50FF)
                                : null,
                            image: controller.profileImagePath.value.isNotEmpty
                                ? (controller.profileImagePath.value.startsWith(
                                        'http',
                                      )
                                      ? DecorationImage(
                                          image: NetworkImage(
                                            controller.profileImagePath.value,
                                          ),
                                          fit: BoxFit.cover,
                                        )
                                      : DecorationImage(
                                          image: FileImage(
                                            File(
                                              controller.profileImagePath.value,
                                            ),
                                          ),
                                          fit: BoxFit.cover,
                                        ))
                                : null,
                            shape: OvalBorder(),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -screenWidth * 0.02,
                        bottom: -screenWidth * 0.02,
                        child: GestureDetector(
                          onTap: () =>
                              showImagePickerBottomSheet(context, controller),
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.02),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.black
                                  : AppColors.textWhite,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.08,
                                ),
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
                            child: Icon(
                              Icons.camera_alt,
                              size: screenWidth * 0.06,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.015),
                  Obx(
                    () => SizedBox(
                      width: screenWidth * 0.38,
                      child: Text(
                        controller.userName.value,
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.030),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: isDark ? AppColors.deepGrey : AppColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x1E000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSettingItem(
                          icon: Icons.email_outlined,
                          title: 'Email'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.email.value.isNotEmpty
                                  ? controller.email.value
                                  : 'No email set',
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          isEditable: false,
                          screenWidth: screenWidth,
                          context: context,
                        ),

                        buildSettingItem(
                          icon: Icons.person,
                          title: 'Name'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.userName.value,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => showNameBottomSheet(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.lock_outline,
                          title: 'Reset password'.tr,
                          trailing: Text(
                            'Edit'.tr,
                            textAlign: TextAlign.right,
                            style: getTextStyle2(
                              color: Color(0xFF828282),
                              fontSize: screenWidth * 0.036,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () =>
                              showResetPasswordBottomSheet(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.group_outlined,
                          title: 'My friends'.tr,
                          trailing: Obx(
                            () => Text(
                              '${controller.friendCount.value} Friends',
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => showMaterialModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(34),
                              ),
                            ),
                            builder: (context) => MyFriendsBottomsheet2(),
                          ),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  Container(
                    width: double.infinity,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      color: isDark ? AppColors.black : AppColors.textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(screenWidth * 0.06),
                      ),
                      shadows: [
                        BoxShadow(
                          color: Color(0x1E000000),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildSettingItem(
                          icon: Icons.category_outlined,
                          title: 'Category setting'.tr,
                          onTap: () =>
                              showCategoryBottomSheet(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.message_outlined,
                          title: 'Assistant'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.assistantType.value.isNotEmpty
                                  ? controller.assistantType.value
                                  : 'Supporter'.tr,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () =>
                              showAssistantBottomSheet(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.calendar_month_outlined,
                          title: 'Date setting'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.dateRange.value,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => ShowMonthSetting(
                            controller: controller,
                          ).show(context),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.attach_money,
                          title: 'Currency'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.currency.value,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => showCurrencyDialog(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.language,
                          title: 'Language'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.language.value,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => showLanguageDialog(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                        buildSettingItem(
                          icon: Icons.wb_sunny_outlined,
                          title: 'Mode'.tr,
                          trailing: Obx(
                            () => Text(
                              controller.themeMode.value,
                              textAlign: TextAlign.right,
                              style: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: screenWidth * 0.036,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          onTap: () => showThemeDialog(context, controller),
                          screenWidth: screenWidth,
                          context: context,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.03),
                  GestureDetector(
                    onTap: () =>
                        showDeleteAccountBottomSheet(context, controller),
                    child: Container(
                      width: double.infinity,
                      height: screenHeight * 0.06,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.06,
                      ),
                      decoration: ShapeDecoration(
                        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFAAAAAA)),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.08,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Delete account'.tr,
                          textAlign: TextAlign.center,
                          style: getTextStyle2(
                            color: Color(0xFF828282),
                            fontSize: screenWidth * 0.036,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.15),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}