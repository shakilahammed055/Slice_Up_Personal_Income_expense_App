// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:teddy_5618/core/Urls/endpoint.dart';
import 'package:teddy_5618/features/auth/auth_service/auth_service.dart';
import 'package:uuid/uuid.dart'; // Add uuid package for unique IDs
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ExpenseType {
  final String id;
  final String name;

  ExpenseType({required this.id, required this.name});
}

class ExpenseEntry {
  final String id; // Added unique ID
  final double amount;
  final String
  date; // Format: 'dd/MM/yyyy' or repeat option like 'Every Friday'
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
  var selectedType = Rxn<ExpenseType>();
  var selectedDate = DateTime.now().obs;
  final amountController = TextEditingController();
  final noteController = TextEditingController();
  final dateController = TextEditingController();
  final expenseTypes = <ExpenseType>[].obs;
  final incomeTypes = <ExpenseType>[].obs;
  final entries = <ExpenseEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    amountController.addListener(() {
      amount.value = amountController.text;
    });
    updateDateText(selectedDate.value);
    fetchExpenseTypes();
    fetchIncomeTypes();
  }

  Future<void> fetchExpenseTypes() async {
  try {
    final token = await AuthService.getApprovalToken();
    final response = await http.get(
      Uri.parse(
        "https://teddybackend-mivk.onrender.com/api/v1/users/categories",
      ),
      headers: {'Authorization': token ?? ''},
    );
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      if (jsonData['success'] == true) {
        final dataList = jsonData['data'] as List;
        final filteredDataList = dataList.where((item) => item['type'] == 'personal').toList();
        expenseTypes.value = filteredDataList
            .map(
              (item) => ExpenseType(
                id: item['_id'] as String,
                name: item['name'] as String,
              ),
            )
            .toList();
      }
    }
  } catch (e) {
    // Handle error silently or show snackbar if needed
    debugPrint('Error fetching expense types: $e');
  }
}

  Future<void> fetchIncomeTypes() async {
  debugPrint('Entering fetchIncomeTypes function');
  try {
    debugPrint('Calling AuthService.getApprovalToken()');
    final token = await AuthService.getApprovalToken();
    debugPrint('Token retrieved: $token');
    debugPrint('Constructing Uri.parse with Urls.getallcategory');
    debugPrint('Urls.getallcategory value: ${Urls.getallcategory}');
    final uri = Uri.parse("https://teddybackend-mivk.onrender.com/api/v1/users/categories");
    debugPrint('URI parsed: $uri');
    debugPrint('Preparing headers: {"Authorization": "${token ?? ""}"}');
    final headers = {'Authorization': token ?? ''};
    debugPrint('Calling http.get with URI: $uri and headers: $headers');
    final response = await http.get(uri, headers: headers);
    debugPrint('HTTP response received - statusCode: ${response.statusCode}');
    debugPrint('HTTP response body: ${response.body}');
    debugPrint('Checking if response.statusCode == 200');
    if (response.statusCode == 200) {
      debugPrint('Status is 200, proceeding to jsonDecode');
      final jsonData = jsonDecode(response.body);
      debugPrint('JSON decoded: $jsonData');
      debugPrint('Checking jsonData["success"] == true');
      if (jsonData['success'] == true) {
        debugPrint('Status is success, casting jsonData["data"] to List');
        final dataList = jsonData['data'] as List;
        debugPrint('Data list casted: $dataList');
        debugPrint('Filtering dataList for type "personal"');
        final filteredDataList = dataList.where((item) => item['type'] == 'personal').toList();
        debugPrint('Filtered data list: $filteredDataList');
        debugPrint('Mapping filteredDataList to ExpenseType objects');
        final mappedList = filteredDataList
            .map(
              (item) {
                debugPrint('Processing item: $item');
                debugPrint('Extracting item["_id"] as String: ${item['_id']}');
                final id = item['_id'] as String;
                debugPrint('Extracting item["name"] as String: ${item['name']}');
                final name = item['name'] as String;
                debugPrint('Creating ExpenseType(id: $id, name: $name)');
                return ExpenseType(
                  id: id,
                  name: name,
                );
              },
            )
            .toList();
        debugPrint('Mapped list: $mappedList');
        debugPrint('Assigning to incomeTypes.value');
        incomeTypes.value = mappedList;
        debugPrint('incomeTypes.value updated successfully');
      } else {
        debugPrint('jsonData["success"] is not true: ${jsonData['success']}');
      }
    } else {
      debugPrint('response.statusCode is not 200: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint('Exception caught in fetchIncomeTypes: $e');
    // Handle error silently or show snackbar if needed
    debugPrint('Error fetching income types: $e');
  }
  debugPrint('Exiting fetchIncomeTypes function');
}

  Future<bool> createCategory(bool isIncome, String categoryName) async {
    debugPrint(
      'createCategory called with isIncome: $isIncome, categoryName: $categoryName',
    );
    if (categoryName.isEmpty) {
      debugPrint('categoryName is empty, showing error');
      EasyLoading.showError('Category name cannot be empty.');
      debugPrint('Returning false due to empty categoryName');
      return false;
    }

    debugPrint('categoryName is not empty, proceeding to try block');
    try {
      debugPrint('Fetching token...');
      final token = await AuthService.getApprovalToken();
      debugPrint('Token fetched: ${token ?? 'null'}');
      final url = isIncome
          ? 'https://teddybackend-mivk.onrender.com/api/v1/incomeAndExpences/createIncomeType'
          : 'https://teddybackend-mivk.onrender.com/api/v1/incomeAndExpences/createExpensesType';
      debugPrint('Selected URL: $url');

      debugPrint('Creating MultipartRequest...');
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers['Authorization'] = token ?? '';
      request.fields['data'] = jsonEncode({'name': categoryName});
      debugPrint('Request fields set: ${request.fields}');

      debugPrint('Sending HTTP POST request with form-data...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('HTTP response status code: ${response.statusCode}');
      debugPrint('HTTP response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Status code is 200 or 201, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['status'] == 'success') {
          debugPrint('API status is success, adding to local list');
          // Add to local list if successful
          final newType = ExpenseType(
            id: jsonData['data']['_id'] as String,
            name: categoryName,
          );
          if (isIncome) {
            debugPrint('Adding to incomeTypes...');
            if (!incomeTypes.any((t) => t.name == categoryName)) {
              incomeTypes.add(newType);
              debugPrint('Added $categoryName to incomeTypes');
            } else {
              debugPrint('$categoryName already exists in incomeTypes');
            }
          } else {
            debugPrint('Adding to expenseTypes...');
            if (!expenseTypes.any((t) => t.name == categoryName)) {
              expenseTypes.add(newType);
              debugPrint('Added $categoryName to expenseTypes');
            } else {
              debugPrint('$categoryName already exists in expenseTypes');
            }
          }
          debugPrint('Returning true');
          return true;
        } else {
          debugPrint('API status is not success: ${jsonData['status']}');
          final errorMsg = jsonData['message'] ?? 'Failed to create category.';
          debugPrint('Showing error: $errorMsg');
          EasyLoading.showError(errorMsg);
          debugPrint('Returning false due to API error');
          return false;
        }
      } else {
        debugPrint('Status code not 200 or 201: ${response.statusCode}');
        debugPrint('Showing generic error');
        EasyLoading.showError('Failed to create category. Please try again.');
        debugPrint('Returning false due to HTTP error');
        return false;
      }
    } catch (e) {
      debugPrint('Exception caught: $e');
      debugPrint('Error creating category: $e');
      debugPrint('Showing network error');
      EasyLoading.showError('Network error. Please check your connection.');
      debugPrint('Returning false due to exception');
      return false;
    }
  }

  void switchTab(String tab) {
    selectedTab.value = tab;
    clearForm();
  }

  void setType(ExpenseType type) {
    selectedType.value = type;
  }

  void addCategory(String category, bool isIncome) {
    final newType = ExpenseType(
      id: Uuid().v4(),
      name: category,
    ); // Local ID for now
    if (category.isNotEmpty &&
        !(isIncome ? incomeTypes : expenseTypes).any(
          (t) => t.name == category,
        )) {
      (isIncome ? incomeTypes : expenseTypes).add(newType);
    }
  }

  void editCategory(String oldCategory, String newCategory, bool isIncome) {
    final types = isIncome ? incomeTypes : expenseTypes;
    final index = types.indexWhere((t) => t.name == oldCategory);
    if (index != -1 &&
        newCategory.isNotEmpty &&
        !types.any((t) => t.name == newCategory)) {
      types[index] = ExpenseType(id: types[index].id, name: newCategory);
      if (selectedType.value != null &&
          selectedType.value!.name == oldCategory) {
        selectedType.value = types[index];
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
    types.removeWhere((t) => t.name == category);
    if (selectedType.value != null && selectedType.value!.name == category) {
      selectedType.value = null;
    }
    entries.removeWhere(
      (entry) => entry.type == category && entry.isIncome == isIncome,
    );
  }

  void updateDateText(DateTime date) {
    dateController.text = DateFormat('dd/MM/yyyy').format(date);
    selectedDate.value = date;
  }

  Future<void> _saveToBackend({
    required double amount,
    required String dateStr,
    required String note,
  }) async {
    debugPrint(
      'Entering _saveToBackend with amount: $amount, dateStr: $dateStr, note: $note',
    );
    try {
      debugPrint('Fetching token...');
      final token = await AuthService.getApprovalToken();
      debugPrint('Token fetched: ${token ?? 'null'}');
      final isIncome = selectedTab.value == 'Income'.tr;
      debugPrint('isIncome: $isIncome');
      final transactionType = isIncome ? 'income' : 'expense';
      debugPrint('transactionType: $transactionType');

      // Parse and format date (assumes one-time date format; repeat options will fail parsing)
      debugPrint('Parsing date: $dateStr');
      DateTime parsedDate;
      try {
        parsedDate = DateFormat('dd/MM/yyyy').parse(dateStr);
        debugPrint('Parsed date: $parsedDate');
      } catch (e) {
        debugPrint('Date parsing error: $e');
        throw Exception('Invalid date format. Please select a one-time date.');
      }
      final apiDate = DateFormat('yyyy-MM-dd').format(parsedDate);
      debugPrint('Formatted API date: $apiDate');

      final typeId = selectedType.value!.id;
      debugPrint('typeId: $typeId');
      final description = note.isEmpty ? selectedType.value!.name : note;
      debugPrint('description: $description');

      final body = {
        "transactionType": transactionType,
        "date": apiDate,
        "amount": amount,
        "description": description,
        "type_id": typeId,
        // "type_id": "68ddf75611a3de7d7203e6c7",
      };
      debugPrint('Request body: ${jsonEncode(body)}');

      debugPrint(
        'Sending POST request to: https://teddybackend-mivk.onrender.com/api/v1/incomeAndExpences/addIncomeOrExpenses',
      );
      final response = await http.post(
        Uri.parse(
          'https://teddybackend-mivk.onrender.com/api/v1/incomeAndExpences/addIncomeOrExpenses',
        ),
        headers: {
          'Authorization': token ?? '',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );
      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint('Response code is 200 or 201, parsing JSON...');
        final jsonData = jsonDecode(response.body);
        debugPrint('Parsed JSON: $jsonData');
        if (jsonData['status'] == 'success') {
          debugPrint('API status is success, adding to local entries');
          // Add to local entries on success
          entries.add(
            ExpenseEntry(
              amount: amount,
              date: dateStr,
              type: selectedType.value!.name,
              note: description,
              isIncome: isIncome,
            ),
          );
          debugPrint('Entry added to local list');
          return;
        } else {
          debugPrint('API status is not success: ${jsonData['status']}');
          throw Exception(jsonData['message'] ?? 'Failed to save entry');
        }
      } else {
        debugPrint('Status code not 200 or 201: ${response.statusCode}');
        throw Exception('Failed to save entry: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Exception in _saveToBackend: $e');
      throw Exception('Error saving entry: $e');
    }
  }

  Future<void> saveEntry({
    required double amount,
    required String date,
    required String note,
  }) async {
    if (selectedType.value == null) {
      EasyLoading.showError('Please select a category.');
      return;
    }
    if (amount <= 0) {
      EasyLoading.showError('Amount must be greater than zero.');
      return;
    }
    try {
      await _saveToBackend(amount: amount, dateStr: date, note: note);
      EasyLoading.showSuccess('${selectedTab.value} saved successfully');
      clearForm();
    } catch (e) {
      EasyLoading.showError(e.toString());
    }
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

    EasyLoading.showSuccess('Entry Deleted');

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
      groupedEntries.entries.toList()..sort((a, b) {
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
    selectedType.value = null;
    amount.value = '';
    selectedDate.value = DateTime.now();
    updateDateText(DateTime.now());
  }
}
