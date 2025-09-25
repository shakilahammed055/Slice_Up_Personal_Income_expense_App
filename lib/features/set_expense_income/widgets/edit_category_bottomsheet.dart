import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class EditCategoryBottomSheet extends StatelessWidget {
  final bool isIncome;
  final String currentCategory;
  final Function(String) onCategoryEdited;

  const EditCategoryBottomSheet({
    super.key,
    required this.isIncome,
    required this.currentCategory,
    required this.onCategoryEdited,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController categoryController = TextEditingController(
      text: currentCategory,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(
          context,
        ).unfocus(); // Dismiss keyboard when tapping outside
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: 260),
          child: SingleChildScrollView(
            child: Container(
              width: 390,
              padding: EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              decoration: ShapeDecoration(
                color: isDark ? AppColors.black : AppColors.textWhite,
                // color: Colors.white,
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
                        Container(
                          padding: EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                 icon: SvgPicture.asset(
                                  'assets/icons/delete.svg',
                                  height: 17.h,
                                  width: 15.w,
                                ),
                                onPressed: () {
                                  FocusScope.of(context).unfocus();
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 278,
                                child: Text(
                                  'Edit Category'.tr,
                                  textAlign: TextAlign.center,
                                  style: getTextStyle2(
                                    color: Color(0xFF141414),
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
                          child: SizedBox(width: 24, height: 24),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 342,
                          height: 48,
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFFEDEDF0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            cursorHeight: 20,
                            controller: categoryController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Enter category name'.tr,
                              hintStyle: getTextStyle2(
                                color: Color(0xFF828282),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                            style: getTextStyle2(
                              color: Color(0xFF141414),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            textInputAction: TextInputAction.done,
                            onSubmitted: (value) {
                              final newCategory = value.trim();
                              if (newCategory.isNotEmpty &&
                                  newCategory != currentCategory) {
                                onCategoryEdited(newCategory);
                                Get.snackbar(
                                  'Success'.tr,
                                  'Category updated to "$newCategory"',
                                );
                              } else if (newCategory.isEmpty) {
                                Get.snackbar(
                                  'Error'.tr,
                                  'Please enter a category name'.tr,
                                );
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: 80,
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(color: Color(0xFFFCFCFD)),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            final newCategory = categoryController.text.trim();
                            if (newCategory.isNotEmpty &&
                                newCategory != currentCategory) {
                              onCategoryEdited(newCategory);
                              Get.snackbar(
                                'Success'.tr,
                                'Category updated to "$newCategory"',
                              );
                            } else if (newCategory.isEmpty) {
                              Get.snackbar(
                                'Error'.tr,
                                'Please enter a category name'.tr,
                              );
                            }
                          },
                          child: Container(
                            width: 358,
                            height: 52,
                            padding: EdgeInsets.symmetric(horizontal: 24),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: Color(0xFF2A31EF),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.81,
                                  child: Text(
                                    'Save',
                                    textAlign: TextAlign.center,
                                    style: getTextStyle2(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
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