import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:teddy_5618/core/common/styles/global_text_style.dart';
import 'package:teddy_5618/core/utils/constants/colors.dart';
import 'package:teddy_5618/features/group_screen/screen/group_trip_spent_screen.dart';
import 'package:teddy_5618/features/group_screen/controller/expenses_page_controller.dart';
import 'package:teddy_5618/features/group_screen/model/trip_model.dart';
import 'package:teddy_5618/features/group_screen/controller/expense_event_controller.dart';

class ExpensesPageScreen extends StatelessWidget {
  final Trip? trip; // Add trip parameter

  const ExpensesPageScreen({super.key, this.trip});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Initialize controller with trip ID
    final controllerTag = trip?.id ?? 'default';
    final controller = Get.put(
      ExpensesPageController(groupId: trip?.id),
      tag: controllerTag,
    );

    // Set up event listener for expense updates
    if (trip?.id != null) {
      try {
        final eventController = Get.put(ExpenseEventController());
        eventController.listenToExpenseUpdates(trip!.id!, () {
          debugPrint(
            "🔔 [EXPENSES_PAGE] Received expense update event, refreshing...",
          );
          controller.refreshExpenses();
        });
      } catch (e) {
        debugPrint("⚠️ [EXPENSES_PAGE] Could not set up event listener: $e");
      }
    }

    // Debug: Print trip information
    debugPrint("🔍 [EXPENSES_PAGE] Trip provided: ${trip?.id} - ${trip?.name}");
    debugPrint("🏷️ [EXPENSES_PAGE] Controller tag: $controllerTag");

    // If no trip is provided, show a message
    if (trip == null || trip!.id == null || trip!.id!.isEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? AppColors.backgroundDark
            : AppColors.backgroundLightGrey,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 64,
                color: isDark ? AppColors.textWhite : AppColors.backgroundDark,
              ),
              const SizedBox(height: 16),
              Text(
                'No trip selected',
                style: getTextStyle2(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textWhite
                      : AppColors.backgroundDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select a valid trip to view expenses',
                style: getTextStyle2(fontSize: 14, color: AppColors.textGrey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLightGrey,
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

            // Show empty state (still scrollable so pull-to-refresh works)
            if (controller.expenses.isEmpty) {
              return RefreshIndicator(
                onRefresh: controller.refreshExpenses,
                color: AppColors.green,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(
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
                                'No expenses found'.tr,
                                style: getTextStyle2(
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.textWhite
                                      : AppColors.black,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add your first expense to get started'.tr,
                                style: getTextStyle2(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }

            // Show expenses data
            return Column(
              children: [
                // Expenses list
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: controller.refreshExpenses,
                    color: AppColors.green,
                    child: ListView.builder(
                      itemCount: controller.expenses.length,
                      itemBuilder: (context, index) {
                        final dayData = controller.expenses[index];
                        return expensescard(
                          context,
                          dayData,
                          controller,
                          trip?.id,
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 50),
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
        onPressed: () async {
          // Pass the trip ID to the spent screen
          final groupId = trip?.id ?? controller.groupId.value;
          debugPrint(
            "🚀 [EXPENSES_FAB] Navigating to GroupTripSpentScreen with groupId: $groupId",
          );

          // Navigate and wait for result
          await Get.to(() => GroupTripSpentScreen(groupId: groupId));

          // Refresh expenses when returning from GroupTripSpentScreen
          debugPrint(
            "🔄 [EXPENSES_FAB] Returned from GroupTripSpentScreen, refreshing expenses...",
          );
          controller.refreshExpenses();
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

Widget expensescard(
  BuildContext context,
  Map<String, dynamic> dayData,
  ExpensesPageController controller,
  String? groupId,
) {
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
            color: isDark
                ? AppColors.backgroundDark
                : const Color.fromARGB(255, 200, 200, 200),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
        borderRadius: const BorderRadius.all(Radius.circular(16)),
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
              borderRadius: const BorderRadius.only(
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
                    color: isDark ? const Color(0xFFAAAAAA) : Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: _buildExpensesList(expenses, isDark, controller, groupId),
          ),
        ],
      ),
    ),
  );
}

// Helper function to build expenses list from API data
List<Widget> _buildExpensesList(
  List<dynamic> expenses,
  bool isDark,
  ExpensesPageController controller,
  String? groupId,
) {
  List<Widget> expenseWidgets = [];

  for (int i = 0; i < expenses.length; i++) {
    final expense = expenses[i] as Map<String, dynamic>;

    // Add expense item
    // Make each expense item tappable so the user can edit it
    expenseWidgets.add(
      Padding(
        padding: const EdgeInsets.only(left: 16, right: 12),
        child: GestureDetector(
          onTap: () async {
            // determine group id to pass
            final gid = (groupId != null && groupId.isNotEmpty)
                ? groupId
                : controller.groupId.value;

            debugPrint(
              '✏️ [EXPENSES_PAGE] Tapped expense, navigating to edit screen for group: $gid',
            );

            await Get.to(
              () => GroupTripSpentScreen(
                groupId: gid,
                transactionToEdit: expense,
              ),
            );

            // refresh after returning
            controller.refreshExpenses();
          },
          child: _buildExpenseItem(
            title: expense['title'] ?? 'Unknown',
            note: expense['notes'] ?? '',
            amount: expense['formattedAmount'] ?? 'US\$ 0.00',
            amountColor: isDark ? AppColors.textWhite : AppColors.black,
            statusText: expense['status'] ?? 'Unknown',
            statusColor: (expense['statusColor'] as Color?) ?? Colors.grey,
            isDark: isDark,
          ),
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
  String? note,
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
        // Title
        Expanded(
          child: Row(
            children: [
              Text(
                title,
                style: getTextStyle2(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textWhite : AppColors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(width: 10.w),
              if (note != null && note.isNotEmpty) ...[
                Flexible(
                  child: Text(
                    note,
                    style: getTextStyle2(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.textGrey : AppColors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
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
