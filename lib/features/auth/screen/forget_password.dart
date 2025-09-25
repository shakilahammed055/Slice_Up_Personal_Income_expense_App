import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/auth/controller/forget_password_controller.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ForgetPasswordController forgetPasswordController = Get.put(ForgetPasswordController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Create a FocusNode for the TextField
    final FocusNode emailFocusNode = FocusNode();

    // Add listener to update isEmailFocused when focus changes
    emailFocusNode.addListener(() {
      forgetPasswordController.onEmailFocusChange(emailFocusNode.hasFocus);
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: Image.asset(
                    isDark ? IconPath.backarrowwhite : IconPath.backarrow,
                    width: 22,
                    height: 22,
                  ),
                ),
              ),
              SizedBox(height: Get.height * 0.08),
              Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Email'.tr,
                    style: getTextStyle2(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 24),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(() => Container(
                            width: double.infinity,
                            height: 48.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 4.h,
                            ),
                            decoration: ShapeDecoration(
                              color: Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: forgetPasswordController.isEmailFocused.value
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
                                focusNode: emailFocusNode, // Attach the FocusNode
                                cursorHeight: 20,
                                onChanged: forgetPasswordController.updateEmail,
                                keyboardType: TextInputType.emailAddress,
                                  textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Email'.tr,
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
                                  color: Color(0xFF2B2F38),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  lineHeight: 21,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
              Spacer(),
              Container(
                width: double.infinity,
                height: 80,
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Color(0xFFFCFCFD),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Obx(() => GestureDetector(
                          onTap: forgetPasswordController.isButtonEnabled.value
                              ? forgetPasswordController.onNextPressed
                              : null,
                          child: Container(
                            width: 358,
                            height: 52,
                            decoration: ShapeDecoration(
                              color: forgetPasswordController.isButtonEnabled.value
                                  ? Color(0xFF2B2F38)
                                  : Color(0xFFD6D6D6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Next'.tr,
                                style: getTextStyle2(
                                  color: forgetPasswordController.isButtonEnabled.value
                                      ? Colors.white
                                      : Color(0xFF828282),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        )),
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