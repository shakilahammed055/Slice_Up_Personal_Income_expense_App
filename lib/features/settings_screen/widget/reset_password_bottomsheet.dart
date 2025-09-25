import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
import 'package:teddy_5618/features/auth/controller/forget_password_controller.dart'; // Import your controller

void showResetPasswordBottomSheet(
  BuildContext context,
  SettingController controller,
) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  TextEditingController emailController = TextEditingController();
  final RxBool isButtonEnabled = false.obs;

  // Email validation function
  void validateEmail(String email) {
    if (email.isEmpty) {
      isButtonEnabled.value = false;
    } else if (!GetUtils.isEmail(email)) {
      isButtonEnabled.value = false;
    } else {
      isButtonEnabled.value = true;
    }
  }

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
      return Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  width: double.infinity,
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0,
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 12,
                                top: 12,
                                child: SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        left: 3,
                                        top: 3,
                                        child: Container(
                                          width: 26,
                                          height: 26,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 286,
                              child: Text(
                                'Reset Password'.tr,
                                textAlign: TextAlign.center,
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => Get.back(),
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: Icon(
                                  Icons.close,
                                  size: 24,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Email Input Section
                Container(
                  width: double.infinity,
                  height: 97,
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                                height: 48,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 4,
                                ),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: TextField(
                                          controller: emailController,
                                          onChanged: (value) {
                                            validateEmail(value.trim());
                                          },
                                          decoration: InputDecoration(
                                            isDense: true,
                                            hintText:
                                                'Enter your Email Address'.tr,
                                            border: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            contentPadding: EdgeInsets.zero,
                                          ),
                                          style: getTextStyle2(
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.done,
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
                    ],
                  ),
                ),

                // Send Button Section
                Obx(
                  () => Container(
                    width: double.infinity,
                    height: 80,
                    padding: EdgeInsets.symmetric(horizontal: 23, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: isButtonEnabled.value
                              ? () async {
                                  // Call the API from your ForgetPasswordController
                                  final forgetController = Get.put(
                                    ForgetPasswordController(),
                                  );
                                  forgetController.email.value = emailController
                                      .text
                                      .trim();
                                  // Call the API
                                  await forgetController.onNextPressed();
                                  // Clean up
                                  Get.delete<ForgetPasswordController>();
                                }
                              : null,
                          child: Container(
                            width: double.infinity,
                            height: 48,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            decoration: ShapeDecoration(
                              color: isButtonEnabled.value
                                  ? (isDark
                                        ? AppColors.textWhite
                                        : AppColors.black)
                                  : (isDark
                                        ? AppColors.deepGrey
                                        : Color(0xFFEDEDF0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Send'.tr,
                                  textAlign: TextAlign.center,
                                  style: getTextStyle2(
                                    color: isButtonEnabled.value
                                        ? (isDark
                                              ? AppColors.black
                                              : AppColors.textWhite)
                                        : (isDark
                                              ? AppColors.textWhite.withValues(
                                                  alpha: 0.5,
                                                )
                                              : AppColors.black.withValues(
                                                  alpha: 0.5,
                                                )),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
