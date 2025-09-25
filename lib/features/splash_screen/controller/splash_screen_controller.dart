import 'package:get/get.dart';
import 'package:teddy_5618/features/splash_screen/screen/splash_screen1.dart';

class SplashScreenController extends GetxController {
  //
    @override
  void onInit() {
    navigateAfterDelay();
    super.onInit();
  }

  void navigateAfterDelay() {
    Future.delayed(Duration(seconds: 3), () {
      Get.offAll(() => SplashScreen1());
    });
  }
}
