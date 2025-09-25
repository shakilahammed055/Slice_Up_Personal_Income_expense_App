import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';

class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? borderRadius;
  final bool isEnabled;
  final Widget? icon;
  final MainAxisAlignment? mainAxisAlignment;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.fontSize,
    this.fontWeight,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.borderRadius,
    this.isEnabled = true,
    this.icon,
    this.mainAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onPressed : null,
      child: Container(
        width: double.infinity,
        height: height ?? 52.h,
        padding: padding ?? EdgeInsets.symmetric(horizontal: 15.w),
        margin: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: isEnabled
              ? (backgroundColor ?? const Color(0xFF2A31EF))
              : Colors.grey,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 30.r),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, SizedBox(width: 8.w)],
            Text(
              text.tr,
              textAlign: TextAlign.center,
              style: getTextStyle3(
                color: textColor ?? Colors.white,
                fontSize: fontSize ?? 16.sp,
                fontWeight: fontWeight ?? FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
