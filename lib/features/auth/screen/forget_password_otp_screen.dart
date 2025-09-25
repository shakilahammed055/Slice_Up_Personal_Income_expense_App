import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/auth/controller/forget_password_otp_controller.dart';

class ForgetPasswordOtpScreen extends StatelessWidget {
  const ForgetPasswordOtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ForgetPasswordOtpController forgetPasswordOtpController = Get.put(
      ForgetPasswordOtpController(),
    );

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
                    'Verify your email'.tr,
                    style: getTextStyle2(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      5,
                      (index) => SizedBox(
                        width: 55.40.w,
                        height: 65.40.h,
                        child: TextField(
                          controller:
                              forgetPasswordOtpController.controllers[index],
                          focusNode:
                              forgetPasswordOtpController.focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                                width: 2,
                              ),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.backgroundDark
                                : const Color(0xFFEDEDF0),
                            hintText: '',
                            hintStyle: getTextStyle2(
                              color: const Color(0xFFAAAAAA),
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              lineHeight: 12.5,
                            ),
                          ),
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                          ),
                          onChanged: (value) => forgetPasswordOtpController
                              .onOtpChanged(value, index),
                        ),
                      ),
                    ),
                  ),
                  // const SizedBox(height: 12),
                  Obx(
                    () => forgetPasswordOtpController.error.value.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Text(
                              forgetPasswordOtpController.error.value,
                              style: getTextStyle2(
                                color: Colors.red,
                                fontSize: 12,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  // const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Didn’t receive the code? '.tr,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: forgetPasswordOtpController.resendOtp,
                            child: Text(
                              'Resend'.tr,
                              style: getTextStyle2(
                                color: const Color(0xFF2A31EF),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                lineHeight: 15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Obx(
                () => GestureDetector(
                  onTap: forgetPasswordOtpController.isButtonEnabled.value
                      ? forgetPasswordOtpController.verifyOtp
                      : forgetPasswordOtpController.validateAndShowErrors,
                  child: Container(
                    width: 358,
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: ShapeDecoration(
                      color: forgetPasswordOtpController.isButtonEnabled.value
                          ? (isDark ? AppColors.textWhite : AppColors.black)
                          : const Color(0xFFD6D6D6),
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
                          'Verify'.tr,
                          textAlign: TextAlign.center,
                          style: getTextStyle2(
                            color:
                                forgetPasswordOtpController
                                    .isButtonEnabled
                                    .value
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
    );
  }
}
