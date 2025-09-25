import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/auth/controller/reset_password_controller.dart';

class ResetPassword extends StatelessWidget {
  ResetPassword({super.key});
  final ResetPasswordController resetPasswordController = Get.put(
    ResetPasswordController(),
  );
  final bool isDark = Theme.of(Get.context!).brightness == Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(height: Get.height * 0.11),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reset Your Password'.tr,
                    style: getTextStyle2(
                      color: isDark ? Colors.white : Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Focus(
                        onFocusChange:
                            resetPasswordController.onPasswordFocusChange,
                        child: Obx(
                          () => Container(
                            width: double.infinity,
                            height: 48.h,
                            padding:  EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    resetPasswordController
                                        .isPasswordFocused
                                        .value
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
                                cursorHeight: 20,
                                controller:
                                    resetPasswordController.passwordController,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Password'.tr,
                                  hintStyle: getTextStyle2(
                                    color: const Color(0xFFAAAAAA),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 25,
                                  ),
                                  suffixIcon: Obx(
                                    () => IconButton(
                                      icon: Icon(
                                        resetPasswordController
                                                .isPasswordVisible
                                                .value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFFAAAAAA),
                                      ),
                                      onPressed: resetPasswordController
                                          .togglePasswordVisibility,
                                    ),
                                  ),
                                ),
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                obscureText: !resetPasswordController
                                    .isPasswordVisible
                                    .value,
                                onChanged: (value) =>
                                    resetPasswordController.updateButtonState(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () =>
                            resetPasswordController
                                .passwordError
                                .value
                                .isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 5,
                                ),
                                child: Text(
                                  resetPasswordController.passwordError.value,
                                  style: getTextStyle2(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : SizedBox.shrink(),
                      ),
                      SizedBox(height: 12),
                      Focus(
                        onFocusChange: resetPasswordController
                            .onConfirmPasswordFocusChange,
                        child: Obx(
                          () => Container(
                            width: double.infinity,
                            height: 48.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.backgroundDark
                                  : const Color(0xFFF0F0F0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side:
                                    resetPasswordController
                                        .isConfirmPasswordFocused
                                        .value
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
                                controller: resetPasswordController
                                    .confirmPasswordController,
                                     textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  hintText: 'Confirm Password'.tr,
                                  hintStyle: getTextStyle2(
                                    color: const Color(0xFFAAAAAA),
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    lineHeight: 25,
                                  ),
                                  suffixIcon: Obx(
                                    () => IconButton(
                                      icon: Icon(
                                        resetPasswordController
                                                .isConfirmPasswordVisible
                                                .value
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: const Color(0xFFAAAAAA),
                                      ),
                                      onPressed: resetPasswordController
                                          .toggleConfirmPasswordVisibility,
                                    ),
                                  ),
                                ),
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                obscureText: !resetPasswordController
                                    .isConfirmPasswordVisible
                                    .value,
                                onChanged: (value) =>
                                    resetPasswordController.updateButtonState(),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Obx(
                        () =>
                            resetPasswordController
                                .confirmPasswordError
                                .value
                                .isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                  top: 8,
                                  left: 5,
                                ),
                                child: Text(
                                  resetPasswordController
                                      .confirmPasswordError
                                      .value,
                                  style: getTextStyle2(
                                    color: Colors.red,
                                    fontSize: 12,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => GestureDetector(
                  onTap: resetPasswordController.isButtonEnabled.value
                      ? resetPasswordController.onResetPasswordPressed
                      : null,
                  child: Container(
                    width: 358,
                    height: 52,
                    decoration: ShapeDecoration(
                      color: resetPasswordController.isButtonEnabled.value
                          ? (isDark ? AppColors.textWhite : AppColors.black)
                          : const Color(0xFFD6D6D6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Reset Password'.tr,
                        style: getTextStyle2(
                          color: resetPasswordController.isButtonEnabled.value
                              ? (isDark ? AppColors.black : AppColors.textWhite)
                              : const Color(0xFF828282),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            ],
          ),
        ),
      ),
    );
  }
}



