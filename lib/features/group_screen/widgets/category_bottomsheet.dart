import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_add_category_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

class CategoryBottomsheet extends StatelessWidget {
  final RxList<String> types;
  final Function(String) onTypeSelected;
  final bool isIncome;
  const CategoryBottomsheet({
    super.key,
    required this.types,
    required this.onTypeSelected,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // ✅ Inject GroupTripSpentController
    final groupTripController = Get.find<GroupTripSpentController>();

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 184),
        child: Container(
          width: double.infinity,
          clipBehavior: Clip.antiAlias,
          decoration: ShapeDecoration(
            color: isDark ? const Color(0xFF262626) : AppColors.textWhite,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
          ),
          child: Column(
            children: [
              // -------------------- Header --------------------
              Container(
                width: double.infinity,
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    const SizedBox(width: 48),
                    Expanded(
                      child: Text(
                        'Category'.tr,
                        textAlign: TextAlign.center,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
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

              // -------------------- Body --------------------
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Add new category
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) {
                              return SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.80,
                                child: GroupAddCategoryBottomsheet(
                                  isIncome: isIncome,
                                  onCategoryAdded: (newCategory) {
                                    // Add category via API
                                    groupTripController.addCategory(
                                      newCategory,
                                    );
                                    Navigator.pop(context);
                                    Navigator.pop(context);
                                    groupTripController.setType(newCategory);
                                  },
                                ),
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 56,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: ShapeDecoration(
                            color: isDark
                                ? AppColors.deepGrey
                                : const Color(0xFFEDEDF0),
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
                            children: [
                              Text(
                                'Add new'.tr,
                                style: getTextStyle2(
                                  color: const Color(0xFF828282),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Spacer(),
                              const Icon(Icons.add, color: Color(0xFF828282)),
                            ],
                          ),
                        ),
                      ),

                      // Category list
                      Obx(
                        () => Column(
                          children: types.map((type) {
                            return GestureDetector(
                              onTap: () {
                                // Select the category and close the bottom sheet
                                onTypeSelected(type);
                              },
                              child: Container(
                                height: 54,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 16,
                                ),
                                decoration: ShapeDecoration(
                                  color: isDark
                                      ? const Color(0xFF262626)
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
                                  children: [
                                    Expanded(
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
                                    Obx(
                                      () => Icon(
                                        groupTripController
                                                    .selectedType
                                                    .value ==
                                                type
                                            ? Icons.check
                                            : null,
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    // Edit
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
                                                      groupTripController
                                                          .editCategory(
                                                            type,
                                                            newCategory,
                                                          );
                                                      Navigator.pop(context);
                                                    },
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(Icons.edit_outlined),
                                    ),
                                    const SizedBox(width: 10),
                                    // Delete
                                    GestureDetector(
                                      onTap: () {
                                        groupTripController.deleteCategory(
                                          type,
                                        );
                                        Navigator.pop(context);
                                        Get.snackbar(
                                          'Success'.tr,
                                          'Category "$type" deleted',
                                        );
                                      },
                                      child: const Icon(
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
            ],
          ),
        ),
      ),
    );
  }
}
