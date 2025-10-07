import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';

import 'package:teddy_5618/features/group_screen/controller/group_search_controller.dart';

import 'package:teddy_5618/features/home_screen/widgets/texxtfield.dart';

// Responsive Helper Class
class ResponsiveHelper {
  final BuildContext context;
  final Size size;

  ResponsiveHelper(this.context) : size = MediaQuery.of(context).size;

  bool get isSmallPhone => size.width <= 360;
  bool get isMediumPhone => size.width > 362 && size.width < 414;
  bool get isLargePhone => size.width >= 414;

  double fromSmallMediumLarge({
    required double small,
    required double medium,
    required double large,
  }) {
    if (isSmallPhone) return small;
    if (isMediumPhone) return medium;
    return large;
  }
}

class GroupSearchScreen extends StatelessWidget {
  final String? groupId; // Add groupId parameter

  const GroupSearchScreen({super.key, this.groupId});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveHelper(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize search controller
    final searchController = Get.put(
      GroupSearchController(),
      tag: groupId ?? 'default',
    );

    // Set group ID for searching
    if (groupId != null) {
      searchController.setGroupId(groupId!);
    }

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

      body: Column(
        children: [
          SizedBox(
            height: responsive.fromSmallMediumLarge(
              small: 8,
              medium: 10,
              large: 16,
            ),
          ),
          TexxtField(
            controller: searchController.searchTextController,
            onClear: searchController.clearSearchText,
          ),
          SizedBox(
            height: responsive.fromSmallMediumLarge(
              small: 24,
              medium: 12,
              large: 40,
            ),
          ),
          Expanded(
            child: Obx(() {
              // Show search results or default message
              if (searchController.isSearching.value) {
                return Center(
                  child: CircularProgressIndicator(color: AppColors.green),
                );
              }

              if (searchController.searchQuery.value.isEmpty) {
                return SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1,
                    width: MediaQuery.of(context).size.width,
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLightGrey,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Start typing to search expenses',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              if (searchController.searchResults.isEmpty) {
                return SingleChildScrollView(
                  child: Container(
                    height: MediaQuery.of(context).size.height / 1,
                    width: MediaQuery.of(context).size.width,
                    color: isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLightGrey,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No expenses found',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // Show search results
              return SingleChildScrollView(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: isDark
                      ? AppColors.backgroundDark
                      : AppColors.backgroundLightGrey,
                  child: Column(
                    children: [
                      // SizedBox(height: 20),
                      ...searchController.groupedSearchResults.map((dayData) {
                        return expensescard(context, dayData);
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Expense card widget (same as expenses page)
Widget expensescard(BuildContext context, Map<String, dynamic> dayData) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final String date = dayData['date'] ?? 'Unknown Date';
  final List<dynamic> expenses = dayData['expenses'] ?? [];

  return Container(
    padding: const EdgeInsets.only(left: 24.0, right: 24, top: 24, bottom: 5),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
    child: Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical:12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Text(
              date,
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFFAAAAAA),
              ),
            ),
          ),

          Column(children: _buildExpensesList(expenses, isDark)),
        ],
      ),
    ),
  );
}

// Helper function to build expenses list from API data
List<Widget> _buildExpensesList(List<dynamic> expenses, bool isDark) {
  List<Widget> expenseWidgets = [];

  for (int i = 0; i < expenses.length; i++) {
    final expense = expenses[i] as Map<String, dynamic>;

    // Add expense item
    expenseWidgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: _buildExpenseItem(
          title: expense['title'] ?? 'Unknown',
          amount: expense['formattedAmount'] ?? 'US\$ 0.00',
          amountColor: isDark ? AppColors.textWhite : AppColors.black,
          statusText: expense['status'] ?? 'Unknown',
          statusColor: (expense['statusColor'] as Color?) ?? Colors.grey,
          isDark: isDark,
        ),
      ),
    );

    // Add divider (except for the last item)
    if (i < expenses.length - 1) {
      expenseWidgets.add(
        Divider(
          height: 1.5,
          thickness: 1,
          color: isDark ? AppColors.deepGrey : AppColors.borderGrey,
          indent: 0,
          endIndent: 0,
        ),
      );
    }
  }

  return expenseWidgets;
}

Widget _buildExpenseItem({
  required String title,
  required String amount,
  required Color amountColor,
  required String statusText,
  required Color statusColor,
  required bool isDark,
}) {
  return SizedBox(
    height: 48,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Title
        Expanded(
          child: Text(
            title,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Amount and status (centered vertically)
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusText,
              style: getTextStyle2(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: statusColor,
              ),
            ),
            Text(
              amount,
              style: getTextStyle2(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: amountColor,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
