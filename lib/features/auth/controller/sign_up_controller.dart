// ignore_for_file: unused_local_variable
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/auth/screen/otp_screen.dart';

class SignUpController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmpasswordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final isconfirmPasswordVisible = false.obs;
  final isButtonEnabled = false.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final confirmpasswordError = ''.obs;
  final isEmailFocused = false.obs;
  final isPasswordFocused = false.obs;
  final isconfirmPasswordFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(updateButtonState);
    passwordController.addListener(updateButtonState);
    confirmpasswordController.addListener(updateButtonState);
  }

  void updateButtonState() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmpasswordController.text;

    // Email validation
    if (email.isEmpty) {
      emailError.value = 'Email is required'.tr;
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      emailError.value = 'Invalid email format'.tr;
    } else {
      emailError.value = '';
    }

    // Password validation
    if (password.isEmpty) {
      passwordError.value = 'Password is required'.tr;
    } else if (password.length < 8) {
      passwordError.value = 'Password must be at least 8 characters'.tr;
    } else {
      passwordError.value = '';
    }

    // Confirm password validation
    if (confirmPassword.isEmpty) {
      confirmpasswordError.value = 'Confirm password is required'.tr;
    } else if (confirmPassword.length < 8) {
      confirmpasswordError.value =
          'Confirm password must be at least 8 characters'.tr;
    } else if (confirmPassword != password) {
      confirmpasswordError.value = 'Passwords do not match'.tr;
    } else {
      confirmpasswordError.value = '';
    }

    // Enable button only if all fields are valid
    isButtonEnabled.value =
        emailError.value.isEmpty &&
        passwordError.value.isEmpty &&
        confirmpasswordError.value.isEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty;
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleconfirmPasswordVisibility() {
    isconfirmPasswordVisible.value = !isconfirmPasswordVisible.value;
  }

  void onEmailFocusChange(bool hasFocus) {
    isEmailFocused.value = hasFocus;
    if (!hasFocus) updateButtonState();
  }

  void onPasswordFocusChange(bool hasFocus) {
    isPasswordFocused.value = hasFocus;
    if (!hasFocus) updateButtonState();
  }

  void onConfirmPasswordFocusChange(bool hasFocus) {
    isconfirmPasswordFocused.value = hasFocus;
    if (!hasFocus) updateButtonState();
  }

  Future<void> signup() async {
    updateButtonState();

    if (emailError.value.isNotEmpty ||
        passwordError.value.isNotEmpty ||
        confirmpasswordError.value.isNotEmpty) {
      EasyLoading.showError('Please fix the errors before signing up'.tr);
      return;
    }

    EasyLoading.show(status: 'Signing up...'.tr);

    try {
      final requestBody = {
        'email': emailController.text.trim(),
        'password': confirmpasswordController.text,
      };
      final response = await http.post(
        Uri.parse(Urls.createuser),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['data']['user'];
        final token = responseData['data']['token'];
        final userId = userData['_id'] as String;
        final role = userData['role'] as String;
        final isProfileCreated = userData['OTPVerified'].toString();

        // Save auth data using AuthService
        await AuthService.saveAuthData(
          approvalToken: '',
          userId: userId,
          role: role,
          userEmail: emailController.text.trim(), // Save the email too
          isProfileCreated: isProfileCreated,
          profileId: userId,
          token: token,
        );

        // Remove listeners before clearing controllers
        emailController.removeListener(updateButtonState);
        passwordController.removeListener(updateButtonState);
        confirmpasswordController.removeListener(updateButtonState);

        // Clear input fields
        emailController.clear();
        passwordController.clear();
        confirmpasswordController.clear();

        // Re-attach listeners after clearing
        emailController.addListener(updateButtonState);
        passwordController.addListener(updateButtonState);
        confirmpasswordController.addListener(updateButtonState);

        // Navigate to OTP screen
        Get.off(() => const OtpScreen());

        EasyLoading.showSuccess('Signup successful! Please verify your email');
      } else {
        final responseData = jsonDecode(response.body);
        String errorMessage =
            responseData['message'] ?? 'Registration failed'.tr;
        debugPrint('Error message: $errorMessage');
        EasyLoading.showError(errorMessage);
        passwordError.value = errorMessage;
      }
    } catch (e) {
      debugPrint('Signup error: $e'.tr);
      EasyLoading.showError('Signup failed: ${e.toString()}');
      passwordError.value = 'Signup failed: ${e.toString()}';
    } finally {
      EasyLoading.dismiss();
    }
  }

  @override
  void onClose() {
    // Remove listeners before disposing controllers
    emailController.removeListener(updateButtonState);
    passwordController.removeListener(updateButtonState);
    confirmpasswordController.removeListener(updateButtonState);

    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.onClose();
  }
}
