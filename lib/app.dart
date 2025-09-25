// // import 'package:flutter/material.dart';
// // import 'package:flutter_easyloading/flutter_easyloading.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:get/get.dart';
// // import 'package:teddy_5618/core/localization/translations.dart';
// // import 'package:teddy_5618/routes/app_routes.dart';
// // import 'core/bindings/controller_binder.dart';
// // import 'core/utils/theme/theme.dart';

// // class Teddy5618 extends StatelessWidget {
// //   final Locale? savedLocale;
// //   const Teddy5618({super.key, this.savedLocale});

// //   @override
// //   Widget build(BuildContext context) {
// //     return ScreenUtilInit(
// //       designSize: const Size(390, 844),
// //       minTextAdapt: true,
// //       splitScreenMode: true,
// //       builder: (_, child) {
// //         return GetMaterialApp(

// //           debugShowCheckedModeBanner: false,
// //           initialRoute: AppRoute.getsplashscreen(),
// //           getPages: AppRoute.routes,
// //           initialBinding: ControllerBinder(),
// //           themeMode: ThemeMode.system,
// //           theme: AppTheme.lightTheme,
// //           translations: AppTranslations(),
// //           locale: savedLocale ?? const Locale('en', 'US'),
// //           fallbackLocale: const Locale('en', 'US'),
// //           darkTheme: AppTheme.darkTheme,
// //           // ✅ Control text scaling globally
// //           builder: (context, widget) {
// //             EasyLoading.init();
// //             double baseScale = 1.0; // default
// //             double width = MediaQuery.of(context).size.width;

// //             if (width < 360) {
// //               baseScale = 0.9; // smaller devices
// //             } else if (width > 500) {
// //               baseScale = 1.1; // tablets or large screens
// //             }
// //             return MediaQuery(
// //               data: MediaQuery.of(
// //                 context,
// //               ).copyWith(textScaler: TextScaler.linear(baseScale)),
// //               child: widget!,
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }

// import 'package:flutter/material.dart';
// import 'package:flutter_easyloading/flutter_easyloading.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/localization/translations.dart';
// import 'package:teddy_5618/routes/app_routes.dart';
// import 'core/bindings/controller_binder.dart';
// import 'core/utils/theme/theme.dart';

// class Teddy5618 extends StatelessWidget {
//   final Locale? savedLocale;
//   const Teddy5618({super.key, this.savedLocale});

//   @override
//   Widget build(BuildContext context) {
//     return ScreenUtilInit(
//       designSize: const Size(390, 844),
//       minTextAdapt: true,
//       splitScreenMode: true,
//       builder: (_, child) {
//         return GetMaterialApp(
//           debugShowCheckedModeBanner: false,
//           initialRoute: AppRoute.getsplashscreen(),
//           getPages: AppRoute.routes,
//           initialBinding: ControllerBinder(),
//           themeMode: ThemeMode.system,
//           theme: AppTheme.lightTheme,
//           translations: AppTranslations(),
//           locale: savedLocale ?? const Locale('en', 'US'),
//           fallbackLocale: const Locale('en', 'US'),
//           darkTheme: AppTheme.darkTheme,
//           builder: (context, widget) {
//             // Adjust text scaling based on screen width
//             double baseScale = 1.0; // default
//             double width = MediaQuery.of(context).size.width;

//             if (width < 360) {
//               baseScale = 0.9; // smaller devices
//             } else if (width > 500) {
//               baseScale = 1.1; // tablets or large screens
//             }
//             // Wrap the widget with EasyLoading
//             return MediaQuery(
//               data: MediaQuery.of(context).copyWith(
//                 textScaler: TextScaler.linear(baseScale),
//               ),
//               child: SafeArea( top: false, child:  Container( color: Colors.transparent, child: EasyLoading.init()(context, widget ?? const SizedBox()))),
//             );
//           },
//         );
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/localization/translations.dart';
import 'package:teddy_5618/routes/app_routes.dart';
import 'core/bindings/controller_binder.dart';
import 'core/utils/theme/theme.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

class Teddy5618 extends StatelessWidget {
  final Locale? savedLocale;
  const Teddy5618({super.key, this.savedLocale});

  @override
  Widget build(BuildContext context) {
    final SettingController controller = Get.find<SettingController>();
    
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoute.getsplashscreen(),
          getPages: AppRoute.routes,
          initialBinding: ControllerBinder(),
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: controller.themeMode.value == 'Dark'.tr
              ? ThemeMode.dark
              : ThemeMode.light,
          translations: AppTranslations(),
          locale:
              savedLocale ?? controller.nameToLocale(controller.language.value),
          fallbackLocale: const Locale('en', 'US'),
          builder: (context, widget) {
            double baseScale = 1.0;
            double width = MediaQuery.of(context).size.width;

            if (width < 360) {
              baseScale = 0.9;
            } else if (width > 500) {
              baseScale = 1.1;
            }
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(baseScale)),
              child: SafeArea(
                top: false,
                child: Container(
                  color: Colors.transparent,
                  child: EasyLoading.init()(
                    context,
                    widget ?? const SizedBox(),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
