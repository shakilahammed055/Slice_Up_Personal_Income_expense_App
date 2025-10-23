import 'package:get/get.dart';
import 'package:flutter/material.dart';

/// Global controller to handle expense-related events across the app
class ExpenseEventController extends GetxController {
  // Observable for expense updates per group
  final RxMap<String, int> expenseUpdateTrigger = <String, int>{}.obs;

  /// Notify that expenses have been updated for a specific group
  void notifyExpenseUpdated(String groupId) {
    final currentCount = expenseUpdateTrigger[groupId] ?? 0;
    expenseUpdateTrigger[groupId] = currentCount + 1;

    debugPrint(
      "📢 [EXPENSE_EVENT] Notified expense update for group: $groupId",
    );
  }

  /// Get observable for a specific group's expense updates
  RxInt getExpenseUpdateObservable(String groupId) {
    if (!expenseUpdateTrigger.containsKey(groupId)) {
      expenseUpdateTrigger[groupId] = 0;
    }
    return (expenseUpdateTrigger[groupId] ?? 0).obs;
  }

  /// Listen to expense updates for a specific group
  void listenToExpenseUpdates(String groupId, Function() callback) {
    ever(expenseUpdateTrigger, (Map<String, int> triggers) {
      if (triggers.containsKey(groupId)) {
        debugPrint(
          "🔔 [EXPENSE_EVENT] Expense update detected for group: $groupId",
        );
        callback();
      }
    });
  }

  /// Clear all update triggers (useful for testing or reset)
  void clearAll() {
    expenseUpdateTrigger.clear();
    debugPrint("🧹 [EXPENSE_EVENT] Cleared all expense update triggers");
  }

  /// Notify that an entire group was deleted. Consumers can react to this by
  /// checking group IDs and cleaning up related controllers/UI.
  void notifyGroupDeleted(String groupId) {
    // Use the same map to signal with a special negative value (or simply log)
    expenseUpdateTrigger[groupId] = (expenseUpdateTrigger[groupId] ?? 0) - 1;
    debugPrint('📢 [EXPENSE_EVENT] Notified group deleted: $groupId');
  }
}
