// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/set_expense_income/controller/calender_controller.dart';
// import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';

// class CalendarDialog extends StatelessWidget {
//   final Function(DateTime) onDateSelected;

//   const CalendarDialog({super.key, required this.onDateSelected});

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final CalendarController controller = Get.find();

//     return Container(
//       constraints: BoxConstraints(minHeight: 184),
//       width: double.infinity,
//       decoration: ShapeDecoration(
//         color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(24),
//             topRight: Radius.circular(24),
//           ),
//         ),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//             width: double.infinity,
//             height: 56,
//             padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(width: 48),
//                 Expanded(
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       SizedBox(
//                         width: 286,
//                         child: Text(
//                           'Calendar'.tr,
//                           textAlign: TextAlign.center,
//                           style: getTextStyle2(
//                             color: isDark
//                                 ? AppColors.textWhite
//                                 : AppColors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   icon: Icon(Icons.close),
//                   onPressed: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//           ),
//           Obx(
//             () => Container(
//               width: double.infinity,
//               padding: EdgeInsets.only(bottom: 0),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     decoration: BoxDecoration(
//                       color: isDark
//                           ? AppColors.backgroundDark
//                           : AppColors.textWhite,
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => controller.switchTab(0),
//                             child: Container(
//                               padding: EdgeInsets.only(
//                                 top: 8,
//                                 left: 12,
//                                 right: 12,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 171,
//                                     child: Text(
//                                       'One time'.tr,
//                                       textAlign: TextAlign.center,
//                                       style: getTextStyle2(
//                                         color: controller.selectedTab.value == 0
//                                             ? isDark
//                                                   ? AppColors.textWhite
//                                                   : AppColors.black
//                                             : Color(0xFF828282),
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                         lineHeight: 30,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: double.infinity,
//                                     height: 2,
//                                     decoration: BoxDecoration(
//                                       color: controller.selectedTab.value == 0
//                                           ? isDark
//                                                 ? AppColors.textWhite
//                                                 : AppColors.black
//                                           : Color(0x000400FF),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         Expanded(
//                           child: GestureDetector(
//                             onTap: () => controller.switchTab(1),
//                             child: Container(
//                               padding: EdgeInsets.only(
//                                 top: 8,
//                                 left: 12,
//                                 right: 12,
//                               ),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 mainAxisAlignment: MainAxisAlignment.start,
//                                 crossAxisAlignment: CrossAxisAlignment.center,
//                                 children: [
//                                   SizedBox(
//                                     width: 171,
//                                     child: Text(
//                                       'Repeat'.tr,
//                                       textAlign: TextAlign.center,
//                                       style: getTextStyle2(
//                                         color: controller.selectedTab.value == 1
//                                             ? isDark
//                                                   ? AppColors.textWhite
//                                                   : AppColors.black
//                                             : Color(0xFF828282),
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                         lineHeight: 30,
//                                       ),
//                                     ),
//                                   ),
//                                   Container(
//                                     width: double.infinity,
//                                     height: 2,
//                                     decoration: BoxDecoration(
//                                       color: controller.selectedTab.value == 1
//                                           ? isDark
//                                                 ? AppColors.textWhite
//                                                 : AppColors.black
//                                           : Color(0x000400FF),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   controller.selectedTab.value == 0
//                       ? _buildCalendarView(controller, onDateSelected, context)
//                       : _buildRepeatView(controller, context),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCalendarView(
//     CalendarController controller,
//     Function(DateTime) onDateSelected,
//     BuildContext context,
//   ) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.only(top: 0),
//       decoration: BoxDecoration(
//         color: isDark ? AppColors.black : AppColors.textWhite,
//       ),
//       child: Container(
//         padding: EdgeInsets.all(24),
//         clipBehavior: Clip.none,
//         decoration: ShapeDecoration(
//           color: isDark ? AppColors.black : AppColors.textWhite,
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//           shadows: [
//             BoxShadow(
//               color: Color(0x16000000),
//               blurRadius: 19,
//               offset: Offset(2, 16),
//               spreadRadius: 0,
//             ),
//           ],
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: () => controller.previousMonth(),
//                     child: SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: Icon(
//                         Icons.chevron_left,
//                         size: 16,
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                       ),
//                     ),
//                   ),
//                   Text(
//                     controller.getMonthYear(),
//                     textAlign: TextAlign.center,
//                     style: getTextStyle2(
//                       color: isDark ? AppColors.textWhite : AppColors.black,
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: () => controller.nextMonth(),
//                     child: SizedBox(
//                       width: 16,
//                       height: 16,
//                       child: Icon(
//                         Icons.chevron_right,
//                         size: 16,
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               child: Obx(
//                 () => Column(
//                   children: [
//                     SizedBox(
//                       width: double.infinity,
//                       child: Row(
//                         children: controller.weekdays.map((day) {
//                           return Expanded(
//                             child: Container(
//                               height: 15,
//                               padding: EdgeInsets.zero,
//                               margin: EdgeInsets.zero,
//                               child: Center(
//                                 child: Text(
//                                   day,
//                                   textAlign: TextAlign.center,
//                                   style: getTextStyle2(
//                                     color: Color(0xFF828282),
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     ),
//                     SizedBox(height: 5),
//                     GridView.builder(
//                       shrinkWrap: true,
//                       physics: NeverScrollableScrollPhysics(),
//                       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 7,
//                         mainAxisSpacing: 8,
//                         crossAxisSpacing: 8,
//                         childAspectRatio: 1,
//                       ),
//                       itemCount: controller.daysInMonth.length,
//                       itemBuilder: (context, index) {
//                         final date = controller.daysInMonth[index];
//                         final isCurrent = controller.isCurrentMonth(date);
//                         return Obx(() {
//                           final isSelected = controller.isSelected(date);
//                           return GestureDetector(
//                             behavior: HitTestBehavior.opaque,
//                             onTap: () {
//                               controller.selectDate(date);
//                               onDateSelected(date);
//                             },
//                             child: Container(
//                               padding: EdgeInsets.all(8),
//                               decoration: isSelected
//                                   ? BoxDecoration(
//                                       color: isDark
//                                           ? AppColors.textWhite
//                                           : AppColors.black,
//                                       borderRadius: BorderRadius.circular(8),
//                                     )
//                                   : null,
//                               child: Center(
//                                 child: Text(
//                                   date.day.toString(),
//                                   style: getTextStyle2(
//                                     color: isSelected
//                                         ? isDark
//                                               ? AppColors.black
//                                               : AppColors.textWhite
//                                         : isCurrent
//                                         ? isDark
//                                               ? AppColors.textWhite
//                                               : AppColors.black
//                                         : isDark
//                                         ? AppColors.textWhite
//                                         : Color(
//                                             0xFF141414,
//                                           ).withValues(alpha: 0.5),
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRepeatView(CalendarController controller, BuildContext context) {
//     final repeatOptions = [
//       'Every Friday'.tr,
//       'Every Saturday'.tr,
//       'Every Sunday'.tr,
//       'Every Monday'.tr,
//       'Every Tuesday'.tr,
//       'Every Wednesday'.tr,
//       'Every Thursday'.tr,
//       'Every 1st of Month'.tr,
//       'Every 2nd of Month'.tr,
//     ];

//     final ScrollController scrollController = ScrollController();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final selectedIndex = repeatOptions.indexOf(
//         controller.selectedRepeatOption.value,
//       );
//       if (selectedIndex != -1) {
//         const itemHeight = 44.0;
//         final offset =
//             selectedIndex * itemHeight - (291 / 2) + (itemHeight / 2);
//         final maxScrollExtent = scrollController.position.maxScrollExtent;
//         final minScrollExtent = scrollController.position.minScrollExtent;
//         final boundedOffset = offset.clamp(minScrollExtent, maxScrollExtent);
//         scrollController.jumpTo(boundedOffset);
//       }
//     });

//     scrollController.addListener(() {
//       const itemHeight = 44.0;
//       final scrollOffset = scrollController.offset;
//       final containerHeight = 291.0;
//       final centerOffset = scrollOffset + (containerHeight / 2);
//       final centerIndex = (centerOffset / itemHeight).round();
//       if (centerIndex >= 0 && centerIndex < repeatOptions.length) {
//         controller.selectRepeatOption(repeatOptions[centerIndex]);
//       }
//     });

//     return Container(
//       width: double.infinity,
//       height: 365,
//       padding: EdgeInsets.only(top: 36, left: 0, right: 0, bottom: 48),
//       child: ShaderMask(
//         blendMode: BlendMode.dstOut,
//         shaderCallback: (bounds) => LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
//           stops: [0.0, 0.2], // Gradient fades out at the top
//         ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//         child: ShaderMask(
//           blendMode: BlendMode.dstIn,
//           shaderCallback: (bounds) => LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
//             stops: [0.0, 0.1], // Gradient fades in at the bottom
//           ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
//           child: Container(
//             width: double.infinity,
//             height: 291,
//             padding: EdgeInsets.symmetric(horizontal: 24),
//             child: ListView.builder(
//               controller: scrollController,
//               itemCount: repeatOptions.length,
//               itemBuilder: (context, index) {
//                 final isDark = Theme.of(context).brightness == Brightness.dark;
//                 final option = repeatOptions[index];
//                 return GestureDetector(
//                   onTap: () {
//                     controller.selectRepeatOption(option);
//                     const itemHeight = 44.0;
//                     final offset =
//                         index * itemHeight - (291 / 2) + (itemHeight / 2);
//                     final maxScrollExtent =
//                         scrollController.position.maxScrollExtent;
//                     final minScrollExtent =
//                         scrollController.position.minScrollExtent;
//                     final boundedOffset = offset.clamp(
//                       minScrollExtent,
//                       maxScrollExtent,
//                     );
//                     scrollController.animateTo(
//                       boundedOffset,
//                       duration: Duration(milliseconds: 300),
//                       curve: Curves.easeInOut,
//                     );
//                     final expenseController = Get.find<ExpenseController>();
//                     expenseController.dateController.text = option;
//                     Navigator.pop(context);
//                   },
//                   child: SizedBox(
//                     width: 342,
//                     height: 44,
//                     child: Padding(
//                       padding: EdgeInsets.symmetric(vertical: 10),
//                       child: Obx(
//                         () => Text(
//                           option,
//                           textAlign: TextAlign.center,
//                           style: getTextStyle2(
//                             color:
//                                 controller.selectedRepeatOption.value == option
//                                 ? isDark
//                                       ? AppColors.textWhite
//                                       : Color(0xFF141414)
//                                 : Color(0xFF828282),
//                             fontSize: 20,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }




import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/set_expense_income/controller/calender_controller.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';

class RepeatOption {
  final String display;
  final int every;
  final String unit;

  const RepeatOption(this.display, this.every, this.unit);
}

class CalendarDialog extends StatelessWidget {
  final Function(DateTime) onDateSelected;

  const CalendarDialog({super.key, required this.onDateSelected});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final CalendarController controller = Get.find();

    return Container(
      constraints: BoxConstraints(minHeight: 184),
      width: double.infinity,
      decoration: ShapeDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.textWhite,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        width: 286,
                        child: Text(
                          'Calendar'.tr,
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
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Obx(
            () => Container(
              width: double.infinity,
              padding: EdgeInsets.only(bottom: 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.textWhite,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.switchTab(0),
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 171,
                                    child: Text(
                                      'One time'.tr,
                                      textAlign: TextAlign.center,
                                      style: getTextStyle2(
                                        color: controller.selectedTab.value == 0
                                            ? isDark
                                                  ? AppColors.textWhite
                                                  : AppColors.black
                                            : Color(0xFF828282),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        lineHeight: 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 0
                                          ? isDark
                                                ? AppColors.textWhite
                                                : AppColors.black
                                          : Color(0x000400FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.switchTab(1),
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 8,
                                left: 12,
                                right: 12,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 171,
                                    child: Text(
                                      'Repeat'.tr,
                                      textAlign: TextAlign.center,
                                      style: getTextStyle2(
                                        color: controller.selectedTab.value == 1
                                            ? isDark
                                                  ? AppColors.textWhite
                                                  : AppColors.black
                                            : Color(0xFF828282),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        lineHeight: 30,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: double.infinity,
                                    height: 2,
                                    decoration: BoxDecoration(
                                      color: controller.selectedTab.value == 1
                                          ? isDark
                                                ? AppColors.textWhite
                                                : AppColors.black
                                          : Color(0x000400FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  controller.selectedTab.value == 0
                      ? _buildCalendarView(controller, onDateSelected, context)
                      : _buildRepeatView(controller, context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarView(
    CalendarController controller,
    Function(DateTime) onDateSelected,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.black : AppColors.textWhite,
      ),
      child: Container(
        padding: EdgeInsets.all(24),
        clipBehavior: Clip.none,
        decoration: ShapeDecoration(
          color: isDark ? AppColors.black : AppColors.textWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          shadows: [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 19,
              offset: Offset(2, 16),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => controller.previousMonth(),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    controller.getMonthYear(),
                    textAlign: TextAlign.center,
                    style: getTextStyle2(
                      color: isDark ? AppColors.textWhite : AppColors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => controller.nextMonth(),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: controller.weekdays.map((day) {
                          return Expanded(
                            child: Container(
                              height: 15,
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              child: Center(
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: getTextStyle2(
                                    color: Color(0xFF828282),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: 5),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 1,
                      ),
                      itemCount: controller.daysInMonth.length,
                      itemBuilder: (context, index) {
                        final date = controller.daysInMonth[index];
                        final isCurrent = controller.isCurrentMonth(date);
                        return Obx(() {
                          final isSelected = controller.isSelected(date);
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              controller.selectDate(date);
                              onDateSelected(date);
                            },
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: isDark
                                          ? AppColors.textWhite
                                          : AppColors.black,
                                      borderRadius: BorderRadius.circular(8),
                                    )
                                  : null,
                              child: Center(
                                child: Text(
                                  date.day.toString(),
                                  style: getTextStyle2(
                                    color: isSelected
                                        ? isDark
                                              ? AppColors.black
                                              : AppColors.textWhite
                                        : isCurrent
                                        ? isDark
                                              ? AppColors.textWhite
                                              : AppColors.black
                                        : isDark
                                        ? AppColors.textWhite
                                        : Color(
                                            0xFF141414,
                                          ).withValues(alpha: 0.5),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRepeatView(CalendarController controller, BuildContext context) {
    final List<RepeatOption> repeatOptions = [
      RepeatOption('Every Friday'.tr, 5, 'week'),
      RepeatOption('Every Saturday'.tr, 6, 'week'),
      RepeatOption('Every Sunday'.tr, 0, 'week'),
      RepeatOption('Every Monday'.tr, 1, 'week'),
      RepeatOption('Every Tuesday'.tr, 2, 'week'),
      RepeatOption('Every Wednesday'.tr, 3, 'week'),
      RepeatOption('Every Thursday'.tr, 4, 'week'),
      RepeatOption('Every 1st of Month'.tr, 1, 'month'),
      RepeatOption('Every 2nd of Month'.tr, 2, 'month'),
    ];

    final ScrollController scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectedOptDisplay = controller.selectedRepeatOption.value;
      // ignore: unnecessary_null_comparison
      if (selectedOptDisplay != null) {
        final index = repeatOptions.indexWhere((opt) => opt.display == selectedOptDisplay);
        if (index != -1) {
          const itemHeight = 44.0;
          final offset = index * itemHeight - (291 / 2) + (itemHeight / 2);
          scrollController.jumpTo(offset.clamp(0.0, scrollController.position.maxScrollExtent));
        }
      }
    });

    scrollController.addListener(() {
      const itemHeight = 44.0;
      final scrollOffset = scrollController.offset;
      final containerHeight = 291.0;
      final centerOffset = scrollOffset + (containerHeight / 2);
      final centerIndex = (centerOffset / itemHeight).round().clamp(0, repeatOptions.length - 1);
      controller.selectRepeatOption(repeatOptions[centerIndex].display);
    });

    return Container(
      width: double.infinity,
      height: 365,
      padding: EdgeInsets.only(top: 36, left: 0, right: 0, bottom: 48),
      child: ShaderMask(
        blendMode: BlendMode.dstOut,
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withValues(alpha: 0.9), Colors.transparent],
          stops: [0.0, 0.2],
        ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
            stops: [0.0, 0.1],
          ).createShader(Rect.fromLTWH(0, 0, bounds.width, bounds.height)),
          child: Container(
            width: double.infinity,
            height: 291,
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: ListView.builder(
              controller: scrollController,
              itemCount: repeatOptions.length,
              itemBuilder: (context, index) {
                final RepeatOption opt = repeatOptions[index];
                final isDark = Theme.of(context).brightness == Brightness.dark;
                return GestureDetector(
                  onTap: () {
                    controller.selectRepeatOption(opt.display);
                    const itemHeight = 44.0;
                    final offset = index * itemHeight - (291 / 2) + (itemHeight / 2);
                    scrollController.animateTo(
                      offset.clamp(0.0, scrollController.position.maxScrollExtent),
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                    final expenseController = Get.find<ExpenseController>();
                    expenseController.setRepeatConfig(opt.every, opt.unit, controller.selectedDate.value);
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    width: 342,
                    height: 44,
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Obx(
                        () => Text(
                          opt.display,
                          textAlign: TextAlign.center,
                          style: getTextStyle2(
                            color: controller.selectedRepeatOption.value == opt.display
                                ? isDark
                                    ? AppColors.textWhite
                                    : Color(0xFF141414)
                                : Color(0xFF828282),
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}