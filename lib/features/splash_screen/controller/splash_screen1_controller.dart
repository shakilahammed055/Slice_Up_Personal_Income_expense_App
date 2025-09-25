import 'package:flutter/rendering.dart';
import 'package:get/get.dart';

class SplashScreen1Controller extends GetxController {
  void navigateToHome() {
    Get.offNamed('/signupscreen');
  }

  void handleGoogleSignIn() async {
    // Implement Google Sign-In logic here
    debugPrint('Google Sign-In initiated');
    navigateToHome();
  }

  void handleAppleSignIn() async {
    // Implement Apple Sign-In logic here
    debugPrint('Apple Sign-In initiated');
    navigateToHome();
  }

  void handleEmailSignIn() {
    // Navigate to email sign-in screen or show dialog
    debugPrint('Email Sign-In initiated');
    navigateToHome();
  }
}
