import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/features/splash_screen/controller/splash_screen_controller.dart';
import '../../../core/utils/constants/icon_path.dart' show IconPath;

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SplashScreenController());

    return CupertinoPageScaffold(
      child: Container(
        decoration: BoxDecoration(color: Color(0xff2B31F0)),
        child: Center(child: Image.asset(IconPath.logo, width: 250)),
      ),
    );
  }
}
