import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';

class ShowMonthSetting extends StatelessWidget {
  const ShowMonthSetting({super.key, required this.controller});

  final SettingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(); // Placeholder to avoid build errors; actual logic is in show method
  }

  void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: 184,
            maxHeight: MediaQuery.of(context).size.height * 0.48,
          ),
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
              children: [
                Container(
                  width: double.infinity,
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 32),
                      Text(
                        'Month setting'.tr,
                        style: getTextStyle2(
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.clearMonthSettings();
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.close,
                          color: isDark ? AppColors.textWhite : AppColors.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Start'.tr,
                                      style: getTextStyle2(
                                        color: Color(0xFF828282),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: AlwaysScrollableScrollPhysics(),
                                        itemCount: controller.getDaysInMonth(DateTime.now().year, DateTime.now().month),
                                        itemBuilder: (context, index) {
                                          int date = index + 1;
                                          return GestureDetector(
                                            onTap: () {
                                              try {
                                                controller.setStartDate(date);
                                                // Set end date to the previous day in the next month
                                                DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month, date);
                                                DateTime endDate = DateTime(startDate.year, startDate.month + 1, startDate.day - 1);
                                                // Adjust if endDay goes below 1
                                                if (endDate.day < 1) {
                                                  endDate = DateTime(endDate.year, endDate.month, controller.getDaysInMonth(endDate.year, endDate.month - 1));
                                                }
                                                controller.setEndDate(endDate.day);
                                              } catch (e) {
                                                debugPrint('Error in Start date tap: $e');
                                              }
                                            },
                                            child: Obx(
                                              () => Container(
                                                margin: EdgeInsets.symmetric(vertical: 4),
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: controller.selectedStartDate.value == date
                                                      ? isDark
                                                          ? AppColors.deepGrey
                                                          : Color(0xFFD3D3D3)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$date',
                                                    style: getTextStyle2(
                                                      color: isDark ? AppColors.textWhite : AppColors.black,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'End'.tr,
                                      style: getTextStyle2(
                                        color: Color(0xFF828282),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    SizedBox(
                                      height: 200,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: AlwaysScrollableScrollPhysics(), // Enable scrolling
                                        itemCount: controller.getDaysInMonth(DateTime.now().year, DateTime.now().month + 1),
                                        itemBuilder: (context, index) {
                                          int date = index + 1;
                                          return Obx(
                                            () => GestureDetector(
                                              // No onTap to keep it non-selectable
                                              child: Container(
                                                margin: EdgeInsets.symmetric(vertical: 4),
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: controller.selectedEndDate.value == date
                                                      ? isDark
                                                          ? AppColors.deepGrey
                                                          : Color(0xFFD3D3D3)
                                                      : Colors.transparent,
                                                  borderRadius: BorderRadius.circular(8),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    '$date',
                                                    style: getTextStyle2(
                                                      color: isDark ? AppColors.textWhite : AppColors.black,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Divider(
                            height: 1,
                            color: isDark
                                ? AppColors.surfaceDark
                                : Color(0xffD0D3D9),
                          ),
                          SizedBox(height: 8),
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                controller.saveDateRange();
                                if (controller.isDateRangeSet.value) {
                                  Navigator.of(context).pop();
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Container(
                                  width: double.infinity,
                                  height: 48,
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? AppColors.textWhite
                                        : AppColors.black,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(24),
                                      ),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Update'.tr,
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.black
                                            : AppColors.textWhite,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                // Container(
                //   width: double.infinity,
                //   padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                //   child: Center(
                //     child: Container(
                //       width: 134,
                //       height: 4,
                //       decoration: ShapeDecoration(
                //         color: Color(0xFF2B2F38),
                //         shape: RoundedRectangleBorder(
                //           borderRadius: BorderRadius.circular(100),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }
}