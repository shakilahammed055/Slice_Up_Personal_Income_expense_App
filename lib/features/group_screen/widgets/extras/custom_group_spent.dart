// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/app_texts.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/group_screen/controller/category_bottomsheet_controller.dart';
// import 'package:teddy_5618/features/group_screen/controller/group_trip_spent_controller.dart';
// import 'package:teddy_5618/features/group_screen/widgets/category_bottomsheet.dart';

// import 'package:teddy_5618/features/group_screen/widgets/group_calender_dialog.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_trip_dropdown.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_trip_friend_spent_amo.dart';
// import 'package:teddy_5618/features/group_screen/widgets/group_trip_paid_friend.dart';

// class CustomGroupSpent extends StatelessWidget {
//   const CustomGroupSpent({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.put(GroupTripSpentController());
//     final categoryController = Get.put(CategoryController());
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 20),
//         child: SingleChildScrollView(
//           child: Column(
//             children: [
//               const SizedBox(height: 20),
          
//               /// Date Row
//               Row(
//                 children: [
//                   Text(
//                     AppText.date,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Spacer(),
//                   // SizedBox(width: MediaQuery.of(context).size.width / 15),
//                   GestureDetector(
//                     onTap: () => showCalendarBottomSheet(context),
//                     child: Obx(
//                       () => Container(
//                         height: 44.h,
//                         width: MediaQuery.of(context).size.width / 1.4,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: isDark
//                               ? AppColors.backgroundDark
//                               : AppColors.lightGreyContainer,
//                         ),
//                         alignment: Alignment.centerLeft,
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           controller.selectedDate.value != null
//                               ? DateFormat(
//                                   'dd MMM yyyy',
//                                 ).format(controller.selectedDate.value!)
//                               : 'Select Date',
//                           style: getTextStyle2(
//                             color: controller.selectedDate.value != null
//                                 ? isDark
//                                       ? AppColors.textWhite
//                                       : AppColors.black
//                                 : Colors.grey,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
          
//               /// Amount Row
//               Row(
//                 children: [
//                   Text(
//                     'Amount'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   // SizedBox(width: MediaQuery.of(context).size.width / 50),
//                   Spacer(),
//                   Container(
//                     height: 44.h,
//                     width: MediaQuery.of(context).size.width / 1.4,
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
//                         inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//                         decoration: const InputDecoration(
//                           isDense: true,
//                           hintText: 'Enter Amount',
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
//               const SizedBox(height: 12),
          
//               /// Paid Row
//               Row(
//                 children: [
//                   Text(
//                     'Paid'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Spacer(),
//                   // SizedBox(width: MediaQuery.of(context).size.width / 12),
//                   GestureDetector(
//                     onTap: () {
//                       showMaterialModalBottomSheet(
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
//                         width: MediaQuery.of(context).size.width / 2.9,
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
//                   SizedBox(width: MediaQuery.of(context).size.width / 50),
//                   GroupTripDropdown(
//                     selectedValue: controller.selectedCurrency,
//                     options: controller.currencyOptions,
//                     onChanged: controller.setSelectedCurrency,
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
          
//               /// Type Row
//               Row(
//                 children: [
//                   Text(
//                     'Type'.tr,
//                     style: getTextStyle2(
//                       color: const Color(0xFF828282),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   Spacer(),
//                   // SizedBox(width: MediaQuery.of(context).size.width / 12),
//                   GestureDetector(
//                     onTap: () {
//                       showMaterialModalBottomSheet(
//                         context: context,
//                         shape: const RoundedRectangleBorder(
//                           borderRadius: BorderRadius.vertical(
//                             top: Radius.circular(34),
//                           ),
//                         ),
//                         builder: (context) => CategoryTypeBottomSheet(),
//                       );
//                     },
//                     child: Obx(
//                       () => Container(
//                         height: 44.h,
//                         width: MediaQuery.of(context).size.width / 8,
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(10),
//                           color: isDark
//                               ? AppColors.backgroundDark
//                               : AppColors.lightGreyContainer,
//                         ),
//                         alignment: Alignment.center,
//                         child: Text(
//                           categoryController.selectedIcon.value,
//                           style: getTextStyle2(
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                             color: isDark ? Colors.white : Colors.black,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                   SizedBox(width: MediaQuery.of(context).size.width / 35),
//                   Container(
//                     height: 44.h,
//                     width: MediaQuery.of(context).size.width / 1.8,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(10),
//                       color: isDark
//                           ? AppColors.backgroundDark
//                           : AppColors.lightGreyContainer,
//                     ),
//                     child: TextField(
//                       style: getTextStyle2(
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                         fontSize: 16,
//                         fontWeight: FontWeight.w500,
//                       ),
//                       decoration: const InputDecoration(
//                         hintText: 'Add Notes',
//                         hintStyle: TextStyle(color: Color(0xFF828282)),
//                         border: InputBorder.none,
//                         enabledBorder: InputBorder.none,
//                         focusedBorder: InputBorder.none,
//                       ),
//                     ).marginOnly(left: 10),
//                   ),
//                 ],
//               ),
          
//               const SizedBox(height: 20),
//           Row(
//                 children: [
//                   Expanded(
//                     child: Divider(color: AppColors.borderGrey, thickness: 1),
//                   ),
//                   Padding(
//                     padding: EdgeInsets.symmetric(horizontal: 8),
//                     child: Text(
//                       'Sliceup a custom amount with',
//                       style: TextStyle(color: AppColors.textGrey),
//                     ),
//                   ),
//                   Expanded(
//                     child: Divider(color: AppColors.borderGrey, thickness: 1),
//                   ),
//                 ],
//               ),
//               Text('Total  110 / 120', style: getTextStyle2(fontSize: 12, fontWeight: FontWeight.w400),),
//               Text(
//                 'You can only track what you\'re a part of',
//                 style: getTextStyle2(fontSize: 12, fontWeight: FontWeight.w400, color: Colors.red),
//               ), 
//               const SizedBox(height: 5),
          
//               /// Friends List
//               GroupTripFriendSpentAmount(
//                 controller: controller,
//                 name: 'Ted (Me)',
//                 initials: 'S',
//                 color: AppColors.green,
//               ),
//               const SizedBox(height: 5),
//               GroupTripFriendSpentAmount(
//                 controller: controller,
//                 name: 'Eric',
//                 initials: 'A',
//                 color: AppColors.readishred,
//               ),
//               const SizedBox(height: 5),
//               GroupTripFriendSpentAmount(
//                 controller: controller,
//                 name: 'John',
//                 initials: 'H',
//                 color: AppColors.secondary,
//               ),
//               const SizedBox(height: 5),
//               GroupTripFriendSpentAmount(
//                 controller: controller,
//                 name: 'Johnny',
//                 initials: 'H',
//                 color: AppColors.blueButton,
//               ),
          
//               const SizedBox(height: 80),
//               Divider(color: AppColors.borderGrey, thickness: 1),
//               const SizedBox(height: 10),
          
//               /// Save/Next Button
//               GestureDetector(
//                 onTap: () {
//                   controller.calculateAndSetTotalAmount();
//                 },
//                 child: Obx(
//                   () => Container(
//                     height: 42.h,
//                     width: MediaQuery.of(context).size.width / 1.1,
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(20),
//                       color: AppColors.green,
//                     ),
//                     child: Center(
//                       child: Text(
//                         controller.buttonText.value,
//                         style: getTextStyle2(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               SizedBox(height: 30,)
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
