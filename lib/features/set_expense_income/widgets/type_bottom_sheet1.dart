// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:teddy_5618/core/common/styles/global_text_style.dart';
// import 'package:teddy_5618/core/utils/constants/colors.dart';
// import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
// import 'package:teddy_5618/features/set_expense_income/widgets/add_category_bottomsheet.dart';
// import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

// class TypeBottomSheet extends StatefulWidget {
//   final RxList<ExpenseType> types;
//   final Function(ExpenseType) onTypeSelected;
//   final bool isIncome;

//   const TypeBottomSheet({
//     super.key,
//     required this.types,
//     required this.onTypeSelected,
//     required this.isIncome,
//   });

//   @override
//   State<TypeBottomSheet> createState() => _TypeBottomSheetState();
// }

// class _TypeBottomSheetState extends State<TypeBottomSheet> {
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchTypesIfNeeded();
//   }

//   Future<void> _fetchTypesIfNeeded() async {
//     final controller = Get.find<ExpenseController>();
//     if (widget.isIncome && controller.incomeTypes.isEmpty) {
//       setState(() {
//         isLoading = true;
//       });
//       await controller.fetchIncomeTypes();
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else if (!widget.isIncome && controller.expenseTypes.isEmpty) {
//       setState(() {
//         isLoading = true;
//       });
//       await controller.fetchExpenseTypes();
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return SizedBox(
//       height: MediaQuery.of(context).size.height * 0.8,
//       child: ConstrainedBox(
//         constraints: BoxConstraints(minHeight: 184),
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
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Container(
//                 width: double.infinity,
//                 height: 56,
//                 padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: ShapeDecoration(
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(24),
//                       topRight: Radius.circular(24),
//                     ),
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(width: 48),
//                     Expanded(
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           SizedBox(
//                             width: double.infinity,
//                             child: Text(
//                               'Category'.tr,
//                               textAlign: TextAlign.center,
//                               style: getTextStyle2(
//                                 color: isDark
//                                     ? AppColors.textWhite
//                                     : AppColors.black,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.close,
//                         color: isDark ? AppColors.textWhite : AppColors.black,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//               ),
//               Expanded(
//                 child: isLoading
//                     ? Center(
//                         child: CircularProgressIndicator(
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                             isDark ? AppColors.textWhite : AppColors.black,
//                           ),
//                         ),
//                       )
//                     : Container(
//                         width: double.infinity,
//                         decoration: BoxDecoration(
//                           color: isDark ? Color(0xFF262626) : AppColors.textWhite,
//                         ),
//                         child: SingleChildScrollView(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   showModalBottomSheet(
//                                     context: context,
//                                     isScrollControlled: true,
//                                     builder: (context) {
//                                       return SizedBox(
//                                         height:
//                                             MediaQuery.of(context).size.height * 0.80,
//                                         child: AddCategoryBottomSheet(
//                                           isIncome: widget.isIncome,
//                                           onCategoryAdded: (newCategory) {
//                                             final controller = Get.find<ExpenseController>();
//                                             final typesList = widget.isIncome ? controller.incomeTypes : controller.expenseTypes;
//                                             final newType = typesList.firstWhere((t) => t.name == newCategory);
//                                             controller.setType(newType);
//                                             Navigator.pop(
//                                               context,
//                                             ); // Close AddCategoryBottomSheet
//                                             Navigator.pop(
//                                               context,
//                                             ); // Close TypeBottomSheet
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   );
//                                 },
//                                 child: Container(
//                                   width: double.infinity,
//                                   height: 56,
//                                   padding: EdgeInsets.symmetric(
//                                     horizontal: 24,
//                                     vertical: 16,
//                                   ),
//                                   clipBehavior: Clip.antiAlias,
//                                   decoration: ShapeDecoration(
//                                     color: isDark
//                                         ? AppColors.deepGrey
//                                         : const Color(0xFFEDEDF0),
//                                     shape: RoundedRectangleBorder(
//                                       side: BorderSide(
//                                         width: 1,
//                                         color: isDark
//                                             ? AppColors.deepGrey
//                                             : Color(0xFFEDEDF0),
//                                       ),
//                                     ),
//                                   ),
//                                   child: Row(
//                                     mainAxisSize: MainAxisSize.min,
//                                     mainAxisAlignment: MainAxisAlignment.start,
//                                     crossAxisAlignment: CrossAxisAlignment.center,
//                                     children: [
//                                       SizedBox(
//                                         width: 250,
//                                         child: Text(
//                                           'Add new'.tr,
//                                           style: getTextStyle2(
//                                             color: Color(0xFF828282),
//                                             fontSize: 16,
//                                             fontWeight: FontWeight.w500,
//                                           ),
//                                         ),
//                                       ),
//                                       Spacer(),
//                                       Container(
//                                         height: 32,
//                                         padding: EdgeInsets.symmetric(horizontal: 4),
//                                         child: Icon(
//                                           Icons.add,
//                                           color: Color(0xFF828282),
//                                           size: 24,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               Obx(
//                                 () => Column(
//                                   children: widget.types.map((type) {
//                                     return GestureDetector(
//                                       onTap: () {
//                                         widget.onTypeSelected(type);
//                                       },
//                                       child: Container(
//                                         width: double.infinity,
//                                         height: 54,
//                                         padding: EdgeInsets.symmetric(
//                                           horizontal: 24,
//                                           vertical: 16,
//                                         ),
//                                         clipBehavior: Clip.antiAlias,
//                                         decoration: ShapeDecoration(
//                                           color: isDark
//                                               ? Color(0xFF262626)
//                                               : AppColors.textWhite,
//                                           shape: RoundedRectangleBorder(
//                                             side: BorderSide(
//                                               width: 1,
//                                               color: isDark
//                                                   ? AppColors.deepGrey
//                                                   : const Color(0xFFEDEDF0),
//                                             ),
//                                           ),
//                                         ),
//                                         child: Row(
//                                           mainAxisSize: MainAxisSize.min,
//                                           mainAxisAlignment: MainAxisAlignment.start,
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.center,
//                                           children: [
//                                             SizedBox(
//                                               width: 200,
//                                               child: Text(
//                                                 type.name,
//                                                 style: getTextStyle3(
//                                                   color: isDark
//                                                       ? AppColors.textWhite
//                                                       : AppColors.black,
//                                                   fontSize: 16,
//                                                   fontWeight: FontWeight.w500,
//                                                 ),
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                             ),
//                                             Spacer(),
//                                             Container(
//                                               height: 32,
//                                               padding: EdgeInsets.symmetric(
//                                                 horizontal: 4,
//                                               ),
//                                               child: Obx(() {
//                                                 final expenseController =
//                                                     Get.find<ExpenseController>();
//                                                 return Icon(
//                                                   expenseController
//                                                               .selectedType
//                                                               .value ==
//                                                           type
//                                                       ? Icons.check
//                                                       : null,
//                                                   color: isDark
//                                                       ? AppColors.textWhite
//                                                       : AppColors.black,
//                                                   size: 24,
//                                                 );
//                                               }),
//                                             ),
//                                             SizedBox(width: 20),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 showModalBottomSheet(
//                                                   context: context,
//                                                   isScrollControlled: true,
//                                                   builder: (context) {
//                                                     return SizedBox(
//                                                       height:
//                                                           MediaQuery.of(
//                                                             context,
//                                                           ).size.height *
//                                                           0.80,
//                                                       child: EditCategoryBottomSheet(
//                                                         isIncome: widget.isIncome,
//                                                         currentCategory: type.name,
//                                                         onCategoryEdited:
//                                                             (newCategory) async {
//                                                           try {
//                                                             await Get.find<ExpenseController>().editCategory(
//                                                               type.name,
//                                                               newCategory,
//                                                               widget.isIncome,
//                                                             );
//                                                             Navigator.pop(context);
//                                                           } catch (e) {
//                                                             Get.snackbar('Error'.tr, e.toString());
//                                                           }
//                                                         },
//                                                       ),
//                                                     );
//                                                   },
//                                                 );
//                                               },
//                                               child: Icon(Icons.edit_outlined),
//                                             ),
//                                             SizedBox(width: 10),
//                                             GestureDetector(
//                                               onTap: () {
//                                                 Get.defaultDialog(
//                                                   backgroundColor: isDark
//                                                       ? AppColors.deepGrey
//                                                       : Color(
//                                                           0xffF2F2F2,
//                                                         ).withValues(alpha: 1.1),
//                                                   title:
//                                                       'Are you sure you want to delete  "${type.name}"?',
//                                                   titleStyle: getTextStyle2(
//                                                     color: isDark
//                                                         ? AppColors.textWhite
//                                                         : AppColors.black,
//                                                     fontSize: 17,
//                                                     fontWeight: FontWeight.w600,
//                                                   ),
//                                                   content: Column(
//                                                     mainAxisSize: MainAxisSize.min,
//                                                     children: [
//                                                       Text(
//                                                         'This action cannot be undone.'
//                                                             .tr,
//                                                         textAlign: TextAlign.center,
//                                                       ),
//                                                       SizedBox(height: 20),
//                                                       Row(
//                                                         mainAxisAlignment:
//                                                             MainAxisAlignment
//                                                                 .spaceEvenly,
//                                                         children: [
//                                                           GestureDetector(
//                                                             onTap: () =>
//                                                                 Navigator.pop(
//                                                                   context,
//                                                                 ),
//                                                             child: Container(
//                                                               padding:
//                                                                   EdgeInsets.symmetric(
//                                                                 horizontal: 16,
//                                                                 vertical: 12,
//                                                               ),
//                                                               decoration: ShapeDecoration(
//                                                                  color: isDark
//                                                                     ? Color(
//                                                                         0xFF262626,
//                                                                       )
//                                                                     : AppColors.black,
//                                                                 shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                     05,
//                                                                   ),
//                                                                   side: BorderSide(
//                                                                     width: 0.5,
//                                                                     color:
//                                                                          AppColors
//                                                                               .black,
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               child: Text(
//                                                                 'Cancel',
//                                                                 style: getTextStyle2(
//                                                                   color: Color(
//                                                                     0xFF007AFF,
//                                                                   ),
//                                                                   fontSize: 17,
//                                                                   fontWeight:
//                                                                       FontWeight.w400,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           GestureDetector(
//                                                             onTap: () async {
//                                                               Navigator.pop(context); // Close dialog first
//                                                               final expenseController =
//                                                                   Get.find<
//                                                                     ExpenseController
//                                                                   >();
//                                                               try {
//                                                                 await expenseController
//                                                                     .deleteCategory(
//                                                                   type.name,
//                                                                   widget.isIncome,
//                                                                 );
//                                                                 Get.snackbar(
//                                                                   'Success'.tr,
//                                                                   'Category "${type.name}" deleted',
//                                                                 );
//                                                               } catch (e) {
//                                                                 Get.snackbar(
//                                                                   'Error'.tr,
//                                                                   e.toString(),
//                                                                 );
//                                                               }
//                                                             },
//                                                             child: Container(
//                                                               padding:
//                                                                   EdgeInsets.symmetric(
//                                                                 horizontal: 16,
//                                                                 vertical: 12,
//                                                               ),
//                                                               decoration: ShapeDecoration(
//                                                                 color: isDark
//                                                                     ? Color(
//                                                                         0xFF262626,
//                                                                       )
//                                                                     : AppColors.black,
//                                                                 shape: RoundedRectangleBorder(
//                                                                   borderRadius:
//                                                                       BorderRadius.circular(
//                                                                     05,
//                                                                   ),
//                                                                   side: BorderSide(
//                                                                     width: 0.5,
//                                                                     color: Color(
//                                                                       0x5B3C3C43,
//                                                                     ),
//                                                                   ),
//                                                                 ),
//                                                               ),
//                                                               child: Text(
//                                                                 'Delete'.tr,
//                                                                 style: getTextStyle2(
//                                                                   color: Color(
//                                                                     0xFF007AFF,
//                                                                   ),
//                                                                   fontSize: 17,
//                                                                   fontWeight:
//                                                                       FontWeight.w600,
//                                                                 ),
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   radius: 12,
//                                                 );
//                                               },
//                                               child: Icon(
//                                                 Icons.delete_outline_outlined,
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//               ),
//               SizedBox(
//                 width: double.infinity,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 390,
//                       padding: EdgeInsets.only(
//                         top: 16,
//                         left: 20,
//                         right: 20,
//                         bottom: 8,
//                       ),
//                       decoration: ShapeDecoration(
//                         color: isDark ? AppColors.black : Color(0xFFFCFCFD),
//                         shape: RoundedRectangleBorder(
//                           side: BorderSide(width: 1, color: Color(0xFFD0D3D9)),
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisSize: MainAxisSize.min,
//                         mainAxisAlignment: MainAxisAlignment.start,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: double.infinity,
//                             padding: EdgeInsets.only(
//                               top: 12,
//                               left: 112,
//                               right: 112,
//                             ),
//                             child: Column(
//                               mainAxisSize: MainAxisSize.min,
//                               mainAxisAlignment: MainAxisAlignment.start,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 134,
//                                   height: 4,
//                                   decoration: ShapeDecoration(
//                                     color: Color(0xFF2B2F38),
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(100),
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';
import 'package:teddy_5618/features/set_expense_income/widgets/add_category_bottomsheet.dart';
import 'package:teddy_5618/features/settings_screen/widget/edit_category_bottomsheet.dart';

class TypeBottomSheet extends StatefulWidget {
  final RxList<ExpenseType> types;
  final Function(ExpenseType) onTypeSelected;
  final bool isIncome;

  const TypeBottomSheet({
    super.key,
    required this.types,
    required this.onTypeSelected,
    required this.isIncome,
  });

  @override
  State<TypeBottomSheet> createState() => _TypeBottomSheetState();
}

class _TypeBottomSheetState extends State<TypeBottomSheet> {
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTypesIfNeeded();
  }

  Future<void> _fetchTypesIfNeeded() async {
    final controller = Get.find<ExpenseController>();
    if (widget.isIncome && controller.incomeTypes.isEmpty) {
      setState(() {
        isLoading = true;
      });
      await controller.fetchIncomeTypes();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } else if (!widget.isIncome && controller.expenseTypes.isEmpty) {
      setState(() {
        isLoading = true;
      });
      await controller.fetchExpenseTypes();
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: 184),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            width: double.infinity,
                            child: Text(
                              'Category'.tr,
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
                      icon: Icon(
                        Icons.close,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.textWhite : AppColors.black,
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: isDark
                              ? Color(0xFF262626)
                              : AppColors.textWhite,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (innerContext) {
                                      return SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                            0.80,
                                        child: AddCategoryBottomSheet(
                                          isIncome: widget.isIncome,
                                          onCategoryAdded: (newCategory) {
                                            final controller =
                                                Get.find<ExpenseController>();
                                            final typesList = widget.isIncome
                                                ? controller.incomeTypes
                                                : controller.expenseTypes;
                                            final newType = typesList
                                                .firstWhereOrNull(
                                                  (t) => t.name == newCategory,
                                                );
                                            if (newType != null) {
                                              controller.setType(newType);
                                            }
                                            Navigator.pop(
                                              innerContext,
                                            ); // Close AddCategoryBottomSheet only
                                          },
                                        ),
                                      );
                                    },
                                  );
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: ShapeDecoration(
                                    color: isDark
                                        ? AppColors.deepGrey
                                        : const Color(0xFFEDEDF0),
                                    shape: RoundedRectangleBorder(
                                      side: BorderSide(
                                        width: 1,
                                        color: isDark
                                            ? AppColors.deepGrey
                                            : Color(0xFFEDEDF0),
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 250,
                                        child: Text(
                                          'Add new'.tr,
                                          style: getTextStyle2(
                                            color: Color(0xFF828282),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Spacer(),
                                      Container(
                                        height: 32,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 4,
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          color: Color(0xFF828282),
                                          size: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Obx(
                                () => Column(
                                  children: widget.types.map((type) {
                                    return GestureDetector(
                                      onTap: () {
                                        widget.onTypeSelected(type);
                                      },
                                      child: Container(
                                        width: double.infinity,
                                        height: 54,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 24,
                                          vertical: 16,
                                        ),
                                        clipBehavior: Clip.antiAlias,
                                        decoration: ShapeDecoration(
                                          color: isDark
                                              ? Color(0xFF262626)
                                              : AppColors.textWhite,
                                          shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                              width: 1,
                                              color: isDark
                                                  ? AppColors.deepGrey
                                                  : const Color(0xFFEDEDF0),
                                            ),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: Text(
                                                type.name,
                                                style: getTextStyle3(
                                                  color: isDark
                                                      ? AppColors.textWhite
                                                      : AppColors.black,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Spacer(),
                                            Container(
                                              height: 32,
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              child: Obx(() {
                                                final expenseController =
                                                    Get.find<
                                                      ExpenseController
                                                    >();
                                                return Icon(
                                                  expenseController
                                                              .selectedType
                                                              .value ==
                                                          type
                                                      ? Icons.check
                                                      : null,
                                                  color: isDark
                                                      ? AppColors.textWhite
                                                      : AppColors.black,
                                                  size: 24,
                                                );
                                              }),
                                            ),
                                            SizedBox(width: 20),
                                            GestureDetector(
                                              onTap: () {
                                                showModalBottomSheet(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) {
                                                    return SizedBox(
                                                      height:
                                                          MediaQuery.of(
                                                            context,
                                                          ).size.height *
                                                          0.80,
                                                      child: EditCategoryBottomSheet(
                                                        isIncome:
                                                            widget.isIncome,
                                                        currentCategory:
                                                            type.name,
                                                        onCategoryEdited:
                                                            (
                                                              newCategory,
                                                            ) async {
                                                              try {
                                                                await Get.find<
                                                                      ExpenseController
                                                                    >()
                                                                    .editCategory(
                                                                      type.name,
                                                                      newCategory,
                                                                      widget
                                                                          .isIncome,
                                                                    );
                                                                Navigator.pop(
                                                                  context,
                                                                );
                                                              } catch (e) {
                                                                Get.snackbar(
                                                                  'Error'.tr,
                                                                  e.toString(),
                                                                );
                                                              }
                                                            },
                                                      ),
                                                    );
                                                  },
                                                );
                                              },
                                              child: Icon(Icons.edit_outlined),
                                            ),
                                            SizedBox(width: 10),
                                            GestureDetector(
                                              onTap: () {
                                                Get.defaultDialog(
                                                  backgroundColor: isDark
                                                      ? AppColors.deepGrey
                                                      : Color(
                                                          0xffF2F2F2,
                                                        ).withValues(
                                                          alpha: 1.1,
                                                        ),
                                                  title:
                                                      'Are you sure you want to delete  "${type.name}"?',
                                                  titleStyle: getTextStyle2(
                                                    color: isDark
                                                        ? AppColors.textWhite
                                                        : AppColors.black,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  content: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        'This action cannot be undone.'
                                                            .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                      SizedBox(height: 20),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              decoration: ShapeDecoration(
                                                                color: isDark
                                                                    ? Color(
                                                                        0xFF262626,
                                                                      )
                                                                    : AppColors
                                                                          .textWhite,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        05,
                                                                      ),
                                                                  side: BorderSide(
                                                                    width: 0.5,
                                                                    color: AppColors
                                                                        .black,
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'Cancel',
                                                                style: getTextStyle2(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          GestureDetector(
                                                            onTap: () async {
                                                              Navigator.pop(
                                                                context,
                                                              ); // Close dialog first
                                                              final expenseController =
                                                                  Get.find<
                                                                    ExpenseController
                                                                  >();
                                                              try {
                                                                await expenseController
                                                                    .deleteCategory(
                                                                      type.name,
                                                                      widget
                                                                          .isIncome,
                                                                    );
                                                                Get.snackbar(
                                                                  'Success'.tr,
                                                                  'Category "${type.name}" deleted',
                                                                );
                                                              } catch (e) {
                                                                Get.snackbar(
                                                                  'Error'.tr,
                                                                  e.toString(),
                                                                );
                                                              }
                                                            },
                                                            child: Container(
                                                              padding:
                                                                  EdgeInsets.symmetric(
                                                                    horizontal:
                                                                        16,
                                                                    vertical:
                                                                        12,
                                                                  ),
                                                              decoration: ShapeDecoration(
                                                                color: isDark
                                                                    ? Color(
                                                                        0xFF262626,
                                                                      )
                                                                    : AppColors
                                                                          .textWhite,
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                        05,
                                                                      ),
                                                                  side: BorderSide(
                                                                    width: 0.5,
                                                                    color: Color(
                                                                      0x5B3C3C43,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              child: Text(
                                                                'Delete'.tr,
                                                                style: getTextStyle2(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize: 17,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  radius: 12,
                                                );
                                              },
                                              child: Icon(
                                                Icons.delete_outline_outlined,
                                              ),
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
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 390,
                      padding: EdgeInsets.only(
                        top: 16,
                        left: 20,
                        right: 20,
                        bottom: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: isDark ? AppColors.black : Color(0xFFFCFCFD),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 1, color: Color(0xFFD0D3D9)),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.only(
                              top: 12,
                              left: 112,
                              right: 112,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 134,
                                  height: 4,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFF2B2F38),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
