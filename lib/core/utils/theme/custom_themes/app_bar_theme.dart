// ignore_for_file: camel_case_types

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class App_BarTheme {
  App_BarTheme._();

  static const AppBarTheme lightAppBarTheme = AppBarTheme(
    foregroundColor: Colors.white,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    backgroundColor: AppColors.textWhite,// Use a light background color
    iconTheme: IconThemeData(color: Colors.black),

    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    actionsIconTheme: IconThemeData(color: Colors.black),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.dark, // Control status bar color and icons
  );

  static final AppBarTheme darkAppBarTheme = AppBarTheme(
    foregroundColor: Colors.black,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    backgroundColor: Colors.black, // Use a dark background color
    iconTheme: const IconThemeData(color: Colors.white),
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    actionsIconTheme: const IconThemeData(color: Colors.white),
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light, // Control status bar color and icons
  );
}
