// category_controller.dart
import 'package:get/get.dart';

class CategoryController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxString selectedIcon = '🚗'.obs;
    final selectedName = 'Transport'.obs; // add this

  void selectCategory(int index, String icon, String name) {
    selectedIndex.value = index;
    selectedIcon.value = icon;
    selectedName.value = name;
  }
}