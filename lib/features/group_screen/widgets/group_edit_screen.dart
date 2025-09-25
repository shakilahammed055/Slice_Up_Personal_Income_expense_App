import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/controller/create_trip_bottomsheet_controller.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart'; // Make sure path is correct

class GroupEditScreen extends StatelessWidget {
  const GroupEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TripController tripController = Get.find<TripController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      top: false,
      child: Padding(
     padding: MediaQuery.of(context).viewInsets, 
        child: Container(
          clipBehavior: Clip.antiAlias,
                  
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF262626): AppColors.textWhite,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            child: Column(
                  mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox( width: 32),
                    Text(
                      'Group title'.tr,
                      style: getTextStyle2(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                          color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 25),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  height: 48.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isDark
                          ? AppColors.textWhite
                          : AppColors.backgroundDark,
                      width: 2,
                    ),
                  ),
                  child: Center(

                    child: TextField(
                      controller: tripController.tripNameController,
                      focusNode: tripController.editTripFocusNode,
                      style: getTextStyle2(
                        color: isDark
                            ? AppColors.textWhite
                            : AppColors.backgroundDark,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Create a trip'.tr,
                        hintStyle: getTextStyle2(
                          color: Color(0xFFAAAAAA),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                    ).marginOnly(left: 16),
                  ),
                ).marginSymmetric(horizontal: 13),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Delete Group
                    GestureDetector(
                      onTap: () {
                        showCupertinoDialog(
                          context: context,
                          builder: (BuildContext context) => ConfirmationDialog(
                            title: 'Are you sure you want to delete?'.tr,
                            content:
                                'You won’t be able to undo this.'
                                    .tr,
                            button1: 'No'.tr,
                            button2: 'Yes'.tr,
                            onConfirm: () {
                              // ✅ Custom logic on confirm
                              Get.find<ExpenseController>().clearForm();
                              Get.snackbar(
                                'Success'.tr,
                                'Entry deleted successfully'.tr,
                              );
                            },
                          ),
                        );
                      },
                      child: Container(
                        // width: MediaQuery.of(context).size.width / 2.2,
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                        decoration: BoxDecoration(
                          color: AppColors.textWhite,
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(width: 1, color: AppColors.borderGrey),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Leave group'.tr,
                          style: getTextStyle2(
                            color: isDark ? AppColors.textGrey : AppColors.textGrey,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    
                    // Update Button
                    GestureDetector(
                      onTap: () {
                        tripController.addTrip();
                      },
                      child: Container(
                        // width: MediaQuery.of(context).size.width / 2.2,
                        padding: const EdgeInsets.symmetric(vertical: 16,  horizontal: 60,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Update'.tr,
                          style: getTextStyle2(
                            color: isDark
                                ? AppColors.backgroundDark
                                : AppColors.backgroundDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ).marginSymmetric(horizontal: 15),
                SizedBox(height: 12.h,)
              ],
            ).marginSymmetric(horizontal: 10),
          ),
        ),
      ),
    );
  }
}
