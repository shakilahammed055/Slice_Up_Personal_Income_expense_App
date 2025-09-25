import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Colors
  static const Color primary = Color(
    0xFF1E3A5F,
  ); // Darker primary for a more professional look
  static const Color secondary = Color(
    0xFFFEC601,
  ); // Bright yellow for highlights and accents
  static const Color accent = Color(
    0xFF89A7FF,
  ); // Softer blue for a modern touch
  static const Color lightblack = Color(
    0xFFAAAAAA,
  ); // Softer blue for a modern touch

  // Gradient Colors
  static const Gradient linearGradient = LinearGradient(
    begin: Alignment(0.0, 0.0),
    end: Alignment(0.707, -0.707),
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4), Color(0xFFFAD0C4)],
  );
  // Text Colors
  static const Color textPrimary = Color(
    0xFF212121,
  ); // Darker shade for better readability
  static const Color textSecondary = Color(
    0xFF757575,
  ); // Neutral grey for secondary text
  static const Color textWhite = Colors.white;
  static const Color textOrange = Color(0xFFEF5C00);

  // Background Colors
  static const Color backgroundLight = Color(
    0xFFFAFAFA,
  ); // Light neutral for clean look
  static const Color backgroundDark = Color(
    0xFF141414,
  ); // Dark background for contrast in dark mode
  static const Color primaryBackground = Color(
    0xFFFFFFFF,
  ); // Pure white for primary content areas

  // Surface Colors
  static const Color surfaceLight = Color(
    0xFFE0E0E0,
  ); // Light grey for elevated surfaces
  static const Color surfaceDark = Color(
    0xFF2C2C2C,
  ); // Dark grey for elevated surfaces in dark mode

  // Container Colors
  static const Color lightContainer = Color(
    0xFFF1F8E9,
  ); // Soft green for a subtle highlight

  // Utility Colors
  static const Color success = Color(0xFF4CAF50); // Green for success messages
  static const Color warning = Color(0xFFFFA726); // Orange for warnings
  static const Color error = Color(0xFFF44336); // Red for error messages
  static const Color info = Color(
    0xFF29B6F6,
  ); // Blue for informational messages
  static const Color blueButton = Color(
    0xFF2B31F0,
  ); // Blue for informational messages
  static const Color green = Color(
    0xFF00D460,
  ); // Blue for informational messages
  static const Color readishred = Color(0xFFCB6568);
  static const Color deepGrey = Color(0xFF38383A);
  static const Color lightblue = Color(0xFF007AFF);
    static const Color lightorange = Color(0xFFFFDECA);
  

  static const Color textGrey = Color(0xFF828282);
  static const Color borderGrey = Color(0xFFD0D3D9);
  static const Color black = Color(0xFF000000);

  static const Color backgroundLightGrey = Color(0xFFFAFAFA);

  static const Color lightGreyContainer = Color(0xFFEDEDF0);
  static const Color dialogboxcolor = Color(0xCCA2A2A2);
  static const Color greylightbarcolor =   Color(0xFFD7D7D7);
  static const Color greylightbardeepcolor =   Color(0xFF565656);
  

}
