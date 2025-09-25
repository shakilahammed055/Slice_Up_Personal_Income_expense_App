 import 'package:flutter/material.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

Widget buildFormField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
    FocusNode? focusNode,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label,
            style: getTextStyle2(
              color: Color(0xFF828282),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: TextField(
              cursorHeight: 20,
              controller: controller,
              readOnly: readOnly,
              keyboardType: keyboardType,
              maxLines: maxLines,
              onTap: onTap,
              focusNode: focusNode,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? AppColors.deepGrey
                    : AppColors.lightGreyContainer,
                border: InputBorder.none,
                enabledBorder: InputBorder.none, // No border when enabled
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: getTextStyle2(
                color: isDark ? AppColors.textWhite : AppColors.black,

                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }