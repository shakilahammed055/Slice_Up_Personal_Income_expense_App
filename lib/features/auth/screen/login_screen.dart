import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/auth/controller/login_screen_controller.dart';
import 'package:teddy_5618/features/auth/screen/forget_password.dart';
import 'package:teddy_5618/features/auth/screen/signup_screen.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController loginController = Get.put(
    LoginController(),
    permanent: true,
  );

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
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
                          onTap: () {
                            Get.off(
                              () => const SignupScreen(),
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
                  SizedBox(height: Get.height * 0.055),
                  SizedBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!'.tr,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            lineHeight: 38,
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
                                onFocusChange:
                                    loginController.onEmailFocusChange,
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
                                        : Color(0xFFF0F0F0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side: loginController.isEmailFocused.value
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
                                          loginController.emailController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: 'Email address'.tr,
                                        hintStyle: getTextStyle2(
                                          color: Color(0xFFAAAAAA),
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
                                        lineHeight: 21,
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged:
                                          loginController.validatePassword,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            Obx(
                              () => Focus(
                                onFocusChange:
                                    loginController.onPasswordFocusChange,
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
                                        : Color(0xFFF0F0F0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      side:
                                          loginController
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
                                      cursorHeight: 20.sp,
                                      controller:
                                          loginController.passwordController,
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        hintText: 'Password'.tr,
                                        hintStyle: getTextStyle2(
                                          color: Color(0xFFAAAAAA),
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                          lineHeight: 25,
                                        ),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            loginController
                                                    .isPasswordVisible
                                                    .value
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Color(0xFFAAAAAA),
                                          ),
                                          onPressed: loginController
                                              .togglePasswordVisibility,
                                        ),
                                        errorStyle: getTextStyle2(
                                          color: Colors.red,
                                          fontSize: 12,
                                          lineHeight: 21,
                                        ),
                                      ),
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      obscureText: !loginController
                                          .isPasswordVisible
                                          .value,
                                      onChanged:
                                          loginController.validatePassword,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () =>
                                  loginController.passwordError.value.isNotEmpty
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 8, left: 5),
                                      child: Text(
                                        loginController.passwordError.value,
                                        style: getTextStyle2(
                                          color: Colors.red,
                                          fontSize: 12,
                                        ),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                            ),
                            SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: SizedBox(
                                height: 32,
                                child: GestureDetector(
                                  onTap: () {
                                    Get.to(ForgetPasswordScreen());
                                  },
                                  child: Text(
                                    'Forgot password?'.tr,
                                    textAlign: TextAlign.right,
                                    style: getTextStyle2(
                                      color: Color(0xFF2A31EF),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Obx(
                    () => GestureDetector(
                      onTap: loginController.isButtonEnabled.value
                          ? loginController.login
                          : null,
                      child: Container(
                        width: 358,
                        height: 52,
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        decoration: ShapeDecoration(
                          color: loginController.isButtonEnabled.value
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
                              'Sign in'.tr,
                              textAlign: TextAlign.center,
                              style: getTextStyle2(
                                color: loginController.isButtonEnabled.value
                                    ? (isDark
                                          ? AppColors.black
                                          : AppColors.textWhite)
                                    : Color(0xFF828282),
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
