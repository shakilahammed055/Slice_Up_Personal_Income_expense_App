import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart'; // Add uuid package for unique IDs

class ExpenseEntry {
  final String id; // Added unique ID
  final double amount;
  final String date; // Format: 'dd/MM/yyyy' or repeat option like 'Every Friday'
  final String type;
  final String note;
  final bool isIncome;

  ExpenseEntry({
    String? id, // Allow passing an ID, or generate a new one
    required this.amount,
    required this.date,
    required this.type,
    required this.note,
    required this.isIncome,
  }) : id = id ?? Uuid().v4(); // Generate unique ID if not provided

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpenseEntry &&
          runtimeType == other.runtimeType &&
          id == other.id && // Compare by ID for uniqueness
          amount == other.amount &&
          date == other.date &&
          type == other.type &&
          note == other.note &&
          isIncome == other.isIncome;

  @override
  int get hashCode =>
      id.hashCode ^ // Use ID in hashCode
      amount.hashCode ^
      date.hashCode ^
      type.hashCode ^
      note.hashCode ^
      isIncome.hashCode;
}

class ExpenseController extends GetxController {
  var selectedTab = 'Expense'.obs;
  var amount = ''.obs;
  var selectedType = ''.obs;
  var selectedDate = DateTime.now().obs;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();
  final expenseTypes = [
    '🚗 Transport',
    '🍽️ Food',
    '🏠 Housing',
    '🛍️ Shopping',
    '🎉 Entertainment',
    '👕 Fashion',
    '💊 Clinic',
    '💄 Beauty',
  ].obs;
  final incomeTypes = [
    '💰 Salary',
    '🎁 Bonus',
    '📈 Investment',
    '🎉 Other',
  ].obs;
  final entries = <ExpenseEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(() {
      amount.value = amountController.text;
    });
    updateDateText(selectedDate.value);
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    clearForm();
  }

  void setType(String type) {
    selectedType.value = type;
  }

  void addCategory(String category, bool isIncome) {
    if (category.isNotEmpty &&
        !(isIncome ? incomeTypes : expenseTypes).contains(category)) {
      (isIncome ? incomeTypes : expenseTypes).add(category);
    }
  }

  void editCategory(String oldCategory, String newCategory, bool isIncome) {
    final types = isIncome ? incomeTypes : expenseTypes;
    final index = types.indexOf(oldCategory);
    if (index != -1 && newCategory.isNotEmpty && !types.contains(newCategory)) {
      types[index] = newCategory;
      if (selectedType.value == oldCategory) {
        selectedType.value = newCategory;
      }
      // Update existing entries with the new category name
      for (var i = 0; i < entries.length; i++) {
        if (entries[i].type == oldCategory && entries[i].isIncome == isIncome) {
          entries[i] = ExpenseEntry(
            id: entries[i].id, // Preserve the ID
            amount: entries[i].amount,
            date: entries[i].date,
            type: newCategory,
            note: entries[i].note,
            isIncome: entries[i].isIncome,
          );
        }
      }
      entries.refresh();
    }
  }

  void deleteCategory(String category, bool isIncome) {
    final types = isIncome ? incomeTypes : expenseTypes;
    types.remove(category);
    if (selectedType.value == category) {
      selectedType.value = '';
    }
    entries.removeWhere(
      (entry) => entry.type == category && entry.isIncome == isIncome,
    );
  }

  void updateDateText(DateTime date) {
    dateController.text = DateFormat('dd/MM/yyyy').format(date);
    selectedDate.value = date;
  }

  void saveEntry({
    required double amount,
    required String date,
    required String note,
  }) {
    if (selectedType.value.isEmpty) {
      Get.snackbar('Error', 'Please select a category.');
      return;
    }
    if (amount <= 0) {
      Get.snackbar('Error', 'Amount must be greater than zero.');
      return;
    }
    entries.add(
      ExpenseEntry(
        amount: amount,
        date: date,
        type: selectedType.value,
        note: note.isEmpty ? selectedType.value : note,
        isIncome: selectedTab.value == 'Income',
      ),
    );
    Get.back();
    debugPrint(
      'Saving: Amount=$amount, Date=$date, Type=${selectedType.value}, Note=$note, IsIncome=${selectedTab.value == 'Income'}',
    );
  }

  Future<bool> deleteEntry(ExpenseEntry entry) async {
    // Show confirmation dialog
    bool? confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text('Delete Entry'),
        content: Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return false;

    // Store the entry for potential undo
    final deletedEntry = entry;
    final deletedIndex = entries.indexOf(entry);

    // Remove the entry
    entries.remove(entry);
    entries.refresh(); // Notify listeners

    // Show snackbar with undo option
    Get.snackbar(
      'Entry Deleted',
      'The entry has been deleted.',
      snackPosition: SnackPosition.BOTTOM,
      duration: Duration(seconds: 3),
      mainButton: TextButton(
        onPressed: () {
          // Undo deletion
          entries.insert(deletedIndex, deletedEntry);
          entries.refresh();
        },
        child: Text('Undo'),
      ),
    );

    debugPrint('Deleted entry: $entry, Remaining entries: ${entries.length}');
    return true;
  }

  Map<String, List<ExpenseEntry>> getEntriesByDate() {
    final Map<String, List<ExpenseEntry>> groupedEntries = {};
    for (var entry in entries) {
      if (!groupedEntries.containsKey(entry.date)) {
        groupedEntries[entry.date] = [];
      }
      groupedEntries[entry.date]!.add(entry);
    }
    // Sort entries by date for consistent display
    final sortedEntries = Map.fromEntries(
      groupedEntries.entries.toList()
        ..sort((a, b) {
          try {
            final dateA = DateFormat('dd/MM/yyyy').parse(a.key);
            final dateB = DateFormat('dd/MM/yyyy').parse(b.key);
            return dateB.compareTo(dateA); // Newest first
          } catch (e) {
            return a.key.compareTo(b.key); // Fallback to string comparison
          }
        }),
    );
    return sortedEntries;
  }

  double getTotalAmountForDate(String date) {
    return entries
        .where((entry) => entry.date == date)
        .fold(
          0.0,
          (sum, entry) => sum + (entry.isIncome ? entry.amount : -entry.amount),
        );
  }

  void clearForm() {
    amountController.clear();
    noteController.clear();
    selectedType.value = '';
    amount.value = '';
    selectedDate.value = DateTime.now();
    updateDateText(DateTime.now());
  }
}