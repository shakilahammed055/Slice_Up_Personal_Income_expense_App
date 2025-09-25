import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/type_bottom_sheet1.dart';

Widget buildTypeBottomSheet(
    BuildContext context,
    ExpenseController controller, {
    bool isIncome = false,
  }) {
    final types = isIncome ? controller.incomeTypes : controller.expenseTypes;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            'Type'.tr,
            style: getTextStyle2(
              color: Color(0xFF828282),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Obx(
            () => GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.80,
                      child: TypeBottomSheet(
                        types: types,
                        onTypeSelected: (type) {
                          controller.setType(type);
                          Navigator.pop(context);
                        },
                        isIncome: isIncome,
                      ),
                    );
                  },
                );
              },
              child: AbsorbPointer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: TextField(
                    controller: TextEditingController(
                      text: controller.selectedType.value.isEmpty
                          ? 'Select Type'.tr
                          : controller.selectedType.value,
                    ),
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
                      //  Color(0xFFEDEDF0),
                      border: InputBorder.none, // No border
                      enabledBorder: InputBorder.none, // No border when enabled
                      focusedBorder: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: Icon(Icons.arrow_drop_down, size: 20),
                    ),
                    style: getTextStyle2(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      // color: Color(0xFF141414),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      lineHeight: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }