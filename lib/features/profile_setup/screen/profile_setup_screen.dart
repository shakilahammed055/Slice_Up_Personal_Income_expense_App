import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/profile_setup/controller/profile_setup_controller.dart';

class ProfileSetupScreen extends StatelessWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ProfileController profileController = Get.put(ProfileController());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.09),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome! \nWhat’s your name?'.tr,
                    style: getTextStyle2(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      lineHeight: 35
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Focus(
                          onFocusChange: profileController.onNameFocusChange,
                          child: Container(
                            width: double.infinity,
                            height: 48.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: profileController.isNameFocused.value
                                    ? BorderSide(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                        width: 2,
                                      )
                                    : BorderSide.none,
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                cursorHeight: 20.sp,
                                onChanged: profileController.updateName,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Name'.tr,
                                  hintStyle: getTextStyle2(
                                    color: Color(0xFFAAAAAA),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 25,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                ),
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 21,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Container(
                width: double.infinity,
                height: 80,
                padding: EdgeInsets.symmetric(vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.black : Color(0xFFFCFCFD),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(
                      () => GestureDetector(
                        onTap: profileController.isButtonEnabled.value
                            ? profileController.onNextPressed
                            : null,
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          decoration: ShapeDecoration(
                            color: profileController.isButtonEnabled.value
                                ? isDark
                                    ? AppColors.textWhite
                                    : AppColors.black
                                : Color(0xFFD6D6D6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                              // Removed focus-dependent border
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Finish'.tr,
                              style: getTextStyle2(
                                color: profileController.isButtonEnabled.value
                                    ? isDark
                                        ? AppColors.black
                                        : AppColors.textWhite
                                    : Color(0xFF828282),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}