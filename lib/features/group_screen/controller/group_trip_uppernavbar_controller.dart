import 'package:get/get.dart';

class GroupTripNavbarController extends GetxController {
  RxInt selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;

    // Navigate to different pages based on index
    switch (index) {
      case 0:
        Get.offNamed('/expenses');
        break;
      case 1:
        Get.offNamed('/slice_up');
        break;
      case 2:
        Get.offNamed('/status');
        break;
    }
  }
}
