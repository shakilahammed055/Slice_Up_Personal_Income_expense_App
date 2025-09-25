// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/core/utils/constants/icon_path.dart';
// import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
// import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

// void showCategoryBottomSheet(
//   BuildContext context,
//   SettingController controller,
// ) {
//   showModalBottomSheet(
//     context: context,
//     isScrollControlled: true,
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.only(
//         topLeft: Radius.circular(24),
//         topRight: Radius.circular(24),
//       ),
//     ),
//     builder: (context) {
//       final isDark = Theme.of(context).brightness == Brightness.dark;

//       return ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: 184,
//           maxHeight: MediaQuery.of(context).size.height * 0.85,
//         ),
//         child: Container(
//           width: double.infinity,
//           clipBehavior: Clip.antiAlias,
//           decoration: ShapeDecoration(
//             color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(24),
//                 topRight: Radius.circular(24),
//               ),
//             ),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Padding(
//                 padding: EdgeInsets.symmetric(vertical: 8),
//                 child: Container(
//                   width: 134,
//                   height: 4,
//                   decoration: ShapeDecoration(
//                     color: Color(0xFF262626),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(100),
//                     ),
//                   ),
//                 ),
//               ),
//               Container(
//                 width: double.infinity,
//                 height: 56,
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     IconButton(
//                       icon: Image.asset(
//                         isDark ? IconPath.backarrowwhite : IconPath.backarrow,
//                         scale: 4,
//                       ),
//                       onPressed: () => Get.back(),
//                     ),
//                     Expanded(
//                       child: Text(
//                         'Category'.tr,
//                         textAlign: TextAlign.center,
//                         style: getTextStyle2(
//                           color: isDark ? AppColors.textWhite : AppColors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ),
//                     SizedBox(width: 48),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   child: Container(
//                     color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
//                     child: Column(
//                       children: [
//                         GestureDetector(
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: context,
//                               isScrollControlled: true,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(24),
//                                   topRight: Radius.circular(24),
//                                 ),
//                               ),
//                               builder: (context) => EditCategoryBottomSheet(
//                                 isIncome: false,
//                                 currentCategory: '',
//                                 title: 'Add Personal Category'.tr,
//                                 onCategoryEdited: (newCategory) {
//                                   if (newCategory.isNotEmpty) {
//                                     controller.updatePersonalCategory(
//                                       newCategory,
//                                       context,
//                                     );
//                                   }
//                                 },
//                               ),
//                             );
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             height: 56,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 16,
//                             ),
//                             decoration: ShapeDecoration(
//                               color: isDark
//                                   ? AppColors.deepGrey
//                                   : Color(0xFFEDEDF0),
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: isDark
//                                       ? AppColors.deepGrey
//                                       : Color(0xFFEDEDF0),
//                                 ),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Personal spending'.tr,
//                                     style: getTextStyle2(
//                                       color: Color(0xFF828282),
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 Icon(Icons.add, size: 24),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Obx(
//                           () => Column(
//                             children: controller.personalCategories.asMap().entries.map((
//                               entry,
//                             ) {
//                               final index = entry.key;
//                               final category = entry.value;
//                               final categoryDetail = controller.categoryDetails
//                                   .firstWhere(
//                                     (detail) => detail['name'] == category,
//                                     orElse: () => {
//                                       '_id': '',
//                                       'type': 'personal',
//                                     },
//                                   );
//                               return GestureDetector(
//                                 onTap: () {
//                                   String icon = '';
//                                   String categoryName = category;

//                                   if (category.isNotEmpty) {
//                                     final firstChar = category.characters.first;
//                                     if (RegExp(
//                                       r'[^\w\s]',
//                                     ).hasMatch(firstChar)) {
//                                       icon = firstChar;
//                                       categoryName = category
//                                           .substring(firstChar.length)
//                                           .trim();
//                                     }
//                                   }

//                                   controller.selectCategory(icon, categoryName);
//                                   Get.back();
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 54,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 24,
//                                     vertical: 16,
//                                   ),
//                                   decoration: ShapeDecoration(
//                                     color: isDark
//                                         ? Color(0xFF262626)
//                                         : AppColors.textWhite,
//                                     shape: RoundedRectangleBorder(
//                                       side: BorderSide(
//                                         color: isDark
//                                             ? AppColors.deepGrey
//                                             : Color(0xFFEDEDF0),
//                                       ),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           category,
//                                           style: getTextStyle2(
//                                             color: isDark
//                                                 ? AppColors.textWhite
//                                                 : AppColors.black,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () {
//                                               showModalBottomSheet(
//                                                 context: context,
//                                                 isScrollControlled: true,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                         topLeft:
//                                                             Radius.circular(24),
//                                                         topRight:
//                                                             Radius.circular(24),
//                                                       ),
//                                                 ),
//                                                 builder: (context) => EditCategoryBottomSheet(
//                                                   isIncome: false,
//                                                   currentCategory: category,
//                                                   title:
//                                                       'Edit Personal Category'
//                                                           .tr,
//                                                   onCategoryEdited: (newCategory) {
//                                                     if (newCategory
//                                                             .isNotEmpty &&
//                                                         newCategory !=
//                                                             category) {
//                                                       controller
//                                                           .updateExistingCategory(
//                                                             newCategory,
//                                                             categoryDetail['_id'],
//                                                             categoryDetail['type'],
//                                                             context,
//                                                           );
//                                                     } else if (newCategory
//                                                         .isEmpty) {
//                                                       Get.snackbar(
//                                                         'Error'.tr,
//                                                         'Please enter a category name'
//                                                             .tr,
//                                                       );
//                                                     }
//                                                   },
//                                                 ),
//                                               );
//                                             },
//                                             child: SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: Icon(
//                                                 Icons.edit,
//                                                 color: Color(0xFF828282),
//                                                 size: 24,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 16),
//                                           GestureDetector(
//                                             onTap: () {
//                                               showModalBottomSheet(
//                                                 context: context,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                         topLeft:
//                                                             Radius.circular(24),
//                                                         topRight:
//                                                             Radius.circular(24),
//                                                       ),
//                                                 ),
//                                                 builder: (context) {
//                                                   return Container(
//                                                     height:
//                                                         MediaQuery.of(
//                                                           context,
//                                                         ).size.height *
//                                                         0.30,
//                                                     width: double.infinity,
//                                                     decoration: ShapeDecoration(
//                                                       color: isDark
//                                                           ? AppColors.black
//                                                           : AppColors.textWhite,
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.only(
//                                                               topLeft:
//                                                                   Radius.circular(
//                                                                     24,
//                                                                   ),
//                                                               topRight:
//                                                                   Radius.circular(
//                                                                     24,
//                                                                   ),
//                                                             ),
//                                                       ),
//                                                     ),
//                                                     child: Column(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               EdgeInsets.symmetric(
//                                                                 vertical: 8,
//                                                               ),
//                                                           child: Container(
//                                                             width: 134,
//                                                             height: 4,
//                                                             decoration: ShapeDecoration(
//                                                               color: Color(
//                                                                 0xFF2B2F38,
//                                                               ),
//                                                               shape: RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       100,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                           'Delete Category'.tr,
//                                                           style: getTextStyle2(
//                                                             color: isDark
//                                                                 ? AppColors
//                                                                       .textWhite
//                                                                 : AppColors
//                                                                       .black,
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 16),
//                                                         Text(
//                                                           'Are you sure you want to delete "$category"?',
//                                                           style: getTextStyle2(
//                                                             color: isDark
//                                                                 ? AppColors
//                                                                       .textWhite
//                                                                 : AppColors
//                                                                       .black,
//                                                             fontSize: 14,
//                                                             fontWeight:
//                                                                 FontWeight.w400,
//                                                           ),
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                         ),
//                                                         SizedBox(height: 24),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             ElevatedButton(
//                                                               onPressed: () {
//                                                                 controller
//                                                                     .deleteCategory(
//                                                                       'personal',
//                                                                       index,
//                                                                     );
//                                                                 Get.back();
//                                                               },
//                                                               style: ElevatedButton.styleFrom(
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                         8,
//                                                                       ),
//                                                                 ),
//                                                               ),
//                                                               child: Text(
//                                                                 'Delete'.tr,
//                                                                 style: getTextStyle2(
//                                                                   color: AppColors
//                                                                       .textWhite,
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             SizedBox(width: 16),
//                                                             TextButton(
//                                                               onPressed: () =>
//                                                                   Get.back(),
//                                                               child: Text(
//                                                                 'Cancel'.tr,
//                                                                 style: getTextStyle2(
//                                                                   color: Color(
//                                                                     0xFF828282,
//                                                                   ),
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Spacer(),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                             child: SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: Icon(
//                                                 Icons.delete_outline,
//                                                 color: Color(0xFF828282),
//                                                 size: 24,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: () {
//                             showModalBottomSheet(
//                               context: context,
//                               isScrollControlled: true,
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.only(
//                                   topLeft: Radius.circular(24),
//                                   topRight: Radius.circular(24),
//                                 ),
//                               ),
//                               builder: (context) => EditCategoryBottomSheet(
//                                 isIncome: false,
//                                 currentCategory: '',
//                                 title: 'Add Group Category'.tr,
//                                 onCategoryEdited: (newCategory) {
//                                   if (newCategory.isNotEmpty) {
//                                     controller.updateGroupCategory(
//                                       newCategory,
//                                       context,
//                                     );
//                                   }
//                                 },
//                               ),
//                             );
//                           },
//                           child: Container(
//                             width: double.infinity,
//                             height: 56,
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 24,
//                               vertical: 16,
//                             ),
//                             decoration: ShapeDecoration(
//                               color: isDark
//                                   ? AppColors.deepGrey
//                                   : Color(0xFFEDEDF0),
//                               shape: RoundedRectangleBorder(
//                                 side: BorderSide(
//                                   color: isDark
//                                       ? AppColors.deepGrey
//                                       : Color(0xFFEDEDF0),
//                                 ),
//                               ),
//                             ),
//                             child: Row(
//                               children: [
//                                 Expanded(
//                                   child: Text(
//                                     'Group spending'.tr,
//                                     style: getTextStyle2(
//                                       color: Color(0xFF828282),
//                                       fontSize: 16,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ),
//                                 Icon(Icons.add, size: 24),
//                               ],
//                             ),
//                           ),
//                         ),
//                         Obx(
//                           () => Column(
//                             children: controller.groupCategories.asMap().entries.map((
//                               entry,
//                             ) {
//                               final index = entry.key;
//                               final category = entry.value;
//                               final categoryDetail = controller.categoryDetails
//                                   .firstWhere(
//                                     (detail) => detail['name'] == category,
//                                     orElse: () => {'_id': '', 'type': 'group'},
//                                   );
//                               return GestureDetector(
//                                 onTap: () {
//                                   String icon = '';
//                                   String categoryName = category;

//                                   if (category.isNotEmpty) {
//                                     final firstChar = category.characters.first;
//                                     if (RegExp(
//                                       r'[^\w\s]',
//                                     ).hasMatch(firstChar)) {
//                                       icon = firstChar;
//                                       categoryName = category
//                                           .substring(firstChar.length)
//                                           .trim();
//                                     }
//                                   }
//                                   controller.selectCategory(icon, categoryName);
//                                   Get.back();
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 54,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 24,
//                                     vertical: 16,
//                                   ),
//                                   decoration: ShapeDecoration(
//                                     color: isDark
//                                         ? Color(0xFF262626)
//                                         : AppColors.textWhite,
//                                     shape: RoundedRectangleBorder(
//                                       side: BorderSide(
//                                         color: isDark
//                                             ? AppColors.surfaceDark
//                                             : Color(0xFFEDEDF0),
//                                       ),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     children: [
//                                       Expanded(
//                                         child: Text(
//                                           category,
//                                           style: getTextStyle2(
//                                             color: isDark
//                                                 ? AppColors.textWhite
//                                                 : AppColors.black,
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       Row(
//                                         children: [
//                                           GestureDetector(
//                                             onTap: () {
//                                               showModalBottomSheet(
//                                                 context: context,
//                                                 isScrollControlled: true,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                         topLeft:
//                                                             Radius.circular(24),
//                                                         topRight:
//                                                             Radius.circular(24),
//                                                       ),
//                                                 ),
//                                                 builder: (context) => EditCategoryBottomSheet(
//                                                   isIncome: false,
//                                                   currentCategory: category,
//                                                   title:
//                                                       'Edit Group Category'.tr,
//                                                   onCategoryEdited: (newCategory) {
//                                                     if (newCategory
//                                                             .isNotEmpty &&
//                                                         newCategory !=
//                                                             category) {
//                                                       controller
//                                                           .updateExistingCategory(
//                                                             newCategory,
//                                                             categoryDetail['_id'],
//                                                             categoryDetail['type'],
//                                                             context,
//                                                           );
//                                                     } else if (newCategory
//                                                         .isEmpty) {
//                                                       Get.snackbar(
//                                                         'Error'.tr,
//                                                         'Please enter a category name'
//                                                             .tr,
//                                                       );
//                                                     }
//                                                   },
//                                                 ),
//                                               );
//                                             },
//                                             child: SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: Icon(
//                                                 Icons.edit,
//                                                 color: Color(0xFF828282),
//                                                 size: 24,
//                                               ),
//                                             ),
//                                           ),
//                                           SizedBox(width: 16),
//                                           GestureDetector(
//                                             onTap: () {
//                                               showModalBottomSheet(
//                                                 context: context,
//                                                 shape: RoundedRectangleBorder(
//                                                   borderRadius:
//                                                       BorderRadius.only(
//                                                         topLeft:
//                                                             Radius.circular(24),
//                                                         topRight:
//                                                             Radius.circular(24),
//                                                       ),
//                                                 ),
//                                                 builder: (context) {
//                                                   return Container(
//                                                     height:
//                                                         MediaQuery.of(
//                                                           context,
//                                                         ).size.height *
//                                                         0.30,
//                                                     width: double.infinity,
//                                                     decoration: ShapeDecoration(
//                                                       color: isDark
//                                                           ? AppColors.black
//                                                           : AppColors.textWhite,
//                                                       shape: RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius.only(
//                                                               topLeft:
//                                                                   Radius.circular(
//                                                                     24,
//                                                                   ),
//                                                               topRight:
//                                                                   Radius.circular(
//                                                                     24,
//                                                                   ),
//                                                             ),
//                                                       ),
//                                                     ),
//                                                     child: Column(
//                                                       mainAxisSize:
//                                                           MainAxisSize.min,
//                                                       children: [
//                                                         Padding(
//                                                           padding:
//                                                               EdgeInsets.symmetric(
//                                                                 vertical: 8,
//                                                               ),
//                                                           child: Container(
//                                                             width: 134,
//                                                             height: 4,
//                                                             decoration: ShapeDecoration(
//                                                               color: Color(
//                                                                 0xFF2B2F38,
//                                                               ),
//                                                               shape: RoundedRectangleBorder(
//                                                                 borderRadius:
//                                                                     BorderRadius.circular(
//                                                                       100,
//                                                                     ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ),
//                                                         Text(
//                                                           'Delete Category'.tr,
//                                                           style: getTextStyle2(
//                                                             color: isDark
//                                                                 ? AppColors
//                                                                       .textWhite
//                                                                 : AppColors
//                                                                       .black,
//                                                             fontSize: 16,
//                                                             fontWeight:
//                                                                 FontWeight.w500,
//                                                           ),
//                                                         ),
//                                                         SizedBox(height: 16),
//                                                         Text(
//                                                           'Are you sure you want to delete "$category"?',
//                                                           style: getTextStyle2(
//                                                             color: isDark
//                                                                 ? AppColors
//                                                                       .textWhite
//                                                                 : AppColors
//                                                                       .black,
//                                                             fontSize: 14,
//                                                             fontWeight:
//                                                                 FontWeight.w400,
//                                                           ),
//                                                           textAlign:
//                                                               TextAlign.center,
//                                                         ),
//                                                         SizedBox(height: 24),
//                                                         Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .center,
//                                                           children: [
//                                                             ElevatedButton(
//                                                               onPressed: () {
//                                                                 controller
//                                                                     .deleteCategory(
//                                                                       'group',
//                                                                       index,
//                                                                     );
//                                                                 Get.back();
//                                                               },
//                                                               style: ElevatedButton.styleFrom(
//                                                                 backgroundColor:
//                                                                     Colors.red,
//                                                                 shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                         8,
//                                                                       ),
//                                                                 ),
//                                                               ),
//                                                               child: Text(
//                                                                 'Delete'.tr,
//                                                                 style: getTextStyle2(
//                                                                   color: AppColors
//                                                                       .textWhite,
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                             SizedBox(width: 16),
//                                                             TextButton(
//                                                               onPressed: () =>
//                                                                   Get.back(),
//                                                               child: Text(
//                                                                 'Cancel'.tr,
//                                                                 style: getTextStyle2(
//                                                                   color: Color(
//                                                                     0xFF828282,
//                                                                   ),
//                                                                   fontSize: 14,
//                                                                   fontWeight:
//                                                                       FontWeight
//                                                                           .w500,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ],
//                                                         ),
//                                                         Spacer(),
//                                                       ],
//                                                     ),
//                                                   );
//                                                 },
//                                               );
//                                             },
//                                             child: SizedBox(
//                                               width: 24,
//                                               height: 24,
//                                               child: Icon(
//                                                 Icons.delete_outline,
//                                                 color: Color(0xFF828282),
//                                                 size: 24,
//                                               ),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/utils/constants/icon_path.dart';
import 'package:teddy_5618/features/settings_screen/controller/setting_screen_controller.dart';
import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

void showCategoryBottomSheet(
  BuildContext context,
  SettingController controller,
) {
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
          maxHeight: MediaQuery.of(context).size.height * 0.85,
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
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Container(
                  width: 134,
                  height: 4,
                  decoration: ShapeDecoration(
                    color: Color(0xFF262626),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
              ),
              Container(
                width: double.infinity,
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset(
                        isDark ? IconPath.backarrowwhite : IconPath.backarrow,
                        scale: 4,
                      ),
                      onPressed: () => Get.back(),
                    ),
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
                    SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    color: isDark ? Color(0xFF262626) : Color(0xFFFCFCFD),
                    child: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              builder: (context) => EditCategoryBottomSheet(
                                isIncome: false,
                                currentCategory: '',
                                title: 'Add Personal Category'.tr,
                                onCategoryEdited: (newCategory) {
                                  if (newCategory.isNotEmpty) {
                                    controller.updatePersonalCategory(
                                      newCategory,
                                      context,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Personal spending'.tr,
                                    style: getTextStyle2(
                                      color: Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.add, size: 24),
                              ],
                            ),
                          ),
                        ),
                        Obx(
                          () => Column(
                            children: controller.personalCategories.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final category = entry.value;
                              final categoryDetail = controller.categoryDetails
                                  .firstWhere(
                                    (detail) => detail['name'] == category,
                                    orElse: () => {
                                      '_id': '',
                                      'type': 'personal',
                                    },
                                  );
                              return GestureDetector(
                                onTap: () {
                                  String icon = '';
                                  String categoryName = category;

                                  if (category.isNotEmpty) {
                                    final firstChar = category.characters.first;
                                    if (RegExp(
                                      r'[^\w\s]',
                                    ).hasMatch(firstChar)) {
                                      icon = firstChar;
                                      categoryName = category
                                          .substring(firstChar.length)
                                          .trim();
                                    }
                                  }

                                  controller.selectCategory(icon, categoryName);
                                  Get.back();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? Color(0xFF262626)
                                        : AppColors.textWhite,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: isDark
                                            ? AppColors.deepGrey
                                            : Color(0xFFEDEDF0),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: getTextStyle2(
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(24),
                                                      ),
                                                ),
                                                builder: (context) => EditCategoryBottomSheet(
                                                  isIncome: false,
                                                  currentCategory: category,
                                                  title:
                                                      'Edit Personal Category'
                                                          .tr,
                                                  onCategoryEdited: (newCategory) {
                                                    if (newCategory
                                                            .isNotEmpty &&
                                                        newCategory !=
                                                            category) {
                                                      controller
                                                          .updateExistingCategory(
                                                            newCategory,
                                                            categoryDetail['_id'],
                                                            categoryDetail['type'],
                                                            context,
                                                          );
                                                    } else if (newCategory
                                                        .isEmpty) {
                                                      Get.snackbar(
                                                        'Error'.tr,
                                                        'Please enter a category name'
                                                            .tr,
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Icon(
                                                Icons.edit,
                                                color: Color(0xFF828282),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(24),
                                                      ),
                                                ),
                                                builder: (context) {
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.30,
                                                    width: double.infinity,
                                                    decoration: ShapeDecoration(
                                                      color: isDark
                                                          ? AppColors.black
                                                          : AppColors.textWhite,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    24,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    24,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 8,
                                                              ),
                                                          child: Container(
                                                            width: 134,
                                                            height: 4,
                                                            decoration: ShapeDecoration(
                                                              color: Color(
                                                                0xFF2B2F38,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      100,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Delete Category'.tr,
                                                          style: getTextStyle2(
                                                            color: isDark
                                                                ? AppColors
                                                                      .textWhite
                                                                : AppColors
                                                                      .black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Are you sure you want to delete "$category"?',
                                                          style: getTextStyle2(
                                                            color: isDark
                                                                ? AppColors
                                                                      .textWhite
                                                                : AppColors
                                                                      .black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 24),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                await controller
                                                                    .deleteCategoryViaAPI(
                                                                      categoryDetail['_id'],
                                                                      'personal',
                                                                      index,
                                                                      context,
                                                                    );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'Delete'.tr,
                                                                style: getTextStyle2(
                                                                  color: AppColors
                                                                      .textWhite,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: Text(
                                                                'Cancel'.tr,
                                                                style: getTextStyle2(
                                                                  color: Color(
                                                                    0xFF828282,
                                                                  ),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFF828282),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(24),
                                  topRight: Radius.circular(24),
                                ),
                              ),
                              builder: (context) => EditCategoryBottomSheet(
                                isIncome: false,
                                currentCategory: '',
                                title: 'Add Group Category'.tr,
                                onCategoryEdited: (newCategory) {
                                  if (newCategory.isNotEmpty) {
                                    controller.updateGroupCategory(
                                      newCategory,
                                      context,
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          child: Container(
                            width: double.infinity,
                            height: 56,
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: ShapeDecoration(
                              color: isDark
                                  ? AppColors.deepGrey
                                  : Color(0xFFEDEDF0),
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                  color: isDark
                                      ? AppColors.deepGrey
                                      : Color(0xFFEDEDF0),
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Group spending'.tr,
                                    style: getTextStyle2(
                                      color: Color(0xFF828282),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.add, size: 24),
                              ],
                            ),
                          ),
                        ),
                        Obx(
                          () => Column(
                            children: controller.groupCategories.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final category = entry.value;
                              final categoryDetail = controller.categoryDetails
                                  .firstWhere(
                                    (detail) => detail['name'] == category,
                                    orElse: () => {'_id': '', 'type': 'group'},
                                  );
                              return GestureDetector(
                                onTap: () {
                                  String icon = '';
                                  String categoryName = category;

                                  if (category.isNotEmpty) {
                                    final firstChar = category.characters.first;
                                    if (RegExp(
                                      r'[^\w\s]',
                                    ).hasMatch(firstChar)) {
                                      icon = firstChar;
                                      categoryName = category
                                          .substring(firstChar.length)
                                          .trim();
                                    }
                                  }
                                  controller.selectCategory(icon, categoryName);
                                  Get.back();
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 54,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? Color(0xFF262626)
                                        : AppColors.textWhite,
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        color: isDark
                                            ? AppColors.surfaceDark
                                            : Color(0xFFEDEDF0),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          category,
                                          style: getTextStyle2(
                                            color: isDark
                                                ? AppColors.textWhite
                                                : AppColors.black,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(24),
                                                      ),
                                                ),
                                                builder: (context) => EditCategoryBottomSheet(
                                                  isIncome: false,
                                                  currentCategory: category,
                                                  title:
                                                      'Edit Group Category'.tr,
                                                  onCategoryEdited: (newCategory) {
                                                    if (newCategory
                                                            .isNotEmpty &&
                                                        newCategory !=
                                                            category) {
                                                      controller
                                                          .updateExistingCategory(
                                                            newCategory,
                                                            categoryDetail['_id'],
                                                            categoryDetail['type'],
                                                            context,
                                                          );
                                                    } else if (newCategory
                                                        .isEmpty) {
                                                      Get.snackbar(
                                                        'Error'.tr,
                                                        'Please enter a category name'
                                                            .tr,
                                                      );
                                                    }
                                                  },
                                                ),
                                              );
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Icon(
                                                Icons.edit,
                                                color: Color(0xFF828282),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          GestureDetector(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(24),
                                                        topRight:
                                                            Radius.circular(24),
                                                      ),
                                                ),
                                                builder: (context) {
                                                  return Container(
                                                    height:
                                                        MediaQuery.of(
                                                          context,
                                                        ).size.height *
                                                        0.30,
                                                    width: double.infinity,
                                                    decoration: ShapeDecoration(
                                                      color: isDark
                                                          ? AppColors.black
                                                          : AppColors.textWhite,
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                              topLeft:
                                                                  Radius.circular(
                                                                    24,
                                                                  ),
                                                              topRight:
                                                                  Radius.circular(
                                                                    24,
                                                                  ),
                                                            ),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Padding(
                                                          padding:
                                                              EdgeInsets.symmetric(
                                                                vertical: 8,
                                                              ),
                                                          child: Container(
                                                            width: 134,
                                                            height: 4,
                                                            decoration: ShapeDecoration(
                                                              color: Color(
                                                                0xFF2B2F38,
                                                              ),
                                                              shape: RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      100,
                                                                    ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Text(
                                                          'Delete Category'.tr,
                                                          style: getTextStyle2(
                                                            color: isDark
                                                                ? AppColors
                                                                      .textWhite
                                                                : AppColors
                                                                      .black,
                                                            fontSize: 16,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Text(
                                                          'Are you sure you want to delete "$category"?',
                                                          style: getTextStyle2(
                                                            color: isDark
                                                                ? AppColors
                                                                      .textWhite
                                                                : AppColors
                                                                      .black,
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                        SizedBox(height: 24),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            ElevatedButton(
                                                              onPressed: () async {
                                                                await controller
                                                                    .deleteCategoryViaAPI(
                                                                      categoryDetail['_id'],
                                                                      'group',
                                                                      index,
                                                                      context,
                                                                    );
                                                              },
                                                              style: ElevatedButton.styleFrom(
                                                                backgroundColor:
                                                                    Colors.red,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        8,
                                                                      ),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'Delete'.tr,
                                                                style: getTextStyle2(
                                                                  color: AppColors
                                                                      .textWhite,
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            TextButton(
                                                              onPressed: () =>
                                                                  Get.back(),
                                                              child: Text(
                                                                'Cancel'.tr,
                                                                style: getTextStyle2(
                                                                  color: Color(
                                                                    0xFF828282,
                                                                  ),
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        Spacer(),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Color(0xFF828282),
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ],
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
              ),
            ],
          ),
        ),
      );
    },
  );
}
