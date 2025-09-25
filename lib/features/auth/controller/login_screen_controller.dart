
// ignore_for_file: unnecessary_overrides

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/auth/screen/otp_screen.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';
import 'package:teddy_5618/features/profile_setup/screen/profile_setup_screen.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final isPasswordVisible = false.obs;
  final receivePromotions = false.obs;
  final isButtonEnabled = false.obs;
  final passwordError = ''.obs;
  final isEmailFocused = false.obs;
  final isPasswordFocused = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_updateButtonState);
    passwordController.addListener(_updateButtonState);
  }

  void _updateButtonState() {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final emailValid = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(email);
    final passwordValid = password.length >= 8;
    isButtonEnabled.value = emailValid && passwordValid;
  }

  void validatePassword(String value) {
    if (value.length < 8) {
      passwordError.value = 'Password must be at least 8 characters'.tr;
    } else {
      passwordError.value = '';
    }
    _updateButtonState();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void togglePromotions() {
    receivePromotions.value = !receivePromotions.value;
  }

  void onEmailFocusChange(bool hasFocus) {
    isEmailFocused.value = hasFocus;
  }

  void onPasswordFocusChange(bool hasFocus) {
    isPasswordFocused.value = hasFocus;
  }


 


//Send OTP =========================================================================
  Future<void> sendOTP(String approvalToken) async {
    debugPrint('Starting sendOTP with approvalToken: $approvalToken');
    EasyLoading.show(status: 'Sending OTP...');
    try {
      debugPrint('Making HTTP POST request to send_OTP endpoint');
      final otpResponse = await http.post(
        Uri.parse(
          Urls.sendotp,
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': approvalToken,
        },
      );

      debugPrint(
        'Received OTP response with status code: ${otpResponse.statusCode}',
      );
      debugPrint('OTP response body: ${otpResponse.body}');

      if (otpResponse.statusCode == 200 || otpResponse.statusCode == 201) {
        debugPrint('Parsing OTP response JSON');
        final otpResponseData = jsonDecode(otpResponse.body);
        debugPrint('Parsed OTP response data: $otpResponseData');

        final success = otpResponseData['success'] as bool;
        debugPrint('Success status: $success');
        final message = otpResponseData['message'] as String;
        debugPrint('Message: $message');

        if (success) {
          debugPrint('Extracting token from response body');
          final token = otpResponseData['body']['token'] as String;
          debugPrint('Extracted token: $token');

          debugPrint('Saving token to AuthService');
          await AuthService.saveAuthData(
            approvalToken: approvalToken,
            userId: '',
            role: '',
            token: token,
          );
          debugPrint('Token saved to AuthService successfully');

          debugPrint('Navigating to OtpScreen');
          Get.offAll(() => OtpScreen());
          debugPrint('Showing success message: $message');
          EasyLoading.showSuccess(message);
        } else {
          debugPrint('Send OTP failed: success is false');
          debugPrint('Send OTP error: $message');
          EasyLoading.showError(message);
          passwordError.value = message;
          debugPrint('Set passwordError to: ${passwordError.value}');
        }
      } else {
        debugPrint(
          'OTP request failed with status code: ${otpResponse.statusCode}',
        );
        debugPrint('Parsing error response JSON');
        final otpResponseData = jsonDecode(otpResponse.body);
        debugPrint('Parsed error response data: $otpResponseData');
        String errorMessage =
            otpResponseData['message'] ?? 'Failed to send OTP';
        debugPrint('Send OTP error: $errorMessage');
        EasyLoading.showError(errorMessage);
        passwordError.value = errorMessage;
        debugPrint('Set passwordError to: ${passwordError.value}');
      }
    } catch (e) {
      debugPrint('Exception caught in sendOTP: $e');
      EasyLoading.showError('Failed to send OTP: ${e.toString()}');
      passwordError.value = 'Failed to send OTP: ${e.toString()}';
      debugPrint('Set passwordError to: ${passwordError.value}');
    } finally {
      debugPrint('Dismissing EasyLoading');
      EasyLoading.dismiss();
    }
    debugPrint('sendOTP method completed');
  }




//Log In=============================================================================
  Future<void> login() async {
  debugPrint('Starting login with email: ${emailController.text.trim()}');
  EasyLoading.show(status: 'Logging in...');
  try {
    final email = emailController.text.trim();
    final password = passwordController.text;
    debugPrint('Creating request body with email: $email');
    final requestBody = {'email': email, 'password': password};

    debugPrint('Making HTTP POST request to login endpoint');
    final response = await http.post(
      Uri.parse(Urls.login),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    debugPrint('Received login response with status code: ${response.statusCode}');
    debugPrint('Login response body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      debugPrint('Parsing login response JSON');
      final responseData = jsonDecode(response.body);
      debugPrint('Parsed response data: $responseData');

      final otpVerified = responseData['user']['OTPVerified'] as bool;
      final approvalToken = responseData['approvalToken'] as String;
      final userId = responseData['user']['_id'] as String;
      final role = responseData['user']['role'] as String;
      final isProfileUpdated = responseData['user']['isProfileUpdated'] as bool;
      debugPrint('OTPVerified: $otpVerified, ApprovalToken: $approvalToken, UserId: $userId, Role: $role, isProfileUpdated: $isProfileUpdated');

      // Save auth data to AuthService
      debugPrint('Saving auth data to AuthService');
      await AuthService.saveAuthData(
        approvalToken: approvalToken,
        userId: userId,
        role: role,
      );
      debugPrint('Auth data saved successfully');

      // Navigate based on OTPVerified and isProfileUpdated status
      if (otpVerified) {
        debugPrint('OTP is verified, checking isProfileUpdated');
        if (isProfileUpdated) {
          debugPrint('isProfileUpdated is true, navigating to HomeScreen');
          Get.offAll(() => BottomNavbarView());
        } else {
          debugPrint('isProfileUpdated is false, navigating to ProfileSetupScreen');
          Get.offAll(() => ProfileSetupScreen());
        }
        debugPrint('Showing success message: Login successful!');
        EasyLoading.showSuccess('Login successful!');
      } else {
        debugPrint('OTP not verified, calling sendOTP');
        await sendOTP(approvalToken);
      }

      // Clear input fields
      debugPrint('Clearing input fields');
      emailController.clear();
      passwordController.clear();
      debugPrint('Updating button state');
      _updateButtonState();
    } else {
      debugPrint('Login request failed with status code: ${response.statusCode}');
      debugPrint('Parsing error response JSON');
      final responseData = jsonDecode(response.body);
      debugPrint('Parsed error response data: $responseData');
      String errorMessage = responseData['message'] ?? 'Login failed';
      debugPrint('Error message: $errorMessage');
      EasyLoading.showError(errorMessage);
      passwordError.value = errorMessage;
      debugPrint('Set passwordError to: ${passwordError.value}');
    }
  } catch (e) {
    debugPrint('Exception caught in login: $e');
    EasyLoading.showError('Login failed: ${e.toString()}');
    passwordError.value = 'Login failed: ${e.toString()}';
    debugPrint('Set passwordError to: ${passwordError.value}');
  } finally {
    debugPrint('Dismissing EasyLoading');
    EasyLoading.dismiss();
  }
  debugPrint('login method completed');
}

  @override
  void onClose() {
    super.onClose();
  }
}
