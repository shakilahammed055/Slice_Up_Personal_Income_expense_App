import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/common/widgets/common_button.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AddCategoryBottomSheet extends StatelessWidget {
  final bool isIncome;
  final Function(String) onCategoryAdded;

  const AddCategoryBottomSheet({
    super.key,
    required this.isIncome,
    required this.onCategoryAdded,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController categoryController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final expenseController = Get.find<ExpenseController>();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: ShapeDecoration(
          color:
          isDark ? Color(0xFF262626) : AppColors.textWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color:
              
                 isDark ? Color(0xFF262626) : AppColors.textWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 56,
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: EdgeInsets.all(15),
                            // child: SizedBox(width: 24, height: 24),
                            child: Image.asset(
                              isDark
                                  ? IconPath.backarrowwhite
                                  : IconPath.backarrow,
                              scale: 4,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Text(
                                  'Category'.tr,
                                  textAlign: TextAlign.center,
                                  style: getTextStyle2(
                              color: isDark ? AppColors.textWhite :  Color(0xFF262626),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.close,
                               color: isDark
                                      ? AppColors.textWhite
                                      : Color(0xFF262626),
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,

                    // height: 48.h,.
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 13.h,
                    ),
                    margin: EdgeInsets.all(24.sp),
                    decoration: BoxDecoration(
                      color: 
                      isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: TextField(
                        cursorHeight: 20,
                        controller: categoryController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Enter category name'.tr,
                          hintStyle: getTextStyle2(
                            color: Color(0xFF828282),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            lineHeight: 25,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        style: getTextStyle2(
                          color: Color(0xFF141414),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          lineHeight: 25,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: (value) async {
                          final newCategory = value.trim().isEmpty
                              ? 'New Category'.tr
                              : value.trim();
                          final success = await expenseController.createCategory(isIncome, newCategory);
                          if (success) {
                            EasyLoading.showSuccess('Category "$newCategory" added');
                            onCategoryAdded(newCategory);
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  CommonButton(
                    text: 'Save',
                    onPressed: () async {
                      final newCategory = categoryController.text.trim().isEmpty
                          ? 'New Category'.tr
                          : categoryController.text.trim();
                      final success = await expenseController.createCategory(isIncome, newCategory);
                      if (success) {
                        EasyLoading.showSuccess('Category "$newCategory" added');
                        onCategoryAdded(newCategory);
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}