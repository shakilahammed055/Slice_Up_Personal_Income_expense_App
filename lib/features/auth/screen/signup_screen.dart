import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/auth/controller/sign_up_controller.dart';
import 'package:teddy_5618/features/auth/screen/login_screen.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Use permanent: true to prevent controller disposal
    final SignUpController signUpController = Get.put(SignUpController(), permanent: true);

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).viewInsets.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  SizedBox(height: Get.height * 0.08),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: ShapeDecoration(
                      color: const Color(0xFFEDEDF0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 10,
                                  offset: Offset(1, 1),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign up'.tr,
                                  textAlign: TextAlign.right,
                                  style: getTextStyle2(
                                    color: const Color(0xFF141414),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            Get.off(
                              () => LoginScreen(),
                              transition: Transition.noTransition,
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign in'.tr,
                                  textAlign: TextAlign.right,
                                  style: getTextStyle2(
                                    color: const Color(0xFF141414),
                                    fontSize: 14,
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
                  SizedBox(height: Get.height * 0.05),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Create an account'.tr,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 30),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Focus(
                            onFocusChange: signUpController.onEmailFocusChange,
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
                                    side: signUpController.isEmailFocused.value
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
                                    controller:
                                        signUpController.emailController,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText: 'Email address'.tr,
                                      hintStyle: getTextStyle2(
                                        color: const Color(0xFFAAAAAA),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 25,
                                      ),
                                    ),
                                    style: getTextStyle2(
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 20,
                                    ),
                                    keyboardType: TextInputType.emailAddress,
                                    onChanged: (value) =>
                                        signUpController.updateButtonState(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () => signUpController.emailError.value.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 5,
                                    ),
                                    child: Text(
                                      signUpController.emailError.value,
                                      style: getTextStyle2(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          Focus(
                            onFocusChange:
                                signUpController.onPasswordFocusChange,
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
                                        signUpController.isPasswordFocused.value
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
                                    controller:
                                        signUpController.passwordController,
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      enabledBorder: InputBorder.none,
                                      focusedBorder: InputBorder.none,
                                      errorBorder: InputBorder.none,
                                      disabledBorder: InputBorder.none,
                                      hintText: 'Password (min 8 characters)'.tr,
                                      hintStyle: getTextStyle2(
                                        color: const Color(0xFFAAAAAA),
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 25,
                                      ),
                                      suffixIcon: Obx(
                                        () => IconButton(
                                          icon: Icon(
                                            signUpController
                                                    .isPasswordVisible
                                                    .value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: const Color(0xFFAAAAAA),
                                          ),
                                          onPressed: signUpController
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
                                    obscureText: !signUpController
                                        .isPasswordVisible
                                        .value,
                                    onChanged: (value) =>
                                        signUpController.updateButtonState(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () =>
                                signUpController.passwordError.value.isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 5,
                                    ),
                                    child: Text(
                                      signUpController.passwordError.value,
                                      style: getTextStyle2(
                                        color: Colors.red,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 12),
                          Focus(
                            onFocusChange:
                                signUpController.onConfirmPasswordFocusChange,
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
                                        signUpController
                                            .isconfirmPasswordFocused
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
                                child: TextField(
                                  cursorHeight: 20.sp,
                                  controller: signUpController
                                      .confirmpasswordController,
                                  textAlignVertical: TextAlignVertical.center,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    hintText: 'Confirm Password (min 8 characters)'.tr,
                                    hintStyle: getTextStyle2(
                                      color: const Color(0xFFAAAAAA),
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w500,
                                      lineHeight: 25,
                                    ),
                                    suffixIcon: Obx(
                                      () => IconButton(
                                        icon: Icon(
                                          signUpController
                                                  .isconfirmPasswordVisible
                                                  .value
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                          color: const Color(0xFFAAAAAA),
                                        ),
                                        onPressed: signUpController
                                            .toggleconfirmPasswordVisibility,
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
                                  obscureText: !signUpController
                                      .isconfirmPasswordVisible
                                      .value,
                                  onChanged: (value) =>
                                      signUpController.updateButtonState(),
                                ),
                              ),
                            ),
                          ),
                          Obx(
                            () =>
                                signUpController
                                    .confirmpasswordError
                                    .value
                                    .isNotEmpty
                                ? Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      left: 5,
                                    ),
                                    child: Text(
                                      signUpController
                                          .confirmpasswordError
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
                      const SizedBox(height: 24),
                    ],
                  ),
                  Spacer(),
                  Obx(
                    () => GestureDetector(
                      onTap: signUpController.isButtonEnabled.value
                          ? signUpController.signup
                          : signUpController.updateButtonState,
                      child: Container(
                        width: 358,
                        height: 52,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        decoration: ShapeDecoration(
                          color: signUpController.isButtonEnabled.value
                              ? (isDark ? AppColors.textWhite : AppColors.black)
                              : Color(0xFFD6D6D6),
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
                              'Sign Up'.tr,
                              textAlign: TextAlign.center,
                              style: getTextStyle2(
                                color: signUpController.isButtonEnabled.value
                                    ? (isDark
                                          ? AppColors.black
                                          : AppColors.textWhite)
                                    : const Color(0xFF828282),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}