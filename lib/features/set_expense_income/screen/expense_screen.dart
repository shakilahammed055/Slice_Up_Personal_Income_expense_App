// ignore_for_file: unused_local_variable, deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/group_screen/widgets/confirmation_dialog.dart';
import 'package:teddy_5618/features/set_expense_income/controller/calender_controller.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/calender_dialog.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/form_field.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/type_bottomsheet.dart';

class ExpenseScreen extends StatelessWidget {
  const ExpenseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.lazyPut(() => ExpenseController());
    Get.lazyPut(() => CalendarController());

    final FocusNode amountFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      amountFocusNode.requestFocus();
    });

    return Scaffold(
      backgroundColor:  isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.textWhite,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Image.asset(
            isDark ? IconPath.backarrowwhite : IconPath.backarrow,
            height: 22,
            width: 22,
          ),
          onPressed: () {
            Get.find<ExpenseController>().clearForm();
            Get.back();
          },
        ),
        actions: [
          IconButton(
            icon: SvgPicture.asset(
              'assets/icons/delete.svg',
              height: 17.h,
              width: 15.w,
             color:  isDark ? AppColors.textWhite : AppColors.backgroundDark,
            ),
            onPressed: () {
              showCupertinoDialog(
                context: context,
                builder: (BuildContext context) => ConfirmationDialog(
                  title: 'Are you sure you want to delete?'.tr,
                  content: 'You won’t be able to undo this.'.tr,
                  button1: 'No'.tr,
                  button2: 'Yes'.tr,
                  onConfirm: () {
                    // ✅ Custom logic on confirm
                    Get.find<ExpenseController>().clearForm();
                    Get.snackbar('Success'.tr, 'Entry deleted successfully'.tr);
                  },
                ),
              );
            },
          )

        ],
        centerTitle: true,
        title: Container(
          padding: EdgeInsets.all(4),
          decoration: ShapeDecoration(
            color: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTabButton('Expense'.tr, context),
              _buildTabButton('Income'.tr, context),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Obx(() {
                final expenseController = Get.find<ExpenseController>();
                return Padding(
                  padding: EdgeInsets.all(20),
                  child: expenseController.selectedTab.value == 'Expense'.tr
                      ? _buildExpenseForm(context, amountFocusNode)
                      : _buildIncomeForm(context, amountFocusNode),
                );
              }),
            ),
          ),
          _buildNextButton(),
        ],
      ),
    );
  }

  Widget _buildTabButton(String tab, BuildContext context) {
    return GestureDetector(
      onTap: () => Get.find<ExpenseController>().switchTab(tab),
      child: Obx(() {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final expenseController = Get.find<ExpenseController>();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: ShapeDecoration(
            color: expenseController.selectedTab.value == tab
                ? isDark
                      ? AppColors.backgroundDark
                      : AppColors.textWhite
                : Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            shadows: [
              BoxShadow(
                color: Color(0x0C000000),
                blurRadius: 10,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Text(
            tab,
            style: getTextStyle2(
              color: isDark ? AppColors.textWhite : AppColors.black,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              lineHeight: 15,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildExpenseForm(BuildContext context, FocusNode amountFocusNode) {
    final expenseController = Get.find<ExpenseController>();
    final calendarController = Get.find<CalendarController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(context, expenseController, calendarController),
        SizedBox(height: 12),
        buildFormField(
          label: 'Amount'.tr,
          controller: expenseController.amountController,
          keyboardType: TextInputType.number,
          focusNode: amountFocusNode,
          context: context,
        ),
        SizedBox(height: 12),
        buildTypeBottomSheet(context, expenseController),
        SizedBox(height: 12),
        buildFormField(
          label: 'Note'.tr,
          controller: expenseController.noteController,
          maxLines: 1,
          context: context,
        ),
      ],
    );
  }

  Widget _buildIncomeForm(BuildContext context, FocusNode amountFocusNode) {
    final expenseController = Get.find<ExpenseController>();
    final calendarController = Get.find<CalendarController>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildDateField(context, expenseController, calendarController),
        SizedBox(height: 12),
        buildFormField(
          label: 'Amount'.tr,
          controller: expenseController.amountController,
          keyboardType: TextInputType.number,
          focusNode: amountFocusNode,
          context: context,
        ),
        SizedBox(height: 12),
        buildTypeBottomSheet(context, expenseController, isIncome: true),
        SizedBox(height: 12),
        buildFormField(
          label: 'Note'.tr,
          controller: expenseController.noteController,
          maxLines: 1,
          context: context,
        ),
      ],
    );
  }

  Widget _buildDateField(
    BuildContext context,
    ExpenseController expenseController,
    CalendarController calendarController,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            'Date'.tr,
            style: getTextStyle2(
              color: Color(0xFF828282),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              calendarController.selectDate(
                expenseController.selectedDate.value,
              );
              calendarController.currentMonth.value =
                  expenseController.selectedDate.value;
              calendarController.generateDaysInMonth();

              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return Container(
            
                    decoration: ShapeDecoration(
                      color: isDark
                          ? AppColors.deepGrey
                          : AppColors.textWhite,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                    // height: MediaQuery.of(context).size.height * 0.85,
                    
                    child: CalendarDialog(
                      onDateSelected: (date) {
                        expenseController.updateDateText(date);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
            child: AbsorbPointer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: TextField(
                  controller: expenseController.dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: isDark ? AppColors.deepGrey : Color(0xFFEDEDF0),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    suffixIcon: Icon(Icons.calendar_today, size: 20),
                  ),
                  style: getTextStyle2(
                    color: isDark ? AppColors.textWhite : AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    lineHeight: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Obx(() {
        final expenseController = Get.find<ExpenseController>();

        return ElevatedButton(
          onPressed:
              (expenseController.amount.value.isNotEmpty &&
                  expenseController.selectedType.value.isNotEmpty)
              ? () {
                  try {
                    expenseController.saveEntry(
                      amount: double.parse(expenseController.amount.value),
                      date: expenseController.dateController.text,
                      note: expenseController.noteController.text,
                    );
                    Get.snackbar(
                      'Success'.tr,
                      '${expenseController.selectedTab.value} saved successfully',
                    );
                    expenseController.clearForm();
                  } catch (e) {
                    Get.snackbar('Error'.tr, 'Please enter a valid amount'.tr);
                  }
                }
              : null,
          style: ElevatedButton.styleFrom(
            side: BorderSide.none,
            backgroundColor: Color(0xFF2A31EF),
            disabledBackgroundColor: Color(0xFF2A31EF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
          child: Text(
            (expenseController.amount.value.isNotEmpty &&
                    expenseController.selectedType.value.isNotEmpty)
                ? 'Save'.tr
                : 'Next'.tr,
            style: getTextStyle2(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }
}
