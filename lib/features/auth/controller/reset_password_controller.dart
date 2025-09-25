import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/screen/login_screen.dart';

class ResetPasswordController extends GetxController {
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final isPasswordFocused = false.obs;
  final isConfirmPasswordFocused = false.obs;

  final passwordError = ''.obs;
  final confirmPasswordError = ''.obs;
  final isButtonEnabled = false.obs;

  late String token;
  late String email;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments ?? {};
    email = args['email'] ?? '';
    token = args['token'] ?? '';
  }

  @override
  void onClose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void onPasswordFocusChange(bool hasFocus) {
    isPasswordFocused.value = hasFocus;
  }

  void onConfirmPasswordFocusChange(bool hasFocus) {
    isConfirmPasswordFocused.value = hasFocus;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  void updateButtonState() {
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    passwordError.value = '';
    confirmPasswordError.value = '';

    if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters'.tr;
    }

    if (confirmPassword.isNotEmpty && confirmPassword != password) {
      confirmPasswordError.value = 'Passwords do not match'.tr;
    }

    isButtonEnabled.value = password.length >= 8 && confirmPassword == password;
  }

  Future<void> onResetPasswordPressed() async {
    if (!isButtonEnabled.value) return;

    try {
      EasyLoading.show(status: 'Resetting password...'.tr);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse(
          Urls.resetpassword,
        ),
      );
      request.body = json.encode({
        "token": token,
        "newPassword": passwordController.text.trim(),
      });
      request.headers.addAll(headers);

      final response = await request.send();

      if (response.statusCode == 200) {
        final data = json.decode(await response.stream.bytesToString());
        if (data['success'] == true) {
          EasyLoading.showSuccess(
            data['message'] ?? 'Password reset successfully',
          );
          Get.offAll(() => LoginScreen());
        } else {
          EasyLoading.showError(data['message'] ?? 'Failed to reset password'.tr);
        }
      } else {
        final msg = await response.stream.bytesToString();
        EasyLoading.showError('Failed: $msg');
      }
    } catch (e) {
      EasyLoading.showError('Error: $e');
    } finally {
      EasyLoading.dismiss();
    }
  }
}
