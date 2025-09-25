import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';

class GroupTripFriendSpentAmount extends StatelessWidget {
  const GroupTripFriendSpentAmount({
    super.key,
    required this.controller,
    required this.name,
    required this.initials,
    required this.color,
    required this.fieldMap, // 👈 NEW: which map to use (equal/custom/multiple)
    this.showCheckbox = true,
  });

  final GroupTripSpentController controller;
  final String name;
  final String initials;
  final Color color;
  final bool showCheckbox;
  final Map<String, TextEditingController> fieldMap; // 👈 NEW

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ initialize using the provided map
    controller.initializeFriendControllerIfAbsent(name, fieldMap);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showCheckbox) ...[
            Obx(() {
              final isChecked = controller.isFriendChecked(name);
              return GestureDetector(
                onTap: () => controller.toggleFriendCheckbox(name),
                child: Container(
                  height: 20,
                  width: 20,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? (isDark ? AppColors.textWhite : AppColors.black)
                        : AppColors.lightGreyContainer,
                    border: Border.all(color: Colors.black, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: isChecked
                      ? Center(
                          child: Icon(
                            Icons.check,
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            size: 15,
                            shadows: const [
                              Shadow(blurRadius: 1, offset: Offset(1, 1)),
                            ],
                          ),
                        )
                      : null,
                ),
              );
            }),
            // const SizedBox(width: 10),
          ],

          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 12,
                child: Text(
                  initials,
                  style: getTextStyle2(color: AppColors.textWhite),
                ),
              ),
              12.horizontalSpace,
              Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle2(
                  fontSize: 14,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ).marginOnly(top: 10),

          const SizedBox(width: 10),

          // const Spacer(),
          GestureDetector(
            onTap: () {
              // focus & move caret to end
              final tc = fieldMap[name];
              if (tc != null) {
                FocusScope.of(
                  context,
                ).requestFocus(FocusNode()..requestFocus());
                tc.selection = TextSelection.fromPosition(
                  TextPosition(offset: tc.text.length),
                );
              }
            },
            child: Container(
              height: 44.h,
              width: MediaQuery.of(context).size.width / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: isDark
                    ? AppColors.deepGrey
                    : AppColors.lightGreyContainer,
              ),
              child: Center(
                child: TextField(
                  controller: fieldMap[name], // 👈 use the provided map
                  style: getTextStyle2(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  autofocus: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: "",
                    hintStyle: getTextStyle2(color: AppColors.textGrey),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.only(left: 10),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
