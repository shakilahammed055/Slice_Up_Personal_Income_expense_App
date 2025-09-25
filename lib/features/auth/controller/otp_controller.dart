// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/auth/screen/login_screen.dart';

class OtpController extends GetxController {
  final List<TextEditingController> controllers = List.generate(
    5,
    (_) => TextEditingController(),
  );
  final List<FocusNode> focusNodes = List.generate(5, (_) => FocusNode());
  final isButtonEnabled = false.obs;
  final error = ''.obs;
  final hasSubmitted = false.obs;

  @override
  void onInit() {
    super.onInit();
    for (var controller in controllers) {
      controller.addListener(updateButtonState);
    }
    for (var i = 0; i < focusNodes.length; i++) {
      focusNodes[i].addListener(() {
        update(); // Notify GetX to rebuild if needed
      });
    }
  }

  void updateButtonState() {
    final isAllFilled = controllers.every(
      (controller) =>
          controller.text.isNotEmpty &&
          RegExp(r'^\d$').hasMatch(controller.text),
    );
    isButtonEnabled.value = isAllFilled;

    if (!hasSubmitted.value) {
      error.value = '';
    }
  }

  void onOtpChanged(String value, int index) {
    error.value = '';

    if (value.isNotEmpty) {
      if (index < focusNodes.length - 1) {
        focusNodes[index].unfocus();
        focusNodes[index + 1].requestFocus();
      } else {
        focusNodes[index].unfocus();
      }
    } else if (index > 0) {
      focusNodes[index].unfocus();
      focusNodes[index - 1].requestFocus();
    }

    updateButtonState();
  }

  void validateAndShowErrors() {
    hasSubmitted.value = true;
    validateFields();
  }

  void validateFields() {
    final otp = controllers.map((controller) => controller.text).join();
    if (otp.length < 5) {
      error.value = 'Please enter all 5 digits'.tr;
    } else if (!RegExp(r'^\d{5}$').hasMatch(otp)) {
      error.value = 'Please enter valid digits'.tr;
    } else {
      error.value = '';
    }
  }

  Future<void> verifyOtp() async {
    hasSubmitted.value = true;
    validateFields();

    if (error.value.isEmpty) {
      EasyLoading.show(status: 'Verifying OTP...'.tr);
      try {
        final token = await AuthService.getToken();
        if (token == null) {
          EasyLoading.showError('No token found. Please sign up again.'.tr);
          return;
        }

        final otp = controllers.map((controller) => controller.text).join();
        final requestBody = {'token': token, 'receivedOTP': int.parse(otp)};
        final response = await http.post(
          Uri.parse(Urls.verifyotp),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(requestBody),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          EasyLoading.showSuccess('OTP verified successfully!'.tr);
          Get.to(() => LoginScreen());
          for (var controller in controllers) {
            controller.clear();
          }
        } else {
          final responseData = jsonDecode(response.body);
          String errorMessage =
              responseData['message'] ?? 'OTP verification failed'.tr;
          debugPrint('Error message: $errorMessage');
          error.value = errorMessage;
          EasyLoading.showError(errorMessage);
        }
      } catch (e) {
        error.value = 'OTP verification failed: ${e.toString()}'.tr;
        EasyLoading.showError('OTP verification failed: ${e.toString()}'.tr);
      } finally {
        EasyLoading.dismiss();
      }
    }
  }

  Future<void> resendOtp() async {
    EasyLoading.show(status: 'Resending OTP...'.tr);
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        EasyLoading.showError('No token found. Please sign up again.'.tr);
        return;
      }

      final requestBody = {'resendOTPToken': token};
      final response = await http.post(
        Uri.parse(
          Urls.resendOtp,
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        EasyLoading.showSuccess('OTP resent successfully!'.tr);
        // Clear existing OTP input fields
        for (var controller in controllers) {
          controller.clear();
        }
        error.value = '';
        hasSubmitted.value = false;
        updateButtonState();
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage = responseData['message'] ?? 'Failed to resend OTP'.tr;
        debugPrint('Error message: $errorMessage');
        error.value = errorMessage;
        EasyLoading.showError(errorMessage);
      }
    } catch (e) {
      error.value = 'Failed to resend OTP: ${e.toString()}';
      EasyLoading.showError('Failed to resend OTP: ${e.toString()}');
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }
}
