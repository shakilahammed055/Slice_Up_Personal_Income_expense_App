import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/add_category_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

class TypeBottomSheet extends StatelessWidget {
  final RxList<String> types;
  final Function(String) onTypeSelected;
  final bool isIncome;

  const TypeBottomSheet({
    super.key,
    required this.types,
    required this.onTypeSelected,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 184),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isDark ? Color(0xFF262626) : AppColors.textWhite,
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
                    SizedBox(width: 48),
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
                                color: isDark
                                    ? AppColors.textWhite
                                    : AppColors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? Color(0xFF262626) : AppColors.textWhite,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.80,
                                  child: AddCategoryBottomSheet(
                                    isIncome: isIncome,
                                    onCategoryAdded: (newCategory) {
                                      Get.find<ExpenseController>().addCategory(
                                        newCategory,
                                        isIncome,
                                      );
                                      Navigator.pop(
                                        context,
                                      ); // Close AddCategoryBottomSheet
                                      Navigator.pop(
                                        context,
                                      ); // Close TypeBottomSheet
                                      Get.find<ExpenseController>().setType(
                                        newCategory,
                                      );
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            clipBehavior: Clip.antiAlias,
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : const Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  width: 1,
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 250,
                                  child: Text(
                                    'Add new'.tr,
                                    style: getTextStyle2(
                                      color: Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  height: 32,
                                  padding: EdgeInsets.symmetric(horizontal: 4),
                                  child: Icon(
                                    Icons.add,
                                    color: Color(0xFF828282),
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Obx(
                          () => Column(
                            children: types.map((type) {
                              return GestureDetector(
                                onTap: () {
                                  onTypeSelected(type);
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? Color(0xFF262626)
                                        : AppColors.textWhite,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: isDark
                                            ? AppColors.deepGrey
                                            : const Color(0xFFEDEDF0),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: Text(
                                          type,
                                          style: getTextStyle3(
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 32,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Obx(() {
                                          final expenseController =
                                              Get.find<ExpenseController>();
                                          return Icon(
                                            expenseController
                                                        .selectedType
                                                        .value ==
                                                    type
                                                ? Icons.check
                                                : null,
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            size: 24,
                                          );
                                        }),
                                      ),
                                      SizedBox(width: 20),
                                      GestureDetector(
                                        onTap: () {
                                          showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            builder: (context) {
                                              return SizedBox(
                                                height:
                                                    MediaQuery.of(
                                                      context,
                                                    ).size.height *
                                                    0.80,
                                                child: EditCategoryBottomSheet(
                                                  isIncome: isIncome,
                                                  currentCategory: type,
                                                  onCategoryEdited:
                                                      (newCategory) {
                                                        final expenseController =
                                                            Get.find<
                                                              ExpenseController
                                                            >();
                                                        expenseController
                                                            .editCategory(
                                                              type,
                                                              newCategory,
                                                              isIncome,
                                                            );
                                                        Navigator.pop(context);
                                                      },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                        child: Icon(Icons.edit_outlined),
                                      ),
                                      SizedBox(width: 10),
                                      GestureDetector(
                                        onTap: () {
                                          Get.defaultDialog(
                                            backgroundColor: isDark
                                                ? AppColors.deepGrey
                                                : Color(
                                                    0xffF2F2F2,
                                                  ).withValues(alpha: 1.1),
                                            title:
                                                'Are you sure you want to delete  "$type"?',
                                            titleStyle: getTextStyle2(
                                              color: isDark
                                                  ? AppColors.textWhite
                                                  : AppColors.black,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            content: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'This action cannot be undone.'
                                                      .tr,
                                                  textAlign: TextAlign.center,
                                                ),
                                                SizedBox(height: 20),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () =>
                                                          Navigator.pop(
                                                            context,
                                                          ),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 12,
                                                            ),
                                                        decoration: ShapeDecoration(
                                                           color: isDark
                                                              ? Color(
                                                                  0xFF262626,
                                                                )
                                                              : AppColors.black,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  05,
                                                                ),
                                                            side: BorderSide(
                                                              width: 0.5,
                                                              color: 
                                                                   AppColors
                                                                        .black,
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Cancel',
                                                          style: getTextStyle2(
                                                            color: Color(
                                                              0xFF007AFF,
                                                            ),
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    GestureDetector(
                                                      onTap: () {
                                                        final expenseController =
                                                            Get.find<
                                                              ExpenseController
                                                            >();
                                                        expenseController
                                                            .deleteCategory(
                                                              type,
                                                              isIncome,
                                                            );
                                                        Navigator.pop(context);
                                                        Get.snackbar(
                                                          'Success'.tr,
                                                          'Category "$type" deleted',
                                                        );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal: 16,
                                                              vertical: 12,
                                                            ),
                                                        decoration: ShapeDecoration(
                                                          color: isDark
                                                              ? Color(
                                                                  0xFF262626,
                                                                )
                                                              : AppColors.black,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  05,
                                                                ),
                                                            side: BorderSide(
                                                              width: 0.5,
                                                              color: Color(
                                                                0x5B3C3C43,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        child: Text(
                                                          'Delete'.tr,
                                                          style: getTextStyle2(
                                                            color: Color(
                                                              0xFF007AFF,
                                                            ),
                                                            fontSize: 17,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            radius: 12,
                                          );
                                        },
                                        child: Icon(
                                          Icons.delete_outline_outlined,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 390,
                      padding: EdgeInsets.only(
                        top: 16,
                        left: 20,
                        right: 20,
                        bottom: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: isDark ? AppColors.black : Color(0xFFFCFCFD),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD0D3D9)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 112,
                              right: 112,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 134,
                                  height: 4,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF2B2F38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
