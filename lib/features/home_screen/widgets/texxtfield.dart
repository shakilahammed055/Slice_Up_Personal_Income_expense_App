import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class TexxtField extends StatelessWidget {
  final TextEditingController? controller;
  final VoidCallback? onClear;

  const TexxtField({super.key, this.controller, this.onClear});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Keep your original container color logic
    final Color containerColor = isDark
        ? AppColors.deepGrey
        : AppColors.lightGreyContainer;

    // ✅ Keep your original text color logic
    final Color textColor = isDark
        ? AppColors.textWhite
        : AppColors.backgroundDark;

    // ✅ Keep your original hint color (0xFFAAAAAA for dark mode)
    final Color hintColor = isDark
        ? const Color(0xFFAAAAAA)
        : AppColors.textGrey;

    return Padding(
      // 🔹 Changed: Added side padding around the whole Row
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            height: 44.h,
            width: MediaQuery.of(context).size.width / 1.4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: containerColor,
            ),
            child: Center(
              child: TextField(
                controller: controller,
                style: getTextStyle2(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                decoration: InputDecoration(
                  isDense: true,
                  // 🔹 Changed: Added inner padding for better spacing
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  hintText: 'Search for category or title'.tr,
                  hintStyle: getTextStyle2(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: hintColor,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.transparent),
                  ),
                ),
              ),
            ),
          ),
          // 🔹 Changed: use SizedBox instead of marginOnly
          const SizedBox(width: 16),
          GestureDetector(
            onTap: onClear,
            child: Text(
              'Delete'.tr,
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
