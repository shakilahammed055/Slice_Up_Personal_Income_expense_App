// import 'package:flutter/material.dart';
// import 'package:teddy_5618/app.dart' show Teddy5618;
// import 'package:teddy_5618/core/localization/language_service.dart';
// import 'package:teddy_5618/core/services/storage_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final savedLocale = await LanguageService.loadLocale();
//    await StorageService.init();
//   runApp(Teddy5618(savedLocale: savedLocale));
// }



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/app.dart' show Teddy5618;
import 'package:teddy_5618/core/localization/language_service.dart';
import 'package:teddy_5618/core/services/storage_service.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  final settingController = Get.put(SettingController());
  await settingController.loadInitialSettings(); 
  await settingController.loadSavedLanguage();
  final savedLocale = await LanguageService.loadLocale() ?? settingController.nameToLocale(settingController.language.value);
  runApp(Teddy5618(savedLocale: savedLocale));
}