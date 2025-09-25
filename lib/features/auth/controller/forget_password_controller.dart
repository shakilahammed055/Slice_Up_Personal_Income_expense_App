import 'dart:convert';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/screen/forget_password_otp_screen.dart';

class ForgetPasswordController extends GetxController {
  /// Observables
  final email = ''.obs;
  final isEmailFocused = false.obs;
  final isButtonEnabled = false.obs;

  /// Called when TextField focus changes
  void onEmailFocusChange(bool hasFocus) {
    isEmailFocused.value = hasFocus;
  }

  /// Called on TextField onChanged
  void updateEmail(String value) {
    email.value = value.trim();
    validateEmail();
  }

  /// Validate email format
  void validateEmail() {
    if (email.value.isEmpty) {
      isButtonEnabled.value = false;
    } else if (!GetUtils.isEmail(email.value)) {
      isButtonEnabled.value = false;
    } else {
      isButtonEnabled.value = true;
    }
  }

  /// Called when Next button is pressed
  Future<void> onNextPressed() async {
    validateEmail();
    if (!isButtonEnabled.value) return;

    try {
      EasyLoading.show(status: 'Sending OTP...'.tr);

      var headers = {'Content-Type': 'application/json'};
      var request = http.Request(
        'POST',
        Uri.parse(
          Urls.forgetpassword,
        ),
      );
      request.body = json.encode({"email": email.value});
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        final responseData = json.decode(await response.stream.bytesToString());
        final token = responseData["body"]["token"];

        EasyLoading.showSuccess("OTP sent to ${email.value}");

        // Pass arguments instead of constructor params
        Get.to(
          () => const ForgetPasswordOtpScreen(),
          arguments: {"email": email.value, "token": token},
        );
      } else {
        final errorMsg = await response.stream.bytesToString();
        EasyLoading.showError("Failed: $errorMsg");
      }
    } catch (e) {
      EasyLoading.showError("Error: $e");
    } finally {
      EasyLoading.dismiss();
    }
  }
}
