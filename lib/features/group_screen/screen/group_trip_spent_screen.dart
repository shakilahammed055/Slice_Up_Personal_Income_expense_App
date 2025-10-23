// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/category_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/category_bottomsheet.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_calender_dialog.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_paid_friend.dart';
import 'package:teddy_5618/features/group_screen/widgets/group_trip_shared_with_bottom.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
import 'package:teddy_5618/features/settings_screen/widget/currency_bottomsheet.dart';

class GroupTripSpentScreen extends StatelessWidget {
  final String? groupId; // Add groupId parameter
  final Map<String, dynamic>? transactionToEdit;

  GroupTripSpentScreen({super.key, this.groupId, this.transactionToEdit});

  final GroupTripSpentController controller = Get.put(
    GroupTripSpentController(),
  );
  final SettingController settingController = Get.put(SettingController());
  final categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize group ID if provided (only once)
    if (groupId != null &&
        groupId!.isNotEmpty &&
        controller.currentGroupId.value != groupId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        debugPrint("🎯 Setting group ID to: $groupId");
        controller.setGroupId(groupId!);
      });
    }

    // If a transaction is provided for editing, load it into the controller
    if (transactionToEdit != null && transactionToEdit!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await controller.loadExpenseForEditing(transactionToEdit!);
      });
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.textWhite,
        leading: IconButton(
          icon: const Icon(CupertinoIcons.back, size: 30),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Obx(
                () => Text(
                  controller.selectedDate.value != null
                      ? DateFormat(
                          'dd MMM yyyy',
                        ).format(controller.selectedDate.value!)
                      : 'Select Date',
                  style: getTextStyle2(
                    color: controller.selectedDate.value != null
                        ? (isDark ? AppColors.textWhite : AppColors.black)
                        : Colors.grey,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => showCalendarBottomSheet(context),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/delete.svg',
              height: 17.h,
              width: 15.w,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) => ConfirmationDialog(
                  title: 'Are you sure you want to delete this?'.tr,
                  content: 'Once deleted, your information won’t be saved.'.tr,
                  button1: 'Stay'.tr,
                  button2: 'Leave'.tr,
                  onConfirm: () {
                    // ✅ Custom logic on confirm
                    Get.find<ExpenseController>().clearForm();
                    Get.snackbar('Success'.tr, 'Entry deleted successfully'.tr);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Amount'.tr,
                          style: getTextStyle2(
                            color: const Color(0xFF828282),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        Obx(
                          () => Container(
                            height: 44.h,
                            width: 247.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: isDark
                                  ? AppColors.deepGrey
                                  : AppColors.lightGreyContainer,
                              border: Border.all(
                                color: controller.isTotalAmountFocused.value
                                    ? (isDark
                                          ? AppColors.textWhite
                                          : AppColors.black)
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: TextField(
                                controller: controller.totalAmountController,
                                focusNode: controller.totalAmountFocusNode,
                                onTap: () =>
                                    controller.onTotalAmountFocusChange(true),
                                onEditingComplete: () =>
                                    controller.onTotalAmountFocusChange(false),
                                style: getTextStyle2(
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Enter Amount'.tr,
                                  hintStyle: const TextStyle(
                                    color: Colors.grey,
                                  ),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      children: [
                        SizedBox(height: 25.h),
                        Container(
                          height: 44.h,
                          width: 83.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isDark
                                ? AppColors.deepGrey
                                : AppColors.lightGreyContainer,
                          ),
                          child: GestureDetector(
                            onTap: () =>
                                showCurrencyDialog(context, settingController),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Obx(
                                  () => Text(
                                    settingController.currency.value,
                                    style: getTextStyle3(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Icon(Icons.keyboard_arrow_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Paid by'.tr,
                          style: getTextStyle2(
                            color: const Color(0xFF828282),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            showMaterialModalBottomSheet(
                              isDismissible: false,
                              enableDrag: false,
                              context: context,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(34),
                                ),
                              ),
                              builder: (context) =>
                                  const GroupTripPaidFriendBottom(),
                            );
                          },
                          child: Obx(
                            () => Container(
                              height: 44.h,
                              width: 165.w,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.deepGrey
                                    : AppColors.lightGreyContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller
                                                .selectedPaidByFriend
                                                .value
                                                .length >
                                            10
                                        ? controller.selectedPaidByFriend.value
                                              .substring(0, 10)
                                        : controller.selectedPaidByFriend.value,
                                    style: getTextStyle2(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.h),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(
                          () => Text(
                            controller.isEquallySelected.value
                                ? 'Share with (Equally)'.tr
                                : 'Share with (Custom)'.tr,
                            style: getTextStyle2(
                              color: const Color(0xFF828282),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        GestureDetector(
                          onTap: () {
                            showMaterialModalBottomSheet(
                              context: context,
                              isDismissible: false,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(34),
                                ),
                              ),
                              builder: (context) =>
                                  const GroupTripSharedWithBottom(),
                            );
                          },
                          child: Obx(
                            () => Container(
                              height: 44.h,
                              width: 165.w,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.deepGrey
                                    : AppColors.lightGreyContainer,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    controller
                                            .selectedSharedWithFriends
                                            .isNotEmpty
                                        ? '${controller.selectedSharedWithFriends.length} people'
                                        : 'Select Friend',
                                    style: getTextStyle2(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category'.tr,
                          style: getTextStyle2(
                            color: const Color(0xFF828282),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8.h),

                        GestureDetector(
                          onTap: () {
                            final controller =
                                Get.find<GroupTripSpentController>();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return CategoryBottomsheet(
                                  types: controller.expenseTypes,
                                  isIncome:
                                      false, // not needed but kept since your widget expects it
                                  onTypeSelected: (selectedType) {
                                    controller.setType(selectedType);
                                    controller.selectedCategoryName.value =
                                        selectedType;
                                    // No need to extract icon separately since selectedType already contains it
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            );
                          },
                          child: Obx(() {
                            final controller =
                                Get.find<GroupTripSpentController>();
                            return Container(
                              height: 44.h,
                              width: 165.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? AppColors.deepGrey
                                    : AppColors.lightGreyContainer,
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                children: [
                                  Text(
                                    controller
                                            .selectedCategoryName
                                            .value
                                            .isNotEmpty
                                        ? (controller
                                                      .selectedCategoryName
                                                      .value
                                                      .length >
                                                  12
                                              ? '${controller.selectedCategoryName.value.substring(0, 12)}...'
                                              : controller
                                                    .selectedCategoryName
                                                    .value)
                                        : 'Select Category'.tr,
                                    style: getTextStyle2(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color:
                                          controller
                                              .selectedCategoryName
                                              .value
                                              .isNotEmpty
                                          ? (isDark
                                                ? Colors.white
                                                : Colors.black)
                                          : const Color(0xFF828282),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.keyboard_arrow_down),
                                ],
                              ).marginSymmetric(horizontal: 8),
                            );
                          }),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Note'.tr,
                          style: getTextStyle3(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF828282),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Focus(
                          onFocusChange: controller.onNoteFocusChange,
                          child: Obx(
                            () => Container(
                              height: 44.h,
                              width: 165.w,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: isDark
                                    ? AppColors.deepGrey
                                    : AppColors.lightGreyContainer,
                                border: Border.all(
                                  color: controller.isNoteFocused.value
                                      ? (isDark
                                            ? AppColors.textWhite
                                            : AppColors.black)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),

                              child: Center(
                                child: TextField(
                                  controller: controller.noteController,
                                  style: getTextStyle2(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration:  InputDecoration(
                                    isDense: true,
                                    hintText: 'Add Notes'.tr,
                                    hintStyle: TextStyle(
                                      color: Color(0xFF828282),
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Added extra space for save button
                SizedBox(height: 450.h),
                // Divider(),
              ],
            ).marginSymmetric(horizontal: 24),
          ),
          // Save button - always visible
          Positioned(
            left: 24,
            right: 24,
            bottom: 20,
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard before submitting
                FocusScope.of(context).unfocus();

                // Check if category is selected, if not show CategoryBottomsheet first
                if (controller.selectedCategoryName.value.isEmpty) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CategoryBottomsheet(
                        types: controller.expenseTypes,
                        isIncome: false,
                        onTypeSelected: (selectedType) {
                          controller.setType(selectedType);
                          controller.selectedCategoryName.value = selectedType;
                          Navigator.pop(context);
                          // Removed automatic save - user needs to click save again
                        },
                      );
                    },
                  );
                } else {
                  // If category is already selected, proceed directly
                  controller.addGroupExpense();
                }
              },
              child: Obx(
                () => Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Color(0xFF00D460),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Obx(
                            () => Text(
                              controller.buttonText.value,
                              style: getTextStyle3(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
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
