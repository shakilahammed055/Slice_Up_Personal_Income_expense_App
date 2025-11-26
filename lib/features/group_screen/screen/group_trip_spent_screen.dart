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
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_home_screen.dart';

class GroupTripSpentScreen extends StatelessWidget {
  final String? groupId; // Add groupId parameter
  final Map<String, dynamic>? transactionToEdit;

  const GroupTripSpentScreen({super.key, this.groupId, this.transactionToEdit});

  // Initialize controllers and data when screen loads
  void _initializeScreen(GroupTripSpentController controller) {
    // Initialize group ID and load expense data for editing
    if (transactionToEdit != null && transactionToEdit!.isNotEmpty) {
      final transactionId =
          transactionToEdit!['_id'] ??
          transactionToEdit!['expenseId'] ??
          transactionToEdit!['id'] ??
          '';

      debugPrint("📝 initState: Loading expense for editing: $transactionId");

      // Start fetching group-specific data immediately so UI updates (like
      // currency) can begin as soon as possible. Keep loading the expense
      // for editing scheduled after the first frame to avoid build-time side
      // effects.
      if (groupId != null && groupId!.isNotEmpty) {
        debugPrint("🎯 initState: Setting group ID for editing: $groupId");
        // Call synchronously so network fetch for currency starts now
        controller.setGroupId(groupId!);
      }

      // Schedule expense loading after frame to preserve previous timing
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Small delay to allow initial group fetch to start
        await Future.delayed(const Duration(milliseconds: 100));
        debugPrint("📝 initState: About to call loadExpenseForEditing");
        await controller.loadExpenseForEditing(transactionToEdit!);
        debugPrint(
          "✅ initState: Finished loadExpenseForEditing, date is now: ${controller.selectedDate.value}",
        );
      });
    } else if (groupId != null && groupId!.isNotEmpty) {
      // New expense mode: just set group ID
      // Call synchronously so currency/network fetch begins immediately
      debugPrint("🎯 initState: Setting group ID for new expense: $groupId");
      controller.setGroupId(groupId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ FIX: Use groupId as tag to match SliceupPageScreen's tag
    // This ensures both screens share the same controller instance for real-time updates
    final controllerTag = groupId ?? 'groupTripSpent';

    // Get or create controllers with proper initialization
    // Use Get.lazyPut for lazy initialization to avoid recreating disposed controllers
    if (!Get.isRegistered<GroupTripSpentController>(tag: controllerTag)) {
      Get.lazyPut<GroupTripSpentController>(
        () => GroupTripSpentController(),
        tag: controllerTag,
      );
    }

    final controller = Get.find<GroupTripSpentController>(tag: controllerTag);

    if (!Get.isRegistered<SettingController>()) {
      Get.put(SettingController());
    }

    if (!Get.isRegistered<CategoryController>()) {
      Get.put(CategoryController());
    }

    // Initialize screen data once
    _initializeScreen(controller);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Debug trace: print controller instance and current note after frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        debugPrint(
          'UI post-frame — controller.hash=${controller.hashCode}, note="${controller.noteController.text}"',
        );
      } catch (e) {
        debugPrint('Error in post-frame callback: $e');
      }
    });

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
                onTap: () => showCalendarBottomSheet(
                  context,
                  controllerTag: controllerTag,
                ),
                child: const Icon(Icons.keyboard_arrow_down),
              ),
            ],
          ),
        ),
        actions: [
          Obx(() {
            final disableDelete =
                controller.isAllSettled.value &&
                controller.editingExpenseId.value.isNotEmpty;
            return IconButton(
              icon: SvgPicture.asset(
                'assets/icons/delete.svg',
                height: 17.h,
                width: 15.w,
                color: disableDelete
                    ? Colors.grey
                    : (isDark ? AppColors.textWhite : AppColors.black),
              ),
              onPressed: () {
                // If the group is fully settled, prevent editing/deleting existing expenses
                if (controller.isAllSettled.value &&
                    controller.editingExpenseId.value.isNotEmpty) {
                  Get.snackbar('Info', 'All Settled Up');
                  return;
                }

                // Only show delete button behavior if we're editing an existing expense
                if (controller.editingExpenseId.value.isEmpty) {
                  // Not editing, just clear form
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) => ConfirmationDialog(
                      title: 'Are you sure you want to discard this?'.tr,
                      content:
                          'Once discarded, your information won\'t be saved.'
                              .tr,
                      button1: 'Stay'.tr,
                      button2: 'Discard'.tr,
                      onConfirm: () {
                        controller.clearForm();
                        Get.back(); // Close the screen
                        Get.snackbar(
                          'Discarded'.tr,
                          'Entry discarded successfully'.tr,
                        );
                      },
                    ),
                  );
                } else {
                  // Editing mode - delete the expense
                  showCupertinoDialog(
                    context: context,
                    builder: (BuildContext context) => ConfirmationDialog(
                      title: 'Are you sure you want to delete this expense?'.tr,
                      content: 'This action cannot be undone.'.tr,
                      button1: 'Cancel'.tr,
                      button2: 'Delete'.tr,
                      onConfirm: () async {
                        debugPrint(
                          '🗑️ Delete confirmed for expense: ${controller.editingExpenseId.value}',
                        );

                        // Call the delete API
                        final success = await controller.deleteGroupExpense(
                          controller.editingExpenseId.value,
                        );

                        if (success) {
                          // Navigate to GroupTripHomeScreen after successful deletion
                          Get.back(); // Close confirmation dialog

                          // Create Trip object and navigate to home screen
                          try {
                            Trip tripToPass;
                            try {
                              final tripCtrl = Get.find<TripController>();
                              tripToPass = tripCtrl.trips.firstWhere(
                                (t) => t.id == controller.currentGroupId.value,
                                orElse: () => Trip(
                                  id: controller.currentGroupId.value,
                                  name: tripCtrl.trips.isNotEmpty
                                      ? tripCtrl.trips.first.name
                                      : 'Group Trip',
                                  date: DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(DateTime.now()),
                                ),
                              );
                            } catch (_) {
                              tripToPass = Trip(
                                id: controller.currentGroupId.value,
                                name: 'Group Trip',
                                date: DateFormat(
                                  'yyyy-MM-dd',
                                ).format(DateTime.now()),
                              );
                            }
                            Get.off(
                              () => GroupTripHomeScreen(trip: tripToPass),
                            );
                          } catch (e) {
                            debugPrint('⚠️ Delete navigation failed: $e');
                            // Fallback: just close the screen
                            Get.back();
                          }
                        }
                      },
                    ),
                  );
                }
              },
            );
          }),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
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
                              child: Builder(
                                builder: (context) {
                                  return TextField(
                                    controller:
                                        controller.totalAmountController,
                                    focusNode: controller.totalAmountFocusNode,
                                    onTap: () => controller
                                        .onTotalAmountFocusChange(true),
                                    onEditingComplete: () => controller
                                        .onTotalAmountFocusChange(false),
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
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                    ),
                                  );
                                },
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
                          child: Center(
                            child: Obx(
                              () => Text(
                                controller.selectedCurrency.value.isNotEmpty
                                    ? controller.selectedCurrency.value
                                    : '',
                                style: getTextStyle3(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
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
                              builder: (context) => GroupTripPaidFriendBottom(
                                controllerTag: controllerTag,
                              ),
                            );
                          },
                          child: Container(
                            height: 44.h,
                            width: 165.w,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : AppColors.lightGreyContainer,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Obx(() {
                                  // If the last paid-by action came from the
                                  // Multiple flow, prefer showing 'Multiple'.
                                  if (controller.paidByWasMultiple.value) {
                                    return Text(
                                      'Multiple'.tr,
                                      style: getTextStyle2(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    );
                                  }

                                  final name =
                                      controller.selectedPaidByFriend.value;
                                  return Text(
                                    name.length > 10
                                        ? name.substring(0, 10)
                                        : name,
                                    style: getTextStyle2(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  );
                                }),
                                const Icon(Icons.keyboard_arrow_down),
                              ],
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
                              builder: (context) => GroupTripSharedWithBottom(
                                controllerTag: controllerTag,
                              ),
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
                                  // If user chose Custom sharing flow, show 'Custom'.
                                  Text(
                                    !controller.isEquallySelected.value
                                        ? 'Custom'.tr
                                        : (controller
                                                  .selectedSharedWithFriends
                                                  .isNotEmpty
                                              ? '${controller.selectedSharedWithFriends.length} ${'People'.tr}'
                                              : 'Select Friend'.tr),
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
                                Get.find<GroupTripSpentController>(
                                  tag: controllerTag,
                                );
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) {
                                return CategoryBottomsheet(
                                  types: controller.expenseTypes,
                                  isIncome:
                                      false, // not needed but kept since your widget expects it
                                  controllerTag: controllerTag,
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
                                Get.find<GroupTripSpentController>(
                                  tag: controllerTag,
                                );
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
                                child: Builder(
                                  builder: (context) {
                                    return TextField(
                                      controller: controller.noteController,
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      decoration: InputDecoration(
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
                                    );
                                  },
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
              onTap: () async {
                // Dismiss keyboard before submitting
                FocusScope.of(context).unfocus();

                // If the group is fully settled and we're editing an existing expense,
                // disable update and inform the user. Creating new expenses should still be allowed.
                if (controller.isAllSettled.value &&
                    controller.editingExpenseId.value.isNotEmpty) {
                  Get.snackbar('Info', 'All Settled Up');
                  return;
                }

                // Check if category is selected, if not show CategoryBottomsheet first
                if (controller.selectedCategoryName.value.isEmpty) {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) {
                      return CategoryBottomsheet(
                        types: controller.expenseTypes,
                        isIncome: false,
                        controllerTag: controllerTag,
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
                  // Use saveExpenseWithMembers which respects paidByWasMultiple
                  // and the multiple payments collected in the PaidByMultiple sheet.
                  await controller.saveExpenseWithMembers(
                    navigateAfterSave: true,
                  );
                }
              },
              child: Obx(
                () => Container(
                  height: 52,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color:
                        (controller.isAllSettled.value &&
                            controller.editingExpenseId.value.isNotEmpty)
                        ? Colors.grey
                        : Color(0xFF00D460),
                  ),
                  child: Center(
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : Obx(
                            () => Text(
                              controller.buttonTextKey.value.tr,
                              style: getTextStyle3(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color:
                                    (controller.isAllSettled.value &&
                                        controller
                                            .editingExpenseId
                                            .value
                                            .isNotEmpty)
                                    ? Colors.white70
                                    : Colors.black,
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
