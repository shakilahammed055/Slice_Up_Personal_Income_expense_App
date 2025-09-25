import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/controller/category_bottomsheet_controller.dart';

// ignore: use_key_in_widget_constructors
class CategoryTypeBottomSheet extends StatelessWidget {
  final CategoryController controller = Get.find<CategoryController>();

  final List<Map<String, String>> categories = [
    {'icon': '🚗', 'name': 'Transport'},
    {'icon': '🍔', 'name': 'Food'},
    {'icon': '👕', 'name': 'Fashion'},
    {'icon': '💄', 'name': 'Beauty'},
    {'icon': '✈️', 'name': 'Travel'},
    {'icon': '💊', 'name': 'Clinic'},
    // {'icon': '🎬', 'name': 'Entertainment'},
    {'icon': '🍔', 'name': 'Food'},
    {'icon': '✈️', 'name': 'Travel'},
    // {'icon': '🎬', 'name': 'Entertainment'},
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar with back, title, and close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Image.asset(IconPath.leftIcon, scale: 3.5),
                ),
                Text(
                  'Category'.tr,
                  style: getTextStyle2(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                ),
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.close, size: 30),
                ),
              ],
            ).marginSymmetric(horizontal: 16, vertical: 16),

            // Add / Edit section
            Container(
              height: MediaQuery.of(context).size.height / 15,
              width: double.infinity,
              color: isDark ? AppColors.black : AppColors.lightGreyContainer,
              child: Row(
                children: [
                  Text(
                    'Add / Edit'.tr,
                    style: getTextStyle2(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const Spacer(),
                  Image.asset(
                    IconPath.editIcon,
                    scale: 4,

                    color: isDark ? AppColors.textWhite : AppColors.black,
                  ),
                ],
              ).marginSymmetric(horizontal: 24),
            ),

            // Category chips
            Expanded(child: _buildCategoryChips(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(
      () => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(categories.length, (index) {
            final isSelected = controller.selectedIndex.value == index;
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                controller.selectCategory(index, category['icon']!,  category['name']!,
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.textWhite : AppColors.black)
                      : (isDark
                            ? AppColors.backgroundDark
                            : AppColors.textWhite),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderGrey, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category['icon']!,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      category['name']!,
                      style: getTextStyle2(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isSelected
                            ? (isDark ? AppColors.black : AppColors.textWhite)
                            : (isDark ? AppColors.textWhite : AppColors.black),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
