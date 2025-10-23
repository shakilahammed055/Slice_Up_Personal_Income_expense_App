import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/home_screen/controller/home_screen_controller.dart';
import 'package:teddy_5618/features/home_screen/widgets/texxtfield.dart';
import 'package:teddy_5618/features/home_screen/controller/search_controller.dart';
import 'package:teddy_5618/features/set_expense_income/controller/expense_controller.dart';

// --- RESPONSIVE HELPER ---
class ResponsiveHelper {
  final BuildContext context;
  final Size size;

  ResponsiveHelper(this.context) : size = MediaQuery.of(context).size;

  bool get isSmallPhone => size.width <= 360;
  bool get isMediumPhone => size.width > 362 && size.width < 414;
  bool get isLargePhone => size.width >= 414;

  T fromSmallMediumLarge<T>({
    required T small,
    required T medium,
    required T large,
  }) {
    if (isSmallPhone) return small;
    if (isMediumPhone) return medium;
    return large;
  }
}

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchController = Get.put(SearchScreenController());
    final double screenHeight = MediaQuery.of(context).size.height;
    final expenseController = Get.put(ExpenseController());

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.textWhite,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Icon(
            CupertinoIcons.back,
            size: MediaQuery.of(context).size.height / 25,
          ),
        ),
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.textWhite,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TexxtField(
              controller: searchController.textController,
              onClear: searchController.clearSearch,
            ),
            SizedBox(
              height: responsive.fromSmallMediumLarge(
                small: 24.0,
                medium: 12.0,
                large: 40.0,
              ),
            ),
            Obx(() {
              final homeController = Get.find<HomeController>();
              final String query = searchController.searchText.value
                  .toLowerCase();
              final bool useApi =
                  homeController.isApiDataLoaded.value &&
                  homeController.apiGroupedByDate.isNotEmpty;

              Widget noEntriesWidget = Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      query.isEmpty
                          ? 'No entries available'.tr
                          : 'No entries found'.tr,
                      style: getTextStyle2(
                        color: const Color(0xFF828282),
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.1),
                  ],
                ),
              );

              if (useApi) {
                // Collect all transactions from API groups
                List<Map<String, dynamic>> allTrans = [];
                for (var group in homeController.apiGroupedByDate) {
                  allTrans.addAll(
                    (group['transactions'] as List)
                        .cast<Map<String, dynamic>>(),
                  );
                }

                // Filter transactions by category, title, or date
                List<Map<String, dynamic>> filteredTrans = allTrans.where((
                  trans,
                ) {
                  final String typeName = (trans['typeName'] ?? '')
                      .toLowerCase();
                  final String desc = (trans['description'] ?? '')
                      .toLowerCase();
                  final String dateStr = trans['date'] ?? '';
                  final DateTime dateTime = DateTime.parse(dateStr);
                  final String formattedDate = DateFormat(
                    'EEE d MMM yyyy',
                  ).format(dateTime).toLowerCase();
                  return typeName.contains(query) ||
                      desc.contains(query) ||
                      formattedDate.contains(query);
                }).toList();

                if (filteredTrans.isEmpty) {
                  return noEntriesWidget;
                }

                // Group filtered transactions by date
                Map<String, List<Map<String, dynamic>>> filteredGrouped = {};
                for (var trans in filteredTrans) {
                  final String dateStr = trans['date'] as String;
                  if (!filteredGrouped.containsKey(dateStr)) {
                    filteredGrouped[dateStr] = [];
                  }
                  filteredGrouped[dateStr]!.add(trans);
                }

                // Sort groups by date descending
                final sortedGroups = filteredGrouped.entries.toList()
                  ..sort((a, b) {
                    final DateTime dateA = DateTime.parse(a.key);
                    final DateTime dateB = DateTime.parse(b.key);
                    return dateB.compareTo(dateA);
                  });

                return Column(
                  children: sortedGroups.map((groupEntry) {
                    final String dateStr = groupEntry.key;
                    final List<Map<String, dynamic>> transactions =
                        groupEntry.value;
                    final DateTime dateTime = DateTime.parse(dateStr);
                    final String formattedDate = DateFormat(
                      'EEE d MMM yyyy',
                    ).format(dateTime);
                    final double net = transactions.fold<double>(0.0, (
                      sum,
                      trans,
                    ) {
                      final double amount = (trans['amount'] as num).toDouble();
                      final bool isIncome =
                          trans['transactionType'] == 'income';
                      return sum + (isIncome ? amount : -amount);
                    });

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0x1E000000),
                              blurRadius: 16.r,
                              offset: Offset(0, 6.h),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 48.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: ShapeDecoration(
                                color: isDark
                                    ? Color(0xFF38383A)
                                    : const Color(0xFFEDEDF0),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.w,
                                    color: isDark
                                        ? Color(0xFF38383A)
                                        : const Color(0xFFEDEDF0),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: getTextStyle2(
                                      color: isDark
                                          ? Color(0xFFAAAAAA)
                                          : const Color(0xFF828282),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100.w,
                                    height: 24.h,
                                    child: Text(
                                      '\$${net.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 22.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1.h,
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFEDEDF0),
                            ),
                            ...transactions.asMap().entries.map((indexedEntry) {
                              final Map<String, dynamic> trans =
                                  indexedEntry.value;
                              final String? typeName =
                                  trans['typeName'] as String?;
                              final String iconStr =
                                  typeName?.split(' ').join(' ') ?? '';
                              final String title =
                                  trans['description'] as String? ?? '';
                              final double amount = (trans['amount'] as num)
                                  .toDouble();
                              final bool isIncome =
                                  trans['transactionType'] == 'income';
                              final String transId = trans['_id'] as String;

                              return Column(
                                children: [
                                  if (indexedEntry.key > 0)
                                    Container(
                                      width: double.infinity,
                                      height: 1.h,
                                      color: isDark
                                          ? const Color(0xFF38383A)
                                          : const Color(0xFFEDEDF0),
                                    ),
                                  Dismissible(
                                    key: Key(transId),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      width: double.infinity,
                                      height: 52.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE21818),
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      try {
                                        final String description =
                                            trans['description'] as String? ??
                                            'this transaction';
                                        final success = await homeController
                                            .deleteTransaction(
                                              transId,
                                              description,
                                            );
                                        if (success) {
                                          await homeController
                                              .refreshIncomeAndExpenses();
                                        }
                                        return success;
                                      } catch (e) {
                                        debugPrint(
                                          'Error deleting transaction: $e',
                                        );
                                        return false;
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 48.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: isDark
                                            ? Color(0xFF262626)
                                            : AppColors.textWhite,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1.w,
                                            color: isDark
                                                ? Color(0xFF38383A)
                                                : AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 100.h,
                                            height: 20.h,
                                            child: Text(
                                              iconStr,
                                              style: getTextStyle2(
                                                color: const Color(0xFF828282),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100.w,
                                            child: Text(
                                              title,
                                              style: getTextStyle2(
                                                color: isDark
                                                    ? AppColors.textWhite
                                                    : const Color(0xFF141414),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100.w,
                                            child: Text(
                                              '${isIncome ? '+' : '-'} \$${amount.toStringAsFixed(2)}',
                                              textAlign: TextAlign.right,
                                              style: getTextStyle2(
                                                color: isIncome
                                                    ? const Color(0xFF00D460)
                                                    : const Color(0xFFEF5B00),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              } else {
                // Local mode
                final List<ExpenseEntry> allEntries = expenseController.entries;
                // Filter entries by type, note, or date
                final List<ExpenseEntry> filteredEntries = allEntries.where((
                  entry,
                ) {
                  final String type = entry.type.toLowerCase();
                  final String note = entry.note.toLowerCase();
                  String formattedDate;
                  try {
                    final parts = entry.date.split('/');
                    final dateTime = DateTime(
                      int.parse(parts[2]),
                      int.parse(parts[1]),
                      int.parse(parts[0]),
                    );
                    formattedDate = DateFormat(
                      'EEE d MMM yyyy',
                    ).format(dateTime).toLowerCase();
                  } catch (e) {
                    debugPrint('Error formatting date for entry: $e');
                    formattedDate = entry.date.toLowerCase();
                  }
                  return type.contains(query) ||
                      note.contains(query) ||
                      formattedDate.contains(query);
                }).toList();

                if (filteredEntries.isEmpty) {
                  return noEntriesWidget;
                }

                // Group filtered entries by date
                Map<String, List<ExpenseEntry>> filteredGrouped = {};
                for (var entry in filteredEntries) {
                  if (!filteredGrouped.containsKey(entry.date)) {
                    filteredGrouped[entry.date] = [];
                  }
                  filteredGrouped[entry.date]!.add(entry);
                }

                // Sort groups by date descending
                final sortedGroups = filteredGrouped.entries.toList()
                  ..sort((a, b) {
                    try {
                      final DateTime dateA = DateFormat(
                        'dd/MM/yyyy',
                      ).parse(a.key);
                      final DateTime dateB = DateFormat(
                        'dd/MM/yyyy',
                      ).parse(b.key);
                      return dateB.compareTo(dateA);
                    } catch (e) {
                      return a.key.compareTo(b.key);
                    }
                  });

                return Column(
                  children: sortedGroups.map((groupEntry) {
                    final String date = groupEntry.key;
                    final List<ExpenseEntry> entries = groupEntry.value;
                    String formattedDate;
                    try {
                      final parts = date.split('/');
                      final dateTime = DateTime(
                        int.parse(parts[2]),
                        int.parse(parts[1]),
                        int.parse(parts[0]),
                      );
                      formattedDate = DateFormat(
                        'EEE d MMM yyyy',
                      ).format(dateTime);
                    } catch (e) {
                      debugPrint('Error formatting date: $e');
                      formattedDate = date;
                    }
                    final double total = entries.fold<double>(0.0, (
                      sum,
                      entry,
                    ) {
                      return sum +
                          (entry.isIncome ? entry.amount : -entry.amount);
                    });

                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: ShapeDecoration(
                          color: isDark
                              ? AppColors.backgroundDark
                              : AppColors.textWhite,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          shadows: [
                            BoxShadow(
                              color: const Color(0x1E000000),
                              blurRadius: 16.r,
                              offset: Offset(0, 6.h),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              height: 48.h,
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              decoration: ShapeDecoration(
                                color: isDark
                                    ? Color(0xFF38383A)
                                    : const Color(0xFFEDEDF0),
                                shape: RoundedRectangleBorder(
                                  side: BorderSide(
                                    width: 1.w,
                                    color: isDark
                                        ? Color(0xFF38383A)
                                        : const Color(0xFFEDEDF0),
                                  ),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    formattedDate,
                                    style: getTextStyle2(
                                      color: isDark
                                          ? Color(0xFFAAAAAA)
                                          : const Color(0xFF828282),
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 100.w,
                                    height: 24.h,
                                    child: Text(
                                      '\$${total.toStringAsFixed(2)}',
                                      textAlign: TextAlign.right,
                                      style: getTextStyle2(
                                        color: isDark
                                            ? AppColors.textWhite
                                            : AppColors.black,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        lineHeight: 22.sp,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: double.infinity,
                              height: 1.h,
                              color: isDark
                                  ? const Color(0xFF38383A)
                                  : const Color(0xFFEDEDF0),
                            ),
                            ...entries.asMap().entries.map((indexedEntry) {
                              final entry = indexedEntry.value;
                              final icon = entry.type.split(' ').first;
                              final title = entry.note;
                              return Column(
                                children: [
                                  if (indexedEntry.key > 0)
                                    Container(
                                      width: double.infinity,
                                      height: 1.h,
                                      color: isDark
                                          ? const Color(0xFF38383A)
                                          : const Color(0xFFEDEDF0),
                                    ),
                                  Dismissible(
                                    key: Key(entry.id),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      width: double.infinity,
                                      height: 52.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 12.h,
                                      ),
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFE21818),
                                      ),
                                      alignment: Alignment.centerRight,
                                      child: Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                        size: 24.sp,
                                      ),
                                    ),
                                    confirmDismiss: (direction) async {
                                      try {
                                        return await expenseController
                                            .deleteEntry(entry);
                                      } catch (e) {
                                        debugPrint('Error deleting entry: $e');
                                        return false;
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: 48.h,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16.w,
                                        vertical: 8.h,
                                      ),
                                      decoration: ShapeDecoration(
                                        color: isDark
                                            ? Color(0xFF262626)
                                            : AppColors.textWhite,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 1.w,
                                            color: isDark
                                                ? Color(0xFF38383A)
                                                : AppColors.textWhite,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 32.w,
                                            height: 32.h,
                                            child: Text(
                                              icon,
                                              style: getTextStyle2(
                                                color: const Color(0xFF828282),
                                                fontSize: 24.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 170.w,
                                            child: Text(
                                              title,
                                              style: getTextStyle2(
                                                color: isDark
                                                    ? AppColors.textWhite
                                                    : const Color(0xFF141414),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100.w,
                                            child: Text(
                                              '${entry.isIncome ? '+' : '-'} \$${entry.amount.toStringAsFixed(2)}',
                                              textAlign: TextAlign.right,
                                              style: getTextStyle2(
                                                color: entry.isIncome
                                                    ? const Color(0xFF00D460)
                                                    : const Color(0xFFEF5B00),
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
