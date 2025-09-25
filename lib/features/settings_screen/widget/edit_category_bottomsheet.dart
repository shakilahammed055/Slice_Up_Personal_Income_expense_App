import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';

class EditCategoryBottomSheet extends StatelessWidget {
  final bool isIncome;
  final String currentCategory;
  final Function(String) onCategoryEdited;
  final String? title;

  const EditCategoryBottomSheet({
    super.key,
    required this.isIncome,
    required this.currentCategory,
    required this.onCategoryEdited,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final TextEditingController categoryController = TextEditingController(
      text: currentCategory,
    );

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: ShapeDecoration(
          color: isDark
              ? Color(0xFF262626)
              : AppColors.textWhite, // Fixed white background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
        ),
        height:
            MediaQuery.of(context).size.height * 0.85, // 85% of screen height
        width: MediaQuery.of(context).size.width, // Full screen width
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height *
                0.8, // Reinforce 80% height
            maxWidth: MediaQuery.of(context).size.width, // Full width
          ),
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width, // Full width
                padding: EdgeInsets.only(
                  bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
                ),
                clipBehavior: Clip.antiAlias,
                decoration: ShapeDecoration(
                  color: isDark
                      ? Color(0xFF262626)
                      : AppColors.textWhite, // Fixed white background
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 56,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24, // Placeholder for icon
                            height: 24,
                          ),
                          Text(
                            title ?? 'Add New Category'.tr,
                            style: getTextStyle2(
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: isDark
                                  ? AppColors.textWhite
                                  : AppColors.black, // Fixed black close icon
                            ),
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.deepGrey
                              : Color(0xFFEDEDF0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: TextField(
                          cursorHeight: 20,
                          controller: categoryController,
                          decoration: InputDecoration(
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Enter category name',
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
                            color: isDark
                                ? AppColors.textWhite
                                : AppColors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (value) {
                            final newCategory = value.trim();
                            if (newCategory.isNotEmpty &&
                                newCategory != currentCategory) {
                              onCategoryEdited(newCategory);
                            } else if (newCategory.isEmpty) {
                              // Removed snackbar
                            }
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: GestureDetector(
                        onTap: () {
                          final newCategory = categoryController.text.trim();
                          if (newCategory.isNotEmpty &&
                              newCategory != currentCategory) {
                            onCategoryEdited(newCategory);
                          } else if (newCategory.isEmpty) {
                            // Removed snackbar
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 52,
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          decoration: ShapeDecoration(
                            color: Color(0xFF2A31EF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'Save',
                              style: getTextStyle2(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}