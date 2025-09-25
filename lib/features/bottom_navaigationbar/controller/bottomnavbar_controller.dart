import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:teddy_5618/features/chat_screen/screen/chat_screen.dart';
import 'package:teddy_5618/features/group_screen/screen/group_screen.dart';
import 'package:teddy_5618/features/home_screen/screen/home_screen.dart';

import '../../settings_screen/screen/setting_screen.dart';

class BottomNavbarController extends GetxController {
  var selectedIndex = 0.obs;

  void changeTab(int index) {
    selectedIndex.value = index;
  }

  Widget getCurrentScreen() {
    switch (selectedIndex.value) {
      case 0:
        return HomeScreen();
      case 1:
        return GroupScreen();
      case 2:
        return SettingScreen();
      case 3:
        return ChatScreen(); // Keep ChatScreen at index 3
      default:
        return HomeScreen(); // Fallback
    }
  }

  bool get isChatScreen => selectedIndex.value == 3; // Helper method

  var userType = ''.obs;
  Future<void> getUserType() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userType.value = prefs.getString('userType') ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    getUserType();
  }
}
