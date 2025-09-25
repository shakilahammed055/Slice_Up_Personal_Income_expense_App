import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_spent_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';

class ExpensesPageScreen extends StatelessWidget {
  const ExpensesPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ExpensesPageController controller = Get.put(ExpensesPageController());

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLightGrey,
      //  AppColors.backgroundLightGrey,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Obx(() {
            // Show loading indicator
            if (controller.isLoading.value && controller.expenses.isEmpty) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.green),
              );
            }

            // Show error message
            if (controller.error.value.isNotEmpty &&
                controller.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      controller.error.value,
                      style: getTextStyle2(
                        fontSize: 16,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => controller.refreshExpenses(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.green,
                      ),
                      child: Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            // Show empty state
            if (controller.expenses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No expenses found',
                      style: getTextStyle2(
                        fontSize: 16,
                        color: isDark ? AppColors.textWhite : AppColors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Add your first expense to get started',
                      style: getTextStyle2(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Show expenses data
            return RefreshIndicator(
              onRefresh: controller.refreshExpenses,
              color: AppColors.green,
              child: ListView.builder(
                itemCount: controller.expenses.length,
                itemBuilder: (context, index) {
                  final dayData = controller.expenses[index];
                  return expensescard(context, dayData);
                },
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        onPressed: () {
          Get.to(GroupTripSpentScreen());
        },
        child: Icon(
          Icons.add,
          color: isDark ? AppColors.textWhite : AppColors.backgroundDark,
          size: 32,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Widget expensescard(BuildContext context, Map<String, dynamic> dayData) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final String date = dayData['date'] ?? 'Unknown Date';
  final List<dynamic> expenses = dayData['expenses'] ?? [];

  return Container(
    // margin: const EdgeInsets.all(16.0),
    padding: const EdgeInsets.only(left: 24.0, right: 24, top: 24, bottom: 5),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.0)),
    child: Container(
      decoration: BoxDecoration(
        color: isDark ? Color(0xFF262626) : AppColors.textWhite,
        //  Colors.white,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.backgroundDark
                : const Color.fromARGB(255, 200, 200, 200),
            offset: Offset(0, 2),
            blurRadius: 5,
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
            alignment: Alignment.topLeft,
            height: 45,

            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              color: isDark ? AppColors.deepGrey : AppColors.lightGreyContainer,
            ),

            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  date,
                  style: TextStyle(
                    fontSize: 14,
                    // color: Colors.grey[600],
                    color: isDark ? Color(0xFFAAAAAA) : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
        padding: const EdgeInsets.only(left: 8, right: 12),
        child: _buildExpenseItem(
          icon: expense['categoryIcon'] ?? '💰',
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
  required String icon,
  required String title,
  required String amount,
  required Color amountColor,
  required String statusText,
  required Color statusColor,
  required bool isDark,
}) {
  return SizedBox(
    height: 48, // keep row height fixed
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Icon
        SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 20)),
          ),
        ),

        const SizedBox(width: 12),

        // Title
        Expanded(
          child: Text(
            title,
            style: getTextStyle2(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textWhite : AppColors.black,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),

        // Amount and status (centered vertically)
        Column(
          mainAxisAlignment: MainAxisAlignment.center, // 👈 fix here
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              statusText,
              style: getTextStyle2(
                fontSize: 10,
                color: statusColor,
                fontWeight: FontWeight.w500,
                lineHeight: 12,
              ),
            ),
            Text(
              amount,
              style: getTextStyle2(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: amountColor,
                lineHeight: 18,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
