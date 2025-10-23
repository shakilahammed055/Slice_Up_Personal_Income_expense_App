// import 'package:get/get.dart';
// import 'package:teddy_5618/features/auth/screen/signup_screen.dart';

// class SplashScreenController extends GetxController {
//   //
//     @override
//   void onInit() {
//     navigateAfterDelay();
//     super.onInit();
//   }

//   void navigateAfterDelay() {
//     Future.delayed(Duration(seconds: 3), () {
//       Get.offAll(() => SignupScreen());
//     });
//   }
// }

import 'package:get/get.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:teddy_5618/features/auth/screen/signup_screen.dart';
import 'package:teddy_5618/features/bottom_navaigationbar/screen/bottom_navigationbar.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    navigateAfterDelay();
    super.onInit();
  }

  void navigateAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () async {
      // Check if the user is authenticated (has an approval token)
      bool isAuthenticated = await AuthService.isAuthenticated();

      if (isAuthenticated) {
        // Navigate to BottomNavbarView if authenticated
        Get.offAll(() => BottomNavbarView());
      } else {
        // Navigate to SignupScreen if not authenticated
        Get.offAll(() => const SignupScreen());
      }
    });
  }
}
