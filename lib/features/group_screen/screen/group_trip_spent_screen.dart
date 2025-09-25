// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/group_screen/controller/category_bottomsheet_controller.dart';
// import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_calender_dialog.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_trip_paid_friend.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_trip_shared_with_bottom.dart';
// import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
// import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
// import 'package:teddy_5618/features/settings_screen/widget/category_bttomsheet.dart';
// import 'package:teddy_5618/features/settings_screen/widget/currency_bottomsheet.dart';

// class GroupTripSpentScreen extends StatelessWidget {
//   GroupTripSpentScreen({super.key});

//   final GroupTripSpentController controller = Get.put(
//     GroupTripSpentController(),
//   );
//   final SettingController settingController = Get.put(SettingController());
//   final categoryController = Get.put(CategoryController());

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(CupertinoIcons.back, size: 30),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Center(
//           child: Row(
//             // ... your title code remains the same
//             mainAxisSize: MainAxisSize.min,
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Obx(
//                 () => Text(
//                   controller.selectedDate.value != null
//                       ? DateFormat(
//                           'dd MMM yyyy',
//                         ).format(controller.selectedDate.value!)
//                       : 'Select Date',
//                   style: getTextStyle2(
//                     color: controller.selectedDate.value != null
//                         ? (isDark ? AppColors.textWhite : AppColors.black)
//                         : Colors.grey,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               GestureDetector(
//                 onTap: () => showCalendarBottomSheet(context),
//                 child: const Icon(Icons.keyboard_arrow_down),
//               ),
//             ],
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete),
//             onPressed: () {
//               // --- THIS IS THE CORRECTED PART ---
//               // Use showCupertinoDialog for the authentic, transparent iOS alert.
//               showCupertinoDialog(
//                 context: context,
//                 // This builder automatically creates the blurred background effect.
//                 builder: (BuildContext context) => CupertinoAlertDialog(
//                   title: Text('Are you sure you want to delete this?'.tr),
//                   content: Text(
//                     'Once deleted, your information won\'t be saved.'.tr,
//                   ),
//                   actions: <CupertinoDialogAction>[
//                     CupertinoDialogAction(
//                       child: Text('Stay'.tr),
//                       onPressed: () {
//                         // Use the standard Navigator to pop a native dialog
//                         Navigator.of(context).pop();
//                       },
//                     ),
//                     CupertinoDialogAction(
//                       // This makes the text red, which is a common iOS pattern for destructive actions.
//                       isDestructiveAction: true,
//                       child: Text('Leave'.tr),
//                       onPressed: () {
//                         // 1. Your delete logic
//                         Get.find<ExpenseController>().clearForm();

//                         // 2. Close the dialog
//                         Navigator.of(context).pop();

//                         // 3. Show a snackbar
//                         Get.snackbar(
//                           'Success'.tr,
//                           'Entry deleted successfully'.tr,
//                         );
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),

//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Total Amount'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Container(
//                     height: 44.h,
//                     // width: MediaQuery.of(context).size.width / 1.4,
//                     width: 247.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: isDark
//                           ? AppColors.backgroundDark
//                           : AppColors.lightGreyContainer,
//                     ),
//                     child: Center(
//                       child: TextField(
//                         controller: controller.totalAmountController,
//                         style: getTextStyle2(
//                           color: isDark ? AppColors.textWhite : AppColors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         keyboardType: TextInputType.number,
//                         inputFormatters: [
//                           FilteringTextInputFormatter.digitsOnly,
//                         ],
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           hintText: 'Enter Amount',
//                           hintStyle: TextStyle(color: Colors.grey),
//                           border: InputBorder.none,
//                           enabledBorder: InputBorder.none,
//                           focusedBorder: InputBorder.none,
//                         ),
//                       ).marginOnly(left: 10),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 12),
//               Column(
//                 children: [
//                   SizedBox(height: 25.h),
//                   Container(
//                     height: 44.h,
//                     width: 83.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: isDark
//                           ? AppColors.backgroundDark
//                           : AppColors.lightGreyContainer,
//                     ),
//                     child: GestureDetector(
//                       onTap: () =>
//                           showCurrencyDialog(context, settingController),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Obx(
//                             () => Text(
//                               settingController.currency.value,
//                               // 'US$',
//                               style: getTextStyle3(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 4.w),
//                           Icon(Icons.keyboard_arrow_down),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Paid by'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   GestureDetector(
//                     onTap: () {
//                       showMaterialModalBottomSheet(
//                         isDismissible: false,
//                         enableDrag: false,
//                         context: context,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(34),
//                           ),
//                         ),
//                         builder: (context) => const GroupTripPaidFriendBottom(),
//                       );
//                     },
//                     child: Obx(
//                       () => Container(
//                         height: 44.h,
//                         width: 165.w,
//                         // width: MediaQuery.of(context).size.width / 2.9,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? AppColors.backgroundDark
//                               : AppColors.lightGreyContainer,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               controller.selectedFriend.value,
//                               style: getTextStyle2(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: isDark ? Colors.white : Colors.black,
//                               ),
//                             ),
//                             const Icon(Icons.keyboard_arrow_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 12.h),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Share with (Equally)'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   GestureDetector(
//                     onTap: () {
//                       showMaterialModalBottomSheet(
//                         context: context,
//                         isDismissible: false,
//                         // expand: true,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(34),
//                           ),
//                         ),
//                         builder: (context) => const GroupTripSharedWithBottom(),
//                       );
//                     },
//                     child: Obx(
//                       () => Container(
//                         height: 44.h,
//                         // width: MediaQuery.of(context).size.width / 2.9,
//                         width: 165.w,
//                         padding: const EdgeInsets.symmetric(horizontal: 12),
//                         decoration: BoxDecoration(
//                           color: isDark
//                               ? AppColors.backgroundDark
//                               : AppColors.lightGreyContainer,
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text(
//                               controller.selectedFriend.value,
//                               style: getTextStyle2(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: isDark ? Colors.white : Colors.black,
//                               ),
//                             ),
//                             const Icon(Icons.keyboard_arrow_down),
//                           ],
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Categroy'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   GestureDetector(
//                     onTap: () {
//                       showCategoryBottomSheet(context, settingController);
//                     },
//                     child: Obx(
//                       () => Container(
//                         height: 44.h,
//                         width: 165.w,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: isDark
//                               ? AppColors.backgroundDark
//                               : AppColors.lightGreyContainer,
//                         ),
//                         alignment: Alignment.center,
//                         child: Row(
//                           children: [
//                             Text(
//                               '${settingController.selectedCategoryIcon.value} ${settingController.selectedCategoryName.value}',
//                               style: getTextStyle2(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: isDark ? Colors.white : Colors.black,
//                               ),
//                             ),
//                             Spacer(),
//                             const Icon(Icons.keyboard_arrow_down),
//                           ],
//                         ).marginSymmetric(horizontal: 8),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(width: 12.w),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Note',
//                     style: getTextStyle3(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: const Color(0xFF828282),
//                     ),
//                   ),
//                   SizedBox(height: 8.h),
//                   Container(
//                     height: 44.h,
//                     width: 165.w,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: isDark
//                           ? AppColors.backgroundDark
//                           : AppColors.lightGreyContainer,
//                     ),
//                     child: Center(
//                       child: TextField(
//                         style: getTextStyle2(
//                           color: isDark ? AppColors.textWhite : AppColors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           hintText: 'Add Notes',
//                           hintStyle: TextStyle(color: Color(0xFF828282)),
//                           border: InputBorder.none,
//                           enabledBorder: InputBorder.none,
//                           focusedBorder: InputBorder.none,
//                         ),
//                       ).marginOnly(left: 10),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ],
//       ).marginOnly(left: 24),
//     );
//   }
// }

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
  GroupTripSpentScreen({super.key});

  final GroupTripSpentController controller = Get.put(
    GroupTripSpentController(),
  );
  final SettingController settingController = Get.put(SettingController());
  final categoryController = Get.put(CategoryController());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                                  hintText: 'Enter Amount',
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
                                        ? controller.selectedCategoryName.value
                                        : 'Select Category',
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
                                  decoration: const InputDecoration(
                                    isDense: true,
                                    hintText: 'Add Notes',
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
                controller.addGroupExpense();
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
                        : Text(
                            'Save',
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
        ],
      ),
    );
  }
}
