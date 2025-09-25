import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle getTextStyle({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 21.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return GoogleFonts.poppins(
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: fontSize.sp / lineHeight.sp,
    color: color,
  );
}

TextStyle getTextStyle1({
  double fontSize = 14.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 21.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  return TextStyle(
    fontFamily: 'SF Pro Display',
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight / fontSize,
    color: color,
  );
}

TextStyle getTextStyle2({
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.w400,
  double lineHeight = 21.0,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  String fontFamily = defaultTargetPlatform == TargetPlatform.iOS
      ? 'SF Pro Display'
      : 'Roboto'; // Use SF Pro Display for iOS, Roboto for others
  return TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    height: lineHeight / fontSize,
    color: color,
  );
}

TextStyle getTextStyle3({
  double fontSize = 16.0,
  FontWeight fontWeight = FontWeight.w400,
  TextAlign textAlign = TextAlign.center,
  Color color = Colors.black,
}) {
  String fontFamily = defaultTargetPlatform == TargetPlatform.iOS
      ? 'SF Pro Display'
      : 'Roboto';
  return TextStyle(
    fontFamily: fontFamily,
    fontSize: fontSize.sp,
    fontWeight: fontWeight,
    color: color,
  );
}
