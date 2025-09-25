import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';

class GroupTripDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<String> options;
  final void Function(String) onChanged;

  const GroupTripDropdown({
    super.key,
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Obx(() {
      return Container(
        height: 44.h,
        width: MediaQuery.of(context).size.width / 2.9,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.backgroundDark
              : AppColors.lightGreyContainer,

          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            icon: const Icon(Icons.keyboard_arrow_down),
            iconEnabledColor: isDark ? AppColors.textWhite : AppColors.black,
            dropdownColor: isDark
                ? AppColors.backgroundDark
                : AppColors.lightGreyContainer,
            style: getTextStyle2(
              color: isDark ? AppColors.textWhite : AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            items: options
                .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                .toList(),
            onChanged: (newValue) {
              if (newValue != null) {
                onChanged(newValue);
              }
            },
          ),
        ),
      );
    });
  }
}
